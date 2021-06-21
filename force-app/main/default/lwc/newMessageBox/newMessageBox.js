/**
 * IMPORTS
 */ 
import { LightningElement, api, track } from 'lwc';

import { log, getErrorToast } from 'c/utils';

import getReply from '@salesforce/apex/UiComponentServices.getReply';
import sendEmailMessage from '@salesforce/apex/UiComponentServices.sendEmailMessage';

import { addressTypes } from 'c/utilsApp';

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
     * @description in .slds-clearfix on <lightning-button/> onclick sends a new message
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
     * @description in .slds-clearfix on <lightning-button/> onclick cancels sending a new message
     * @param {DOMEvent} e
    **/
    cancel(e){
        this.reset();
    }

    /**
     * @name handleSubjectChange
     * @description in .message-header on <lightning-input/> onchange sets message's subject to
     * input value
     * @param {DOMEvent} e
    **/
    handleSubjectChange(e){
        this.message.content.Subject = e.currentTarget.value;
    }

    /**
     * @name handleBodyChange
     * @description in .slds-p-vertical_small on <lightning-input-rich-text/> onchange sets message
     * HtmlBody to input value
     * @param {DOMEvent} e
    **/
    handleBodyChange(e){
        this.message.content.HtmlBody = e.target.value;
    }

    /**
     * @name handleAttachmentAttached
     * @description in <lightning-layout/> footer on <c-message-attachments/> on custom event onattached
     * defined in messageAttachments component adds attachement to attachments list.
     * @param {DOMEvent} e
    **/
    handleAttachmentAttached(e){
        this.attachments.push(e.detail);
    }

    /**
     * @name handleAttachmentAttached
     * @description in <lightning-layout/> footer on <c-message-attachments/> on custom 
     * event onattachmentdeleted defined in messageAttachments component 
     * removes attachment from attachments list.
     * @param {DOMEvent} e
    **/
    handleAttachmentDeleted(e){
        this.attachments = this.attachments.filter( attachment => attachment.Title != e.detail.Title );
    }

/**
 * UTILITY FUNCS
 */

    /**
     * @name getNewMessage
     * @description gets new message
     * @param {EmailInfo, EmailMessage, EmailInfo} data, replyToMessage, replyAll 
     * @return {EmailInfo} 
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
     * @description gets message addresses goes through those addresses and if the message type is
     * FromAddress then zero's out that message's type. Deletes message relations.
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
     * and flip the EmailMessageRelation record RelationType for addresses 
     * component for getRelations method 
     * @param {EmailInfo, EmailMessage} newMessage, replyToMessage
    **/
    fixRelations( newMessage, replyToMessage ){

        newMessage.relationsById = {...replyToMessage.relationsById};
        newMessage.EmailMessageRelations = {...replyToMessage.EmailMessageRelations};

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