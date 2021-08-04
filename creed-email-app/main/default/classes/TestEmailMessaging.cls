/**
 * @name TestEmailMessaging
 * @description this tests the application as a whole as a 'User'
 * TODO: Write unit tests
 */
@IsTest(SeeAllData = true)
public class TestEmailMessaging {

   
    
    @IsTest
    static void testOutboundEmail(){
        Case c = new Case();

        insert c;

        EmailInfo wrapper = new EmailInfo();

        wrapper.whatId = c.Id;
        wrapper.ToAddresses = new String[]{'me@test.com'};
        wrapper.FromAddress = 'you@test.com';
        wrapper.setContent( 'Subject', 'HTMLBody', 'PlainTextBody' );
        wrapper.setAttachement( Blob.valueOf('Attachment'), 'Attachment.txt' );

        EmailInfo[] wrappers = new EmailInfo[]{wrapper};

        // insert our attachments since we have before we set messages so SingleEmailMessage can access the ContentVersionIds
        AttachmentCreatorOutbound attachmentCreator = new AttachmentCreatorOutbound( wrappers );
        attachmentCreator.insertAttachments();

        // instatiate a message creator, set option, set contentversionids for attatchments and 
        // set messages which unpacks wrapper info into Messaging.SingleEmailMessage
        MessageCreatorOutbound messageCreator = new MessageCreatorOutbound( wrappers );
        messageCreator.setContentVersionIds( attachmentCreator.getContentVersionIds() );
        messageCreator.setMessages();

        // since the EmailMessage gets created asyncronously after sending the SingleMessage
        // let's store the object in a static variable to access when the EmailMessage trigger gets
        // fired on insert. There we will do the work of creating the necessary ContentDocumentLinks
        // to link the attachment to the EmailMessage. There this variable will get set to null afterward.
        EmailMessageHelper.attachmentCreatorForTrigger = attachmentCreator;

        
        Integer numberOfEmailsSent = 0;

        Test.startTest();

            // send the emails
            MessageHandler handler = new MessageHandler();
            handler.handle( messageCreator );

            numberOfEmailsSent = Limits.getEmailInvocations();
            
        Test.stopTest();

        System.assertEquals( 1, numberOfEmailsSent );
    }

    @IsTest
    static void testInboundEmail(){
        Case c = new Case();

        insert c;
        
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


        EmailExtractor extractor = new EmailExtractor();
        extractor.relatedToId = c.Id;
        extractor.setWrappers( new Messaging.InboundEmail[]{ email } );

        // instatiate a message creator then set messages
        MessageCreatorInbound messageCreator = new MessageCreatorInbound( extractor.getWrappers() );
        messageCreator.setMessages();

        // recieve the emails
        MessageHandler handler = new MessageHandler();
        handler.handle( messageCreator );

        // insert our attachments since we have EmailMessage
        AttachmentCreatorInbound attachmentCreator = new AttachmentCreatorInbound(  extractor.getWrappers() );
        attachmentCreator.insertAttachments();
        attachmentCreator.insertContentDocumentLinks( messageCreator.getInboundMessages() );

        EmailMessage message = [SELECT Id, ParentId FROM EmailMessage][0];

        System.assertEquals( c.Id, message.ParentId );
    }

    @IsTest
    static void testEmailForCase(){
        Case c = new Case(
            SuppliedEmail = 'me@test.com'
        );

        insert c;

        EmailExtractor extractor = new EmailExtractorCase();
        extractor.setWrappers( new Case[]{ c } );

        // instatiate a message creator then set messages
        MessageCreatorOutbound messageCreator = new MessageCreatorOutbound( extractor.getWrappers() );
        messageCreator.setMessages();

        Integer numberOfEmailsSent = 0;

        Test.startTest();

            // send the emails
            MessageHandler handler = new MessageHandler();
            handler.handle( messageCreator );

            numberOfEmailsSent = Limits.getEmailInvocations();
            
        Test.stopTest();

        System.assertEquals( 1, numberOfEmailsSent );
    }
}
