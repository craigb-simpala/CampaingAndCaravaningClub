/**
 *  @who    Jordan Fraser jordan.fraser@weare4c.com
 *  @when   05/07/2019
 *  @what   Test class for FindIncompleteMembershipsHandler
 */

@isTest
public class FindIncompleteMembershipsHandlerTest {
	
	// Set up test data.
	@testSetup static void testSetup() {
		
		Lead[] leads = new List<Lead>();
		Account[] accounts = new List<Account>();

		for (Integer i = 0; i < 200; i++) {
			Lead lea = new Lead(LastName = 'Test ' + i,
								Company = 'Test ' + i,
								PostalCode = 'EC3M 5DJ',
								Email = 'example@example.com');
			leads.add(lea);

			Account acc = new Account(Name = 'Test Account ' + i,
								BillingPostalCode = 'EC3M 5DJ',
								Email__c = 'example@example.com');
			accounts.add(acc);
		}
		
		insert leads;
		insert accounts;

		

	}

	
	// Test when criteria match existing records.
	@isTest static void testFindLeadsPositive() {
		Test.startTest();
		Lead[] leads = FindIncompleteMembershipsHandler.findLeads('Test', 'EC3M 5DJ', 'example@example.com');
		Test.stopTest();

		System.assertEquals(200, leads.size());

	}

	// Test when criteria do not match existing records.
	@isTest static void testFindLeadsNegative() {
		Test.startTest();
		Lead[] leads = FindIncompleteMembershipsHandler.findLeads('Test', 'EC3M 5DJ', 'otheremail@example.com');
		Test.stopTest();

		System.assertEquals(0, leads.size());

	}

	// Test when no criteria are provided.
	@isTest static void testFindLeadsNull() {
		Test.startTest();
		Lead[] leads = FindIncompleteMembershipsHandler.findLeads('', '', '');
		Test.stopTest();

		System.assertEquals(0, leads.size());

	}

	// Test when criteria match existing records.
	@isTest static void testFindAccountsPositive() {
		Test.startTest();
		Account[] accounts = FindIncompleteMembershipsHandler.findAccounts('Test', 'EC3M 5DJ', 'example@example.com');
		Test.stopTest();

		System.assertEquals(200, accounts.size());

	}

	// Test when criteria do not match existing records.
	@isTest static void testFindAccountsNegative() {
		Test.startTest();
		Account[] accounts = FindIncompleteMembershipsHandler.findAccounts('Test', 'EC3M 5DJ', 'otheremail@example.com');
		Test.stopTest();

		System.assertEquals(0, accounts.size());

	}

	// Test when no criteria are provided.
	@isTest static void testFindAccountsNull() {
		Test.startTest();
		Account[] accounts = FindIncompleteMembershipsHandler.findAccounts('', '', '');
		Test.stopTest();

		System.assertEquals(0, accounts.size());

	}

	// Test when lead is successfully created.
	@isTest static void testCreateLeadPositive() {
		Test.startTest();
		FindIncompleteMembershipsHandler.createLead('New Lead', 'EC3M 5DJ', 'example@example.com');
		Test.stopTest();

		Lead[] leads = [SELECT Id FROM Lead WHERE LastName = 'New Lead'];
		System.assertEquals(1, leads.size());
	}

	// Test when lead cannot be created.
	@isTest static void testCreateLeadNegative() {
		Test.startTest();
		try {
			FindIncompleteMembershipsHandler.createLead('', 'SE17 3AF', 'example@example.com');
			System.assert(false,'An expected error was not caught.');
			} catch (Exception e) {
				System.assert(true);
			}
		
		Test.stopTest();

		Lead[] leads = [SELECT Id FROM Lead WHERE PostalCode = 'SE17 3AF'];
		System.assertEquals(0, leads.size());
	}

}