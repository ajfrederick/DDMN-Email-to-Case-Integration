
/**
 * IMPORTS
 */ 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * @name reduceErrors
 * @description Reduces one or more LDS errors into a string[] of error messages.
 * @param Response or FetchReponse[] `errors`
 * @return String[] Error messages
 */
function reduceErrors(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
            // Remove null/undefined items
            .filter((error) => !!error)
            // Extract an error message
            .map((error) => {
                // UI API read errors
                if (Array.isArray(error.body)) {
                    return error.body.map((e) => e.message);
                }
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                }
                // JS errors
                else if (typeof error.message === 'string') {
                    return error.message;
                }
                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter((message) => !!message)
    );
}

/**
 * @name getErrorString
 * @description Quick dirty version of above. Probably won't use
 * @param String `error`
 * @return String Error messages
 */
const getErrorString = (error)=>{
    let ret = 'Unknown Error';

    if( Array.isArray(error.body) ){
        ret = error.body.map(e => e.message).join(', ');
    } else 
    if( typeof error.body.message === 'string' ){
        ret = error.body.message;
    }

    return ret;
};

/**
 * @name validateFields
 * @description validates fields and returns all valid fields
 * @param Array[] `fields`
 * @return Array[]
 */
const validateFields = (fields)=>{
    // use reduce to get an accumulation of validity from lightning-input
    const allValid = [...fields].reduce((validSoFar, input)=>{
        input.reportValidity();
        return validSoFar && input.checkValidity();
    });

    return allValid;
};

/**
 * @name getSuccessToast
 * @description if theres no error messages message gets set to everything went well then returns a new
 * ShowToastEvent custom event with assigned attributes
 * @param String `message`
 * @return CustomEvent
 */
const getSuccessToast = (message)=>{
    if(!message) message = 'Everthing went well.';

    return new ShowToastEvent({
        title : 'SUCCESS!',
        message : message,
        variant : 'success'
    });
};

/**
 * @name getSuccessToast
 * @description if theres no error messages message gets set to everything went well then returns a new
 * ShowToastEvent custom event with assigned attributes
 * @param String `message`
 * @return CustomEvent
 */
const getErrorToast = (errors)=>{
    const messages = reduceErrors(errors);
    
    let message;

    if( messages.length > 1 ){
        message = messages.join(' | ');
    } else {
        message = messages[0];
    }

    return new ShowToastEvent({
        title : 'Sorry but something went wrong!',
        message : message,
        variant : 'error',
        mode : 'sticky'
    });
};

/**
 * @name log
 * @description logs the proxyOBect to to console
 * @param ObjectLiteral `proxyObect`
 */
const log = (proxyObect)=>{
    if( proxyObect === undefined ) proxyObect = 'undefined';
    if( proxyObect === null ) proxyObect = 'null';
    
    console.log(JSON.parse(JSON.stringify(proxyObect)));
}

/**
 * @name getDateDiff
 * @description compares two dates and returns the difference between the dates in seconds
 * @param Date `latterDate`
 * @param Date `formerDate`
 * @return Object - `ret`
 */
const getDateDiff = ( latterDate, formerDate )=>{
    // date diff in seconds
    let dateDiff = Math.abs(latterDate - formerDate) / 1000;

    // amount of seconds in each time span
    let amountOfSeconds = {
        week: 604800,
        day: 86400,  
        hour: 3600,
        minute: 60,
        second: 1,
    };

    // returned object and total counter
    let ret = {
            noDiff : false
        },
        total = 0;

    // loop through the amount of seconds and start lopping of each value
    for( let key in amountOfSeconds ){
        ret[key] = Math.floor( dateDiff / amountOfSeconds[key] );
        dateDiff -= ret[key] * amountOfSeconds[key];

        total += ret[key];
    }

    if( total === 0 ){
        ret.noDiff = true;
    }

    return ret;
}

/**
 * EXPORTS
 */ 
export { 
    validateFields, 
    getErrorToast, 
    getSuccessToast, 
    reduceErrors, 
    getErrorString, 
    getDateDiff,
    log 
};