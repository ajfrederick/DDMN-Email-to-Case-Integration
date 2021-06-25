/**
 * IMPORTS
 */ 
import { LightningElement, api } from 'lwc';

import { log } from 'c/utils';

/**
 * CLASS
 */ 
export default class MessageAttachments extends LightningElement {

/**
 * PROPS
 */
    @api attachments = [];

    @api isNew = false;

    get hasAttachments(){
        return this.isNew ? true : this.attachments.length > 0;
    }

    _errorMessage;

    get errorMessage(){
        return this._errorMessage;
    }
    set errorMessage(value){
        this._errorMessage = value;
        this.hasErrors = value ? true : false;
    }

    hasErrors = false;

/**
 * DOM EVENTS
 */

    /**
     * @name handleAttachment
     * @description on `<lightning-input/>` handles onchange zeros out error messages checks to see if the
     * file is larger than 5 MB and reads the attachment file. Creates/dispatches
     *  custom event attached where handled in newMessageBox. Gets any errors
     * @param DOMEvent `e`
    **/
    handleAttachment(e){
        this.setErrorMessage('');

        const file = e.detail.files[0];

        if( largerThan5MB(file.size) ){
            this.setErrorMessage('Attachment cannot exceed 5 MB');
            return;
        }

        let reader = new FileReader();
        
        reader.onload = ()=>{
            let base64 = reader.result.split('base64,')[1],
                fileExtension = file.name.split('.')[1];

            const detail = {
                Title : file.name,
                base64 : base64,
                FileExtension : fileExtension,
                ContentDocumentId : null
            };

            this.dispatchEvent( new CustomEvent( 'attached', {detail : detail} ) );
        }
        
        reader.readAsDataURL(file);
    }

    setErrorMessage(message){
        this.errorMessage = message;
    }
}

/**
 * UTIL FUNCS
 */

    /**
     * @name handleAttachment
     * @description checks to see if a file's size is larger tha 5MB returns true if it is
     * else returns false
     * @param Integer `size`
     * @return Boolean
    **/
    function largerThan5MB(size){
        return size > 5000000;
    };