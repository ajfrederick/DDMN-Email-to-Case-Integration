/**
 * @name MessageHandler
 * @description handles inbound and outbound messages
**/
public class MessageHandler {

    private MessageCreator messageCreator {get;set;}

/**
 * CONSTRUCTOR
**/

    public MessageHandler() {

    }

/**
 * ACTION METHODS
**/
    /**
     * @name handle
     * @description sends outbound and recieves inbound messages
     * @return void
    **/
    public void handle( MessageCreator mc  ){
        messageCreator = mc;

        if( messageCreator.hasOutboundMessages() ){
            send( messageCreator.getOutboundMessages() );
        }

        if( messageCreator.hasInboundMessages() ){
            receive( messageCreator.getInboundMessages() );
        }
    }

    /**
     * @name send
     * @description Sends messages
     * @param Messaging.SingleEmailMessage[] messages
     * @return void
    **/
    private void send( Messaging.SingleEmailMessage[] messages ){

        try {
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail( messages );

            OutboundEmailResults outboundResults = new OutboundEmailResults( results );
            outboundResults.setSuccesses( messages );

            if( outboundResults.hasFailures() ){
                String joinedErrorMessages = String.join( outboundResults.getErrorMessages(), '\n\n' );

                throw new EmailException( joinedErrorMessages );
            }

        } catch( Exception e ){
            ExceptionHandler handler = new ExceptionHandler(e);
            handler.handle();
        }
    }

    /**
     * @name receive
     * @description inserts/receive messages
     * @return void
    **/
    private void receive( EmailMessage[] messages ){

        try {

            insert messages;

            /*
            EmailMessageRelation[] relations = createEmailMessageRelations( messages );

            if( relations.size() > 0 ){
                insert relations;
            }
            */

        } catch( Exception e ){
            ExceptionHandler handler = new ExceptionHandler(e);
            handler.handle();
        }
    }

/**

    
--- THIS IS COMMENTED OUT BECAUSE IT SEEMS AS OF MAY 10, 2021 THIS IS BUILT SALESFORCE FUNCTIONALITY ---


    /**
     * @name createEmailMessageRelations
     * @description creates the necessary email message relations when there are contacts or users as To, Cc, or Bcc address
     * @param EmailMessage[] messages
     * @return EmailMessageRelation[]
   
    private EmailMessageRelation[] createEmailMessageRelations( EmailMessage[] messages ){
        EmailMessageRelation[] relations = new EmailMessageRelation[]{};

        // this is because for some reason EmailMessage doesn't have the ability to store the sender Id like 'ToIds' for recipients
        // so we have to get Ids of any users or contacts that sent the message this way
        Map<String, Id> senderIdsByAddress = getSenderIdsByAddress( messages );

        for( EmailMessage message : messages ){

            relations.add( getFromRelation(message, senderIdsByAddress) );
            
            // create relations for To Addresses
            for( Id id : message.ToIds ){
                relations.add( new EmailMessageRelation(
                    emailMessageId = message.Id,
                    relationId = id,
                    relationType = 'ToAddress'
                ));
            }

            // create relations for Cc Addresses
            for( Id id : message.CcIds ){
                relations.add( new EmailMessageRelation(
                    emailMessageId = message.Id,
                    relationId = id,
                    relationType = 'CcAddress'
                ));
            }

            // create relations for Bcc Addresses
            for( Id id : message.BccIds ){
                relations.add( new EmailMessageRelation(
                    emailMessageId = message.Id,
                    relationId = id,
                    relationType = 'BccAddress'
                ));
            }
        }

        return relations;
    }

    /**
     * @name getFromRelation
     * @description creates a EmailMessageRelations from a 'From Address' 
     * @return EmailMessageRelation
  
    private EmailMessageRelation getFromRelation( EmailMessage message, Map<String, Id> senderIdsByAddress ){
        
        EmailMessageRelation fromRelation = new EmailMessageRelation(
            emailMessageId = message.Id,
            relationType = 'FromAddress'
        );

        if( senderIdsByAddress.containsKey( message.FromAddress ) ){
            fromRelation.relationId = senderIdsByAddress.get( message.FromAddress );
        } else {
            fromRelation.relationAddress = message.FromAddress;
        }

        return fromRelation;
    }

    /**
     * @name getSenderIdsByAddress
     * @description creates the necessary email message relations when there are contacts as Sender
     * @return EmailMessageRelation

    private Map<String, Id> getSenderIdsByAddress( EmailMessage[] messages ){
        Map<String, Id> senderIdsByAddress = new Map<String, Id>();

        String[] addresses = new String[]{};

        for( EmailMessage message : messages ){
            addresses.add( message.FromAddress );
        }

        Contact[] senders = new Contact[]{};

        // Get all contacts
        try {

            senders.addAll([SELECT 
                                Id,
                                Email
                                    FROM Contact 
                                    WHERE Email IN :addresses]);

        } catch( QueryException qe ){
            ExceptionHandler handler = new ExceptionHandler(qe);
            handler.debug();
        }

        for( Contact sender : senders ){
            senderIdsByAddress.put( sender.Email, sender.Id );
        }

        return senderIdsByAddress;
    }
**/

/**
 * CLASSES
**/

    public class EmailException extends Exception {}
}
