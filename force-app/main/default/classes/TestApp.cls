/**
 * @name TestApp
 * @description this tests the application as a whole as a 'User'
 * TODO: Write unit tests
 */
@isTest(SeeAllData = true)
public class TestApp {
    
    @IsTest
    static void testEmail(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromAddress = 'test@from.com';
        email.ToAddresses  = new String[]{'test@to.com'};
        email.subject = 'Subject';
        email.HtmlBody = 'Body';
        email.messageId = 'messageId';

        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = Blob.valueOf('Attachment');
        attachment.filename = 'attachment.txt';
        
        email.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[]{attachment};

        ConnectTeamInboundEmailHandler emailHandler = new ConnectTeamInboundEmailHandler();
        emailHandler.handleInboundEmail( email, null );

        Case[] cases = [SELECT 
                            Id 
                                FROM Case
                                WHERE SuppliedEmail = :email.fromAddress];

        Case newCase = cases[0];

        System.assertEquals( 1, cases.size() );

        // Test Front End Services Get Data
        String JSONmessages = UiComponentServices.getData( newCase.Id );

        UiComponentServices.FeedData feedData = (UiComponentServices.FeedData) JSON.deserialize( JSONmessages, UiComponentServices.FeedData.class );

        System.assertEquals( 1, feedData.messages.size() );
        System.assertEquals( 1, feedData.attachmentsByMessageId.get( feedData.messages[0].Id ).size() );

        // Test Front End Services Get Reply for new Message
        String JSONnewMessage = UiComponentServices.getReply( JSON.serialize( feedData.messages[0]) );

        EmailInfo newMessage = (EmailInfo) JSON.deserialize( JSONnewMessage, EmailInfo.class );
        
        System.assertEquals( newCase.Id, newMessage.whatId );
        System.assertEquals( email.messageId, newMessage.inReplyTo );

        newMessage.ToAddresses.add(email.fromAddress);
        newMessage.content.HtmlBody = 'reply here';
        
        // only reseting this cause test fails sending email because inReplyTo will not be a vaild external message Id
        newMessage.inReplyTo = null; 

        UiComponentServices.NewMessageAttachmentData newMessageAttachment = new UiComponentServices.NewMessageAttachmentData();
        newMessageAttachment.Title = 'attachment.txt';
        newMessageAttachment.base64 = EncodingUtil.base64Encode( Blob.valueOf('Attachment') );
        newMessageAttachment.FileExtension = 'txt';

        UiComponentServices.NewMessageData newMessageData = new UiComponentServices.NewMessageData();
        newMessageData.message = newMessage;
        newMessageData.attachments = new UiComponentServices.NewMessageAttachmentData[]{newMessageAttachment};

        // Test send new Message
        String JSONmessages2 = UiComponentServices.sendEmailMessage( JSON.serialize( newMessageData ) );

        UiComponentServices.FeedData feedData2 = (UiComponentServices.FeedData) JSON.deserialize( JSONmessages2, UiComponentServices.FeedData.class );

        System.assertEquals( 2, feedData2.messages.size() );

        //update the case to close
        newCase.Status = 'Closed';
        update newCase;

        String JSONmessages3 = UiComponentServices.getData( newCase.Id );

        UiComponentServices.FeedData feedData3 = (UiComponentServices.FeedData) JSON.deserialize( JSONmessages3, UiComponentServices.FeedData.class );

        System.assertEquals( 3, feedData3.messages.size() );
    }
}
