/**
 * IMPORTS
 */ 
import { LightningElement, api } from 'lwc';

/**
 * CLASS
 */ 
export default class Modal extends LightningElement {
/**
 * PROPS
 */ 
    @api noFooter = false;

/**
 * DOM EVENT HANDLERS    
 */

    /**
     * @name cancel
     * @description in .slds-modal__footer on <button/> onclick dispatches custom event close
     * @param {DOMEvent} e
    **/
    cancel(e){
        this.dispatchEvent( new CustomEvent( 'close' ) );
    }
}