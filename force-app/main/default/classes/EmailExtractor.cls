/**
 * @name EmailExtractor
 * @description gets proper email info from object for email message. Abstract so you can define
 * the process of getting email addresses for different Objects
**/
public virtual class EmailExtractor {

/**
 * FIELDS
**/

    protected EmailInfo[] wrappers {
        get {
            if( wrappers == null ) wrappers = new EmailInfo[]{};
            return wrappers;
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
        String toAddress = System.Label.Connect_Team_From_Email_Address;

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
}
