/**
 * @name EmailPost
 * @description posts inbound and outbound messages
**/
global class EmailPost {

    private EmailFactory emailFactory {get;set;}

    private EmailResultsOutbound resultsOutbound {get;set;}

    global static Boolean triggerEnabled {
        get {
            if( triggerEnabled == null ) triggerEnabled = false;

            return triggerEnabled;
        }
        set;
    }

/**
 * CONSTRUCTOR
**/

    global EmailPost( EmailFactory emailFactory ) {
        this.emailFactory = emailFactory;
    }

/**
 * ACTION METHODS
**/

    /**
     * @name post
     * @description sends outbound and recieves inbound messages
     * @return void
    **/
    global void post(){
        triggerEnabled = true;

        if( emailFactory.hasOutboundMessages() ){
            send( emailFactory.getOutboundMessages() );
        }

        if( emailFactory.hasInboundMessages() ){
            receive( emailFactory.getInboundMessages() );
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

            resultsOutbound = new EmailResultsOutbound( results );
            resultsOutbound.setSuccesses( messages );

            if( resultsOutbound.hasFailures() ){
                String joinedErrorMessages = String.join( resultsOutbound.getErrorMessages(), '\n\n' );

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
     * @name linkContentVersions
     * @description adds a version factory to the trigger helper. This inserts the ContentDocumentLinks which links a ContectVersion
     * to an EmailMessage. It has to be accessible after the trigger fires.
     * @param  ContentVersionPost versionPost 
    **/
    global void linkContentVersions( ContentVersionPost versionPost ){
        EmailMessageUtil.versionPost = versionPost;
    }

    /**
     * @name addTriggerHook
     * @description adds a hood that gets used on the email message trigger to post operations after or before an email 
     * message gets inserted, updated or deleted. It gives a developer opportunity to add operations from outside the application.
     * @param TriggerHook hook
    **/
    global void addTriggerHook( TriggerHook hook ){
        EmailMessageUtil.hooks.add( hook );
    }

/**
 * UTILITY METHODS
**/

    /**
     * @name getEmailResultsOutbound
     * @description return the results of the outbound messages to get failures
     * @return EmailResultsOutbound
    **/
    global EmailResultsOutbound getEmailResultsOutbound(){
        return resultsOutbound;
    }

/**
 * CLASSES
**/

    global class EmailException extends Exception {}
}