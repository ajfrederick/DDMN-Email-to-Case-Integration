/**
 * @name EmailInfo
 * @description wrapper class to get email content and info predictablyh no matter the source
**/
public class EmailInfo {

/**
 * FIELDS
**/

    // email to addresses
    public String[] ToAddresses {
        get {
            if( ToAddresses == null ) ToAddresses = new String[]{};
            return ToAddresses;
        }
        set;
    }

    // email cc addresses
    public String[] CcAddresses {
        get {
            if( CcAddresses == null ) CcAddresses = new String[]{};
            return CcAddresses;
        }
        set;
    }

    // email Bcc addresses
    public String[] BccAddresses {
        get {
            if( BccAddresses == null ) BccAddresses = new String[]{};
            return BccAddresses;
        }
        set;
    }

    // all addresses
    public String[] allAddresses {
        get {
            allAddresses = new String[]{};

            allAddresses.addAll( ToAddresses );
            allAddresses.addAll( CcAddresses );
            allAddresses.addAll( BccAddresses );

            return allAddresses;
        }
        set;
    }

    // email from address
    public String FromAddress {get;set;}

    // email from name
    public String FromName {get;set;}

    // email template
    public EmailTemplate template {get;set;}

    // email content
    public EmailContent content {get;set;}

    // optional record Id to be used for whatId
    public Id whatId {get;set;}

    // optional contact, user or lead Id to be used for whoId
    public Id whoId {get;set;}

    // external unique identifier given by email clients and salesforce email client
    public String messageId  {get;set;}

    // external unique identifier given by email clients and salesforce email client
    public String inReplyTo {get;set;}

    // attachments
    public AttachmentData[] attachments {
        get {
            if( attachments == null ) attachments = new AttachmentData[]{};
            return attachments;
        }
        set;
    }

/**
 * CONSTRUCTOR
**/

    public EmailInfo(){

    }

/**
 * ACTION METHODS
**/

    public void setContent( String Subject, String HtmlBody, String PlainTextBody ){
        EmailContent cont = new EmailContent();
        cont.Subject = Subject;
        cont.HtmlBody = HtmlBody;
        cont.PlainTextBody = PlainTextBody;

        content = cont;
    }

    public void setAttachement( Blob body, String filename ){
        attachments.add( new AttachmentData( body, filename ) );
    }

    public void setAttachement( String body, String filename ){
        Blob bodyBlob = EncodingUtil.base64Decode(body);

        attachments.add( new AttachmentData( bodyBlob, filename ) );
    }

/**
 * UTILITY METHODS
**/

    public Boolean hasToAddresses(){
        return !ToAddresses.isEmpty();
    }

    public Boolean hasTemplate(){
        return template != null;
    }

    public Boolean hasContent(){
        return content != null;
    }

    public Boolean hasWhatId(){
        return whatId != null;
    }

    public Boolean hasWhoId(){
        return whoId != null;
    }

    public Boolean hasMessageId(){
        return !String.isBlank( messageId );
    }

    public Boolean hasInReplyTo(){
        return !String.isBlank( inReplyTo );
    }

/**
 * CLASSES
**/
    public class EmailContent {
        public String Subject {get;set;}
        public String HtmlBody {get;set;}
        public String PlainTextBody {get;set;}
    }

    public class AttachmentData {
        public Blob VersionData {get;set;}
        public String Title {get;set;}

        public AttachmentData( Blob body, String filename ){
            VersionData = body;
            Title = filename;
        }
    }
}