/**
 * IMPORTS
 */ 
import { LightningElement, api } from 'lwc';
import { log, getErrorToast } from 'c/utils';

import searchRecipients from '@salesforce/apex/UiComponentServices.searchRecipients';

import { getAddressObj } from 'c/utilsApp';

/**
 * CLASS
 */ 
export default class RecipientOptions extends LightningElement {

/**
 * PROPERTIES
 */ 
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
                
                options.map((option, i)=>{
                    let fullName = '';
                    
                    if(option.FirstName) fullName += option.FirstName;
                    if(option.LastName) fullName += ' ' + option.LastName;

                    option.FullName = fullName;

                    if( i === options.length-1 ) option.isLast = true;
                });

                if( options.length ){
                    this.options = options;
                    this.show();
                } else {
                    this.options = null;
                    this.hide();
                }
            })
            .catch((error)=>{
                let errorToast = getErrorToast(error);

                this.dispatchEvent(errorToast);
            });
    }

    options;

    optionsClass = 'recipient-options slds-box';

    shown = false

/**
 * DOM EVENT HANDLERS
 */
    /**
     * @name handleClick
     * @description in .optionsClass in <template/> for loop on <div/> onclick sets up 
     * email with email, id, and name. Sets up detail with address obj and type. Creates a
     * new custom event addressadded. Then dispatches the new custom event.
     * @param {DOMEvent} e
    **/
    handleClick(e){
        let email = e.currentTarget.dataset.email,
            id = e.currentTarget.dataset.id,
            name = e.currentTarget.dataset.name;

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
/**
 * UTIL FUNCS
 */
    /**
     * @name hide
     * @description if element is shown replaces the class ' displayed' with ''
     * and hides element
    **/
    hide(){
        if( !this.shown ) return;
        this.optionsClass = this.optionsClass.replace(' displayed', '');
        this.shown = false;
    }

    /**
     * @name show
     * @description if element is not shown adds the class ' displayed'
     * and shows element
    **/
    show(){
        if( this.shown ) return;
        this.optionsClass = this.optionsClass + ' displayed';
        this.shown = true;
    }
}