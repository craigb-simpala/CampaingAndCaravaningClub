@isTest
public with sharing class SandboxRefreshEmailInvalidatorTest {

    @testSetup
    static void setup(){
        List<Account> accounts = new List<Account>();
        for(Integer i=0;i<200;i++){
            Account acc = new Account(Name='Test'+i,Email__c='test@test.com');
            accounts.add(acc);
        }
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        for(Integer i=0;i<200;i++){
            Contact con = new Contact(LastName='Test'+i);
            contacts.add(con);
        }
        insert contacts;

        List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<200;i++){
            Lead lead = new Lead(LastName='Test'+i,Email='test@test.com', Company='test', Secondary_Member_Email__c='test@test.com');
            leads.add(lead);
        }
        insert leads;
    }

    /*
    * @method invalidateEmailAddresses
    * @case when refreshing the sandbox with 200 account records with non-null emails
    * @result expect the email__c field on each account to be appended with '.invalid'
    */
    @isTest
    static void testInvalidateAccountEmails() {
        Test.startTest();
            // Using any Ids as orgId and sandboxId for test, e.g. Account Ids 
            // Id possible pass valid id
            Test.testSandboxPostCopyScript(
                new SandboxRefreshEmailInvalidator(), 
                UserInfo.getOrganizationId(), 
                UserInfo.getOrganizationId(), 
                UserInfo.getOrganizationName()
            ); 
        Test.stopTest();
        List<Account> accounts = [SELECT Id, Email__c FROM Account];
        for(Account account:accounts){
            System.assert(account.Email__c.endsWith('.invalid'));
        }
    }

    /*
    * @method invalidateEmailAddresses
    * @case when refreshing the sandbox with 200 lead records with 2 non-null emails fields
    * @result expect the Email & Secondary_Member_Email__c fields on each lead to be appended with '.invalid'
    */
    @isTest
    static void testInvalidateLeadEmails() {
        Test.startTest();
            Test.testSandboxPostCopyScript(
                new SandboxRefreshEmailInvalidator(), 
                UserInfo.getOrganizationId(), 
                UserInfo.getOrganizationId(), 
                UserInfo.getOrganizationName()
            ); 
        Test.stopTest();
        List<Lead> leads = [SELECT Id, Email, Secondary_Member_Email__c FROM Lead];
        for(Lead lead:leads){
            System.assert(lead.Email.endsWith('.invalid'));
            System.assert(lead.Secondary_Member_Email__c.endsWith('.invalid'));

        }
    }

    /*
    * @method invalidateEmailAddresses
    * @case when refreshing the sandbox with 200 contact records with a null email field
    * @result expect the Email field on each contact to still be null
    */
    @isTest
    static void testContactEmailsUnchanged() {
        Test.startTest();
            Test.testSandboxPostCopyScript(
                new SandboxRefreshEmailInvalidator(), 
                UserInfo.getOrganizationId(), 
                UserInfo.getOrganizationId(), 
                UserInfo.getOrganizationName()
            ); 
        Test.stopTest();
        List<Contact> contacts = [SELECT Id, Email FROM Contact];
        for(Contact contact:contacts){
            System.assert(contact.Email==null);
        }
    }
    
}