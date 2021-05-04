import { LightningElement, api } from 'lwc';
import { log } from 'c/utils';

import searchRecipients from '@salesforce/apex/UiComponentServices.searchRecipients';

import { getAddressObj } from 'c/utilsApp';

export default class RecipientOptions extends LightningElement {

    // an array of addresses of this address type for this message
    @api addresses;

    // String: type of address ie 'To, From Cc'...
    @api addressType;

    _searchString;

    @api
    get searchString(){
        return this._searchString;
    }
    set searchString(value){

        if( !value ){
            this.options = null;
            this._searchString = null;
            this.hide();
            return;
        }

        this._searchString = value;

        const emails = this.addresses.map((address)=>{
            return address.email;
        })

        searchRecipients({ searchString : value, emails : emails })
            .then((options)=>{

                if( options.length ){
                    this.options = options;
                    this.show();
                } else {
                    this.options = null;
                    this.hide();
                }
            })
            .catch((error)=>{
                console.error(error);
            });
    }

    options;

    optionsClass = 'recipient-options slds-box';

    shown = false

    handleClick(e){
        let email = e.currentTarget.dataset.email,
            id = e.currentTarget.dataset.id,
            name = e.currentTarget.innerHTML;

        let detail = {
                addressObj : getAddressObj( email, id, name ),
                addressType : this.addressType
            };

        let event = new CustomEvent('addressadded', {
                detail : detail,
                bubbles : true,
                composed: true
            });

        this.dispatchEvent( event );

        this.hide();
    }

    hide(){
        if( !this.shown ) return;
        this.optionsClass = this.optionsClass.replace(' displayed', '');
        this.shown = false;
    }

    show(){
        if( this.shown ) return;
        this.optionsClass = this.optionsClass + ' displayed';
        this.shown = true;
    }
}