/**
 * @name MessageCreator
 * @description creates email messages and is extended by MessageCreatorOutbound and MessageCreatorInbound
**/
public abstract class MessageCreator {

/**
 * FIELDS
**/

    // List of outboundMessages
    public Messaging.SingleEmailMessage[] outboundMessages {
        get {
            if( outboundMessages == null ) outboundMessages = new Messaging.SingleEmailMessage[]{};
            return outboundMessages;
        }
        set;
    }

    // List of inboundMessages
    public EmailMessage[] inboundMessages {
        get {
            if( inboundMessages == null ) inboundMessages = new EmailMessage[]{};
            return inboundMessages;
        }
        set;
    }

    // Class containers that contain email to info
    protected EmailContainer[] containers {get;set;}

/**
 * CONSTRUCTOR
**/

    public MessageCreator( EmailContainer[] ws ){
        containers = ws;
    }

/**
 * ACTION METHODS
**/

    /**
     * @name create
     * @description loop through containers and get an email message
     * @return void
    **/
    public abstract void create();

    /**
     * @name getOutboundMessages
     * @description for external use. returns list of outbound messages
     * @return Messaging.SingleEmailMessage[]
    **/
    public Messaging.SingleEmailMessage[] getOutboundMessages(){
        return outboundMessages;
    }

    /**
     * @name getInboundMessages
     * @description for external use. returns list of inbound messages
     * @return EmailMessage[]
    **/
    public EmailMessage[] getInboundMessages(){
        return inboundMessages;
    }

/**
 * UTILITY METHODS
**/

    /**
     * @name hasOutboundMessages
     * @description checks to see if there are outbound messages populating the array.
     * @return Boolean
    **/
    public Boolean hasOutboundMessages(){
        return !outboundMessages.isEmpty();
    }
    
    /**
     * @name hasInboundMessages
     * @description checks to see if there are inbound messages populating the array.
     * @return Boolean
    **/
    public Boolean hasInboundMessages(){
        return !inboundMessages.isEmpty();
    }
}
