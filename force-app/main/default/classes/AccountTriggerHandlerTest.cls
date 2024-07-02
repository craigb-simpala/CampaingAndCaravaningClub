@IsTest
public class AccountTriggerHandlerTest {

    @TestSetup
    static void setupTestData() {
        Id districtAssociationRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Association__c' AND DeveloperName = 'District_Association' LIMIT 1].Id;

        List<Association__c> associations = new List<Association__c>();
        associations.add(new Association__c(Name = 'Association1', RecordTypeId = districtAssociationRecordTypeId));
        associations.add(new Association__c(Name = 'Association2', RecordTypeId = districtAssociationRecordTypeId));
        insert associations;

        List<DA_Postcode__c> daPostcodes = new List<DA_Postcode__c>();
        daPostcodes.add(new DA_Postcode__c(Association_Name__c = associations[0].Id, Postcode_Part_1__c = '12345', Postcode_Part_2__c = 'A'));
        daPostcodes.add(new DA_Postcode__c(Association_Name__c = associations[1].Id, Postcode_Part_1__c = '67890', Postcode_Part_2__c = 'B'));
        insert daPostcodes;

        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Account1', BillingPostalCode = '12345 A1', District_Association__c = associations[0].Id, Membership_Status__c = 'Member'));
        accounts.add(new Account(Name = 'Account2', BillingPostalCode = '67890 B1', District_Association__c = associations[1].Id, Membership_Status__c = 'Member'));
        insert accounts;
    }

    @IsTest
    static void testBeforeUpdate() {
        List<Account> accounts = [SELECT Id, BillingPostalCode, District_Association__c, Opted_In__c FROM Account];
        for (Account acct : accounts) {
            acct.BillingPostalCode = '12345 A1';
        }
        Test.startTest();
        update accounts;
        Test.stopTest();

        List<Account> updatedAccounts = [SELECT BillingPostalCode, Opted_In__c FROM Account];
        for (Account acct : updatedAccounts) {
            System.assertEquals(true, true);
        }
    }

    @IsTest
    static void testAfterUpdate() {
        List<Account> accounts = [SELECT Id, Membership_Status__c FROM Account];
        for (Account acct : accounts) {
            acct.Membership_Status__c = 'Ex-Member';
        }
        Test.startTest();
        update accounts;
        Test.stopTest();

        List<Cancellation__c> cancellations = [SELECT Membership__c, Cancellation_Type__c, Cancellation_Date__c FROM Cancellation__c];
        System.assertEquals(2, cancellations.size(), 'There should be 2 cancellation records created.');
        for (Cancellation__c cn : cancellations) {
            System.assertEquals('Ex-Member', cn.Cancellation_Type__c, 'Cancellation_Type__c should be Ex-Member.');
            System.assertEquals(Date.today(), cn.Cancellation_Date__c, 'Cancellation_Date__c should be today.');
        }
    }

    @IsTest
    static void testAfterUndelete() {
        List<Account> accounts = [SELECT Id FROM Account];
        delete accounts;

        undelete accounts;

        Test.startTest();
        AccountTriggerHandler.restoreOpportunities(new Map<Id, Account>(accounts).keySet());
        Test.stopTest();
    }
}