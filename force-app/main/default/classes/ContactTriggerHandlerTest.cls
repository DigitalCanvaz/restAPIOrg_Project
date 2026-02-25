/**
 * @description Unit tests for ContactTrigger (via ContactTriggerHandler).
 * Covers insert/update paths, Web vs non-Web, and idempotency. Uses WITH SECURITY_ENFORCED.
 */
@IsTest
private class ContactTriggerHandlerTest {

    @TestSetup
    static void setupData() {
        // No shared data required; create records per test
    }

    @IsTest
    static void testBeforeInsert_WebSetsPrimary() {
        // Prepare multiple records for bulk behavior
        List<Contact> toInsert = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            toInsert.add(new Contact(LastName = 'Web ' + i, LeadSource = 'Web'));
        }

        Test.startTest();
        insert toInsert;
        Test.stopTest();

        // Assert all got Level__c = 'Primary'
        for (Contact c : [SELECT Id, Level__c FROM Contact WHERE Id IN :toInsert WITH SECURITY_ENFORCED]) {
            System.assertEquals('Primary', c.Level__c, 'Level__c must be Primary on Web insert');
        }
    }

    @IsTest
    static void testBeforeInsert_NonWebDoesNotSet() {
        Contact c = new Contact(LastName = 'NonWeb', LeadSource = 'Phone Inquiry');

        Test.startTest();
        insert c;
        Test.stopTest();

        Contact got = [SELECT Id, Level__c FROM Contact WHERE Id = :c.Id WITH SECURITY_ENFORCED];
        System.assertEquals(null, got.Level__c, 'Level__c should not be set for non-Web insert');
    }

    @IsTest
    static void testBeforeUpdate_WebSetsPrimary() {
        Contact c = new Contact(LastName = 'Upd', LeadSource = 'Partner Referral', Level__c = null);
        insert c;

        // Change LeadSource to Web
        c.LeadSource = 'Web';

        Test.startTest();
        update c;
        Test.stopTest();

        Contact got = [SELECT Id, LeadSource, Level__c FROM Contact WHERE Id = :c.Id WITH SECURITY_ENFORCED];
        System.assertEquals('Web', got.LeadSource, 'LeadSource should be Web after update');
        System.assertEquals('Primary', got.Level__c, 'Level__c should be Primary when LeadSource is Web after update');
    }

    @IsTest
    static void testBeforeUpdate_IdempotentWhenAlreadyPrimary() {
        Contact c = new Contact(LastName = 'AlreadyPrimary', LeadSource = 'Web', Level__c = 'Primary');
        insert c;

        // Update another field; ensure no errors and value remains
        c.FirstName = 'X';

        Test.startTest();
        update c;
        Test.stopTest();

        Contact got = [SELECT Id, Level__c FROM Contact WHERE Id = :c.Id WITH SECURITY_ENFORCED];
        System.assertEquals('Primary', got.Level__c, 'Level__c remains Primary for Web contacts');
    }
}
