/**
 * @name AttachmentCreator
 * @description this base class helps create and insert attachments for outgoing and incoming emails
 */
public abstract class AttachmentCreator {

/**
 * FIELDS
 */

    // Class containers that contain email to info
    protected EmailContainer[] containers {get;set;}

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
    public Boolean useFirstAttachmentsForAllMessages {
        get {
            if( useFirstAttachmentsForAllMessages == null ) useFirstAttachmentsForAllMessages = false;
            return useFirstAttachmentsForAllMessages;
        }
        set;
    }

/**
 * CONSTRUCTOR
 */

    public AttachmentCreator( EmailContainer[] ws ) {
        containers = ws;
    }

/**
 * ACTION METHODS
 */ 
    /**
     * @name getMessageId
     * @description returns an external email message Id for insertContentDocumentLinks method
     * @param EmailMessage message
     * @return String
     */
    protected abstract String getMessageId( EmailMessage message );

    /**
     * @name getMessageId
     * @description returns an external email message Id for insertContentDocumentLinks method
     * @param EmailContainer container
     * @return String
     */
    protected abstract String getMessageId( EmailContainer container );

    /**
     * @name insertAttachments
     * @description inserts the Email attachments as ContentVersion and then creates the necessary ContentDocumentLinks
     * for incoming messages
     * @param EmailContainer containers
     * @return void
     */
    public void insertAttachments(){

        for( EmailContainer container : containers ){
            String messageId = getMessageId( container );

            if( useFirstAttachmentsForAllMessages ){
                setVersionsForAllMessages( container, messageId );
            } else {
                setVersions( container, messageId );
            }
        }

        try {

            insert versions;

        } catch( Exception e ){
            CreedExceptionHandler handler = new CreedExceptionHandler(e);
            handler.handle();
        }

        setVerionIdsOnContainers();
    }

    /**
     * @name insertContentDocumentLinks
     * @description creates ContentDocumentLinks that link content documents to EmailMessage. Gets called in email message trigger
     * after the messages have been sent
     * @param EmailMessage[] messages
     * @return void
    **/
    public void insertContentDocumentLinks( EmailMessage[] messages ){
        if( versionsByMessageId.isEmpty() ) return;

        // put the fresh list of versions in a map keyed on their Id to access below
        Map<Id, ContentVersion> versionsById = refreshVersions();

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
     * @name setVersions
     * @description sets a single or single set of content verions (attachments) for many emails
     * @param EmailContainer container
     * @param String messageId
     * @return void
     */
    private void setVersions( EmailContainer container, String messageId ){

        for( EmailContainer.AttachmentData attachment : container.attachments ){
            ContentVersion version = getContentVersion(attachment);

            if( versionsByMessageId.containsKey( messageId ) ){
                versionsByMessageId.get(messageId).add(version);
            } else {
                versionsByMessageId.put( messageId, new ContentVersion[]{version} );
            }

            versions.add(version);
        }

        /**
         * clear attachement data so that message creator only uses the ContentVersion (file) created here.
         * If we don't clear it the message creator will read the attachments list and creat an attachment that isn't
         * saved as a file and essentially send two of every attachment because of the files created in this class.
         */
        container.attachments.clear();
    }

    /**
     * @name setVersionsForAllMessages
     * @description sets a single or single set of content verions (attachments) for many emails
     * @param EmailContainer container
     * @param String messageId
     * @return void
     */
    private void setVersionsForAllMessages( EmailContainer container, String messageId ){

        if( versions.size() == 0 ){
            setVersions( container, messageId );
        } else {
            versionsByMessageId.put( messageId, versions );
        }
    }

    /**
     * @name getContentVersions
     * @description returns all versions that where created. Used in creating outbound messages
     * @return ContentVersion[]
     */
    public ContentVersion[] getContentVersions(){
        return versions;
    }

    /**
     * @name getContentVersionIds
     * @description returns all version Ids that where created. Used in creating outbound messages.
     * return must be String[] because the method for setting attachments on outgoing SingleEmailMessages takes 
     * type String[] as an argument
     * @return String[]
     */
    public String[] getContentVersionIds(){
        String[] ids = new String[]{};

        for( ContentVersion version : versions ){
            ids.add(version.Id);
        }

        return ids;
    }

    /**
     * @name getContentVersionIdsByMessageId
     * @description returns all version Ids that where created by the external messageId
     * @return Map<String, String[]>
     */
    public Map<String, String[]> getContentVersionIdsByMessageId(){
        Map<String, String[]> contentVersionIdsByMessageId = new Map<String, String[]>();

        for( String messageId : versionsByMessageId.keyset() ){

            for( ContentVersion version : versionsByMessageId.get(messageId) ){

                if( contentVersionIdsByMessageId.containsKey(messageId) ){
                    contentVersionIdsByMessageId.get(messageId).add(version.Id);
                } else {
                    contentVersionIdsByMessageId.put( messageId, new String[]{version.Id} );
                }
            }
        }

        return contentVersionIdsByMessageId;
    }

    /**
     * @name getContentVersion
     * @description returns a predicatably formatted ContentVersion
     * @param EmailContainer.AttachmentData attachment 
     * @return ContentVersion
     */
    private ContentVersion getContentVersion( EmailContainer.AttachmentData attachment ){
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
     * @name setVerionIdsOnContainers
     * @description set files on container to be accessed by MessageCreator
     * @param none
     * @return none
     */
    private void setVerionIdsOnContainers(){

        for( EmailContainer container : containers ){
            String messageId = getMessageId( container );

            if( versionsByMessageId.containsKey(messageId) ){

                for( ContentVersion version : versionsByMessageId.get(messageId) ){
                    container.addVersionId( version.Id );
                }
            }
        }
    }

/**
 * QUERY METHODS
 */

    /**
     * @name refreshVersions
     * @description simply to get the ContentDocumentId that gets populated after insert.
     * also does the work of putting them in a map keyed on Id
     * @return Map<Id, ContentVersion>
    **/
    private Map<Id, ContentVersion> refreshVersions(){
        if(versions.isEmpty()) return new Map<Id, ContentVersion>();

        // get all the Ids to query for fresh copy of versions to access the newly created ContentDocumentId
        Set<Id> versionIds = new Map<Id, ContentVersion>(versions).keyset();

        // the ContentDocumentId is the Id of the ContentDocument that is created when a content version is created
        versions = [SELECT 
                        Id,
                        Title,
                        PathOnClient,
                        VersionData,
                        ContentDocumentId 
                            FROM ContentVersion 
                            WHERE Id IN :versionIds];

        // put the fresh list of versions in a map keyed on their Id to access below
        return new Map<Id, ContentVersion>(versions);
    }
}