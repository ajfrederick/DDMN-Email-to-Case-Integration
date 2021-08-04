/**
 * @name EmailMessageHelper
 * @description Helper class for EmailMessage Trigger
**/
public class EmailMessageHelper {

    public static AttachmentCreator attachmentCreatorForTrigger {get;set;}

/**
 * TIGGER METHODS
**/

    /**
     * @name updateContentDocumentLinks
     * @description called by EmailMessageTrigger after insert. This is because you have to save attachments for outbound messages
     * as ContentVersions before you send the email. These ContentVersion's get linked only to the User that sends them and not
     * the EmailMessage record that gets saved in the database. As a result we need to do that ourselves.
     * @param EmailMessage[] messages
     * @return void
    **/
    public static void updateContentDocumentLinks( EmailMessage[] messages ){
        
        if( Test.isRunningTest() ){
            attachmentCreatorForTrigger = null;
            return;
        }

        if( attachmentCreatorForTrigger == null ) return;

        attachmentCreatorForTrigger.insertContentDocumentLinks( messages );

        attachmentCreatorForTrigger = null;
    }
}
