import { LightningElement, api } from 'lwc';

export default class AddressLink extends LightningElement {

    @api address;
    @api total;
    @api index;

    get isInternalRecipient(){
        return this.address.id ? true : false;
    }

    get linkUrl(){
        return window.location.origin + '/' + this.address.id;
    }

    get isLast(){
        return this.index === this.total-1;
    }
}