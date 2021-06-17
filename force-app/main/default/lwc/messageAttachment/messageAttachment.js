/**
 * IMPORTS
 */ 
import { LightningElement, api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

import { log } from 'c/utils';

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

    showDelete(){
        this.deleteClass += ' displayed';
    }

    hideDelete(){
        this.deleteClass = 'delete-attachment';
    }

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