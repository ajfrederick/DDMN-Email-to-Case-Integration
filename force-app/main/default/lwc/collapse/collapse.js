/**
 * IMPORTS
 */ 
import { LightningElement } from 'lwc';


/**
 * CLASS
 */ 
export default class Collapse extends LightningElement {

    isCollapsed = true;
    collapseClass = 'collapse collapsed';
    buttonClass = 'collapse-button collapsed slds-align_absolute-center';
    iconName = 'utility:chevrondown';
    title = 'Open';

/**
 * DOM EVENT HANDLERS
 */

    /**
     * @name toggleCollapse
     * @description on <lightning-icon/> onclick toggles collapse functionality
     */
    toggleCollapse(){
        if( this.isCollapsed ){
            this.isCollapsed = false;
            this.collapseClass = 'collapse';
            this.buttonClass = 'collapse-button slds-align_absolute-center';
            this.iconName = 'utility:chevronup';
            this.title = 'Close'
        } else {
            this.isCollapsed = true;
            this.collapseClass = 'collapse collapsed';
            this.buttonClass = 'collapse-button collapsed slds-align_absolute-center';
            this.iconName = 'utility:chevrondown';
            this.title = 'Open';
        }
    }
}