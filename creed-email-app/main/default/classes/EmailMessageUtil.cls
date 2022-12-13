/**
 * @name EmailMessageUtil
 * @description Helper class for EmailMessageTrigger
**/
global class EmailMessageUtil {

    global static ContentVersionPost versionPost {get;set;}

    global static TriggerHook[] hooks {
        get {
            if( hooks == null ) hooks = new TriggerHook[]{};
            return hooks;
        }
        set;
    }

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
    global static void updateContentDocumentLinks( EmailMessage[] messages ){
        
        if( Test.isRunningTest() || versionPost == null ){
            versionPost = null;
            return;
        }

        versionPost.postContentDocumentLinks( messages );

        versionPost = null;
    }
}