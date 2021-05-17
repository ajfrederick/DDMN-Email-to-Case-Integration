/**
 * @name ConnectTeamInboundEmailHandler
 * @description creates EmailMessageRelations. SF does this automatically but for some reason it's hit or miss
 * on whether or not it actually links the relations record to a user or contact record. Let's remedy that
**/
public class EmailMessageRelationCreator {

/**
 * FIELDS
**/

    public static final String[] addressTypes = new String[]{'From','To','Cc','Bcc'};

/**
 * ACTION METHODS
**/

    /**
     * @name create
     * @description makes message relations
     * @return void
    **/
    public static void create( EmailMessage[] messages ){

        Map<Id, EmailMessageRelation[]> relationsByMessageId = getRelationsByMessageId( messages );
        Map<Id, EmailMessageRelation[]> existingRelationsByMessageId = getExistingRelationsByMessageId( relationsByMessageId );

        EmailMessageRelation[] relationsToInsert = new EmailMessageRelation[]{};
        EmailMessageRelation[] relationsToUpdate = new EmailMessageRelation[]{};

        // loop through the new relations we just made and then check to see if the 'System'
        // already made a relation for the message and the email address and simply did not connect
        // the user and/or contact record
        for( Id messageId : relationsByMessageId.keyset() ){

            // loop through new relations first
            for( EmailMessageRelation newRelation : relationsByMessageId.get(messageId) ){
                Boolean isUpdate = false;

                // if there are relations that already exist see if they simply need updating
                if( existingRelationsByMessageId.containsKey( messageId ) ){

                    // loop throught the existing relations
                    for( EmailMessageRelation oldRelation : existingRelationsByMessageId.get(messageId) ){

                        // if it needs updating then that means we found a system made relation but it is not
                        // associated with a user or contact record
                        if( needsUpdate( oldRelation, newRelation ) ){
                            oldRelation.RelationId = newRelation.RelationId;
                            relationsToUpdate.add( oldRelation );
                            isUpdate = true;
                        }
                    }
                }

                // if we aren't updating an existing relations then add the new one for insert
                if( !isUpdate ) relationsToInsert.add( newRelation );
            }
        }
        
        try {

            insert relationsToInsert;
            update relationsToUpdate;
            
        } catch( Exception e ){
            ExceptionHandler handler = new ExceptionHandler(e);
            handler.handle();
        }
    }

/**
 * UTILITY METHODS
**/
    /**
     * @name getRelationsByMessageId
     * @description creates all the potential new relations and puts it in a map by message Id
     * This is so we can check if there are any relations that were made by the system but where not
     * properly connected to a user or contact record.
     * @param EmailMessage[) message
     * @return Map<Id, EmailMessageRelation>
    **/
    private static Map<Id, EmailMessageRelation[]> getRelationsByMessageId( EmailMessage[] messages ){
        
        RecipientData recipientData = new RecipientData();

        EmailMessageRelationHelper helper = new EmailMessageRelationHelper( recipientData );

        for( String addressType : addressTypes ){
            recipientData.setType(addressType);
            helper.unpackAddresses(messages);
            helper.getRelations(messages);
        }

        return helper.relationsByMessageId;
    }

    /**
     * @name getExistingRelationsByMessageId
     * @description returns any EmailMessageRelations that are already in the system for all the EmailMessages
     * This is to check above whether or not there is a a relation that already exist but simply isn't link to a Contact or User record
     * but should be if one for the email address exists
     * @param EmailMessage[) message
     * @return Map<Id, EmailMessageRelation>
    **/
    private static Map<Id, EmailMessageRelation[]> getExistingRelationsByMessageId( Map<Id, EmailMessageRelation[]> relationsByMessageId ){
        // this is to check an system made EmailMessageRelations
        EmailMessageRelation[] existingRelations = new EmailMessageRelation[]{};

        try {

            existingRelations.addAll([SELECT
                                    Id,
                                    RelationAddress,
                                    RelationId,
                                    RelationType,
                                    EmailMessageId
                                        FROM EmailMessageRelation
                                        WHERE EmailMessageId IN :relationsByMessageId.keyset()]);

        } catch( Exception e ){
            ExceptionHandler handler = new ExceptionHandler(e);
            handler.debug();
        }

        Map<Id, EmailMessageRelation[]> existingRelationsByMessageId = new Map<Id, EmailMessageRelation[]>();

        for( EmailMessageRelation relation : existingRelations ){
            if( existingRelationsByMessageId.containsKey( relation.EmailMessageId ) ){
                existingRelationsByMessageId.get( relation.EmailMessageId ).add( relation );
            } else {
                existingRelationsByMessageId.put( relation.EmailMessageId, new EmailMessageRelation[]{relation} );
            }
        }

        return existingRelationsByMessageId;
    }


    /**
     * @name needsUpdate
     * @description returns true if the relations match in RelationType, RelationAddress and it does not have a RelationId
     * or the Id does not match
     * @param EmailMessageRelation oldRelation
     * @param EmailMessageRelation newRelation 
     * @return EmailMessageRelation
    **/
    private static Boolean needsUpdate( EmailMessageRelation oldRelation, EmailMessageRelation newRelation ){
        Boolean needsUpdate = false;
        
        if( oldRelation.RelationType == newRelation.RelationType ){
            if( oldRelation.RelationAddress == newRelation.RelationAddress ){
                if( oldRelation.RelationId != newRelation.RelationId ){
                    needsUpdate = true;
                }
            }
        }

        return needsUpdate;
    }
}
