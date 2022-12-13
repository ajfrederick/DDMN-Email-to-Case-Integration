/**
 * @name ContentVersionPostOutbound
 * @description this child class helps create and insert attachments for outgoing emails
 */
global class ContentVersionPostOutbound extends ContentVersionPost {

/**
 * CONSTRUCTOR
 */

    global ContentVersionPostOutbound( EmailParcel[] parcels ) {
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
        return message.Headers.substringAfter('In-Reply-To: ');
    }

    /**
     * @name getMessageId
     * @description returns an external email message Id for insertContentDocumentLinks method
     * @param EmailParcel parcel
     * @return String
     */
    global override String getMessageId( EmailParcel parcel ){
        return parcel.inReplyTo;
    }
}