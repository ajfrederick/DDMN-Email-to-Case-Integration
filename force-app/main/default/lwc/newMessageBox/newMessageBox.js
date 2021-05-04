import { LightningElement, api, track } from 'lwc';

import { log } from 'c/utils';

import getReply from '@salesforce/apex/UiComponentServices.getReply';
import sendEmailMessage from '@salesforce/apex/UiComponentServices.sendEmailMessage';

import { addressTypes } from 'c/utilsApp';

export default class NewMessageBox extends LightningElement {

/**
 * PROPS
 */

    // New message object of apex type EmailInfo. The shape is defined in the getReply method above
    message;

    @track attachments = [];

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
                let newMessage = JSON.parse( data ); // newMessage of apex type EmailInfo

                // TO DO make this more eligant. But this is to flip flop address info since it's a reply
                newMessage.ToAddresses.push(replyToMessage.FromAddress);

                if( replyAll ){
                    newMessage.CcAddresses = replyToMessage.ToAddresses.filter( address => !address.includes( newMessage.FromAddress ) );
                  
                    if( replyToMessage.CcAddresses ){
                        newMessage.CcAddresses = replyToMessage.CcAddresses.filter((address)=>{
                            return !address.includes( newMessage.FromAddress );
                        }).concat( newMessage.CcAddresses );
                    }
                }

                // copy this objects over for addresses component
                newMessage.relationsById = {...replyToMessage.relationsById};
                newMessage.EmailMessageRelations = {...replyToMessage.EmailMessageRelations};

                this.message = newMessage;

            })
            .catch((error)=>{
                console.error(error);
            }); 
    }

/**
 * DOM FUNCS
 */

    // sends a new message
    send(){
        this.prepMessage();

        const JSONnewMessageData = JSON.stringify({
            message : this.message,
            attachments : this.attachments
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
                console.error(error);
            });
    }

    // cancels sending a new message
    cancel(e){
        this.reset();
    }

    handleSubjectChange(e){
        this.message.content.Subject = e.currentTarget.value;
    }

    handleBodyChange(e){
        this.message.content.HtmlBody = e.target.value;
    }

    handleAttachmentAttached(e){
        this.attachments.push(e.detail);
    }

    handleAttachmentDeleted(e){
        this.attachments = this.attachments.filter( attachment => attachment.Title != e.detail.Title );
    }

    prepMessage(){
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
    
    reset(){
        this.message = null;
        this.attachments = [];
    }
}