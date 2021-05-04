public class AttachmentCreatorInbound extends AttachmentCreator {
    
    public AttachmentCreatorInbound( EmailInfo[] wrappers ) {
        super(wrappers);
    }

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
