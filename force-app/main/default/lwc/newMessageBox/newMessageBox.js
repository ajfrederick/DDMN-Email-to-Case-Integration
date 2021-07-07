/**
 * IMPORTS
 */ 
import { LightningElement, api, track } from 'lwc';

import { log, getErrorToast } from 'c/utils';

import getReply from '@salesforce/apex/UiComponentServices.getReply';
import sendEmailMessage from '@salesforce/apex/UiComponentServices.sendEmailMessage';

import { addressTypes } from 'c/utilsApp';

/**
 * CLOSURE VAR
 */ 

let timeoutId = null;

/**
 * CLASS
 */ 
export default class NewMessageBox extends LightningElement {

/**
 * PROPS
 */

    // New message object of apex type EmailInfo. The shape is defined in the getReply method above
    message;

    replyToMessage;

    @track attachments = [];

    isSending = false;

/**
 * API FUNCS
 */

    @api setNewMessage(event){
        let replyToMessage = event.detail.message, // replyToMessage of type EmailMessage
            replyToMessageJSON = JSON.stringify(replyToMessage),
            replyAll = event.detail.replyAll;

        // get reply message object. We want an expected format so let's get it from the server.
        getReply({replyToMessageJSON : replyToMessageJSON})
            .then((data)=>{
                this.message = this.getNewMessage(data, replyToMessage, replyAll);;
            })
            .catch((error)=>{
                let errorToast = getErrorToast(error);

                this.dispatchEvent(errorToast);
            });

        this.replyToMessage = {...replyToMessage};
    }

/**
 * DOM EVENT HANDLERS
 */

    /**
     * @name send
     * @description when the send `<lightning-button/>` is clicked this method setsup a timeout to avoid doubling clicking and
     * trying to send multiple messages. The message object, its attachments, and the reply message object are all converted into
     * a JSON string that is used as a parameter when the sendEmailMessage method is called. After the message
     * is sent using the sendEmailMessage method the custom event sent is created/dispatched which is handled in emailMessageFeed.js 
     * and properties are zero'd out/reset.
    **/
    send(){
        this.isSending = true;

        // debounce to avoid double click
        const later = ()=>{
            timeoutId = null;

            this.prepMessageForSend();

            const JSONnewMessageData = JSON.stringify({
                message : this.message,
                attachments : this.attachments,
                replyToMessage : this.replyToMessage
            });

            sendEmailMessage({ JSONnewMessageData : JSONnewMessageData })
                .then((data)=>{
                    let detail = {
                        detail : { 
                            data : JSON.parse(data)
                        }
                    };

                    this.dispatchEvent( new CustomEvent('sent', detail) );

                    this.reset();
                })
                .catch((error)=>{
                    let errorToast = getErrorToast(error);
    
                    this.dispatchEvent(errorToast);
                });
        };
        
        clearTimeout(timeoutId);

        timeoutId = setTimeout(later, 300);
    }

    /**
     * @name cancel
     * @description when the cancel `<lightning-button/>` is clicked this method cancels sending a new message
     * resets the properties (message, replyToMessage, attachments, isSending), and closes the new message modal.
     * @param DOMEvent `e`
    **/
    cancel(e){
        this.reset();
    }

    /**
     * @name handleSubjectChange
     * @description when the subject `<lightning-input/>` is changed the message's subject is set to
     * the new input value.
     * @param DOMEvent `e`
    **/
    handleSubjectChange(e){
        this.message.content.Subject = e.currentTarget.value;
    }

    /**
     * @name handleBodyChange
     * @description when the body `<lightning-input-rich-text/>` is changed the message properites'
     * content is set to the new input value.
     * @param DOMEvent `e`
    **/
    handleBodyChange(e){
        this.message.content.HtmlBody = e.target.value;
    }

    /**
     * @name handleAttachmentAttached
     * @description handles the custom event attached on`<c-message-attachments/>` defined in messageAttachments.js 
     * this method adds the new attachement to the attachments array prop.
     * @param DOMEvent `e`
    **/
    handleAttachmentAttached(e){
        this.attachments.push(e.detail);
    }

