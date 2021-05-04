import { LightningElement, api } from 'lwc';

import { log } from 'c/utils';

export default class MessageAttachments extends LightningElement {

    @api attachments = [];

    @api isNew = false;

    get hasAttachments(){
        return this.isNew ? true : this.attachments.length > 0;
    }

    handleAttachment(e){
        const file = e.detail.files[0];

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
}