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
     * @description called from the body's setter. Searches the body String which contains the email’s entire body 
     * (message and all quoted messages). Using the DOMParser a temporary HTML document is created then searched for
     * corrisponding 'creed-message' and 'creed-message-quote' classes. Using what is found the mehod then separates
     * the actual message that is sent and the message history.
     * @param String `body`
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