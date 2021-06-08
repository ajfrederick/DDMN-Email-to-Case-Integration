/**
 * @name TestApp
 * @description this tests the application as a whole as a 'User'
 * TODO: Write unit tests
 */
@IsTest(SeeAllData = true)
public class TestApp {

   
    
    @IsTest
    static void testEmail(){

/**
 * MAKE DATA
 */

        // Create contact for Recipient list
        Contact contact = new Contact(
            FirstName = 'New',
            LastName = 'Contact',
            Email = 'test@from.com'
        );

        insert contact;

/**
 * SEND AND RECIEVE EMAIL
 */

        // Create new inbound email
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromAddress = 'test@from.com';
        email.ToAddresses  = new String[]{'test@to.com'};
        email.subject = 'Subject';
        email.HtmlBody = 'Body';
        email.messageId = 'messageId';

        // Create an attachment for the email
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = Blob.valueOf('Attachment');
        attachment.filename = 'attachment.txt';

        // Set the attachement on the email
        email.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[]{attachment};

        // Use the Apex Email Services InboundEmailHandler to recieve the email
        ConnectTeamInboundEmailHandler emailHandler = new ConnectTeamInboundEmailHandler();
        emailHandler.handleInboundEmail( email, null );

        // There will now be a case assuming all goes right
        Case[] cases = [SELECT 
                            Id,
                            SuppliedEmail,
                            ContactId
                                FROM Case
                                WHERE SuppliedEmail = :email.fromAddress];

        Case newCase = cases[0];

        System.assertEquals( 1, cases.size() );
        System.assertEquals( contact.Id, newCase.ContactId );
        System.assertEquals( contact.Email, newCase.SuppliedEmail );

/**
 * TEST GET FEED
 */

        // Test Front End Services Get Data
        String JSONmessages = UiComponentServices.getData( newCase.Id );

        UiComponentServices.FeedData feedData = (UiComponentServices.FeedData) JSON.deserialize( JSONmessages, UiComponentServices.FeedData.class );

        System.assertEquals( 1, feedData.messages.size() );
        System.assertEquals( 1, feedData.attachmentsByMessageId.get( feedData.messages[0].Id ).size() );

/**
 * TEST REPLY TO
 */

        // Get Reply for new Message by 'Replying' to the first message in the feed data
        String replyToMessageJSON = JSON.serialize( feedData.messages[0] );

        String JSONnewMessage = UiComponentServices.getReply( replyToMessageJSON );

        EmailInfo newMessage = (EmailInfo) JSON.deserialize( JSONnewMessage, EmailInfo.class );
        
        System.assertEquals( newCase.Id, newMessage.whatId );
        System.assertEquals( email.messageId, newMessage.inReplyTo );

        newMessage.ToAddresses.add(email.fromAddress);
        newMessage.content.HtmlBody = 'reply here';
        
        // only reseting this cause test fails sending email because inReplyTo will not be a vaild external message Id
        newMessage.inReplyTo = null;

        // Search Recipients
        SObject[] contacts = UiComponentServices.searchRecipients('test@from.com', new String[]{});

        System.assertEquals( 1, contacts.size() );

        // Create ReplyToMessage object for newMessageData
        UiComponentServices.ReplyToMessage replyToMessage = (UiComponentServices.ReplyToMessage) JSON.deserialize( replyToMessageJSON, UiComponentServices.ReplyToMessage.class );
        
        // Create NewMessageAttachmentData object for newMessageData
        UiComponentServices.NewMessageAttachmentData newMessageAttachment = new UiComponentServices.NewMessageAttachmentData();
        newMessageAttachment.Title = 'attachment.txt';
        newMessageAttachment.base64 = EncodingUtil.base64Encode( Blob.valueOf('Attachment') );
        newMessageAttachment.FileExtension = 'txt';

        // Create NewMessageData object for sendEmailMessage method
        UiComponentServices.NewMessageData newMessageData = new UiComponentServices.NewMessageData();
        newMessageData.message = newMessage;
        newMessageData.attachments = new UiComponentServices.NewMessageAttachmentData[]{newMessageAttachment};
        newMessageData.replyToMessage = replyToMessage;

        // Test send new Message
        String JSONmessages2 = UiComponentServices.sendEmailMessage( JSON.serialize( newMessageData ) );

        UiComponentServices.FeedData feedData2 = (UiComponentServices.FeedData) JSON.deserialize( JSONmessages2, UiComponentServices.FeedData.class );

        System.assertEquals( 2, feedData2.messages.size() );

/**
 * TEST CLOSE CASE
 */

        //update the case to close
        newCase.Status = 'Closed';
        update newCase;

        String JSONmessages3 = UiComponentServices.getData( newCase.Id );

        UiComponentServices.FeedData feedData3 = (UiComponentServices.FeedData) JSON.deserialize( JSONmessages3, UiComponentServices.FeedData.class );

        System.assertEquals( 3, feedData3.messages.size() );
    }
}
