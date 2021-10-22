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

/**
 * CONSTRUCTOR
**/

    public MessageCreatorOutbound( EmailContainer[] containers ) {
        super(containers);
    }

/**
 * ACTION METHODS
**/

    /**
     * @name create
     * @description loop through containers and get an email message
     * @return void
    **/
    public override void create(){

        for( EmailContainer container : containers ){
            if( !isVaild( container ) ) continue;

            outboundMessages.add( getMessage( container ) );
        }
    }

    /**
     * @name getMessage
     * @description creates a single email massage and sets necessary fields base on certain conditions
     * waterfalls the next 3 methods
     * @param EmailContainer container
     * @return SObject message
    **/
    private Messaging.SingleEmailMessage getMessage( EmailContainer container ){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

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
     * @description called within getMessage, configures outgoing email. Message targeted recipitent's 
     * id is set, sets the whatId which helps to further ensure that merge fields in the template contain the correct data, 
     * and also sets InReplyTo which identifies the email or emails to which this email is a reply (parent emails).
     * @param Messaging.SingleEmailMessage message, EmailContainer container
     * @return void
    **/
    private void configureMessage( Messaging.SingleEmailMessage message, EmailContainer container ){
        
        if( container.hasWhoId() ){  
            message.setTargetObjectId( container.whoId );
        }

        if( container.hasWhatId() ){
            message.setWhatId( container.whatId );
        }

        if( container.hasInReplyTo() ){
            message.setInReplyTo( container.inReplyTo );
        }

        message.setSaveAsActivity( true );
        message.setUseSignature( false );
    }

    /**
     * @name setAddressInfo
     * @description called within getMessage
     * sets outgoing message's to, cc, and bcc addresses. Sets from Address with org wide email address Id
     * @param Messaging.SingleEmailMessage message
     * @param EmailContainer container 
     * @return void
    **/
    private void setAddressInfo( Messaging.SingleEmailMessage message, EmailContainer container ){
        
        message.setToAddresses( container.ToAddresses );
        message.setCcAddresses( container.CcAddresses );
        message.setBccAddresses( container.BccAddresses );

        // we have to do this cause this how SF handles setting the From Address for outgoing emails
        if( oweAddressId != null ){
            message.setOrgWideEmailAddressId( oweAddressId );
        }
    }

    /**
     * @name setContent
     * @description called within getMessage if there is a message and a container
     * sets body/subject of the outgoing message with values from the container & sets id's for attatched documents
     * @param Messaging.SingleEmailMessage message, EmailContainer container 
     * @return void
    **/
    private void setContent( Messaging.SingleEmailMessage message, EmailContainer container ){
        String body = '';
        String subject = '';

        if( container.template != null ){
            subject = container.template.Subject;
            body = container.template.HtmlValue;
        } else 
        if( container.getContent() != null ){
            subject = container.getSubject();
            body = container.getHTMLBody();
        }

        message.setSubject( subject );
        message.setHtmlBody( body );
        message.setTreatBodiesAsTemplate(true);

        // set Salesforce files as attachments if there are any
        if( !container.getVersionIds().isEmpty() ){
            message.setEntityAttachments( container.getVersionIds() );
        } else
        // or set attachements with Attachment data. These attachments aren't saved in Salesforce as files
        if( !container.attachments.isEmpty() ){
           Messaging.EmailFileAttachment[] attachments = new Messaging.EmailFileAttachment[]{};

            for( EmailContainer.AttachmentData attachment : container.attachments ){
                Messaging.EmailFileAttachment attachmentToAdd = new Messaging.EmailFileAttachment();
                attachmentToAdd.setFileName( attachment.filename );
                attachmentToAdd.setBody( attachment.body );
                attachmentToAdd.setContentType( attachment.contentType );

                attachments.add( attachmentToAdd );
            }

            message.setFileAttachments( attachments );
        }
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
        return container.hasToAddresses();
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
