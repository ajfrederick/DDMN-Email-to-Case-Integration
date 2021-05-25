import { LightningElement, api } from 'lwc';
import { log } from 'c/utils';

export default class AddressPill extends LightningElement {

    // address object that is made in addresses component
    @api address;

    @api addressType;
    
    get hasRelation(){
        return this.address.id ? true : false;
    }

    get linkUrl(){
        return window.location.origin + '/' + this.address.id;
    }
    
    handlePillRemove(e){
        let detail = {
                email : this.address.email,
                addressType : this.addressType
            };

        let event = new CustomEvent('addressremoved', {
                detail : detail,
                bubbles : true,
                composed: true
            });

        this.dispatchEvent( event );
    }
}