/**
 * @name EmailMessageRelationUtil
 * @description Ensures that system generated EmailMessageRelations get associated with recipient record
**/
global class EmailMessageRelationUtil {

    /**
     * @name updateRelationIds
     * @description updates EmailMessageRelations if they aren't properly associated with a Contact or User record
     * @param EmailMessage[] message
     * @return Map<Id, EmailMessageRelation>
    **/
    global static void updateRelationIds( EmailMessage[] messages ){
        if( !EmailPost.triggerEnabled ) return;

        Set<Id> messageIds = new Map<Id, EmailMessage>( messages ).keyset();

        EmailMessageRelation[] relations = getRelations( messageIds );

        String[] addresses = new String[]{};

        for( EmailMessageRelation relation : relations ){
            addresses.add( relation.RelationAddress );
        }

        Map<String, SObject> recipientsByAddress = getRecipientsByAddress( addresses );

        EmailMessageRelation[] relationsToUpdate = new EmailMessageRelation[]{};

        for( EmailMessageRelation relation : relations ){
            if( relation.RelationId != null ) continue;

            String address = relation.RelationAddress;

            if( !recipientsByAddress.containsKey( address ) ) continue;

            relation.RelationId = recipientsByAddress.get(address).Id;

            relationsToUpdate.add(relation);
        }

        try {

            update relationsToUpdate;

        } catch( Exception e ){
            CreedExceptionHandler handler = new CreedExceptionHandler(e);
            handler.handle();
        }

        EmailPost.triggerEnabled = null;
    }

    /**
     * @name getExistingRelationsByMessageId
     * @description returns any EmailMessageRelations, which are system generated, for all the EmailMessages to update them if
     * they aren't associated properly with a User or Contact
     * @param Set<Id> messageIds
     * @return Map<Id, EmailMessageRelation>
    **/
    private static EmailMessageRelation[] getRelations( Set<Id> messageIds ){
        EmailMessageRelation[] relations = new EmailMessageRelation[]{};

        try {

            relations.addAll([SELECT
                                Id,
                                RelationAddress,
                                RelationId,
                                RelationType,
                                EmailMessageId
                                    FROM EmailMessageRelation
                                    WHERE EmailMessageId IN :messageIds]);

        } catch( Exception e ){
            CreedExceptionHandler handler = new CreedExceptionHandler(e);
            handler.debug();
        }

        return relations;
    }

    /**
     * @name getRecipientsByAddress
     * @description returns map of recipient records (User or Contact) keyed on their email address
     * @param Set<Id> messageIds
     * @return Map<Id, EmailMessageRelation>
    **/
    private static Map<String, SObject> getRecipientsByAddress( String[] addresses ){
        SObject[] recipients = new SObject[]{};

        try {

            recipients.addAll([SELECT
                                Id,
                                Email
                                    FROM User
                                    WHERE Email IN :addresses]);

            recipients.addAll([SELECT
                                Id,
                                Email
                                    FROM Contact
                                    WHERE Email IN :addresses]);

        } catch( Exception e ){
            CreedExceptionHandler handler = new CreedExceptionHandler(e);
            handler.debug();
        }

        Map<String, SObject> recipientsByAddress = new Map<String, SObject>();

        for( SObject recipient : recipients ){
            recipientsByAddress.put( (String) recipient.get('Email'), recipient );
        }

        return recipientsByAddress;
    }
}