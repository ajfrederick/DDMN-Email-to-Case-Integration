/**
 * @name ConnectTeamInboundEmailHandler
 * @description handles inbound emails that come through the custom Connect_Team 'Email Service' in Setup
**/
public class ConnectTeamInboundEmailHandler implements Messaging.InboundEmailHandler {
    
    /**
     * @name createInbound
     * @description required method by interface that gets executed when an email is sent to the setup email service
     * @param Messaging.InboundEmail email
     * @param Messaging.InboundEnvelope envelope 
     * @return Messaging.InboundEmailResult
    **/
    public Messaging.InboundEmailResult handleInboundEmail( Messaging.InboundEmail email, Messaging.InboundEnvelope envelope ){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        Case newCase = createInbound( email );

        // the reason this isn't handeled on the insert trigger is so that in the message thread on the case
        // layout the incoming email message gets logged in salesforce before the automated outgoing message does
        // that way the feed shows up chronologically
        if( newCase != null ){
            createOutbound( newCase.Id );
        }

        result.success = true;

        return result;
    }   

    /**
     * @name createInbound
     * @description creates inbound internal email message
     * @param Messaging.InboundEmail email
     * @return Case
    **/
    private static Case createInbound( Messaging.InboundEmail email ){
        Id caseId = checkForExistingCase( email );

        Case newCase;

        // if no Id was found then create a new case
        if( caseId == null ){
            newCase = createCase( email );
            caseId = newCase.Id;
        }

        EmailContainerCreator containerCreator = new EmailContainerCreator();
        containerCreator.relatedToId = caseId;
        containerCreator.create( new Messaging.InboundEmail[]{ email } );

        // instatiate a message creator then set messages
        MessageCreatorInbound messageCreator = new MessageCreatorInbound( containerCreator.getContainers() );
        messageCreator.create();

        MessageHandler handler = new MessageHandler( messageCreator );
        handler.handle();

        // insert our attachments since we have EmailMessage
        AttachmentCreatorInbound attachmentCreator = new AttachmentCreatorInbound(  containerCreator.getContainers() );
        attachmentCreator.insertAttachments();
        attachmentCreator.insertContentDocumentLinks( messageCreator.getInboundMessages() );

        return newCase;
    }

     /**
     * @name createOutbound
     * @description creates inbound outbound auto response for new case. Is a future method to assure that this method happens far
     * enough in the future from the creation of the original inbound message
     * @param Messaging.InboundEmail email
     * @return Case
    **/
    @future
    private static void createOutbound( Id caseId ){
        Case newCase = [SELECT
            Id,
            SuppliedEmail,
            ContactId,
            ContactEmail
                FROM Case
                WHERE Id = :caseId
                LIMIT 1];

        EmailContainerCreatorCase containerCreator = new EmailContainerCreatorCase();
        containerCreator.setTemplate( Constants.NEW_EMAIL_TEMPLATE_NAME );
        containerCreator.create( new Case[]{ newCase } );

        // instatiate a message creator, set option, then set messages
        MessageCreatorOutbound messageCreator = new MessageCreatorOutbound( containerCreator.getContainers() );
        messageCreator.setOrgWideEmailAddressId( Constants.FROM_ADDRESS );
        messageCreator.setMessages();

        // send the emails
        MessageHandler handler = new MessageHandler();
        handler.handle( messageCreator );
    }

    /**
     * @name checkForExistingCase
     * @description checks for a reply to messageId and if there is one and the message has a ParentId (caseId)
     * then use that Id otherwise we need to create a new case
     * @param Messaging.InboundEmail email
     * @return Id
    **/
    private static Id checkForExistingCase( Messaging.InboundEmail email ){
        EmailMessage replyToMessage;

        if( email.inReplyTo != null ){

            try {

                replyToMessage = [SELECT 
                                    Id, 
                                    ParentId 
                                        FROM EmailMessage 
                                        WHERE MessageIdentifier = :email.inReplyTo];

            } catch( Exception e ){
                ExceptionHandler handler = new ExceptionHandler(e);
                handler.debug();
            }
        }
        
        Id caseId;

        if( replyToMessage != null ){
            caseId = replyToMessage.ParentId;
        }

        return caseId;
    }

    /**
     * @name createCase
     * @description inserts a case when an email comes in without a hidden case Id
     * @param Messaging.InboundEmail email
     * @return Case
    **/
    private static Case createCase( Messaging.InboundEmail email ){

        Case obj = new Case(
            Origin = 'Email',
            SuppliedEmail = email.FromAddress,
            Subject = email.Subject,
            Description = email.PlainTextBody,
            RecordTypeId = Constants.CONNECT_TEAM_RECORD_TYPE_ID,
            OwnerId = Constants.CONNECT_TEAM_QUEUE_ID
        );

        try {

            Contact contact = [SELECT 
                                Id,
                                AccountId
                                    FROM Contact 
                                    WHERE Email = :email.FromAddress
                                    LIMIT 1];

            if( contact != null ){
                obj.ContactId = contact.Id;
                obj.AccountId = contact.AccountId;
            }

        } catch( QueryException qe ){
            ExceptionHandler handler = new ExceptionHandler( qe );
            handler.debug();
        }

        try {
            insert obj;
        } catch( Exception e ){
            ExceptionHandler handler = new ExceptionHandler( e );
            handler.handle();
        }

        return obj;
    }
}