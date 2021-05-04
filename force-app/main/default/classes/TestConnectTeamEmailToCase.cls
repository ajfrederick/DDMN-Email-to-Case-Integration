/**
 * @name TestConnectTeamEmailToCase
 * @description This is a functional test class. It is responsible for testing the complete functionality of the connect team's
 * email to case email response code
**/
@isTest
public class TestConnectTeamEmailToCase {

/**
 * DATA SETUP
**/

    @TestSetup
    static void makeData(){
        
        Account account = new Account(
            Name = 'New Account'
        );
        insert account;

        Contact contact = new Contact(
            FirstName = 'New',
            LastName = 'Contact',
            Email = 'contact@test.com',
            AccountId = account.Id
        );
        insert contact;
    }

/**
 * TEST METHODS
**/

    @isTest
    static void testNewCaseWithContact(){
        Case record = getCaseWithContact();

        Test.startTest();
            insert record;
            Integer inv = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals( 1, inv );
    }

    @isTest
    static void testNewCaseWithNoContact(){
        Case record = getCase();
        record.SuppliedEmail = 'test@test.com';

        Test.startTest();
            insert record;
            Integer inv = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals( 1, inv );
    }

    @isTest
    static void testClosedCase(){
        Case record = getCaseWithContact();
        insert record;

        record.Status = 'Closed';

        Test.startTest();
            update record;
            Integer inv = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals( 1, inv );
    }

    @isTest
    static void testIsNotConnectTeamCase(){
        Case record = new Case(
            Origin = 'Email'
        );

        Test.startTest();
            insert record;
            Integer inv = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals( 0, inv );
    }

    @isTest
    static void testNewConnectTeamCaseNoEmail(){
        Case record = getCase();

        Test.startTest();
            insert record;
            Integer inv = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals( 0, inv );
    }

    @isTest
    static void testUpdateConnectTeamCaseNoEmail(){
        Case record = getCase();
        insert record;

        record.SuppliedEmail = 'test@test.com';

        Test.startTest();
            update record;
            Integer inv = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals( 1, inv );
    }

/**
 * UTILITY METHODS
**/

    private static Case getCase(){
        return new Case(
            RecordTypeId = Constants.CONNECT_TEAM_RECORD_TYPE_ID,
            Origin = 'Email'
        );
    }

    private static Case getCaseWithContact(){
        Contact contact = getContact();

        Case record = getCase();
        record.ContactId = contact.Id;

        return record;
    }

    private static Contact getContact(){
        return [SELECT 
                    Id,
                    Email
                FROM Contact LIMIT 1];
    }
}
