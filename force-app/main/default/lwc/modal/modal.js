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
     * @description when the `<button/>` within the `<footer/>` is clicked this method creates/dispatches 
     * custom event close. Closes the new message modal.
     * @param DOMEvent `e`
    **/
    cancel(e){
        this.dispatchEvent( new CustomEvent( 'close' ) );
    }
}