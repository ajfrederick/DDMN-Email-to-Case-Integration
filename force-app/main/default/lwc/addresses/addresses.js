/**
 * IMPORTS
 */ 

import { LightningElement, api, track } from 'lwc';
import { log } from 'c/utils';

import { getRelations, getAddressObj, addressTypes } from 'c/utilsApp';

/**
 * CLASS
 */ 

export default class Addresses extends LightningElement {

/**
 * PROPS
 */

    @api message;

    @track addresses = {};

    @api isNew = false;

    isFocus = false;

    get hasTos(){
        return this.isNew || this.addresses[addressTypes[1]].length > 0;
    }

    get hasCcs(){
        return this.isNew || this.addresses[addressTypes[2]].length > 0;
    }

    get hasBccs(){
        return this.isNew || this.addresses[addressTypes[3]].length > 0;
    }

/**
 * LIFECYCLE HOOKS
 */

    /**
     * @name connectedCallback
     * @description prep class with props and 
     * fill with 'address objects' that are formatted for the UI
    */
    connectedCallback(){
        addressTypes.map((addressType)=>{
            this.addresses[addressType] = getAddresses( 
                this.message, 
                this.message[addressType], 
                addressType 
            );
        });
    }

/**
 * API FUNCS
 */

    @api getAddresses(){
        return this.addresses;
    }

/**
 * DOM EVENT FUNCS
 */

    /**
     * @name handleClick
     * @description on .addresses handles onclick focuses addresses removes and then adds event listener
     * for click. Stops event propagation for onclick on .addresses
     * @param DOMEvent `e`
     */
    handleClick(e){
        if( !this.isNew ) return;

        this.isFocus = true;

        const handleDocClick = ()=>{
            this.isFocus = false;

            document.removeEventListener( 'click', handleDocClick );
        };

        document.addEventListener( 'click', handleDocClick );

        e.stopPropagation();
    }

    /**
     * @name handleAddressRemoved
     * @description on c-address handles custom event addressremoved defined in the addressPill.js
     * this method removes address from addresses.
     * @param ObjectLiteral `detail`
     */
    handleAddressRemoved({detail}){
        this.addresses[detail.addressType] = this.addresses[detail.addressType].filter( address => address.email !== detail.email );
    }

    /**
     * @name handleAddressAdded
     * @description on c-address handles custom event addressremoved defined in the recipientOptions.js
     * this method adds address to addresses.
     * @param CustomEvent.detail detail
     */
    handleAddressAdded({detail}){
        this.addresses[detail.addressType].push(detail.addressObj);
    }
}

/**
 * CLOSURE UTIL FUNCS
 */

/**
 * @name getAddresses
 * @description method that unpacks address addresses of any type (ie To Address, Cc Address, etc.)
 * from addressesbase model to markup model. Unpacks either an address of an email or an address, name and id of a contact or user
 * @param String `message` email message that all addresses pertain to
 * @param String `addresses` comma separated 'string' list of Email Addresses
 * @param String `addressType` type of address (ie From, To, etc). types list above.
 */
function getAddresses( message, addresses, addressType ){
    // gets any users or contacts that are associated with an address
    let relations = getRelations( message, addressType ),
        addressObjs = [];

    // means it's the FromAddress which is never a list
    if( !Array.isArray(addresses) ){

        if( addresses ){
            addresses = [addresses];
        } else {
            addresses = [];
        }
    }

    // loop through the relationships and add object with Name and Id for Markup
    /*relations.map((rel)=>{
        let name = rel.FirstName + ' ' + rel.LastName,
            obj = getAddressObj(
                rel.Email,
                rel.Id,
                name
            );
                    
        addressObjs.push( obj );
    });*/
    
    // if the address is purely an address then it will only contain 
    // an email address string which was split into this array 
    addresses.map((address)=>{
        let rels = relations.filter( rel => rel.Email == address ),
            obj;

        if( rels.length > 0 ){

            let rel = rels[0],
                name = rel.FirstName + ' ' + rel.LastName;

            obj = getAddressObj(
                rel.Email,
                rel.Id,
                name
            );

        } else {
            obj = getAddressObj( address );
        }

        addressObjs.push( obj );
    });

    return addressObjs;
}