/**
 * @name CaseHelper
 * @description Helper class for Case Trigger
**/
public class CaseHelper {

/**
 * TIGGER METHODS
**/

    /**
     * @name afterInsert
     * @description called by CaseTrigger after insert
     * @param Map<Id, Case> newMap
     * @return void
    **/
    public static void afterInsert( Map<Id, Case> newMap ){

    }

    /**
     * @name afterUpdate
     * @description called by CaseTrigger after update
     * @param Map<Id, Case> oldMap
     * @param Map<Id, Case> newMap
     * @return void
    **/
    public static void afterUpdate( Map<Id, Case> oldMap, Map<Id, Case> newMap ){
        ConnectTeamCaseSorter sorter = new ConnectTeamCaseSorter( newMap );

        Case[] closedCases = sorter.getClosedCases( oldMap );
        Case[] emailChangedCases = sorter.getEmailChangedCases( oldMap );

        sendEmails( closedCases, Constants.CLOSED_EMAIL_TEMPLATE_NAME );
        //sendEmails( emailChangedCases, Constants.NEW_EMAIL_TEMPLATE_NAME );
    }

/**
 * ACTION METHODS
**/

    /**
     * @name sendEmails
     * @description Sends email alerts for new cases
     * @param Case[] cases
     * @param String templateName
     * @return void
    **/
    private static void sendEmails( Case[] cases, String templateName ){
        EmailExtractorCase extractor = new EmailExtractorCase();
        extractor.setTemplate( templateName );
        extractor.setWrappers( cases );

        // instatiate a message creator, set option, then set messages
        MessageCreatorOutbound messageCreator = new MessageCreatorOutbound( extractor.getWrappers() );
        messageCreator.setOrgWideEmailAddressId( Utils.FROM_ADDRESS );
        messageCreator.setMessages();

        // send the emails
        MessageHandler handler = new MessageHandler();
        handler.handle( messageCreator );
    }

}