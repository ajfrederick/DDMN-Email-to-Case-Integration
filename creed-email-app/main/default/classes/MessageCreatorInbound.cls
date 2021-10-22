/**
 * @name MessageCreatorInbound
 * @description creates email messages that are incoming
**/
public class MessageCreatorInbound extends MessageCreator {

/**
 * CONSTRUCTOR
**/

    public MessageCreatorInbound( EmailContainer[] containers ) {
        super(containers);
    }

/**
 * ACTION MEHTODS
**/

    /**
     * @name create
     * @description loop through containers and get an email message
     * @return void
    **/
    public override void create(){

        for( EmailContainer container : containers ){
            if( !isVaild( container ) ) continue;

            inboundMessages.add( getMessage( container ) );
        }
    }

    /**
     * @name getMessage
     * @description creates a single email massage and sets necessary fields base on certain conditions
     * waterfalls the next 3 methods
     * @param EmailContainer container
     * @return EmailMessage message
    **/
    private EmailMessage getMessage( EmailContainer container ){
        EmailMessage message = new EmailMessage();

        configureMessage( message, container );
        setAddressInfo( message, container );
        setContent( message, container );

        return message;
    }

/**
 * WATER FALL METHODS FOR CLEANLINESS
**/

    /**
     * @name configureMessage
     * @description called within getMessage, sets and incoming message's
     *  parentId to the given EmailContainer object's whatId. Message is also identified as an incoming message.
     * 
     * @param EmailMessage message
     * @param EmailContainer container
     * @return void
    **/
    private void configureMessage( EmailMessage message, EmailContainer container  ){
        
        if( container.hasWhatId() ){
            message.ParentId = container.whatId;
        }

        message.MessageIdentifier = container.messageId;
        message.Incoming = true;
    }

    /**
     * @name setAddressInfo
     * @description called within getMessage 
     * sets all the associated addresses (to, cc, bcc, from, and name addresses) for the an inbound message as well as the
     * name of the sender of the email.
     * @param EmailMessage message, EmailContainer container
     * @return void
    **/
    private void setAddressInfo( EmailMessage message, EmailContainer container ){
        message.ToAddress = getAddressString( container.ToAddresses );
        message.CcAddress = getAddressString( container.CcAddresses );
        message.BccAddress = getAddressString( container.BccAddresses );
   
        message.fromAddress = container.fromAddress;
        message.fromName = container.fromName;
    }

    /**
     * @name setContent
     * @description called within getMessage,
     * sets the related content of the message: the Subject, HtmlBody, & TextBody of the inbound message
     * @param EmailMessage message, EmailContainer container
     * @return void
    **/
    private void setContent( EmailMessage message, EmailContainer container ){
        message.Subject = container.getSubject();
        message.HtmlBody = container.getHTMLBody();
        message.TextBody = container.getPlainTextBody();
    }

/**
 * UTILITY MEHTODS
**/

    /**
     * @name isVaild
     * @description checks container to ensure it has a toAddress and it doesn't match the forward from email address
     * @param EmailContainer container
     * @return Boolean
    **/
    private Boolean isVaild( EmailContainer container ){
        return container.hasToAddresses() && container.hasContent();
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
