public with sharing class TriggerFactory {

	/**
	 * @description 	Class which will be instanstiated if no handler can be located
	 */
	private class EmptyTriggerHandler extends TriggerHandler {}
	
	
	/**
	 * @description 	Locates and instantiates the registered handler for an sObject.
	 * @param soType 	The sObject type to locate the handler for
	 */
	public static void createHandler(Schema.sObjectType soType){
		getHandler(soType).execute();
	}
	

	/**
	 * @description 	Instantiates the correct handler for the sObject type being processed.
	 * @param soType 	The sObject type to instaniate the handler for
	 * @return 			Instance of a new trigger handler for the requested sObject type
	 */
	private static TriggerHandler getHandler(Schema.sObjectType soType){
         if(soType == Account.sObjectType) {
        	return new AccountTriggerHandler();
        }
			
         if(soType == Cancellation__c.sObjectType) {
        	return new CancellationTriggerHandler();
        }
			
         if(soType == Contact.sObjectType) {
        	return new ContactTriggerHandler(); 
        }
 		
         if(soType == Member_Get_Member__c.sObjectType) {
        	return new MemberGetMemberTriggerHandler();
        }
 		
         if(soType == Opportunity.sObjectType) {
        	return new OpportunityTriggerHandler();
        }
 		
         if(soType == Payment_Method__c.sObjectType) {
        	return new PaymentMethodTriggerHandler();
        }
 		
         if(soType == Transaction__c.sObjectType) {
        	return new TransactionTriggerHandler();
        }
 		
		return new EmptyTriggerHandler();
	}
	
}