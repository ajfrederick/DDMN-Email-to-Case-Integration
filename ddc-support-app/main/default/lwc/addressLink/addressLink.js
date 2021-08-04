/**
 * IMPORTS
 */ 

import { LightningElement, api } from 'lwc';
import { log } from 'c/utils';

/**
 * CLASS
 */ 

export default class AddressLink extends LightningElement {

/**
 * PROPERTIES
 */ 

    @api address;
    @api total = null;
    @api index = null;

    get isInternalRecipient(){
        return this.address.id ? true : false;
    }

    get linkUrl(){
        return window.location.origin + '/' + this.address.id;
    }

    get isLast(){
        
        if( this.index == null && this.total == null ){
            return true;
        }

        return this.index === this.total-1;
    }

    get isOrgFromAddress(){
        return this.address.email === window.MessageFeedConfig.orgWideAddress.Address;
    }

    fromAddressDisplayName = window.MessageFeedConfig.orgWideAddress.DisplayName;
}