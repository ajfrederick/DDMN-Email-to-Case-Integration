import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * Reduces one or more LDS errors into a string[] of error messages.
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
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
 * Quick dirty version of above. Probably won't use
 * @param {String} error
 * @return {String} Error messages
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

const validateFields = (fields)=>{
    // use reduce to get an accumulation of validity from lightning-input
    const allValid = [...fields].reduce((validSoFar, input)=>{
        input.reportValidity();
        return validSoFar && input.checkValidity();
    });

    return allValid;
};


const getSuccessToast = (message)=>{
    if(!message) message = 'Everthing went well.';

    return new ShowToastEvent({
        title : 'SUCCESS!',
        message : message,
        variant : 'success'
    });
};

const getErrorToast = (error)=>{
    const messages = reduceErrors(error);
    
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

const log = (proxyObect)=>{
    if( proxyObect === undefined ) proxyObect = 'undefined';
    if( proxyObect === null ) proxyObect = 'null';
    
    console.log(JSON.parse(JSON.stringify(proxyObect)));
}

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

    // returned object
    let ret = {};

    // loop through the amount of seconds and start lopping of each value
    for( let key in amountOfSeconds ){
        ret[key] = Math.floor( dateDiff / amountOfSeconds[key] );
        dateDiff -= ret[key] * amountOfSeconds[key];
    }

    return ret;
}

export { 
    validateFields, 
    getErrorToast, 
    getSuccessToast, 
    reduceErrors, 
    getErrorString, 
    getDateDiff,
    log 
};