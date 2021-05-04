import { LightningElement, api } from 'lwc';

export default class Modal extends LightningElement {
    
    @api noFooter = false;

    cancel(e){
        this.dispatchEvent( new CustomEvent( 'close' ) );
    }
}