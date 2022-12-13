/**
 * @name TriggerHook
 * @description this interface allows an external application access to this Email Applications EmailMessageTrigger to perform
 * operations when an email message is sent or received.
 * 
 * @author Creed Interactive (Andrew Frederick) October 2021
 */
global interface TriggerHook {
    void beforeInsert( Map<Id, EmailMessage> newMap );
    void beforeUpdate( Map<Id, EmailMessage> oldMap, Map<Id, EmailMessage> newMap );
    void beforeDelete( Map<Id, EmailMessage> oldMap, Map<Id, EmailMessage> newMap );
    void afterInsert( Map<Id, EmailMessage> newMap );
    void afterUpdate( Map<Id, EmailMessage> oldMap, Map<Id, EmailMessage> newMap );
    void afterDelete( Map<Id, EmailMessage> oldMap, Map<Id, EmailMessage> newMap );
    void afterUndelete( EmailMessage[] undeletedList );
}