/**
 * @name AttachmentCreatorInbound
 * @description this child class helps create and insert attachments for incoming emails
 */
public class AttachmentCreatorInbound extends AttachmentCreator {
    
/**
 * CONSTRUCTOR
 */

    public AttachmentCreatorInbound( EmailContainer[] containers ) {
        super(containers);
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
     * @param EmailContainer container
     * @return String
     */
    protected override String getMessageId( EmailContainer container ){
        return container.messageId;
    }
}
