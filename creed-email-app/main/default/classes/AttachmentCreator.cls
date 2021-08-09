/**
 * @name AttachmentCreator
 * @description this base class helps create and insert attachments for outgoing and incoming emails
 */
public abstract class AttachmentCreator {

/**
 * FIELDS
 */

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

    // Class Wrappers that contain email to info
    protected EmailInfo[] wrappers {get;set;}

    // used for when it's necessary to save one content version for many emails
    public Boolean useFirstAttachementsForAllMessages {
        get {
            if( useFirstAttachementsForAllMessages == null ) useFirstAttachementsForAllMessages = false;
            return useFirstAttachementsForAllMessages;
        }
        set;
    }

/**
 * CONSTRUCTOR
 */

    public AttachmentCreator( EmailInfo[] ws ) {
        wrappers = ws;
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
     * @param EmailInfo wrapper
     * @return String
     */
    protected abstract String getMessageId( EmailInfo wrapper );

    /**
     * @name insertAttachments
     * @description inserts the Email attachments as ContentVersion and then creates the necessary ContentDocumentLinks
     * for incoming messages
     * @param EmailInfo wrappers
     * @return void
     */
    public void insertAttachments(){

        for( EmailInfo wrapper : wrappers ){
            String messageId = getMessageId( wrapper );

            if( useFirstAttachementsForAllMessages ){
                setVersionsForAllMessages( wrapper, messageId );
            } else {
                setVersions( wrapper, messageId );
            }
        }

        try {

            insert versions;

        } catch( Exception e ){
            ExceptionHandler handler = new ExceptionHandler(e);
            handler.handle();
        }
    }

    /**
     * @name insertContentDocumentLinks
     * @description creates ContentDocumentLinks that link content documents to EmailMessage
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
            ExceptionHandler handler = new ExceptionHandler(e);
            handler.handle();
        }
    }

/**
 * UTILITY METHODS
 */ 
    /**
     * @name setVersions
     * @description sets a single or single set of content verions (attachments) for many emails
     * @param EmailInfo wrapper
     * @param String messageId
     * @return void
     */
    private void setVersions( EmailInfo wrapper, String messageId ){

        for( EmailInfo.AttachmentData attachment : wrapper.attachments ){
            ContentVersion version = getContentVersion(attachment);

            if( versionsByMessageId.containsKey( messageId ) ){
                versionsByMessageId.get(messageId).add(version);
            } else {
                versionsByMessageId.put( messageId, new ContentVersion[]{version} );
            }

            versions.add(version);
        }
    }

    /**
     * @name setVersionsForAllMessages
     * @description sets a single or single set of content verions (attachments) for many emails
     * @param EmailInfo wrapper
     * @param String messageId
     * @return void
     */
    private void setVersionsForAllMessages( EmailInfo wrapper, String messageId ){

        if( versions.size() == 0 ){
            setVersions( wrapper, messageId );
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
     * @name getContentVersion
     * @description returns a predicatably formatted ContentVersion
     * @param EmailInfo.AttachmentData attachment 
     * @return ContentVersion
     */
    private ContentVersion getContentVersion( EmailInfo.AttachmentData attachment ){
        return new ContentVersion(
            Title = attachment.Title,
            PathOnClient = attachment.Title,
            VersionData = attachment.VersionData,
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