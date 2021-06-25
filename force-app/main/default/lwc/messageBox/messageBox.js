/**
 * IMPORTS
 */ 
import { LightningElement, api } from 'lwc';

import { log, getDateDiff } from 'c/utils';
import { getRelations } from 'c/utilsApp';

// Schema field info
import IS_INCOMING from '@salesforce/schema/EmailMessage.Incoming';
const INCOMING = IS_INCOMING.fieldApiName;

/**
 * CLASS
 */ 
export default class MessageBox extends LightningElement {

/**
 * PROPERTIES
 */ 
    _message;

    // email messages
    @api 
    get message(){
        return this._message;
    };
    set message(value){
        this.setIconData( value );
        
        this.messageDate = new Date(value.MessageDate);

        this._message = value;
    };

    iconData;

    messageDate;

    get durationFromSent(){
        let dateDiff = getDateDiff(new Date, this.messageDate);
            
        let ret = '(';

        if( dateDiff.noDiff ){

            ret += '0 seconds';

        } else {

            for( let key in dateDiff ){
                let value = dateDiff[key], unit = key;

                if( value > 0 ){
                    if( value > 1 ) unit += 's';

                    ret += value + ' ' + unit;

                    break;
                }
            }
        }

        return ret += ' ago)';
    }

    get hasAttachments(){
        return this.message.attachments.length > 0;
    }

    get showFooter(){
        return this.message.Incoming || this.hasAttachments;
    }

/**
 * DOM EVENT HANDLERS
 */

    /**
     * @name reply
     * @description in Reply Button section on `<lightning-button/>` handles onclick sets a new message with
     * the message input.
     * @param DOMEvent `e`
    **/
    reply(e){
        this.setNewMessage({
            message : this.message
        });
    }

    /**
     * @name replyAll
     * @description in Reply All Button section on `<lightning-button/>` handles onclick sets new message with
     * the message input and replyAll set to true
     * @param DOMEvent `e`
    **/
    replyAll(e){
        this.setNewMessage({
            message : this.message,
            replyAll : true  
        });
    }

    /**
     * @name handleMouseOver
     * @description handles onmouseover adds the 'sld-current-color' class to the element
     * @param DOMEvent `e`
    **/
    handleMouseOver(e){
        e.currentTarget.classList.add('slds-current-color');
    }

    /**
     * @name handleMouseOut
     * @description handles onmouseout removes the 'sld-current-color' from the element
     * @param DOMEvent `e`
    **/
    handleMouseOut(e){
        e.currentTarget.classList.remove('slds-current-color');
    }

/**
 * CONFIGURATION FUNCS
 */

    /**
     * @name setIconData
     * @description creates icon data for a given message
     * @param EmailMessage `message`
    **/
    setIconData(message){
        this.iconData = new IconData(message);
    }

/**
 * UTILITIES
 */
     /**
     * @name setNewMessage
     * @description creates/dispatches the custom event reply where handled in emailMessageFeed
     * @param ObjecLiteral `detail`
    **/   
    setNewMessage(detail){
        this.dispatchEvent( new CustomEvent( 'reply', {detail} ) );
    }
}

/**
 * MODULE CLASSES/CONSTRUCTOR FUNCS
 */

    /**
     * @description used to unpack name or address data to create initals for Icons in markup. 
     * This is only for markup.
     * @param EmailMessage `message`
     */
    function IconData(message){
        let fromRelation, str1, str2, name;

        if( message[INCOMING] ){
            
            fromRelation = getRelations(message, 'FromAddress');

            // since the getRelations returns an array but there will always only be one from address
            fromRelation = fromRelation.length > 0 ? fromRelation[0] : null;

            if( fromRelation ){
                str1 = fromRelation.FirstName;
                str2 = fromRelation.LastName;
            } else {
                str1 = message.FromAddress;
            }

            name = 'standard:client';
            
        } else {
            str1 = message.FromName;
            str2 = message.FromName.charAt(1);

            name = 'standard:account';
        }

        let initials = str1.charAt(0).toUpperCase();

        if( str2 ){
            initials += str2.charAt(0).toUpperCase();
        } else {
            initials += str1.charAt(1);
        }
        
        this.initials = initials;
        this.name = name;
    }