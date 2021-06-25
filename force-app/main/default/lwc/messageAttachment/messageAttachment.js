/**
 * IMPORTS
 */ 
import { LightningElement, api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

import { log } from 'c/utils';

/**
 * CLASS
 */ 
export default class MessageAttachment extends NavigationMixin(LightningElement) {

/**
 * PROPS
 */
    @api attachment;

    @api isNew = false;

    deleteClass = 'delete-attachment';

    get iconName(){
        let ret = 'doctype:attachment';

        for( let i = 0; i < fileExtensions.length; i++ ){
            let extensions = fileExtensions[i].extensions,
                _iconName = fileExtensions[i].iconName,
                shouldBreak = false;
            
            for( let ii = 0; ii < extensions.length; ii++ ){
                let extension = extensions[ii];

                if( this.attachment.FileExtension === extension ){
                    ret = _iconName;
                    shouldBreak = true;
                    break;
                }
            }

            if( shouldBreak ) break;
        }

        return ret;
    }

/**
 * DOM EVENTS
 */
    /**
     * @name preview
     * @description on `<lightning-icon/>` handles onclick navigates to the filePreview page 
     * @param DOMEvent `e`
    **/
    preview(e){
        if( this.isNew ) return;
        
        this[NavigationMixin.Navigate]({
            type : 'standard__namedPage',
            attributes : {
                pageName : 'filePreview'
            },
            state : {
                selectedRecordId : this.attachment.ContentDocumentId
            }
        });
    }

    /**
     * @name showDelete
     * @description on .message-attachment handles onmouseover removes the ' displayed' class
    **/
    showDelete(){
        this.deleteClass += ' displayed';
    }

    /**
     * @name hideDelete
     * @description on .message-attachment handles onmouseout removes the 'delete-attachment' class
    **/
    hideDelete(){
        this.deleteClass = 'delete-attachment';
    }

    /**
     * @name deleteAttachment
     * @description on `<lightning-icon/>` handles onclick removes attachment. Sets detail title and 
     *  creates/dispatches custom event attachmentdeleted where handled in newMessageBox
    **/
    deleteAttachment(){
        let detail = {
            Title : this.attachment.Title    
        };

        this.dispatchEvent( new CustomEvent( 'attachmentdeleted', {
            detail : detail,
            bubbles : true,
            composed: true
        }));
    }
}

const fileExtensions = [
    {
        extensions : ['pdf'],
        iconName : 'doctype:pdf'
    },
    {
        extensions : ['html'],
        iconName : 'doctype:html'
    },
    {
        extensions : ['xml'],
        iconName : 'doctype:xml'
    },
    {
        extensions : ['txt'],
        iconName : 'doctype:txt'
    },
    {
        extensions : ['doc', 'docx'],
        iconName : 'doctype:word'
    },
    {
        extensions : ['xls','xlsx'],
        iconName : 'doctype:excel'
    },
    {
        extensions : ['csv'],
        iconName : 'doctype:csv'
    },
    {
        extensions : ['png','jpg','tiff','gif'],
        iconName : 'doctype:image'
    },
    {
        extensions : ['mp3','wav','aiff','aac', 'm4a','flac'],
        iconName : 'doctype:audio'
    },
    {
        extensions : ['zip'],
        iconName : 'doctype:zip'
    },
];