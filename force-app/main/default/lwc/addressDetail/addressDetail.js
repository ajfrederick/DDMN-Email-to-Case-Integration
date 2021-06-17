/**
 * IMPORTS
 */ 

import { LightningElement, api } from 'lwc';
import { log } from 'c/utils';

/**
 * CLASS
 */ 

export default class AddressDetail extends LightningElement {

/**
 * PROPS
 */

    @api addresses;

    _shown = false;

    @api 
    get shown(){
        return this._shown;
    }
    set shown(value){
        this._shown = value;

        if( this.shown ){
            this.detailClass = 'address-detail displayed';
        } else {
            this.detailClass = 'address-detail';
        }
    }

    detailClass;

/**
 * DOM EVENT FUNCS
 */

    
    keepDetail(){
        this.dispatchEvent( new CustomEvent('detailentered') );
    }

    hideDetail(){
        let event = new CustomEvent( 'detailleft', {
            detail : {
                    removeDetail : true
                }
            });

        this.dispatchEvent( event );
    }
}