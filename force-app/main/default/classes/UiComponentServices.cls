/**
 * @name UiComponentServices
 * @description this class is for all emailMessageFeed lwc component server calls
**/
public class UiComponentServices {

    public static AttachmentCreator attachmentCreatorForTrigger {get;set;}

/**
 * LWC MEHTODS
**/

    /**
     * @name getData
     * @description this is the first UI component call which send the UI back custom data that it can interact with
     * @param Id recordId
     * @return String {JSON}
    **/
    @AuraEnabled
    public static String getData( Id recordId ){
        if( String.IsBlank( recordId ) ) throw new AuraHandledException('In order to get Email Messages for this record an Id is required');
    
        FeedData feedData = new FeedData();

        try {
            
            // get all email messages related to record
            feedData.messages.addAll( getEmailMessages( recordId ) );

            setMessageRelations( feedData );
            setAttachements( feedData );

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return JSON.serialize(FeedData);
    }

    /**
     * @name getReply
     * @description this returns a predicatbly formatted object, formatted as an EmailInfo Object, when a user clicks reply
     * it sets only one To Address
     * @param String replyToMessageJSON
     * @return String {JSON}
    **/
    @AuraEnabled
    public static String getReply( String replyToMessageJSON ){
        EmailMessage message;

        try {   
            message = (EmailMessage) JSON.deserialize( replyToMessageJSON, EmailMessage.Class );
        } catch( Exception e ){
            throw new AuraHandledException(e.getMessage());
        }

        EmailInfo wrapper = getWrapper( message );

        return JSON.serialize( wrapper );
    }

    /**
     * @name sendEmailMessage
     * @description sends a reply message which was formatted by the above methods
     * @param EmailInfo message
     * @return String {JSON}
    **/
    @AuraEnabled
    public static String sendEmailMessage( String JSONnewMessageData ){
        if( JSONnewMessageData == null ) throw new AuraHandledException('Cannot send a null message');

        NewMessageData newMessageData = (NewMessageData) JSON.deserialize( JSONnewMessageData, NewMessageData.class );

        EmailInfo wrapper = newMessageData.message;

        try {

            for( NewMessageAttachmentData attachment : newMessageData.attachments ){
                wrapper.setAttachement( attachment.base64, attachment.Title );
            }

            EmailInfo[] wrappers = new EmailInfo[]{wrapper};

            // insert our attachments since we have before we set messages so SingleEmailMessage can access the ContentVersionIds
            AttachmentCreatorOutbound attachmentCreator = new AttachmentCreatorOutbound( wrappers );
            attachmentCreator.insertAttachments();

            // instatiate a message creator, set option, set contentversionids for attatchments and 
            // set messages which unpacks wrapper info into Messaging.SingleEmailMessage
            MessageCreatorOutbound messageCreator = new MessageCreatorOutbound( wrappers );
            messageCreator.setOrgWideEmailAddressId( Constants.FROM_ADDRESS );
            messageCreator.setContentVersionIds( attachmentCreator.getContentVersionIds() );
            messageCreator.setMessages();

            // since the EmailMessage gets created asyncronously after sending the SingleMessage
            // let's store the object in a static variable to access when the EmailMessage trigger gets
            // fired on insert. There we will do the work of creating the necessary ContentDocumentLinks
            // to link the attachment to the EmailMessage. There this variable will get set to null afterward.
            attachmentCreatorForTrigger = attachmentCreator;

            // send the emails
            MessageHandler handler = new MessageHandler();
            handler.handle( messageCreator );

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return getData( wrapper.whatId );
    }

    /**
     * @name sendEmailMessage
     * @description returns a list of users and contacts for adding emails addresses
     * @param String searchString
     * @return SObject[]
    **/
    @AuraEnabled
    public static SObject[] searchRecipients( String searchString, String[] emails ){
        if( String.isBlank( searchString ) ) return null;

        String search = '%' + String.escapeSingleQuotes(searchString) + '%';

        String[] escapedEmails = new String[]{};
                
        for( String email : emails ){
            escapedEmails.add( String.escapeSingleQuotes(email) );
        }

        List<List<SObject>> searchResults = [FIND :search 
                                                IN ALL FIELDS 
                                                RETURNING
                                                    Contact(
                                                        Id, 
                                                        FirstName, 
                                                        LastName, 
                                                        Email 
                                                            WHERE Email != :Constants.FROM_ADDRESS
                                                            AND Email NOT IN :emails
                                                    ),
                                                    User(
                                                        Id, 
                                                        FirstName, 
                                                        LastName, 
                                                        Email 
                                                            WHERE Email != :Constants.FROM_ADDRESS
                                                            AND Email NOT IN :emails
                                                    )];
        
        SObject[] ret = new SObject[]{};

        for( SObject[] objs : searchResults ){
            for( SObject obj : objs ){
                ret.add( obj );
            }
        }

        return ret;
    }

/**
 * UTILITY MEHTODS
**/

    

    /**
     * @name setMessageRelations
     * @description set message relations (User/Contact records) on return object to lwc
     * @param FeedData FeedData 
     * @return void
    **/
    private static void setMessageRelations( FeedData feedData ){
        Set<Id> relationIds = new Set<Id>();

        // loop through them to harvest any Ids that will be relates to a user or contact that a message has been
        // recieved from or sent to
        for( EmailMessage message : feedData.messages ){
            for( EmailMessageRelation relation : message.EmailMessageRelations ){
                relationIds.add( relation.relationId );
            }
        }

        // instatiate a list and query records
        SObject[] relations = new SObject[]{};
        relations.addAll( getContacts( relationIds ) );
        relations.addAll( getUsers( relationIds ) );

        // put all those records in the map on FeedData
        for( SObject relation : relations ){
            feedData.relationsById.put( relation.Id, relation );
        }
    }

    /**
     * @name setAttachements
     * @description set attachments on returned FeedData object to lwc app
     * @param FeedData FeedData 
     * @return void
    **/
    private static void setAttachements( FeedData feedData ){
        Set<Id> docIds = new Set<Id>();

        // loop through messages to harvest ContentDocumentIds for query
        for( EmailMessage message : feedData.messages ){
            docIds.addAll( message.ContentDocumentIds );
        }

        ContentVersion[] fileVersions = getFileVersions(docIds);

        Map<Id, ContentVersion> fileVersionsByDocumentId = new Map<Id, ContentVersion>();

        for( ContentVersion fileVersion : fileVersions ){
            fileVersionsByDocumentId.put( fileVersion.ContentDocumentId, fileVersion );
        }
        
        for( EmailMessage message : feedData.messages ){

            for( Id docId : message.ContentDocumentIds ){
                ContentVersion fileVersion;

                if( fileVersionsByDocumentId.containsKey(DocId) ){
                    fileVersion = fileVersionsByDocumentId.get(DocId);
                }

                if( fileVersion == null ) continue;
System.debug(fileVersion);
                if( feedData.attachmentsByMessageId.containsKey(message.Id) ){
                    feedData.attachmentsByMessageId.get( message.Id ).add( fileVersion );
                } else {
                    feedData.attachmentsByMessageId.put( message.Id, new ContentVersion[]{fileVersion} );
                }
            }
        }
    }

    /**
     * @name getWrapper
     * @description returns an EmailInfo object for reply and replyAll methods
     * @param EmailMessage message 
     * @return EmailInfo
    **/
    public static EmailInfo getWrapper( EmailMessage message ){
        EmailInfo wrapper = new EmailInfo();

        try {

            OrgWideEmailAddress oweAddress = Utils.getOrgWideEmailAddress( Constants.FROM_ADDRESS );
            
            wrapper.whatId = message.ParentId;
            wrapper.FromAddress = oweAddress.Address;
            wrapper.FromName = oweAddress.DisplayName;
            wrapper.setContent( message.Subject, '', '');
            wrapper.inReplyTo = message.MessageIdentifier;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return wrapper;
    }

/**
 * QUERY UTILITIES
 */

    /**
     * @name getEmailMessages
     * @description queries all messages and their relations (for contact and user record linkage)
     * @param Id recordId
     * @return EmailMessage[]
    **/
    private static EmailMessage[] getEmailMessages( Id recordId ){
        EmailMessage[] messages = new EmailMessage[]{};

        try {

            messages.addAll([SELECT
                Id,
                ToAddress,
                CcAddress,
                BccAddress,
                FromAddress,
                FromName,
                Subject,
                TextBody,
                HtmlBody,
                ParentId,
                Incoming,
                MessageIdentifier,
                MessageDate,
                ContentDocumentIds,
                (SELECT
                    Id,
                    RelationId,
                    RelationAddress,
                    RelationType,
                    RelationObjectType
                        FROM EmailMessageRelations)
                    FROM EmailMessage
                    WHERE ParentId = :recordId
                    ORDER BY MessageDate desc]);

        } catch( Exception e ){
            ExceptionHandler handler = new ExceptionHandler( e );
            handler.debug();
        }
        
        return messages;
    }

    /**
     * @name getContacts
     * @description queries all contacts that may be associated with an email address in a message
     * @param Set<Id> contactIds 
     * @return Contacts[]
    **/
    private static Contact[] getContacts( Set<Id> contactIds ){
        if( contactIds == null || contactIds.isEmpty() ) return new Contact[]{};

        return [SELECT
                Id,
                FirstName,
                LastName,
                Email
                    FROM Contact
                    WHERE Id IN :contactIds];
    }

    /**
     * @name getUsers
     * @description queries all usres that may be associated with an email address in a message
     * @param Set<Id> userIds 
     * @return User[]
    **/
    private static User[] getUsers( Set<Id> userIds ){
        if( userIds == null || userIds.isEmpty() ) return new User[]{};

        return [SELECT
                Id,
                FirstName,
                LastName,
                Email
                    FROM User
                    WHERE Id IN :userIds];
    }

    /**
     * @name getFileVersions
     * @description gets on ContentVersion (files) that are saved which serve as attachments to email messages
     * @param Set<Id> docIds
     * @return ContentVerion[]
    **/
    private static ContentVersion[] getFileVersions( Set<Id> docIds ){
        if( docIds == null || docIds.isEmpty() ) return new ContentVersion[]{};

        return [SELECT
                Id,
                Title,
                FileExtension,
                ContentDocumentId
                    FROM ContentVersion
                    WHERE ContentDocumentId IN :docIds];
    }

/**
 * CLASSES
**/

    // wrapper class that gets serialized into JSON for first main UI call that looks for all the message data for a record
    public class FeedData {

        public EmailMessage[] messages {
            get {
                if( messages == null ) messages = new EmailMessage[]{};
                return messages;
            }
            set;
        }

        public Map<Id, SObject> relationsById {
            get {
                if( relationsById == null ) relationsById = new Map<Id, SObject>();
                return relationsById;
            }
            set;
        }

        public Map<Id, ContentVersion[]> attachmentsByMessageId {
            get {
                if( attachmentsByMessageId == null ) attachmentsByMessageId = new Map<Id, ContentVersion[]>();
                return attachmentsByMessageId;
            }
            set;
        }
    }

    public class NewMessageData {
        public EmailInfo message {get;set;}
        public NewMessageAttachmentData[] attachments {get;set;}
    }

    public class NewMessageAttachmentData {
        public String Title {get;set;}
        public String base64 {get;set;}
        public String FileExtension {get;set;}
    }
}