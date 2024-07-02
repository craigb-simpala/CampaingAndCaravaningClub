/**
 *  @who    Jordan Fraser jordan.fraser@weare4c.com
 *  @when   05/07/2019
 *  @what   Logic for the FindIncompleteMemberships Lightning Component.
 */

public with sharing class FindIncompleteMembershipsHandler {
	
	
	/**
    *  Returns a list of leads that meet the search criteria.
    *
    *  @param  surname	The last name of the lead. One of three possible search criteria.
    *  @param  postcode	The postal code of the lead. One of three possible search criteria.
    *  @param  email	The email of the lead. One of three possible search criteria.
    *  @return Lead[] 	List of matching lead records.
    */

	@AuraEnabled
	public static Lead[] findLeads(String surname, String postcode, String email) {
		
		Lead[] results = new List<Lead>();

		// Return empty array if no parameters provided.
		if (String.isBlank(surname) && String.isBlank(postcode) && String.isBlank(email)) {
			return results;
		}

		// Build query.
		String query = 'SELECT Id, FirstName, LastName, PostalCode, Email FROM Lead WHERE IsConverted = false';
		
		if (!String.isBlank(surname)) {
			query += ' AND LastName LIKE \'%' + String.escapeSingleQuotes(surname) + '%\'';
		}

		if (!String.isBlank(postcode)) {
			query += ' AND PostalCode = \'' + String.escapeSingleQuotes(postcode) + '\'';
		}

		if (!String.isBlank(email)) {
			query += ' AND Email = \'' + String.escapeSingleQuotes(email) + '\'';
		}
		

		// Execute query.
		results = Database.query(query);
		return results;
	}


	/**
    *  Returns a list of account records that meet the search criteria.
    *
    *  @param  surname	The last name of the account. One of three possible search criteria.
    *  @param  postcode	The postal code of the account. One of three possible search criteria.
    *  @param  email	The email of the account. One of three possible search criteria.
    *  @return Lead[] 	List of matching account records.
    */

	@AuraEnabled
	public static Account[] findAccounts(String surname, String postcode, String email) {
		Account[] results = new List<Account>();

		// Return empty array if no parameters provided.
		if (String.isBlank(surname) && String.isBlank(postcode) && String.isBlank(email)) {
			return results;
		}

		// Build query.
		String query = 'SELECT Id, Name, BillingStreet, BillingCity, BillingPostalCode, Hybrid_Membership_Number__c, Membership_Status__c, Email__c FROM Account WHERE Name != null';
		
		if (!String.isBlank(surname)) {
			query += ' AND Name LIKE \'%' + String.escapeSingleQuotes(surname) + '%\'';
		}

		if (!String.isBlank(postcode)) {
			query += ' AND BillingPostalCode = \'' + String.escapeSingleQuotes(postcode) + '\'';
		}

		if (!String.isBlank(email)) {
			query += ' AND Email__c = \'' + String.escapeSingleQuotes(email) + '\'';
		}
		

		// Execute query.
		results = Database.query(query);
		return results;
	}

	/**
    *  Create a new lead record.
    *
    *  @param  surname	The last name of the lead.
    *  @param  postcode	The postal code of the lead.
    *  @param  email	The email of the lead.
    *  @return newLead	The created lead record.
    */

	@AuraEnabled
	public static Lead createLead(String surname, String postcode, String email) {

		// Instantiate lead.
		Lead newLead = new Lead(LastName = surname,
								Company = surname,
								PostalCode = postcode,
								Email = email);

		
		// Insert lead.
		try {
			insert newLead;
		}
		
		// If lead cannot be inserted, return an error message to the user.
		catch (Exception e) {
			throw new AuraHandledException('There was a problem creating this New Membership. Error message: ' + e.getMessage());
		}
		

		return newLead;
	}


}