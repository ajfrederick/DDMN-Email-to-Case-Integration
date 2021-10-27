/**
 * @name EmailContainerCreatorCase
 * @description 
 * 
 * defines specifically how to get email info from Case
 * this is done because a Case may or may not have a Contact associated with it so we need to plan for two scenarios
 * 
 * 1) When a case has a contact
 * 2) When it does not
**/
public class EmailContainerCreatorCase extends EmailContainerCreator {

/**
 * CONSTRUCTOR
**/

    public EmailContainerCreatorCase(){

    }

/**
 * ACTION METHODS
**/ 
    
    /**
     * @name create
     * @description deconstructs email addresses
     * @param SObject[] objs
     * @return void
    **/
    public override void create( SObject[] objs ){
        Case[] cases = (Case[]) objs;

        for( Case obj : cases ){
            if( obj.ContactEmail == null && obj.SuppliedEmail == null ) continue;
            
            EmailContainer container = new EmailContainer();
            container.whatId = obj.Id;
            container.template = template;

            container.setContent( obj.Subject, obj.Description, obj.Description );
        
            // Scenario 1
            if( obj.ContactEmail != null ){
                container.ToAddresses.add(obj.ContactEmail);
                container.whoId = obj.ContactId;
            // Scenario 2
            } else
            if( obj.SuppliedEmail != null ){
                container.ToAddresses.add(obj.SuppliedEmail);
            }

            containers.add( container );
        }
    }
}