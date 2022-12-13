/**
 * @name EmailParcelFactory
 * @description gets proper email info from object for email message. Abstract so you can define
 * the process of getting email addresses for different Objects
**/
global virtual class EmailParcelFactory {

/**
 * FIELDS
**/

    // a list of central, understandable, ubiquitis parcels for the whole email application. These get passed around and 
    // loaded up with info and then unpacked
    global EmailParcel[] parcels {
        get {
            if( parcels == null ){ parcels = new EmailParcel[]{}; }
            return parcels;
        }
        set;
    }

    // parcels can be created from either SObjects or inboundEmails. This is the list of objs.
    global SObject[] objs {
        get {
            if( objs == null ){ objs = new SObject[]{}; }
            return objs;
        }
        set;
    }

    // parcels can be created from either SObjects or inboundEmails. This is the list of Inbound Emails.
    global Messaging.InboundEmail[] inboundEmails {
        get {
            if( inboundEmails == null ){ inboundEmails = new Messaging.InboundEmail[]{}; }
            return inboundEmails;
        }
        set;
    }

    // OLD: To Be Deprecated
    global Map<String, Id[]> versionIdsByName {
        get {
            if( versionIdsByName == null ){ versionIdsByName = new Map<String, Id[]>(); }
            return versionIdsByName;
        }
        set;
    }

    // Deconstructed ContentVersions (files) that are already in the database which are added to parcel and will be used to send an attachment
    // keyed on an explicitly named value passed into the method below
    global Map<String, AttachmentData[]> attachmentsByName {
        get {
            if( attachmentsByName == null ){ attachmentsByName = new Map<String, AttachmentData[]>(); }
            return attachmentsByName;
        }
        set;
    }

    global EmailTemplate template {get;set;}

    global Id oweAddressId {get;set;}

    global Id relatedToId {get;set;}
    
/**
 * CONSTRUCTOR
**/

    global EmailParcelFactory( SObject[] objs ){
        this.objs = objs;
    }

    global EmailParcelFactory( Messaging.InboundEmail[] inboundEmails ){
        this.inboundEmails = inboundEmails;
    }

/**
 * ACTION METHODS
**/

    /**
     * @name build
     * @description creates email parcels from sObjects
     * @param none
     * @return void
    **/
    global void build(){
        build( objs );
        build( inboundEmails );
    }

    /**
     * @name build
     * @description creates email parcels from sObjects. This will be extended by sub classes. e.g. if you want a factory
     * for Cases create EmailParcelFactoryCase.cls
     * @param SObject[] objs
     * @return void
    **/
    global virtual void build( SObject[] objs ){

    }

    /**
     * @name build
     * @description creates email parcels from InboundEmails
     * @param Messaging.InboundEmail[] emails 
     * @return void
    **/
    global void build( Messaging.InboundEmail[] emails ){

        for( Messaging.InboundEmail email : emails ){
            EmailParcel parcel = new EmailParcel();

            for( String address : email.ToAddresses ){
                parcel.toAddresses.add(address);
            }

            if( email.CcAddresses != null ){

                for( String address : email.CcAddresses ){
                    parcel.ccAddresses.add(address);
                }
            }

            parcel.FromAddress = email.FromAddress;
            parcel.FromName = email.FromName;
            
            parcel.setContent(
                email.Subject, 
                email.HtmlBody, 
                email.PlainTextBody
            );

            if( email.binaryAttachments != null ){
                for( Messaging.InboundEmail.BinaryAttachment attachment : email.binaryAttachments ){
                    parcel.setAttachment( attachment.filename, attachment.body );
                }
            }

            if( email.textAttachments != null ){
                for( Messaging.InboundEmail.TextAttachment attachment : email.textAttachments ){
                    parcel.setAttachment( attachment.filename, attachment.body );
                }
            }

            parcel.whatId = relatedToId;
            parcel.messageId = email.messageId;
            parcel.inReplyTo = email.inReplyTo;

            parcels.add( parcel );
        }
    }

    /**
     * @name transorm
     * @description takes parcels and adds property values to them if need be
     * @param EmailParcel[] existingpParcels
     * @return void
    **/
    global virtual void transorm( EmailParcel[] existingpParcels ){

        for( EmailParcel parcel : existingpParcels ){
            parcel.template = template;
            parcel.oweAddressId = oweAddressId;
        }
    }

    /**
     * @name getParcels
     * @description returns parcels
     * @return EmailParcel[]
    **/
    global EmailParcel[] getParcels(){
        return parcels;
    }

/**
 * UTILITY METHODS
**/ 
    
    /**
     * @name hasParcels
     * @description returns true if this class has found email address
     * @return Boolean
    **/
    global Boolean hasParcels(){
        return !parcels.isEmpty();
    }

    /**
     * @name setTemplate
     * @description sets Email Template filtered by developerName
     * @param String name
     * @return void
    **/
    global void setTemplate( String name ){
        template = EmailAppUtil.getTemplate( name );
    }

    /**
     * @name setOrgWideEmailAddressId
     * @description sets Org Wide Email Address for From Address
     * @param String address
    **/
    global void setOrgWideEmailAddressId( String addressName ){
        OrgWideEmailAddress oweAddress = EmailAppUtil.getOrgWideEmailAddress( addressName );

        if( oweAddress != null ){
            oweAddressId = oweAddress.Id;
        }
    }

     /**
     * @name addAttachmentByName
     * @description adds an  attachment id by a particular key value
     * @param String filename
     * @param String base64Body
     * @param String key
     * @return void
    **/
    global virtual void addAttachmentByName( String key, ContentVersion version ){
        AttachmentData attachment = new AttachmentData( version );

        if( attachmentsByName.containsKey(key) ){
            attachmentsByName.get(key).add(attachment);
        } else {
            attachmentsByName.put(key, new AttachmentData[]{attachment});
        }
    }

    /**
     * @name addVersionIdsByName
     * @description loops a list of versions and deconstructs it into raw attachment data
     * @param ContentVersion[] versions
     * @return void
    **/
    global virtual void addAttachmentsByName( ContentVersion[] versions ){

        for( ContentVersion version : versions ){
            addAttachmentByName( version.Title, version );
        }
    }

    /**
     * @name addVersionIdByName
     * @description adds a version id by a particular key value
     * @param ContentVersion version
     * @return void
    **/
    global void addVersionIdByName( String key, ContentVersion version ){

        if( versionIdsByName.containsKey(key) ){
            versionIdsByName.get(key).add(version.Id);
        } else {
            versionIdsByName.put(key, new String[]{version.Id});
        }
    }

    /**
     * @name addVersionIdsByName
     * @description loops a list and adds a verion id by a particular key value this is overrideable
     * so that a sub class can name a different key
     * @param ContentVersion[] versions
     * @return void
    **/
    global virtual void addVersionIdsByName( ContentVersion[] versions ){

        for( ContentVersion version : versions ){
            addVersionIdByName( version.Title, version );
        }
    }



/**
 * CLASSES
**/

    // To convert ContentVersion to raw data. This was done to avoid sharing limits. Files can only be shared 2000 times 
    // and the use in an email counts as a 'share'

    global class AttachmentData {

        global ContentVersion version {get;set;}

        // DEPRECATED can be deleted ANYTIME AFTER 9/19/2022
        global String filename {get;set;}
        global Blob blobBody {get;set;}

        global AttachmentData( ContentVersion version ){
            this.version = version;
        }

         // DEPRECATED can be deleted ANYTIME AFTER 9/19/2022
        global AttachmentData( String filename, Blob blobBody ){
            this.filename = filename;
            this.blobBody = blobBody;
        }

        global String getFileName(){
            return version.PathOnClient;
        }

        global Blob getBlobBody(){
            return version.VersionData;
        }
    }

/**
 * DEPRECTATED METHODS: CAN BE DELETED ANYTIME AFTER 9/19/2022
 */

    /**
     * @name addAttachmentByName
     * @description adds an  attachment id by a particular key value
     * @param String filename
     * @param String base64Body
     * @param String key
     * @return void
    **/
    global virtual void addAttachmentByName( String filename, Blob blobBody, String key ){
        AttachmentData attachment = new AttachmentData( filename, blobBody );

        if( attachmentsByName.containsKey(key) ){
            attachmentsByName.get(key).add(attachment);
        } else {
            attachmentsByName.put(key, new AttachmentData[]{attachment});
        }
    }

    /**
     * @name addVersionIdByName
     * @description adds a version id by a particular key value
     * @param ContentVersion version
     * @return void
    **/
    global void addVersionIdByName( ContentVersion version, String key ){

        if( versionIdsByName.containsKey(key) ){
            versionIdsByName.get(key).add(version.Id);
        } else {
            versionIdsByName.put(key, new String[]{version.Id});
        }
    }
}