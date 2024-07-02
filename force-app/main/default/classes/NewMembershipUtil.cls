/**
 *  @who    Jordan Fraser jordan.fraser@weare4c.com
 *  @when   08/07/2019
 *  @what   Utility methods relevant to the New Memberships process.
 */


public with sharing class NewMembershipUtil {


	@InvocableMethod ( label = 'Calculate section pricing.' description = 'Parses the provided string of section names and returns the total price.')
	public static List<Decimal> calculateTotalSectionPrice(String[] sectionLists) {
		
		// Initialise return collection.
		List<Decimal> returnedPrices = new List<Decimal>();

		// Generate map of section product records.
		Map<String, Club_Product__c> products = new Map<String, Club_Product__c>();

		Date today = Date.today();
		List<Club_Product__c> productList = [SELECT Id,Name,Product_Detail__c,Product_Description__c,
					(SELECT Price__c FROM Prices__r WHERE Start_Date__c <= :today AND (End_Date__c >= :today or End_Date__c = null) ORDER BY Start_Date__c) 
					FROM Club_Product__c WHERE RecordType.Name='Section' ORDER BY Name];
		
		
		if (productList.size() > 0) {
			for (Club_Product__c product : productList) {
				products.put(product.Name, product);
			}


			// Iterate through lists of sections. 
			if (sectionLists.size() > 0) {
				for (String sectionList : sectionLists) {
				
					if (!String.isBlank(sectionList)) {
						
						// Initialise running total price.
						Decimal price = 0;

						// Split string into individual section names.
						List<String> sections = sectionList.split(':',-2);

						// Iterate through sections and add price to total.
						for (String section : sections) {
							if (products.containsKey(section)) {
								Club_Product__c product = products.get(section);
								if (product.Prices__r.size() > 0) {
									price += product.Prices__r[0].Price__c;
								}
							}
						}

						// Assign total to returnedPrices.
						returnedPrices.add(price);
					}
				}
			}			
		}
		
		// Return total price.
		return returnedPrices;
		}
		
	}