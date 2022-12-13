/**
 * @name EmailFactoryOutbound
 * @description creates email messages that are outgoing
**/
global class EmailFactoryOutbound extends EmailFactory {

/**
 * CONSTRUCTORS
**/

    global EmailFactoryOutbound( EmailParcelFactory parcelFactory ){
        super( parcelFactory.getParcels() );
    }

    global EmailFactoryOutbound( EmailParcel[] parcels ) {
        super( parcels );
    }

/**
 * ACTION METHODS
**/

    /**
     * @name build
     * @description loop through parcels and get an email message
     * @return void
    **/
    global override void build(){

        for( EmailParcel parcel : parcels ){
            if( !isVaild( parcel ) ) continue;

            outboundMessages.add( getMessage( parcel ) );
        }
    }

    /**
     * @name getMessage
     * @description creates a single email massage and sets necessary fields base on certain conditions
     * waterfalls the next 3 methods
     * @param EmailParcel parcel
     * @return SObject message
    **/
    private Messaging.SingleEmailMessage getMessage( EmailParcel parcel ){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        configureMessage( message, parcel );
        setAddressInfo( message, parcel );
        setContent( message, parcel );

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
     * @param Messaging.SingleEmailMessage message, EmailParcel parcel
     * @return void
    **/
    private void configureMessage( Messaging.SingleEmailMessage message, EmailParcel parcel ){
        
        if( parcel.hasWhoId() ){  
            message.setTargetObjectId( parcel.whoId );
        }

        if( parcel.hasWhatId() ){
            message.setWhatId( parcel.whatId );
        }

        if( parcel.hasInReplyTo() ){
            message.setInReplyTo( parcel.inReplyTo );
        }

        message.setSaveAsActivity( true );
        message.setUseSignature( false );
    }

    /**
     * @name setAddressInfo
     * @description called within getMessage
     * sets outgoing message's to, cc, and bcc addresses. Sets from Address with org wide email address Id
     * @param Messaging.SingleEmailMessage message
     * @param EmailParcel parcel 
     * @return void
    **/
    private void setAddressInfo( Messaging.SingleEmailMessage message, EmailParcel parcel ){
        
        message.setToAddresses( parcel.ToAddresses );
        message.setCcAddresses( parcel.CcAddresses );
        message.setBccAddresses( parcel.BccAddresses );

        // we have to do this cause this how SF handles setting the From Address for outgoing emails
        if( parcel.oweAddressId != null ){
            message.setOrgWideEmailAddressId( parcel.oweAddressId );
        }
    }

    /**
     * @name setContent
     * @description called within getMessage if there is a message and a parcel
     * sets body/subject of the outgoing message with values from the parcel & sets id's for attatched documents
     * @param Messaging.SingleEmailMessage message, EmailParcel parcel 
     * @return void
    **/
    private void setContent( Messaging.SingleEmailMessage message, EmailParcel parcel ){
        String body = '';
        String subject = '';

        if( parcel.template != null ){
            subject = parcel.template.Subject;
            body = parcel.template.HtmlValue;
        } else 
        if( parcel.getContent() != null ){
            subject = parcel.getSubject();
            body = parcel.getHTMLBody();
        }

        message.setSubject( subject );
        message.setHtmlBody( body );
        message.setTreatBodiesAsTemplate(true);

        // set Salesforce files as attachments if there are any
        if( parcel.hasVersionIds() ){
            message.setEntityAttachments( parcel.getVersionIds() );
        }

        // Set attachements with Attachment data. These attachments aren't saved in Salesforce as files
        if( parcel.hasAttachments() ){
           Messaging.EmailFileAttachment[] attachments = new Messaging.EmailFileAttachment[]{};

            for( EmailParcel.AttachmentData attachment : parcel.attachments ){
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
     * @description checks parcel to ensure it has a toAddress and it doesn't match the forward from email address
     * @param EmailParcel parcel
     * @return Boolean
    **/
    private Boolean isVaild( EmailParcel parcel ){
        return parcel.hasToAddresses() || parcel.hasWhoId();
    }
}