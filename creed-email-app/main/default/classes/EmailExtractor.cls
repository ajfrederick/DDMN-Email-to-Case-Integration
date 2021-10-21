/**
 * @name EmailExtractor
 * @description gets proper email info from object for email message. Abstract so you can define
 * the process of getting email addresses for different Objects
**/
public virtual class EmailExtractor {

/**
 * FIELDS
**/

    // a list of central understandable ubiquitis wrappers for the whole email application. These get passed around and loaded up
    // with info and then unpacked
    protected EmailInfo[] wrappers {
        get {
            if( wrappers == null ) wrappers = new EmailInfo[]{};
            return wrappers;
        }
        set;
    }

    // attachment data to create ContentVersions (files)
    public AttachmentData[] attachments {
        get {
            if( attachments == null ) attachments = new AttachmentData[]{};
            return attachments;
        }
        set;
    }

    // to add ContentVersions (files) to wrapper that are already in the database and will be used to send an attachment
    public Map<String, String[]> versionIdsByTitle {
        get {
            if( versionIdsByTitle == null ) versionIdsByTitle = new Map<String, String[]>();
            return versionIdsByTitle;
        }
        set;
    }

    protected EmailTemplate template {get;set;}

    public Id relatedToId {get;set;}
    
/**
 * CONSTRUCTOR
**/

    public EmailExtractor(){
        
    }

    public EmailExtractor( EmailInfo[] ws ){
        wrappers = ws;
    }

/**
 * ACTION METHODS
**/

    /**
     * @name setWrappers
     * @description deconstructs email addresses from sObjects
     * @param SObject[] objs
     * @return void
    **/
    public virtual void setWrappers( SObject[] objs ){

    }

    /**
     * @name setWrappers
     * @description deconstructs email addresses from InboundEmails
     * @param Messaging.InboundEmail[] emails 
     * @return void
    **/
    public void setWrappers( Messaging.InboundEmail[] emails ){

        for( Messaging.InboundEmail email : emails ){
            EmailInfo wrapper = new EmailInfo();

            for( String address : email.ToAddresses ){
                wrapper.toAddresses.add(address);
            }

            if( email.CcAddresses != null ){

                for( String address : email.CcAddresses ){
                    wrapper.ccAddresses.add(address);
                }
            }

            wrapper.FromAddress = email.FromAddress;
            wrapper.FromName = email.FromName;
            
            wrapper.setContent(
                email.Subject, 
                email.HtmlBody, 
                email.PlainTextBody
            );

            if( email.binaryAttachments != null ){
                for( Messaging.InboundEmail.BinaryAttachment attachment : email.binaryAttachments ){
                    wrapper.setAttachement( attachment.body, attachment.filename );
                }
            }

            if( email.textAttachments != null ){
                for( Messaging.InboundEmail.TextAttachment attachment : email.textAttachments ){
                    wrapper.setAttachement( attachment.body, attachment.filename );
                }
            }

            wrapper.whatId = relatedToId;
            wrapper.messageId = email.messageId;
            wrapper.inReplyTo = email.inReplyTo;

            wrappers.add( wrapper );
        }
    }

    /**
     * @name getWrappers
     * @description returns wrappers
     * @return EmailInfo[]
    **/
    public EmailInfo[] getWrappers(){
        return wrappers;
    }

/**
 * UTILITY METHODS
**/ 
    
    /**
     * @name hasWrappers
     * @description returns true if this class has found email address
     * @return Boolean
    **/
    public Boolean hasWrappers(){
        return !wrappers.isEmpty();
    }

    /**
     * @name setTemplate
     * @description sets Email Template filtered by developerName
     * @param String name
     * @return void
    **/
    public void setTemplate( String name ){
        template = Utils.getTemplate( name );
    }

    /**
     * @name setTemplate
     * @description adds a verion id by it's name
     * @param ContentVersion version
     * @return void
    **/
    public void addVersionId( ContentVersion version ){
        String key = version.Title;

        if( versionIdsByTitle.containsKey(key) ){
            versionIdsByTitle.get(key).add(version.Id);
        } else {
            versionIdsByTitle.put(key, new String[]{version.Id});
        }
    }
}
