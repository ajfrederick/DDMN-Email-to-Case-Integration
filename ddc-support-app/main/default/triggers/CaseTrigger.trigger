trigger CaseTrigger on Case ( 
    //before insert, 
    //before update,
    //before delete,
    after insert, 
    after update
    //after delete,
    //after undelete
) {
    if( Trigger.isBefore ){
        if( Trigger.isInsert ){

        } else 
        if( Trigger.isUpdate ){

        } else 
        if( Trigger.isDelete ){

        }
    } else 
    if( Trigger.isAfter ){
        if( Trigger.isInsert ){
            //CaseHelper.afterInsert( Trigger.newMap );
        } else 
        if( Trigger.isUpdate ){
            CaseHelper.afterUpdate( Trigger.oldMap, Trigger.newMap );
        } else 
        if( Trigger.isDelete ){

        }  else 
        if( Trigger.isUndelete ){

        }  
    }
}