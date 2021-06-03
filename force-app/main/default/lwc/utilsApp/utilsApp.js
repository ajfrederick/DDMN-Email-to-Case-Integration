/**
 * @description app sepecific utils
 */

const getRelations = ( message, addressType )=>{
    if( !message || !message.relationsById ) return [];
    
    // prep some vars... the returned array, upacking the EmailMessageRelations records 
    // and the relationsById which are contact and/or user records
    let relationsToReturn = [],
        messageRelationsRecords = message.EmailMessageRelations.records,
        relationsById = message.relationsById;

    messageRelationsRecords.map((rel)=>{
        // this is hacky. needs refactoring BUT check if FromAddress then exit if this message relations type does not match our preferred addressType. slice to remove plural from 'addressType'
        if( (addressType === 'FromAddress' && rel.RelationType !== addressType) || (addressType !== 'FromAddress' && rel.RelationType !== addressType.slice(0, -2)) ) return;

        // Loop through the user or contact records and if the RelationId matches the 
        // user or contact record add to the returned array
        for( let id in relationsById ){
            if( id === rel.RelationId ){
                relationsToReturn.push( relationsById[id] );
            }
        }
    });

    return relationsToReturn;
}

const getAddressObj = (address, id = null, name = null )=>{
    return {
        id : id,
        name : name,
        email : address
    };
};

const addressTypes = [
    'FromAddress',
    'ToAddresses',
    'CcAddresses',
    'BccAddresses'
];

const emailValid = (email)=>{
    const re = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(String(email).toLowerCase());
};

export {
    getRelations,
    getAddressObj,
    emailValid,
    addressTypes
};