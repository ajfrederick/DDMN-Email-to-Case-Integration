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
     * @description when mouse enters .detailclass this method creates/dispatches the
     * detailentered custom event. Handled in keepDetail() in address.js
    **/
    keepDetail(){
        this.dispatchEvent( new CustomEvent('detailentered') );
    }

    /**
     * @name hideDetail
     * @description when mouse leaves .detailclass this method indicates the address detail should be
     * removed by creating/dispatching detailleft custom. Handled in hideDetail() in address.js
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