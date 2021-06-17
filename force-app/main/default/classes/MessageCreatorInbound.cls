/**
 * @name MessageCreatorInbound
 * @description creates email messages that are incoming
**/
public class MessageCreatorInbound extends MessageCreator {

/**
 * CONSTRUCTOR
**/

    public MessageCreatorInbound( EmailInfo[] wrappers ) {
        super(wrappers);
    }

/**
 * ACTION MEHTODS
**/

    /**
     * @name setMessages
     * @description loop through wrappers and get an email message
     * @return void
    **/
    public override void setMessages(){

        for( EmailInfo wrapper : wrappers ){
            if( !isVaild( wrapper ) ) continue;

            inboundMessages.add( getMessage( wrapper ) );
        }
    }

    /**
     * @name getMessage
     * @description creates a single email massage and sets necessary fields base on certain conditions
     * waterfalls the next 3 methods
     * @param EmailInfo wrapper
     * @return SObject message
    **/
    private EmailMessage getMessage( EmailInfo wrapper ){
        EmailMessage message = new EmailMessage();

        configureMessage( message, wrapper );
        setAddressInfo( message, wrapper );
        setContent( message, wrapper );

        return message;
    }

/**
 * WATER FALL METHODS FOR CLEANLINESS
**/

    /**
     * @name configureMessage
     * @description called within getMessage 
     * checks to see if the wrapper has an id, if so it sets the ParentId to the wrapper whatId
     * identifies message as incoming message & sets the messages's identifier as wrapper's message id
     * @param EmailMessage message, EmailInfo wrapper
     * @return void
    **/
    private void configureMessage( EmailMessage message, EmailInfo wrapper  ){
        
        if( wrapper.hasWhatId() ){
            message.ParentId = wrapper.whatId;
        }

        message.MessageIdentifier = wrapper.messageId;
        message.Incoming = true;
    }

    /**
     * @name setAddressInfo
     * @description called within getMessage 
     * sets all the associated addresses (to, cc, bcc, from, and name addresses) for the message
     * @param EmailMessage message, EmailInfo wrapper
     * @return void
    **/
    private void setAddressInfo( EmailMessage message, EmailInfo wrapper ){
        message.ToAddress = getAddressString( wrapper.ToAddresses );
        message.CcAddress = getAddressString( wrapper.CcAddresses );
        message.BccAddress = getAddressString( wrapper.BccAddresses );
   
        message.fromAddress = wrapper.fromAddress;
        message.fromName = wrapper.fromName;
    }

    /**
     * @name setContent
     * @description called within getMessage 
     * sets the related content of the message: the Subject, HtmlBody, & TextBody
     * @param EmailMessage message, EmailInfo wrapper
     * @return void
    **/
    private void setContent( EmailMessage message, EmailInfo wrapper ){
        message.Subject = wrapper.content.Subject;
        message.HtmlBody = wrapper.content.HtmlBody;
        message.TextBody = wrapper.content.PlainTextBody;
    }

/**
 * UTILITY MEHTODS
**/

    /**
     * @name isVaild
     * @description checks wrapper to ensure it has a toAddress and it doesn't match the forward from email address
     * @param EmailInfo wrapper
     * @return Boolean
    **/
    private Boolean isVaild( EmailInfo wrapper ){
        return wrapper.hasToAddresses() && wrapper.hasContent();
    }

    /**
     * @name getAddressString
     * @description returns the rest of the email address that aren't associated with a User or Contact. Formated
     * as a semi colon delimited string because that's the way Salesforce developed it.
     * @param String[] addresses
     * @return String 
    **/
    private String getAddressString( String[] addresses ){
        String addressString = '';

        for( String address : addresses ){
            addressString += address + '; ';
        }

        // remove the last semi colon
        return addressString.removeEnd('; ');
    }
}
