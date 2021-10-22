/**
 * @name MessageHandler
 * @description handles inbound and outbound messages
**/
public class MessageHandler {

    private MessageCreator messageCreator {get;set;}

    private OutboundEmailResults outboundResults {get;set;}

    public static Boolean triggerEnabled {
        get {
            if( triggerEnabled == null ) triggerEnabled = false;

            return triggerEnabled;
        }
        set;
    }

/**
 * CONSTRUCTOR
**/

    public MessageHandler( MessageCreator mc ) {

    }

/**
 * ACTION METHODS
**/
    /**
     * @name handle
     * @description sends outbound and recieves inbound messages
     * @return void
    **/
    public void handle(){
        triggerEnabled = true;

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

            outboundResults = new OutboundEmailResults( results );
            outboundResults.setSuccesses( messages );

            if( outboundResults.hasFailures() ){
                String joinedErrorMessages = String.join( outboundResults.getErrorMessages(), '\n\n' );

                throw new EmailException( joinedErrorMessages );
            }

        } catch( Exception e ){
            CreedExceptionHandler handler = new CreedExceptionHandler(e);
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

        } catch( Exception e ){
            CreedExceptionHandler handler = new CreedExceptionHandler(e);
            handler.handle();
        }
    }

    /**
     * @name getOutboundEmailResults
     * @description return the results of the outbound messages to get failures
     * @return OutboundEmailResults
    **/
    public OutboundEmailResults getOutboundEmailResults(){
        return outboundResults;
    }

/**
 * CLASSES
**/

    public class EmailException extends Exception {}
}