    /**
     * @name handleAttachmentAttached
     * @description handles the custom event attachmentdeleted on`<c-message-attachments/>` defined in messageAttachments.js 
     * this method removes the attachment by filtering out attachments from the attachments prop with matching Titles.
     * @param DOMEvent `e`
    **/
    handleAttachmentDeleted(e){
        this.attachments = this.attachments.filter( attachment => attachment.Title != e.detail.Title );
    }

/**
 * UTILITY FUNCS
 */

    /**
     * @name getNewMessage
     * @description this method gets new EmailInfo message and since this is a REPLY the TO and FROM addresses are flipped.
     * Also if there are ccAddresses on the REPLYTO message those Ccaddresses are added to to the newMessage CcAddresses.
     * @param EmailInfo `data` 
     * @param EmailMessage `replyToMessage`
     * @param EmailInfo `replyAll` 
     * @return EmailInfo 
    **/
    getNewMessage(data, replyToMessage, replyAll){
        let newMessage = JSON.parse( data ); // newMessage of apex type EmailInfo

        // TO DO make this more eligant. But this is to flip flop address info since it's a reply
        newMessage.ToAddresses = [replyToMessage.FromAddress];

        // if reply all convert reply to message To Address and Cc Addresses (if there are Cc Addresses) to CcAddress for new message
        if( replyAll ){
            newMessage.CcAddresses = replyToMessage.ToAddresses.filter( address => !address.includes( newMessage.FromAddress ) );
            
            // only if there are CcAddresses on the reply to message
            if( replyToMessage.CcAddresses ){
                newMessage.CcAddresses = replyToMessage.CcAddresses.filter((address)=>{
                    return !address.includes( newMessage.FromAddress );
                }).concat( newMessage.CcAddresses );
            }
        }

        this.fixRelations( newMessage, replyToMessage );

        return newMessage;
    }

    /**
     * @name prepMessageForSend
     * @description gets addresses from the c-addresses component and for each address that is not a from address
     * that email gets added to the message addresstype array. Then properties relationsById and EmailMessageRelations are
     * removed from the message object.
     * 
     * 
    **/
    prepMessageForSend(){
        let addressesComp = this.template.querySelector('c-addresses'),
            addresses = addressesComp.getAddresses();

        for( let addressType in addresses ){
            if( addressType === addressTypes[0] ) continue;
            

            this.message[addressType] = [];

            addresses[addressType].map((address)=>{
                this.message[addressType].push(address.email);
            });
        }

        delete this.message.relationsById;
        delete this.message.EmailMessageRelations;
    }

    /**
     * @name fixRealtions
     * @description copies objects over for addresses component
     * and flips the EmailMessageRelation record RelationType for the addresses component and the getRelations method 
     * @param EmailInfo `newMessage`
     * @param EmailInfo `replyToMessage`
    **/
    fixRelations( newMessage, replyToMessage ){
        // copy these objects over for addresses component
        newMessage.relationsById = {...replyToMessage.relationsById};
        newMessage.EmailMessageRelations = {...replyToMessage.EmailMessageRelations};

        // hack-ish: flip the EmailMessageRelation record RelationType for addresses component for getRelations method
        // TODO: overall better organize data from server and how it is sorted through, flattened, etc
        let records = [];

        newMessage.EmailMessageRelations.records.map((record)=>{

            let r = {...record};

            if( r.RelationType === 'FromAddress' ){
                r.RelationType = 'ToAddress';
            } else
            if( r.RelationType === 'ToAddress' ){
                r.RelationType = 'CcAddress';
            }

            records.push(r);
        });

        newMessage.EmailMessageRelations.records = [...records];
    }
    
    /**
     * @name reset
     * @description resets message
    **/
    reset(){
        this.message = null;
        this.replyToMessage = null;
        this.attachments = [];
        this.isSending = false;
    }
}