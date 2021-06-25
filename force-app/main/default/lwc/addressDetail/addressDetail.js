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

    /**
     * @name keepDetial
     * @description on .detailclass handles onmouseenter creates/dispatches detailentered 
     * custom event where handled in address
    **/
    keepDetail(){
        this.dispatchEvent( new CustomEvent('detailentered') );
    }

     /**
     * @name hideDetail
     * @description on .detailclass handles onmouseleave hides details
     * and creates/dispatches detailleft custom event where handled in address
    **/
    hideDetail(){
        let event = new CustomEvent( 'detailleft', {
            detail : {
                    removeDetail : true
                }
            });

        this.dispatchEvent( event );
    }
}