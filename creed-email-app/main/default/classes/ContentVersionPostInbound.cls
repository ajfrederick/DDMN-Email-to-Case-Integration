/**
 * @name ContentVersionPostInbound
 * @description this child class helps create and insert attachments for incoming emails
 */
global class ContentVersionPostInbound extends ContentVersionPost {
    
/**
 * CONSTRUCTOR
 */

    global ContentVersionPostInbound( EmailParcel[] parcels ) {
        super(parcels);
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
    global override String getMessageId( EmailMessage message ){
        return message.MessageIdentifier;
    }

    /**
     * @name getMessageId
     * @description returns an external email message Id for insertContentDocumentLinks method
     * @param EmailParcel parcel
     * @return String
     */
    global override String getMessageId( EmailParcel parcel ){
        return parcel.messageId;
    }
}