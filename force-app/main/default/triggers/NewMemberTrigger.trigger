trigger NewMemberTrigger on Contact (after insert) {
	if(GetProfileId.p.Name != 'Data Loader Sys Admin'){
	    Set<id> accountids = new Set<id>();
	    constants c = new constants();
	    List<Correspondence__c> corrList = new List<Correspondence__c>();
	    
	    for(Contact cn:Trigger.new){
	        accountids.add(cn.AccountId);       
	    }
	    
	    Map<id,Account> accMap = new Map<id,Account>([select id, Renewal_Date__c, District_Association__c,
	                                                     (Select Id, Tenure2__c, Salutation,FirstName,LastName, status__c, RecordTypeId from Contacts where
	                                                      RecordTypeId = :c.leadContactRecordTypeId OR RecordTypeId = :c.secondaryContactRecordTypeId ) 
	                                                      FROM Account WHERE Id in :accountids]);
	    
	    for(Contact cn:Trigger.new){
	        system.debug('Inside the trigger');
	        if(cn.RecordTypeId == c.associateContactRecordTypeId){
	        system.debug('Inside the is statement ' + cn.RecordTypeId +' '+c.associateContactRecordTypeId);
	            Correspondence__c corr = new Correspondence__c();
	            corr.Correspondence_Type__c = 'New Associate Member';
	            corr.Correspondence_date__c =  system.today();
	            corr.Membership__c = cn.AccountId;
	            corr.Associate_Member__c = cn.Id;
	            if(accMap.size() > 0){
	                system.debug(accMap.get(cn.AccountId).Contacts);
	                for(Contact lc: accMap.get(cn.AccountId).Contacts){
	                    if(lc.RecordTypeId == c.leadContactRecordTypeId){
	                        corr.Lead_Member_Salutation__c =  lc.Salutation;
	                        corr.Lead_Member_First_Name__c =  lc.FirstName;
	                        corr.Lead_Member_Last_Name__c =  lc.LastName;
	                        corr.Lead_Member__c = lc.Id;
	                        //corr.Tenure__c = lc.Tenure2__c;
	                    }
	                }
	                
	                //corr.Old_DA__c = accMap.get(cn.AccountId).District_Association__c;
	            }
	            system.debug('adding correspondence to the list ' + corr);
	            corrList.add(corr);
	        } 
	        
	        /*if(cn.RecordTypeId == c.secondaryContactRecordTypeId){
	        system.debug('Inside the is statement ' + cn.RecordTypeId +' '+c.secondaryContactRecordTypeId);
	            Correspondence__c corr = new Correspondence__c();
	            corr.Correspondence_Type__c = 'New Second Member';
	            corr.Correspondence_date__c =  system.today();
	            corr.Membership__c = cn.AccountId;
	            corr.Member__c = cn.Id;
	            if(accMap.size() > 0){
	                system.debug(accMap.get(cn.AccountId).Contacts);
	                for(Contact lc: accMap.get(cn.AccountId).Contacts){
	                    if(lc.RecordTypeId == c.secondaryContactRecordTypeId && lc.Status__c == 'Active'){
	                        corr.Second_Member_Salutation__c =  lc.Salutation;
	                        corr.Second_Member_First_Name__c =  lc.FirstName;
	                        corr.Second_Member_Last_Name__c =  lc.LastName;
	                        corr.Tenure__c = lc.Tenure2__c;
	                    }
	                }
	                corr.Old_DA__c = accMap.get(cn.AccountId).District_Association__c;
	            }
	            system.debug('adding correspondence to the list ' + corr);
	            corrList.add(corr);
	        }*/         
	    }
	    
	    insert corrList;
	    
	
	      //  Set<id> accids = new Set<id>();
	    List <Contact> alist =  New List<Contact>();
	    
	      Map<id,Account> accMap2 = new Map<id,Account>([select id, (Select Id, Name,  Status__c, RecordTypeId from Contacts where RecordTypeId = :c.secondaryContactRecordTypeId) FROM Account WHERE  Id IN: accountids]);
	  
	
	    for(Contact cn: Trigger.new){
	        if(accMap2.size() > 0){
	            for (Contact co: accMap2.get(cn.AccountId).Contacts) {
	                Contact updateC = co;
	                if (co.RecordTypeId == c.secondaryContactRecordTypeId && co.Status__c == 'Active' && co.Id != cn.Id){
	                    updateC.Date_Ended__c = System.today();
	                    alist.add(updateC);
	                    }
	            }
	        
	        }
	        
	    }
	    
	    
	    
	    update alist;
	   
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    //RecordType rt = [SELECT Id from RecordType WHERE SobjectType = 'Contact' AND Name = 'Lead' AND DeveloperName ='Lead'];
	    /*constants c = new constants();
	    
	    for (contact con: Trigger.new) {
	        
	            system.debug(con.RecordTypeId);
	        
	            if (con.RecordTypeId == c.associateContactRecordTypeId)
	                con.addError('Associate Members should be added using the [Change Membership] button');
	            if (con.RecordTypeId == c.leadContactRecordTypeId)
	                con.addError('New Lead Members cannot be added to the Membership');
	                system.debug(RecordType.Name);
	                break;
	    }
	    
	 */
	}
    
}