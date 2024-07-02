/**
 *  @who    Jordan Fraser jordan.fraser@weare4c.com
 *  @when   08/07/2019
 *  @what   Test methods for NewMembershipUtil.
 */

@isTest
public class NewMembershipUtilTest {


	@isTest static void testCalculateTotalSectionPricePositive() {

		String clubProdSectionRecordTypeId = Schema.SObjectType.Club_Product__c.RecordTypeInfosByName.get('Section').RecordTypeId;

		// Set up Club_Product__c records.
		Club_Product__c[] products = new List<Club_Product__c>();

		Club_Product__c product1 = new Club_Product__c(Name = 'product1',
														RecordTypeId = clubProdSectionRecordTypeId);
		products.add(product1);

		Club_Product__c product2 = new Club_Product__c(Name = 'product2',
														RecordTypeId = clubProdSectionRecordTypeId);
		products.add(product2);

		Club_Product__c product3 = new Club_Product__c(Name = 'product3',
														RecordTypeId = clubProdSectionRecordTypeId);
		products.add(product3);

		insert products;

		// Set up Price__c records.
		Price__c[] prices = new List<Price__c>();
		for (Club_Product__c product : products) {
			Price__c price = new Price__c(Price__c = 5,
										Product__c = product.id,
										Start_Date__c = Date.newInstance(1970, 01, 01),
										End_Date__c = Date.newInstance(2270, 01, 01));
			prices.add(price);

		}
		insert prices;



		// Run test.
		Test.startTest();
		List<String> inputs = new List<String>();
		for (Integer i = 0; i < 100; i++) {
			inputs.add('product1:product2:product3');
		}
		Decimal[] outputs = NewMembershipUtil.calculateTotalSectionPrice(inputs);
		Test.stopTest();

		// Validate results.
		for (Decimal output : outputs) {
			System.assertEquals(15.0, output);
		}


	}

	@isTest static void testCalculateTotalSectionPriceNegative() {
		// Run test.
		Test.startTest();
		List<String> inputs = new List<String>();
		for (Integer i = 0; i < 100; i++) {
			inputs.add('product1:product2:product3');
		}
		Decimal[] outputs = NewMembershipUtil.calculateTotalSectionPrice(inputs);
		Test.stopTest();

		// Validate results.
		for (Decimal output : outputs) {
			System.assertEquals(0, output);
		}
	}
	
}