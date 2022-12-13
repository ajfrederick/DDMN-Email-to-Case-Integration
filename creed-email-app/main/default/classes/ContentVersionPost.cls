/**
 * @name ContentVersionPost
 * @description this base class helps create and insert ContentVersions (files) for outgoing and incoming emails
 */
global abstract class ContentVersionPost {

/**
 * FIELDS
 */

    // Class parcels that contain email to info
    global EmailParcel[] parcels {get;set;}

    private ContentVersion[] versions {
        get {
            if( versions == null ) versions = new ContentVersion[]{};
            return versions;
        }
        set;
    }

    private  Map<String, ContentVersion[]> versionsByMessageId {
        get {
            if( versionsByMessageId == null ) versionsByMessageId = new Map<String, ContentVersion[]>();
            return versionsByMessageId;
        }
        set;
    }

    // used for when it's necessary to save one content version for many emails
    global Boolean useFirstForAllMessages {
        get {
            if( useFirstForAllMessages == null ) useFirstForAllMessages = false;
            return useFirstForAllMessages;
        }
        set;
    }

/**
 * CONSTRUCTOR
 */

    global ContentVersionPost( EmailParcel[] parcels ) {
        this.parcels = parcels;
    }

/**
 * ABSTACT METHODS
 */ 

    /**
     * @name getMessageId
     * @description returns an external email message Id for postContentDocumentLinks method
     * @param EmailMessage message
     * @return String
     */
    global abstract String getMessageId( EmailMessage message );

    /**
     * @name getMessageId
     * @description returns an external email message Id for postContentDocumentLinks method
     * @param EmailParcel parcel
     * @return String
     */
    global abstract String getMessageId( EmailParcel parcel );

/**
 * ACTION METHODS
 */ 

    /**
     * @name post
     * @description inserts the Email attachments as ContentVersion and then creates the necessary ContentDocumentLinks
     * for incoming messages
     * @param none
     * @return void
     */
    global void post(){

        for( EmailParcel parcel : parcels ){
            String messageId = getMessageId( parcel );

            if( useFirstForAllMessages ){
                setFirstForAllMessages( parcel, messageId );
            } else {
                setContentVersions( parcel, messageId );
            }
        }

        try {

            insert versions;

        } catch( Exception e ){
            CreedExceptionHandler handler = new CreedExceptionHandler(e);
            handler.handle();
        }

        setVerionIdsOnparcels();
    }

    /**
     * @name postContentDocumentLinks
     * @description creates ContentDocumentLinks that link content documents to EmailMessage. Gets called in email message trigger
     * after the messages have been sent
     * @param EmailMessage[] messages
     * @return void
    **/
    global void postContentDocumentLinks( EmailMessage[] messages ){
        if( messages == null || messages.isEmpty() || versionsByMessageId.isEmpty() ) return;

        // put the fresh list of versions in a map keyed on their Id to access below
        Map<Id, ContentVersion> versionsById = refreshContentVersions();

        ContentDocumentLink[] links = new ContentDocumentLink[]{};

        // Loop throught the messages once more to create the ContentDocumentLinks which link the ContentDocument
        // from the ContentVersion to the EmailMessage
        for( EmailMessage message : messages ){

            // the MessageIdentifier Field is not an interanl SF Id it's an external identifier assigned by an email client
            String messageId = getMessageId( message );

            if( !versionsByMessageId.containsKey(messageId) ) continue;

            for( ContentVersion ver : versionsByMessageId.get(messageId) ){
                // grab fresh copy of version that contains the ContentDocumentId
                ContentVersion version = versionsById.get(ver.Id);

                links.add( getContentDocumentLink( message, version ) );
            }
        }

        try {

            insert links;

        } catch( Exception e ){
            CreedExceptionHandler handler = new CreedExceptionHandler(e);
            handler.handle();
        }
    }

/**
 * UTILITY METHODS
 */ 

    /**
     * @name setContentVersions
     * @description sets a single or single set of content verions (attachments) for many emails
     * @param EmailParcel parcel
     * @param String messageId
     * @return void
     */
    private void setContentVersions( EmailParcel parcel, String messageId ){

        for( EmailParcel.AttachmentData attachment : parcel.attachments ){
            ContentVersion version = getContentVersion(attachment);

            if( versionsByMessageId.containsKey( messageId ) ){
                versionsByMessageId.get(messageId).add(version);
            } else {
                versionsByMessageId.put( messageId, new ContentVersion[]{version} );
            }

            versions.add(version);
        }

        /**
         * clear attachement data so that the EmailFacotry only uses the ContentVersion (file) created here.
         * If we don't clear it the message creator will read the attachments list and creat an attachment that isn't
         * saved as a file and essentially send two of every attachment because of the files created in this class.
         */
        parcel.attachments.clear();
    }

    /**
     * @name setFirstForAllMessages
     * @description sets a single or single set of content verions (attachments) for many emails
     * @param EmailParcel parcel
     * @param String messageId
     * @return void
     */
    private void setFirstForAllMessages( EmailParcel parcel, String messageId ){

        if( versions.size() == 0 ){
            setContentVersions( parcel, messageId );
        } else {
            versionsByMessageId.put( messageId, versions );
        }
    }

     /**
     * @name setVerionIdsOnparcels
     * @description set files on parcel to be accessed by MessageCreator
     * @param none
     * @return none
     */
    private void setVerionIdsOnparcels(){

        for( EmailParcel parcel : parcels ){
            String messageId = getMessageId( parcel );

            if( versionsByMessageId.containsKey(messageId) ){

                for( ContentVersion version : versionsByMessageId.get(messageId) ){
                    parcel.addVersionId( version.Id );
                }
            }
        }
    }

/**
 * 'GETTER' METHODS
 */ 

    /**
     * @name getContentVersions
     * @description returns all versions that where created. Used in creating outbound messages
     * @return ContentVersion[]
     */
    global ContentVersion[] getContentVersions(){
        return versions;
    }

    /**
     * @name getVersionIds
     * @description returns all version Ids that where created. Used in creating outbound messages.
     * return must be String[] because the method for setting attachments on outgoing SingleEmailMessages takes 
     * type String[] as an argument
     * @return String[]
     */
    global String[] getVersionIds(){
        String[] ids = new String[]{};

        for( ContentVersion version : versions ){
            ids.add(version.Id);
        }

        return ids;
    }

    /**
     * @name getVersionIdsByMessageId
     * @description returns all version Ids that where created by the external messageId
     * @return Map<String, String[]>
     */
    global Map<String, String[]> getVersionIdsByMessageId(){
        Map<String, String[]> versionIdsByMessageId = new Map<String, String[]>();

        for( String messageId : versionsByMessageId.keyset() ){

            for( ContentVersion version : versionsByMessageId.get(messageId) ){

                if( versionIdsByMessageId.containsKey(messageId) ){
                    versionIdsByMessageId.get(messageId).add(version.Id);
                } else {
                    versionIdsByMessageId.put( messageId, new String[]{version.Id} );
                }
            }
        }

        return versionIdsByMessageId;
    }

    /**
     * @name getContentVersion
     * @description returns a predicatably formatted ContentVersion
     * @param EmailParcel.AttachmentData attachment 
     * @return ContentVersion
     */
    private ContentVersion getContentVersion( EmailParcel.AttachmentData attachment ){
        return new ContentVersion(
            Title = attachment.fileName,
            PathOnClient = attachment.fileName,
            VersionData = attachment.body,
            ContentLocation = 'S'
        );
    }

    /**
     * @name getContentDocumentLink
     * @description returns a predicatably formatted ContentDocumentLink
     * @param EmailMessage message
     * @param ContentVersion version
     * @return ContentDocumentLink
     */
    private ContentDocumentLink getContentDocumentLink( EmailMessage message, ContentVersion version ){
        return new ContentDocumentLink(
            LinkedEntityId = message.Id,
            ContentDocumentId = version.ContentDocumentId,
            ShareType = 'V'
        );
    }

/**
 * QUERY METHODS
 */

    /**
     * @name refreshContentVersions
     * @description simply to get the ContentDocumentId that gets populated after insert.
     * also does the work of putting them in a map keyed on Id
     * @return Map<Id, ContentVersion>
    **/
    private Map<Id, ContentVersion> refreshContentVersions(){
        if(versions.isEmpty()) return new Map<Id, ContentVersion>();

        // get all the Ids to query for fresh copy of versions to access the newly created ContentDocumentId
        Set<Id> versionIds = new Map<Id, ContentVersion>(versions).keyset();

        // the ContentDocumentId is the Id of the ContentDocument that is created when a content version is created
        try {

            versions = [SELECT 
                Id,
                Title,
                PathOnClient,
                VersionData,
                ContentDocumentId 
                    FROM ContentVersion 
                    WHERE Id IN :versionIds];

        } catch( Exception e ){
            CreedExceptionHandler handler = new CreedExceptionHandler(e);
            handler.handle();
        }

        // put the fresh list of versions in a map keyed on their Id to access below
        return new Map<Id, ContentVersion>(versions);
    }
}