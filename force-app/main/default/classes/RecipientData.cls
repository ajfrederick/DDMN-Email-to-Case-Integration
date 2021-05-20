/**
 * @name RecipientData
 * @description gets recipient (User/Contact) data to help create prop EmailMessageRelations
**/
public class RecipientData {

/**
 * FIELDS
 */

    public String type {get;set;}

    public Map<Id, SObject> recipientsById {
        get {
            if( recipientsById == null ) recipientsById = new Map<Id, SObject>();
            return recipientsById;
        }
        set;
    }

    public Map<String, SObject> recipientsByAddress {
        get {
            if( recipientsByAddress == null ) recipientsByAddress = new Map<String, SObject>();
            return recipientsByAddress;
        }
        set;
    }

/**
 * CONSTRUCTOR
 */

    public RecipientData(){

    }

/**
 * ACTION METHODS
 */

    public void setType( String t ){
        type = t;
    }

/**
 * QUERY METHODS
 */

    public void getRecipients( Set<Id> recipientIds, String[] recipientAddresses ){
        if( recipientIds.isEmpty() && recipientAddresses.isEmpty() ) return;
        
        SObject[] recipients = new SObject[]{};

        try {

            recipients.addAll([SELECT 
                                Id,
                                Email
                                    FROM Contact 
                                    WHERE Id IN :recipientIds
                                    OR Email IN :recipientAddresses]);

            recipients.addAll([SELECT 
                                Id,
                                Email
                                    FROM User 
                                    WHERE Id IN :recipientIds
                                    OR Email IN :recipientAddresses]);

        } catch( QueryException qe ){
            ExceptionHandler handler = new ExceptionHandler(qe);
            handler.debug();
        }

        for( SObject recipient : recipients ){
            Id id = recipient.Id;

            if( recipientIds.contains(id) ){
                recipientsById.put(id, recipient );
            } else {
                recipientsByAddress.put( (String) recipient.get('Email'), recipient );
            }
        }
    }
}
