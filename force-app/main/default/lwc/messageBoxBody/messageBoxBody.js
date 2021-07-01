/**
 * IMPORTS
 */ 
import { LightningElement, api } from 'lwc';

import {log} from 'c/utils';

/**
 * CLASS
 */ 
export default class MessageBoxBody extends LightningElement {

/**
 * PROPERTIES
 */ 
    message;

    quotedMessage;

    _body

    // Html body of the email message
    @api 
    get body(){
        return this._body;
    }
    set body(value){
        this._body = value;

        this.parseBody(value);
    }

    quotedClass = 'quoted-message';

/**
 * ACTION FUNCS
 */

    /**
     * @name parseBody
     * @description called from the body's setter. Gets all all of the DOM,
     * from within the DOM all message elements are obtained by finding elements with .creed-message, and all of the quoted
     * messages are obtained by finding elements with .creed-message-quote. Then the message and quoted messages are
     * extracted from the elements setting this class' properties (quotedMessage & message).
     * @param MessageBoxBody `body`
    **/
    parseBody(body){
        let document = new DOMParser().parseFromString(body, 'text/html'),
            message = document.getElementsByClassName('creed-message'),
            quotedMessage = document.getElementsByClassName('creed-message-quote');

        if( message.length > 0 ){
            this.message = message[0].innerHTML;
        } else {
            this.message = body;
        }

        if( quotedMessage.length > 0 ){
            this.quotedMessage = quotedMessage[0].innerHTML;
        }
    }

/**
 * DOM EVENT HANDLERS    
 */
    /**
     * @name handleAbbrClick
     * @description when .quoted-message-abbr (the 3 ellipses) is clicked this method hides or shows quoted message history.
     * @param DOMEvent `e`
    **/
    handleAbbrClick(e){
        if( this.quotedClass.indexOf('displayed') > 0 ){
            this.quotedClass = 'quoted-message';
        } else {
            this.quotedClass = 'quoted-message displayed';
        }
    }
}