/**
 * @name AttachmentCreatorInbound
 * @description this child class helps create and insert attachments for incoming emails
 */
public class AttachmentCreatorInbound extends AttachmentCreator {
    
/**
 * CONSTRUCTOR
 */

    public AttachmentCreatorInbound( EmailInfo[] wrappers ) {
        super(wrappers);
    }

/**
 * OVERRIDE METHODS
 */

    /**
     * @name getMessageId
     * @description returns an external email message Id for insertContentDocumentLinks method
     * @param EmailMessage message
     * @return String
     */
    protected override String getMessageId( EmailMessage message ){
        return message.MessageIdentifier;
    }

    /**
     * @name getMessageId
     * @description returns an external email message Id for insertContentDocumentLinks method
     * @param EmailInfo wrapper
     * @return String
     */
    protected override String getMessageId( EmailInfo wrapper ){
        return wrapper.messageId;
    }
}
