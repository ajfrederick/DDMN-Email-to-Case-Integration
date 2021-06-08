import { LightningElement, api, wire } from 'lwc';

import {log, getErrorToast, getSuccessToast} from 'c/utils';

// Apex Service Methods
import getData from '@salesforce/apex/UiComponentServices.getData';
import getFromAddress from '@salesforce/apex/UiComponentServices.getFromAddress';

export default class EmailMessageFeed extends LightningElement {

/**
 * PROPERTIES
 */ 
    // private recordId property for setter and getter
    _recordId;

    // public getter setter which get's set by the lightning record page. We need this value to get the message 
    // so we call the apex method after the value is set
    @api 
    get recordId(){
        return this._recordId;
    };
    set recordId(value){
        this._recordId = value;

        window.MessageFeedConfig = window.MessageFeedConfig || {};

        if( window.MessageFeedConfig.orgWideAddress === undefined ){
            this.getFromAddress();
        } else {
            this.getMessages();
        }
    };

    // array of email messages
    messages;

/**
 * ACTION FUNCTIONS
 */

    // gets all the messages
    getMessages(){
        getData({recordId : this.recordId})
            .then((data)=>{
                this.setData( JSON.parse(data) );
            })
            .catch((error)=>{
                let errorToast = getErrorToast(error);

                this.dispatchEvent(errorToast);
            });
    }

    getFromAddress(){
        getFromAddress()
            .then((addressJSON)=>{
                let address = JSON.parse(addressJSON);
                
                window.MessageFeedConfig.orgWideAddress = {...address};

                this.getMessages();
            })
            .catch((error)=>{
                let errorToast = getErrorToast(error);

                this.dispatchEvent(errorToast);
            });
    }

/**
 * PROMISE FUNCTIONS
 */ 
    // process data recieved from apex call
    setData(data){
        this.messages = data.messages;

        // loop through messages and add to the message object the attachement data, relation (User/Contact) data and 
        // crudely solve the pluralized property name problem. Essentially we're creating our client side data model
        // TODO: create and hold this model in a centralized location?
        this.messages.map((message)=>{
            let rels = message.EmailMessageRelations.records,
                attachments = data.attachmentsByMessageId[message.Id];
 
            message.relationsById = {};
            message.attachments = attachments ? [...attachments] : [];

            rels.map((rel)=>{
                // if has relation records. tack it on to the message object. relationsById is a map of users or contacts keyed on their Id
                if( rel.RelationId && data.relationsById[rel.RelationId] ){
                    message.relationsById[rel.RelationId] = data.relationsById[rel.RelationId];
                }
            });

            // this nonesense is because apex EmailMessage designed by SF has address properties that are singular
            // let's pluralize them so it's predictable throughout the UI. Also let's make them proper arrays since
            // EmailMessage stores them as colon delimited strings. Hence why the prop names are singular.
            message.ToAddresses = message.ToAddress.split(';').map( address => address.trim() );
            delete message.ToAddress;

            if( message.CcAddress ){
                message.CcAddresses = message.CcAddress.split(';').map( address => address.trim() );
                delete message.CcAddress;
            }

            if( message.BccAddress ){
                message.BccAddresses = message.BccAddress.split(';').map( address => address.trim() );
                delete message.BccAddress;
            }

        });
    }

/**
 * DOM EVENT HANDLERS
 */

    setNewMessage(event){
        let newMessageBox = this.template.querySelector('c-new-message-box');

        newMessageBox.setNewMessage( event );
    }

    newMessageSent({detail}){
        this.setData(detail.data);

        this.scroll();

        let successToast = getSuccessToast('Email Sent!');

        this.dispatchEvent(successToast);
    }

/**
 * UTILITIES
 */
    
    scroll(){
        let feed = this.template.querySelector('.email-feed');

        feed.scrollTop = 0;
    }
}