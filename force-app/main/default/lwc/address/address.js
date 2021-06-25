/**
 * IMPORTS
 */ 

import { LightningElement, api } from 'lwc';

import { log } from 'c/utils';
import { emailValid, getAddressObj, addressTypes } from 'c/utilsApp';

let timeoutId;
let detailTimeoutId;

/**
 * CLASS
 */ 

export default class Address extends LightningElement {

/**
 * PROPS
 */

    @api addresses;

    get addressType(){
        return addressTypes.filter( type => type.includes(this.label) )[0];
    }

    get addressesString(){
        let ret = '';

        const append = (address, i, arr)=>{
            ret += address.email;

            if( i < (arr.length-1) ) ret += ', ';
        };

        this.addresses.map( append );

        return ret;
    }

    @api label = '';

    @api isFocus = false;

    @api isNew = false;

    searchString = '';

    errorMessage = null;

    get hasErrors(){
        return this.errorMessage !== null;
    }

    detailShown = false;
    detailEntered = false;

    optionClicked = false;

/**
 * DOM EVENT HANDLERS
 */

    /**
     * @name handleKeyup
     * @description sugggests valid email addreses in address-input
     * @param DOMEvent `e` 
    **/
    handleKeyup(e){
        let address = e.currentTarget.value;

        if( e.which === 13 ){

            let validEmail = this.addAddress( address );

            if( !validEmail ) return;

            e.currentTarget.value = '';

            this.searchString = '';

        } else {
            this.search(e);
        }
    }

    /**
     * @name handleBlur
     * @description sugggests valid email addreses captured from .address-input `<input/>`
     * @param DOMEvent `e`
    **/
    handleBlur(e){
        let currentTarget = e.currentTarget,
            address = currentTarget.value;

        setTimeout(()=>{

            if( this.optionClicked ){
                this.optionClicked = false;
                return;
            }

            let validEmail = this.addAddress( address );
    
            if( !validEmail ) return;
    
            currentTarget.value = '';

            this.searchString = '';

        }, 300);
    }

    /**
     * @name search
     * @description sets value of current email searchString after suggesting valid ones in handleKeyup 
     * @param DOMEvent `e` 
    **/
    search(e){
        if( this.errorMessage ) this.errorMessage = null;

        let value = e.currentTarget.value;

        // debounce since this is a key event and it makes server calls in recipientOptions comp
        const later = ()=>{
            timeoutId = null;

            this.searchString = value;
        };
        
        clearTimeout(timeoutId);

        timeoutId = setTimeout(later, 300);
    }

    /**
     * @name showDetail
     * @description shows details onmouseenter on .address-container
    **/
    showDetail(){

        let show = ()=>{
            this.detailShown = true;
            detailTimeoutId = null;
        }

        detailTimeoutId = setTimeout( show, 1000 );
    }

    /**
     * @name hideDetail
     * @description handles onmouseleave on .address-container hides details
     * @param DOMEvent `e`
    **/
    hideDetail(e){

        if( detailTimeoutId ){
            clearTimeout(detailTimeoutId);
            detailTimeoutId = null;
            return;
        }

        let hide = ()=>{
            if( (!this.detailEntered) || e.detail.removeDetail ){
                this.detailShown = false;
                this.detailEntered = false;
            }
        }

        setTimeout( hide, 200 );
    }

/**
 * CUSTOM EVENT FUNCS
 */

    /**
     * @name handleAddressAdded
     * @description on c-recipient-options handles custom event addressadded defined in recipientOptions.js
     * this method zeros out string values
     * @param CustomEvent `e`
    **/
    handleAddressAdded(e){
        this.optionClicked = true;

        let input = this.template.querySelectorAll('input')[0];
        input.value = '';

        this.searchString = '';
    }
    
    /**
     * @name keepDetail
     * @description on c-address-detail handles custom event detailleft defined in addressDetail.js
     * this method sets detailEntered to true
    **/
    keepDetail(){
        this.detailEntered = true;
    }

    /**
     * @name addAddress
     * @description if email address is valid gets addressObj/addressType and
     * dispatches the addressadded custom event where handled in addresses
     * @param Address `address`
     * @return Boolean
    **/
    addAddress(address){
        if( !address ) return false;
    
        if( !emailValid( address ) ){
            this.errorMessage = 'Must enter valid email address if no supplied option is selected';
            return false;
        }
    
        let detail = {
            addressObj : getAddressObj( address ),
            addressType : this.addressType
        };
    
        let event = new CustomEvent('addressadded', {
                detail : detail
            });
    
        this.dispatchEvent( event );
    
        return true;
    }
}