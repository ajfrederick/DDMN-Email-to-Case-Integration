/**
 * @name AttachmentCreatorOutbound
 * @description this child class helps create and insert attachments for outgoing emails
 */
public class AttachmentCreatorOutbound extends AttachmentCreator {

/**
 * CONSTRUCTOR
 */

    public AttachmentCreatorOutbound( EmailContainer[] containers ) {
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
        return message.Headers.substringAfter('In-Reply-To: ');
    }

    /**
     * @name getMessageId
     * @description returns an external email message Id for insertContentDocumentLinks method
     * @param EmailContainer container
     * @return String
     */
    protected override String getMessageId( EmailContainer container ){
        return container.inReplyTo;
    }
}
