public with sharing class CloneTransactionController {
    private final Transaction__c trans;
    ApexPages.StandardController sController;
    
    public CloneTransactionController(ApexPages.StandardController stdController) {
        sController = stdController;  

		List<String> corrfields = new list<String>();

		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Transaction__c').getDescribe().fields.getMap();
		for(String s : objectFields.keySet()) {
			corrfields.add(s);
		}		
		corrfields.add('Payment_Method__r.Membership__c');
		if(!test.isRunningTest()) 
			stdController.addFields(corrfields);

        this.trans = (Transaction__c)stdController.getRecord();
    }
    
    public PageReference dmlOperation() {
    	 if((trans.Transaction_Type__c == '01' || trans.Transaction_Type__c == '17') && trans.Status__c == 'Rejected'){
    	 	Transaction__c clonedtrans = trans.clone(false,true,false,false);
	        clonedtrans.Status__c = 'Pending';
	        
	        Account membership = [Select Id, Membership_Status__c FROM Account WHERE Id = :this.trans.Payment_Method__r.Membership__c];
	        membership.Membership_Status__c = 'DD Pending';
	        
         	insert clonedtrans;
         	update membership;
         	
         	return new PageReference('/'+clonedtrans.id); 
    	} 
    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Re-submission is not allowed for this type of Transaction'));
    	
         return null;
    }
    

}