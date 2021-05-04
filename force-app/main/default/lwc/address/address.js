import { LightningElement, api } from 'lwc';
import { log } from 'c/utils';

import { addAddress, addressTypes, getAddressObj } from 'c/utilsApp';

let timeoutId;

export default class Address extends LightningElement {
    
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

    searchString = '';

    errorMessage = null;

    get hasErrors(){
        return this.errorMessage !== null;
    }

    handleKeyup(e){
        if( e.which === 13 ){

            let validEmail = addAddress( e, this );

            if( !validEmail ) return;

            e.currentTarget.value = '';

            this.searchString = '';

        } else {
            this.search(e);
        }
    }

    handleBlur(e){
        e.currentTarget.value = '';
        this.errorMessage = null;

        setTimeout(()=>{
            this.searchString = '';
        }, 300);
    }

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

    handleAddressAdded(e){
        let input = this.template.querySelectorAll('input')[0];
        input.value = '';
        this.searchString = '';
    }
}