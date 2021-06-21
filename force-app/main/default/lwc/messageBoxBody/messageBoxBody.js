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
     * @description parses the message box body using the DOMParser. Gets and sets all
     * text and html tags, messages, and quoted messages. These are found using the associated classes
     * and getting the innerHTML of the element.
     * @param {MessageBoxBody} body
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
 * DOM FUNCS     
 */
    /**
     * @name handleAbbrClick
     * @description on quoted-message-abbr onclick hides or shows quoted message history.
     * @param {DOMEvent} e
    **/
    handleAbbrClick(e){
        if( this.quotedClass.indexOf('displayed') > 0 ){
            this.quotedClass = 'quoted-message';
        } else {
            this.quotedClass = 'quoted-message displayed';
        }
    }
}