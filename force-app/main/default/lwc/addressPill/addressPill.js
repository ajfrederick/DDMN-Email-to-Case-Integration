/**
 * IMPORTS
 */ 
import { LightningElement, api } from 'lwc';
import { log } from 'c/utils';

/**
 * CLASS
 */ 
export default class AddressPill extends LightningElement {
/**
 * PROPERTIES
 */ 

/**
 * PROPERTIES
 */ 

    // address object that is made in addresses component
    @api address;

    @api addressType;


    
    get hasRelation(){
        return this.address.id ? true : false;
    }

    get linkUrl(){
        return window.location.origin + '/' + this.address.id;
    }

/**
 * CUSTOM EVENT FUNCS
 */ 
    
/**
 * DOM EVENT HANDLERS
 */

    /**
     * @name handlePillRemove
     * @description When the <lightning-pill/> is clicked this function dispatches 
     * a custom event with a payload of addressType (ie. To, Cc, etc.) and the address' email. 
     * It is captured in the addresses.js component.
     * @param DOMEvent `e`
     */
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