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

    private void configureMessage( EmailMessage message, EmailInfo wrapper  ){
        
        if( wrapper.hasWhatId() ){
            message.ParentId = wrapper.whatId;
        }

        message.MessageIdentifier = wrapper.messageId;
        message.Incoming = true;
    }

    private void setAddressInfo( EmailMessage message, EmailInfo wrapper ){
        String[] emails = setRecipientIds( message, wrapper );
        
        message.ToAddress = getAddressString( wrapper.ToAddresses, emails );
        message.CcAddress = getAddressString( wrapper.CcAddresses, emails );
        message.BccAddress = getAddressString( wrapper.BccAddresses, emails );
        
        message.fromAddress = wrapper.fromAddress;
        message.fromName = wrapper.fromName;
    }

    private void setContent( EmailMessage message, EmailInfo wrapper ){
        message.Subject = wrapper.content.Subject;
        message.HtmlBody = wrapper.content.HtmlBody;
        message.TextBody = wrapper.content.PlainTextBody;
    }
    
    private String[] setRecipientIds( EmailMessage message, EmailInfo wrapper  ){
        SObject[] objs = new SObject[]{};

        objs.addAll( getContacts( wrapper.allAddresses ) );
        objs.addAll( getUsers( wrapper.allAddresses ) );
        
        String[] emails = new String[]{};

        for( SObject obj : objs ){
            String email = (String) obj.get('Email');

            if( wrapper.ToAddresses.contains( email ) ){
                message.ToIds.add( obj.Id );
            } else
            if( wrapper.CcAddresses.contains( email ) ){
                message.CcIds.add( obj.Id );
            } else
            if( wrapper.BccAddresses.contains( email ) ){
                message.BccIds.add( obj.Id );
            }

            emails.add( email );
        }

        return emails;
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

    private Contact[] getContacts( String[] addresses ){
        Contact[] contacts = new Contact[]{};

        try {
            
            contacts.addAll([SELECT
                                Id,
                                Email
                                    FROM Contact
                                    WHERE email IN :addresses]);

        } catch( QueryException qe ){

        }

        return contacts;
    }

    private User[] getUsers( String[] addresses ){
        User[] users = new User[]{};

        try {
            
            users.addAll([SELECT
                                Id,
                                Email
                                    FROM User
                                    WHERE email IN :addresses]);

        } catch( QueryException qe ){

        }

        return users;
    }

    private String getAddressString( String[] addresses, String[] contactEmails ){
        String addressString = '';

        Integer len = addresses.size();

        for( Integer i=0; i<len; i++ ){
            String address = addresses[i];

            if( !contactEmails.contains( address ) ){
                addressString += address;
                
                if( i < (len-1) ){
                    addressString += ',';
                }
            }
        }

        return addressString;
    }
}
