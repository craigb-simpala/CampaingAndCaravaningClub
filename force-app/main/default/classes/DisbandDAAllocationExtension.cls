public with sharing class DisbandDAAllocationExtension {
	
	private final Association__c asso;
    ApexPages.StandardController sController; 
	public String selectedAllAsso { get; set;}
    public constants sc = new constants();
	
    
    public DisbandDAAllocationExtension(ApexPages.StandardController stdController) {
        sController = stdController;  
        
        List<String> accfields = new list<String>();

        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Association__c').getDescribe().fields.getMap();
        for(String s : objectFields.keySet()) {
            accfields.add(s);
            //system.debug(s);
        }
        
        if(!test.isRunningTest()) 
            stdController.addFields(accfields);
        this.asso = (Association__c)stdController.getRecord();
        this.daName = this.asso.Name;
    }
    
    public List<DA_Postcode__c> daRelatedPostcodes{
        get{
            if(daRelatedPostcodes==null){
                daRelatedPostcodes = new List<DA_Postcode__c>();
                daRelatedPostcodes = [SELECT id, Name, Association_Code__c, Association_Name__c, Parent_Region_Name__c, Association_Name__r.Name, Postcode_Part_1__c, Postcode_Part_2__c FROM DA_Postcode__c WHERE Association_Name__c =: asso.Id];
            }
            system.debug('daRelatedPostcodes ' + daRelatedPostcodes);
            return daRelatedPostcodes;
        }
        set;
    }
    
    public String daName{
    	get{
    		return daName;    		
    	}
    	set;
    }
    
    public List<Association__c> allAsso{
        get{
            if(allAsso==null){
                allAsso = new List<Association__c>();
                allAsso = [SELECT id, Name, Association_Code__c, Association_Name__c, Contact_Name__c, Notes__c, Parent_Region__c, Parent_Region_Code__c, Parent_Region_Name__c, Postcode_Group__c,
                						Postcode_Part_1__c, Postcode_Part_2__c, Region_Code__c, Region_Name__c, isActive__c FROM Association__c WHERE Id !=: asso.Id AND RecordTypeId = :daRecType.Id
                						 AND isActive__c = true Order by Name];
            }
            system.debug('allAsso ' + allAsso);
            return allAsso;
        }
        set;
    }

    public RecordType daRecType{
        get{
            if(daRecType==null){
                daRecType = new RecordType();
                daRecType = [SELECT id, Name FROM RecordType WHERE SobjectType = 'Association__c' AND developerName = 'District_Association'];
            }
            system.debug('daRecType ' + daRecType);
            return daRecType;
        }
        set;
    }
    
    public List<SelectOption> getItems() {
		List<SelectOption> op = new List<SelectOption>();

    	for(Association__c a : allAsso) 
    		op.add(new SelectOption(a.Id, a.Name));

   		return op;
	}
	
	 public List<DAPostcodeWrapper> allocatePostcodeWrapper {
        get{
            if(allocatePostcodeWrapper==null){
                allocatePostcodeWrapper = new List<DAPostcodeWrapper>();
                for (DA_Postcode__c p : daRelatedPostcodes){
                    allocatePostcodeWrapper.add(new DAPostcodeWrapper(p, false));
            	}
            }
            return allocatePostcodeWrapper;
        }
        set;
	}
	
	public pagereference  clearAllData(){
		system.debug('cleared bed list');
		allocatePostcodeWrapper=null;
		selectedAllAsso = null;
		return null;
	}
    
    
    public PageReference saveData(){
    	DA_Postcode__c postcode;    	
		List<DAPostcodeWrapper> poWrapper = new List<DAPostcodeWrapper>();
		List<DA_Postcode__c> poList = new List<DA_Postcode__c>();
		List<Account> memberships = new List<Account>();
		List<Correspondence__c> corrList = new List<Correspondence__c>();
		List<Contact> members = new List<Contact>();
		List<String> selectedpoList = new List<String>();
		
        for (DAPostcodeWrapper pcw : allocatePostcodeWrapper){
        	if(pcw.selected){
        		poWrapper.add(pcw);        		
        	}
        }	
    	if(selectedAllAsso == null || selectedAllAsso == ''){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select a DA Association.'));
    		return null;
    	}	
    	if(poWrapper.size() == 0){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select atleast one postcode.'));	
    		return null;
    	}
    	
    	for(DAPostcodeWrapper dpw : poWrapper){
    		if(dpw.selected = true){
	    		dpw.pc.Association_Name__c = selectedAllAsso;
	    		poList.add(dpw.pc);
	    		String p = dpw.pc.Postcode_Part_1__c + ' ';
	    		if(dpw.pc.Postcode_Part_2__c != null){
		    		p += dpw.pc.Postcode_Part_2__c;
	    		}
	    		p+= '%';
		    	selectedpoList.add(p);
    		}
    	}
    	
    	system.debug('selectedpoList ' + selectedpoList);
    	if(selectedAllAsso != null || selectedAllAsso != ''){
    		memberships = [SELECT Id, Name, District_Association__c, BillingPostalCode FROM Account WHERE District_Association__c =: asso.Id AND BillingPostalCode LIKE :selectedpoList];
    	}
    	system.debug(memberships);
    	if(memberships.size() > 0){
    		members = [select id, accountId from contact where accountid IN :memberships and recordtypeid=:sc.leadContactRecordTypeId];
    		for(Account a : memberships){
    			a.District_Association__c = selectedAllAsso;
    			
    			//creating correspondence
    			for(Contact c: members){
    				if(c.accountId == a.Id){
		    			Correspondence__c corr = new Correspondence__c();
						corr.Member__c = c.id;
						corr.Correspondence_date__c = Date.today();
						corr.Correspondence_Type__c='Disband DA';
						corr.Membership__c = a.Id;
						corr.Old_DA__c = asso.id;
						corrList.add(corr);
    				}
    			}				
    		}   		
    	}
    	if(poList.size() > 0){
    		update poList;
    	}
    	if(memberships.size() > 0){
    		update memberships;
    	}
    	if(corrList.size() > 0){
    		insert corrList;
    	}
    	clearAllData();
    	return new PageReference('/' +asso.Id);
    }

}