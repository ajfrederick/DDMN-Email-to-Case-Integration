/**
 * @name EmailFactory
 * @description creates email messages and is extended by EmailFactoryOutbound and EmailFactoryInbound
**/
global abstract class EmailFactory {

/**
 * FIELDS
**/

    // List of outboundMessages
    global Messaging.SingleEmailMessage[] outboundMessages {
        get {
            if( outboundMessages == null ) outboundMessages = new Messaging.SingleEmailMessage[]{};
            return outboundMessages;
        }
        set;
    }

    // List of inboundMessages
    global EmailMessage[] inboundMessages {
        get {
            if( inboundMessages == null ) inboundMessages = new EmailMessage[]{};
            return inboundMessages;
        }
        set;
    }

    // Class parcels that contain email to info
    protected EmailParcel[] parcels {get;set;}

/**
 * CONSTRUCTOR
**/

    global EmailFactory( EmailParcel[] parcels ){
        this.parcels = parcels;
    }

/**
 * ACTION METHODS
**/

    /**
     * @name build
     * @description loop through parcels and get an email message
     * @return void
    **/
    global abstract void build();

    /**
     * @name getOutboundMessages
     * @description for external use. returns list of outbound messages
     * @return Messaging.SingleEmailMessage[]
    **/
    global Messaging.SingleEmailMessage[] getOutboundMessages(){
        return outboundMessages;
    }

    /**
     * @name getInboundMessages
     * @description for external use. returns list of inbound messages
     * @return EmailMessage[]
    **/
    global EmailMessage[] getInboundMessages(){
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
    global Boolean hasOutboundMessages(){
        return !outboundMessages.isEmpty();
    }
    
    /**
     * @name hasInboundMessages
     * @description checks to see if there are inbound messages populating the array.
     * @return Boolean
    **/
    global Boolean hasInboundMessages(){
        return !inboundMessages.isEmpty();
    }
}