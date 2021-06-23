/**
 * @name EmailInfo
 * @description wrapper class to get email content and info predictably no matter the source
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

    /**
     * @name setContent
     * @description creats/sets up a new EmailContent object
     * @param String Subject
     * @param String HtmlBody
     * @param String PlainTextBody
     * @return void
    **/
    public void setContent( String Subject, String HtmlBody, String PlainTextBody ){
        EmailContent cont = new EmailContent();
        cont.Subject = Subject;
        cont.HtmlBody = wrapHTMLBody(HtmlBody);
        cont.PlainTextBody = PlainTextBody;

        content = cont;
    }

    /**
     * @name setAttachement
     * @description adds attachements
     * @param Blob body 
     * @param String filename
     * @return void
    **/
    public void setAttachement( Blob body, String filename ){
        attachments.add( new AttachmentData( body, filename ) );
    }

    /**
     * @name setAttachement
     * @description adds attachements 
     * @param String body
     * @param String filename 
     * @return void
    **/
    public void setAttachement( String body, String filename ){
        Blob bodyBlob = EncodingUtil.base64Decode(body);

        attachments.add( new AttachmentData( bodyBlob, filename ) );
    }

    /**
     * @name setQuote
     * @description wraps the content in quote div, otherwise its an empty string
     * @param String quote
     * @return void
    **/
    public void setQuote( String quote ){
        if( content == null ) setContent( '', '', '' );

        content.HtmlBody += '<br/>' + wrapQuotedHTMLBody(quote);
    }

/**
 * UTILITY METHODS
**/

    /**
     * @name hasToAddresses
     * @description checks to see if ToAddresses of type String[] is empty or not
     * @return Boolean
     */
    public Boolean hasToAddresses(){
        return !ToAddresses.isEmpty();
    }

    /**
     * @name hasTemplate
     * @description checks to see if template of type EmailTemplate is null or not
     * @return Boolean
     */
    public Boolean hasTemplate(){
        return template != null;
    }

    /**
     * @name hasContent
     * @description checks to see if content of type EmailContent is null or not
     * @return Boolean
     */
    public Boolean hasContent(){
        return content != null;
    }

    /**
     * @name hasWhatId
     * @description checks to see if whatId of type Id is null or not
     * @return Boolean
     */
    public Boolean hasWhatId(){
        return whatId != null;
    }

    /**
     * @name hasWhoId
     * @description checks to see if whoId of type Id is null or not
     * @return Boolean
     */
    public Boolean hasWhoId(){
        return whoId != null;
    }

    /**
     * @name hasMessageId
     * @description checks to see if messageId of type String is blank or not
     * @return Boolean
     */
    public Boolean hasMessageId(){
        return !String.isBlank( messageId );
    }

    /**
     * @name hasInReplyTo
     * @description checks to see if inReplyTo of type String is empty or not
     * @return Boolean
     */
    public Boolean hasInReplyTo(){
        return !String.isBlank( inReplyTo );
    }

    /**
     * @name wrapHTMLBody
     * @description takes HTMLBody and wraps it in a div with class of creed-message
     * @param String HtmlBody
     * @return String
     */
    public String wrapHTMLBody( String HtmlBody ){
        return '<div class="creed-message">' + HtmlBody +'</div>';
    }

    /**
     * @name wrapQuotedHTMLBody
     * @description takes a String and wraps it in a div with class of creed-message-quote
     * @param String quote
     * @return String
     */
    private String wrapQuotedHTMLBody( String quote ){
        return '<div class="creed-message-quote">' + quote +'</div>';
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