/*
* @who   Patrick Duncan <patrick.duncan@weare4c.com>
* @what  Apex controller for the NewMembershipPaymentTypeSelector lightning component 
* @when  25/7/2019
*/
public with sharing class PaymentTypeSelectorController {

	/*
	*  @description Function that gets the selected values from the multi-select picklist Allowed_Payment_Types__c for the Club_Product__c record that a new membership has a lookup to
    *  @param  recordId  The new membership's record id
    *  @return the values selected on Allowed_Payment_Types__c
    */
	@AuraEnabled
	public static List<String> getAllowedPaymentTypes(Id recordId){
		List<Lead> results = [SELECT Id, Membership_Type__c FROM Lead WHERE Id = :recordId];
		List<Club_Product__c> product = [SELECT Id, Allowed_Payment_Types__c FROM Club_Product__c WHERE Id = :results.get(0).Membership_Type__c];
		return product.get(0).Allowed_Payment_Types__c.split(';');
 	}

 	/*
	*  @description Function that updates the billing info and Payment_Method__c fields on a new membership
    *  @param  recordId  The new membership's record id
    *          paymentMethod    The selected Payment_Method__c
    *          paymentDetails   List of size 3 containing billing data - should be null if paymentMethod = 'Cash/Cheque'
    */
	@AuraEnabled
	public static void saveNewMembershipBillingDetails(Id recordId, String paymentMethod, String[] paymentDetails){
		List<Lead> results = [SELECT Id FROM Lead WHERE Id = :recordId];
		results.get(0).Payment_Method__c = paymentMethod;
		if(paymentMethod=='Direct Debit'){
			results.get(0).Bank_Account_Name__c = paymentDetails[0];
			results.get(0).Bank_Account_Number__c = paymentDetails[1];
			results.get(0).Sort_Code__c = paymentDetails[2];
		}

		try{
			update results;

		}
		catch(Exception e){
			System.debug('ERROR SAVING NEW MEMBERSHIP: '+e.getCause()+' '+e.getMessage());
		}
	}    
}