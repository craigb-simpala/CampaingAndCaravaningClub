public with sharing class CancellationTriggerHandler extends TriggerHandler {

    public CancellationTriggerHandler(){
        preventRecursiveTrigger(false);
    }

	public override void afterInsert(List<SObject> newObjects, Map<Id,SObject> newMap){

		List<Cancellation__c> newCancellations = (List<Cancellation__c>) newObjects;
		List<Club_Opportunity_Product__c> prodsToDelete = new List<Club_Opportunity_Product__c>();
	    Set<id> accountids = new Set<id>();
	    constants sc = new constants();
	    
	    for(Cancellation__c cn:newCancellations){
        	accountids.add(cn.Membership__c);       
	    }
	
	    Map<id,Account> accMap = new Map<id,account>([select id,Membership_Status__c,Mail_Stop__c,Email_Stop__c,
	                                                (select id,Non_Renewer_flag__c,status__c from Club_Opportunity_Products__r where status__c='Active' OR Status__c ='Pending'),
	                                                (select id,StageName from Opportunities where isclosed=FALSE),
	                                                (SELECT Id, Status__c, Type__c, recordTypeId FROM DD_Mandates__r WHERE Status__c ='Active'  AND recordTypeId = :sc.PaymentMethodDDRecordTypeId)
	                                                 from Account where id in :accountids]);
	    List<Club_Opportunity_Product__c> cprodstoupdate = new List<Club_Opportunity_Product__c>();
	    List<Payment_Method__c> pmListtoupdate = new List<Payment_Method__c>();
	    List<Opportunity> oppstoupdate = new List<Opportunity>();
	
	    for(Cancellation__c cn:newCancellations){
	        accMap.get(cn.Membership__c).Membership_Status__c = cn.Cancellation_Type__c;
	    	if(cn.Cancellation_Type__c=='Cancelled' || cn.Cancellation_Type__c=='Ex-Member'){
		        if(cn.Stop_Communication__c){
		            accMap.get(cn.Membership__c).Mail_Stop__c = true;
		            accMap.get(cn.Membership__c).Email_Stop__c = true;
		            accMap.get(cn.Membership__c).Mag_Stop__c = true;
		            accMap.get(cn.Membership__c).Promotional_Mailstop__c = true;
		            accMap.get(cn.Membership__c).Stop_Marketing_Email__c = true;
		            accMap.get(cn.Membership__c).Stop_Marketing_SMS__c = true;
		        }
		        for(Opportunity op: accMap.get(cn.Membership__c).Opportunities){
		        	op.StageName='Cancelled';
		            oppstoupdate.add(op);
		        }
		        for(Club_Opportunity_Product__c cop: accMap.get(cn.Membership__c).Club_Opportunity_Products__r){
		            Club_Opportunity_Product__c cp = cop;
		          /*  if(cn.Cancellation_Type__c=='Cancelled'){
		                cp.status__c = 'Cancelled';
		            }
		            else{
		                cp.Non_Renewer_flag__c = true;
		                if(cp.status__c=='Pending')cp.status__c = 'Cancelled';
		            }*/
		            if(cp.Status__c == 'Pending'){
		                //cp.status__c = 'Cancelled';
		                prodsToDelete.add(cp);
		            } else if(cp.Status__c == 'Active'){
		            	cp.Status__c = 'Cancelled';
		            	cprodstoupdate.add(cp);
		            }
		        }
		        for(Payment_Method__c pm: accMap.get(cn.Membership__c).DD_Mandates__r){
		           // Payment_Method__c p = pm;
		            pm.status__c = 'Cancelled';
		            pmListtoupdate.add(pm);
		        }                 
	    	}  
	    }
	    
	    update accMap.values();
	    update cprodstoupdate;
	    update oppstoupdate;
	    update pmListtoupdate;
	    delete prodsToDelete;

	}
}