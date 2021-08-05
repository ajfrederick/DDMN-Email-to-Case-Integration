/**
 * @name MessageCreatorOutbound
 * @description creates email messages that are outgoing
**/
public class MessageCreatorOutbound extends MessageCreator {

/**
 * FIELDS
**/

    // org wide email address Id which is optional. You cannot set a proper 'from address' on outgoing email without one
    private Id oweAddressId {get;set;}

    private String[] contentVersionIds {
        get {
            if( contentVersionIds == null ) contentVersionIds = new String[]{};
            return contentVersionIds;
        }
        set;
    }

/**
 * CONSTRUCTOR
**/

    public MessageCreatorOutbound( EmailInfo[] wrappers ) {
        super(wrappers);
    }

/**
 * ACTION METHODS
**/

    /**
     * @name setMessages
     * @description loop through wrappers and get an email message
     * @return void
    **/
    public override void setMessages(){

        for( EmailInfo wrapper : wrappers ){
            if( !isVaild( wrapper ) ) continue;

            outboundMessages.add( getMessage( wrapper ) );
        }
    }

    /**
     * @name getMessage
     * @description creates a single email massage and sets necessary fields base on certain conditions
     * waterfalls the next 3 methods
     * @param EmailInfo wrapper
     * @return SObject message
    **/
    private Messaging.SingleEmailMessage getMessage( EmailInfo wrapper ){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

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
     * @description called within getMessage, configures outgoing email. Message targeted recipitent's 
     * id is set, sets the whatId which helps to further ensure that merge fields in the template contain the correct data, 
     * and also sets InReplyTo which identifies the email or emails to which this email is a reply (parent emails).
     * @param Messaging.SingleEmailMessage message, EmailInfo wrapper
     * @return void
    **/
    private void configureMessage( Messaging.SingleEmailMessage message, EmailInfo wrapper ){
        
        if( wrapper.hasWhoId() ){  
            message.setTargetObjectId( wrapper.whoId );
        }

        if( wrapper.hasWhatId() ){
            message.setWhatId( wrapper.whatId );
        }

        if( wrapper.hasInReplyTo() ){
            message.setInReplyTo( wrapper.inReplyTo );
        }

        message.setSaveAsActivity( true );
        message.setUseSignature( false );
    }

    /**
     * @name setAddressInfo
     * @description called within getMessage
     * sets outgoing message's to, cc, and bcc addresses. Sets from Address with org wide email address Id
     * @param Messaging.SingleEmailMessage message
     * @param EmailInfo wrapper 
     * @return void
    **/
    private void setAddressInfo( Messaging.SingleEmailMessage message, EmailInfo wrapper ){
        
        message.setToAddresses( wrapper.ToAddresses );
        message.setCcAddresses( wrapper.CcAddresses );
        message.setBccAddresses( wrapper.BccAddresses );

        // we have to do this cause this how SF handles setting the From Address for outgoing emails
        if( oweAddressId != null ){
            message.setOrgWideEmailAddressId( oweAddressId );
        }
    }

    /**
     * @name setContent
     * @description called within getMessage if there is a message and a wrapper
     * sets body/subject of the outgoing message with values from the wrapper & sets id's for attatched documents
     * @param Messaging.SingleEmailMessage message, EmailInfo wrapper 
     * @return void
    **/
    private void setContent( Messaging.SingleEmailMessage message, EmailInfo wrapper ){
        String body = '';
        String subject = '';

        if( wrapper.template != null ){
            subject = wrapper.template.Subject;
            body = wrapper.template.HtmlValue;
        } else 
        if( wrapper.content != null ){
            subject = wrapper.content.Subject;
            body = wrapper.content.HtmlBody;
        }

        message.setSubject( subject );
        message.setHtmlBody( body );
        message.setTreatBodiesAsTemplate(true);


        if( !contentVersionIds.isEmpty() ){
            message.setEntityAttachments( contentVersionIds );
        }
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
        return wrapper.hasToAddresses();
    }

    /**
     * @name setContentVersionIds
     * @description sets ContentVersion Ids for attachemnts
     * @param String[] ids
     * @return void
    **/
    public void setContentVersionIds( String[] ids ){
        contentVersionIds = ids;
    }

/**
 * QUERIES
**/

    /**
     * @name setOrgWideEmailAddressId
     * @description sets Org Wide Email Address for From Address
     * @param String address
    **/
    public void setOrgWideEmailAddressId( String addressName ){
        OrgWideEmailAddress oweAddress = Utils.getOrgWideEmailAddress( addressName );

        if( oweAddress != null ){
            oweAddressId = oweAddress.Id;
        }
    }
}
