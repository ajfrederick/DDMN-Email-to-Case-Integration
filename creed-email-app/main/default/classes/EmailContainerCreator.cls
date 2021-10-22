/**
 * @name EmailContainerCreator
 * @description gets proper email info from object for email message. Abstract so you can define
 * the process of getting email addresses for different Objects
**/
public virtual class EmailContainerCreator {

/**
 * FIELDS
**/

    // a list of central understandable ubiquitis containers for the whole email application. These get passed around and loaded up
    // with info and then unpacked
    protected EmailContainer[] containers {
        get {
            if( containers == null ) containers = new EmailContainer[]{};
            return containers;
        }
        set;
    }

    // to add ContentVersions (files) to container that are already in the database and will be used to send an attachment
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

    public EmailContainerCreator(){
        
    }

    public EmailContainerCreator( EmailContainer[] ws ){
        containers = ws;
    }

/**
 * ACTION METHODS
**/

    /**
     * @name create
     * @description creates email containers from sObjects
     * @param SObject[] objs
     * @return void
    **/
    public virtual void create( SObject[] objs ){

    }

    /**
     * @name setContainers
     * @description creates email containers from from InboundEmails
     * @param Messaging.InboundEmail[] emails 
     * @return void
    **/
    public void create( Messaging.InboundEmail[] emails ){

        for( Messaging.InboundEmail email : emails ){
            EmailContainer container = new EmailContainer();

            for( String address : email.ToAddresses ){
                container.toAddresses.add(address);
            }

            if( email.CcAddresses != null ){

                for( String address : email.CcAddresses ){
                    container.ccAddresses.add(address);
                }
            }

            container.FromAddress = email.FromAddress;
            container.FromName = email.FromName;
            
            container.setContent(
                email.Subject, 
                email.HtmlBody, 
                email.PlainTextBody
            );

            if( email.binaryAttachments != null ){
                for( Messaging.InboundEmail.BinaryAttachment attachment : email.binaryAttachments ){
                    container.setAttachment( attachment.filename, attachment.body );
                }
            }

            if( email.textAttachments != null ){
                for( Messaging.InboundEmail.TextAttachment attachment : email.textAttachments ){
                    container.setAttachment( attachment.filename, attachment.body );
                }
            }

            container.whatId = relatedToId;
            container.messageId = email.messageId;
            container.inReplyTo = email.inReplyTo;

            containers.add( container );
        }
    }

    /**
     * @name getContainers
     * @description returns containers
     * @return EmailContainer[]
    **/
    public EmailContainer[] getContainers(){
        return containers;
    }

/**
 * UTILITY METHODS
**/ 
    
    /**
     * @name hasContainers
     * @description returns true if this class has found email address
     * @return Boolean
    **/
    public Boolean hasContainers(){
        return !containers.isEmpty();
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
     * @name addVersionId
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
