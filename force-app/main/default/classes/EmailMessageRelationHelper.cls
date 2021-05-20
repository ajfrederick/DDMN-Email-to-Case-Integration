/**
 * @name EmailMessageRelationHelper
 * @description Helps pull and sort address/recipient data EmailMessage's to help create EmailMessageRelations that the System
 * doesn't create
**/
public class EmailMessageRelationHelper {
  
/**
 * FIELDS
**/

    private RecipientData data {get;set;}

    public Map<Id, EmailMessageRelation[]> relationsByMessageId {
        get {
            if( relationsByMessageId == null ) relationsByMessageId = new Map<Id, EmailMessageRelation[]>();
            return relationsByMessageId;
        }
        set;
    }

/**
 * CONSTRUCTOR
**/

    public EmailMessageRelationHelper( RecipientData d ){
        data = d;
    }

/**
 * ACTION METHODS
**/

    public void unpackAddresses( EmailMessage[] messages ){
        if( String.isBlank(data.type) ) return;

        Set<Id> ids = new Set<Id>();
        String[] addresses = new String[]{};

        for( EmailMessage message : messages ){

            for( String address : getAddresses(message) ){
                addresses.add(address);
            }

            /*for( Id id : getIds(message) ){
                ids.add(id);
            }*/
        }

        data.getRecipients( ids, addresses );
    }

    public void getRelations( EmailMessage[] messages ){
        if( String.isBlank(data.type) ) return;

        for( EmailMessage message : messages ){
            String messageId = message.Id;

            if( !relationsByMessageId.containsKey(messageId) ){
                relationsByMessageId.put( messageId, new EmailMessageRelation[]{} );
            }

            //setRelationsFromIds( message );
            setRelationsFromAddress( message );
        }

    }
    
    private void setRelationsFromIds( EmailMessage message ){
        String messageId = message.Id;

        EmailMessageRelation[] relations = relationsByMessageId.get(messageId);
        
        // loop through email message addresses that were stored in the Id fields
        for( Id id : getIds( message ) ){
            String address = '';

            if( data.recipientsById.containsKey(id) ){
                address = (String) data.recipientsById.get(id).get('Email');
            }

            relations.add( getRelation( messageId, id, address ) );
        }
    }

    private void setRelationsFromAddress( EmailMessage message ){
        String messageId = message.Id;

        EmailMessageRelation[] relations = relationsByMessageId.get(messageId);

        // loop through email message addresses that were stored in the Address fields
        for( String address : getAddresses( message ) ){
            address = address.trim();

            Id id;

            if( data.recipientsByAddress.containsKey(address) ){
                id = (Id) data.recipientsByAddress.get(address).Id;
            }

            // if there is no internal recipient (ie User or Contact) then we don't have to worry about making
            // a relation the system has already done so.
            if( id == null ) continue;

            relations.add( getRelation( messageId, id, address ) );
        }
    }

/**
 * UTILITY METHODS
**/

    private Id[] getIds( EmailMessage message ){       
        Id[] ids = new Id[]{};

        switch on data.type {
            when 'To' {
                ids.addAll( message.ToIds );
            }
            when 'Cc' {
                ids.addAll( message.CcIds );
            }
            when 'Bcc' {
                ids.addAll( message.BccIds );
            }
        }
        
        return ids;
    }

    private String[] getAddresses( EmailMessage message ){
        String[] addresses = new String[]{};

        String addressString;

        switch on data.type {
            when 'From' {
                addresses.add(message.FromAddress);
            }
            when 'To'  {
                addressString = message.ToAddress;
            }
            when 'Cc'  {
                addressString = message.CcAddress;
            }
            when 'Bcc'  {
                addressString = message.BccAddress;
            }
        }

        if( addressString != null ){
            for( String address : addressString.split(';') ){
                addresses.add(address.trim());
            }
        }

        return addresses;
    }

    private EmailMessageRelation getRelation( Id messageId, Id relationId, String relationAddress ){
        return new EmailMessageRelation(
            emailMessageId = messageId,
            relationId = relationId,
            relationAddress = relationAddress,
            relationType = data.type + 'Address'
        );
    }
}