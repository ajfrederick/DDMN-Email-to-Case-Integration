/**
 * @name EmailFactoryInbound
 * @description creates email messages that are incoming
**/
global class EmailFactoryInbound extends EmailFactory {

/**
 * CONSTRUCTORS
**/

    global EmailFactoryInbound( EmailParcelFactory parcelFactory ){
        super( parcelFactory.getParcels() );
    }

    global EmailFactoryInbound( EmailParcel[] parcels ) {
        super( parcels );
    }

/**
 * ACTION MEHTODS
**/

    /**
     * @name build
     * @description loop through parcels and get an email message
     * @return void
    **/
    global override void build(){

        for( EmailParcel parcel : parcels ){
            if( !isVaild( parcel ) ) continue;

            inboundMessages.add( getMessage( parcel ) );
        }
    }

    /**
     * @name getMessage
     * @description creates a single email massage and sets necessary fields base on certain conditions
     * waterfalls the next 3 methods
     * @param EmailParcel parcel
     * @return EmailMessage message
    **/
    private EmailMessage getMessage( EmailParcel parcel ){
        EmailMessage message = new EmailMessage();

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
     * @description called within getMessage, sets and incoming message's
     *  parentId to the given EmailParcel object's whatId. Message is also identified as an incoming message.
     * 
     * @param EmailMessage message
     * @param EmailParcel parcel
     * @return void
    **/
    private void configureMessage( EmailMessage message, EmailParcel parcel  ){
        
        if( parcel.hasWhatId() ){
            message.ParentId = parcel.whatId;
        }

        message.MessageIdentifier = parcel.messageId;
        message.Incoming = true;
    }

    /**
     * @name setAddressInfo
     * @description called within getMessage 
     * sets all the associated addresses (to, cc, bcc, from, and name addresses) for the an inbound message as well as the
     * name of the sender of the email.
     * @param EmailMessage message, EmailParcel parcel
     * @return void
    **/
    private void setAddressInfo( EmailMessage message, EmailParcel parcel ){
        message.ToAddress = getAddressString( parcel.ToAddresses );
        message.CcAddress = getAddressString( parcel.CcAddresses );
        message.BccAddress = getAddressString( parcel.BccAddresses );
   
        message.fromAddress = parcel.fromAddress;
        message.fromName = parcel.fromName;
    }

    /**
     * @name setContent
     * @description called within getMessage,
     * sets the related content of the message: the Subject, HtmlBody, & TextBody of the inbound message
     * @param EmailMessage message, EmailParcel parcel
     * @return void
    **/
    private void setContent( EmailMessage message, EmailParcel parcel ){
        message.Subject = parcel.getSubject();
        message.HtmlBody = parcel.getHTMLBody();
        message.TextBody = parcel.getPlainTextBody();
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
        return parcel.hasToAddresses() && parcel.hasContent();
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