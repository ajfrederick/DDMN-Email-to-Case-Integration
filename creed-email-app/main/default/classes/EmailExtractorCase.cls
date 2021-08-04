/**
 * @name EmailExtractorCase
 * @description 
 * 
 * defines specifically how to get email info from Case
 * this is done because a Case may or may not have a Contact associated with it so we need to plan for two scenarios
 * 
 * 1) When a case has a contact
 * 2) When it does not
**/
public class EmailExtractorCase extends EmailExtractor {

/**
 * CONSTRUCTOR
**/

    public EmailExtractorCase(){

    }

/**
 * ACTION METHODS
**/ 
    
    /**
     * @name setWrappers
     * @description deconstructs email addresses
     * @param SObject[] objs
     * @return void
    **/
    public override void setWrappers( SObject[] objs ){
        Case[] cases = (Case[]) objs;

        for( Case obj : cases ){
            if( obj.ContactEmail == null && obj.SuppliedEmail == null ) continue;
            
            EmailInfo wrapper = new EmailInfo();
            wrapper.whatId = obj.Id;
            wrapper.template = template;
        
            // Scenario 1
            if( obj.ContactEmail != null ){
                wrapper.ToAddresses.add(obj.ContactEmail);
                wrapper.whoId = obj.ContactId;
            // Scenario 2
            } else
            if( obj.SuppliedEmail != null ){
                wrapper.ToAddresses.add(obj.SuppliedEmail);
            }

            wrappers.add( wrapper );
        }
    }
}