global class BatchCreateDDTransactions implements Database.Batchable<sObject> {

//  global String QUERY = 'select id,Mandate_Amount__c,(select id from Transactions__r where Transaction_Type__c !=\'0N\' and Transaction_Type__c !=\'0C\') from Payment_Method__c where DD_Transaction_dd_mm__c = :ddmm and status__c=\'Active\' and recordtypeid=:sc.PaymentMethodDDRecordTypeId '; 
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        constants sc = new constants();
        
        Datetime D = Datetime.now().addDays(-1);
        String ddmm = D.format('dd/MM');
        
        system.debug(ddmm);
        
        String QUERY = 'select id,createddate,Membership__r.Date_Joined__c,Mandate_Amount__c,Sort_Code__c,Bank_Account_Name__c,Bank_Account_Number__c, (select id from Transactions__r where Transaction_Type__c !=\'0N\' and Transaction_Type__c !=\'0C\' and Status__c!=\'Pending\') from Payment_Method__c where DD_Transaction_dd_mm__c = :ddmm and mandate_amount__c>0 and status__c=\'Active\' and Renewal_Payment_Pending__c = true and recordtypeid=\''+sc.PaymentMethodDDRecordTypeId+'\''; 

        if(Test.isRunningTest()) {
            return Database.getQueryLocator(QUERY + ' LIMIT 200');
        }

        
        //ddmm ='07/12';
        
        return Database.getQueryLocator(QUERY);
    }

    global void execute(Database.BatchableContext BC, List<Payment_Method__c> scope) {
        constants sc = new constants();

        List<Transaction__c> transactions = new List<Transaction__c>();
        List<Payment_Method__c> paymentMethodsToUpdate = new List<Payment_Method__c>();
		
		BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
		Long days8Milliseconds = 691200000;

        for(Payment_Method__c pm : scope) {
        	if(system.now().addDays(-10)>pm.Membership__r.Date_Joined__c){
	            Transaction__c t = new Transaction__c(
	//                                       Customer_Sort_Code__c = pm.Sort_Code__c,
	//                                       Customer_Account_Name__c = pm.Bank_Account_Name__c,
	//                                       Customer_Account_Number__c = pm.Bank_Account_Number__c,
	                                         Transaction_Date__c = date.today(),
	                                         Amount__c = pm.Mandate_Amount__c,
	                                         Status__c = 'Pending',
	                                         Payment_Method__c = pm.Id,  
	                                         RecordTypeid = sc.trddebitRecordTypeId                        
	                                );
	            if(pm.transactions__r.size()>0){
	                t.Transaction_Type__c = '17';
	            }
				else
				{
					t.Transaction_Type__c = '01';
				}
				if(pm.CreatedDate.adddays(10)>datetime.now()){
					t.Transaction_Date__c = 	BusinessHours.add(bh.id, pm.createddate, days8Milliseconds).date();
				}
				transactions.add(t);
	            
	        }

	        // Set Renewal_Payment_Pending__c flag back to false to ensure that another payment isn't processed
	        // until the next renewal if the membership term is longer than a year.
	        pm.Renewal_Payment_Pending__c = false;
	        paymentMethodsToUpdate.add(pm);
        }
        
        insert transactions; 
        update paymentMethodsToUpdate;


    }

    global void finish(Database.BatchableContext BC) {}
		
}