public with sharing class LeadSections {

    private final Lead lea;
    ApexPages.StandardController sController;  
    
    public LeadSections(ApexPages.StandardController stdController) {
    	if (!Test.isRunningTest())
		{
    		stdController.addFields(new List<String>{'sections__c'});
		}
        sController = stdController;  
        this.lea = (Lead)stdController.getRecord();

	    if(lea.id!=null && lea.sections__c!=null ){
	        List<String> msections = lea.sections__c.split(':',-2);
	        Set<String> ssections = new Set<String>();
	        ssections.addall(msections);
	
	        for (sectionSelectWrapper s:sections){
	            if(ssections.contains(s.s.name))s.selected=true;
	        }
	    }
    }

    public List<sectionSelectWrapper> sections {
        get{
            if(sections==null){
                sections = new List<sectionSelectWrapper>();
                Date now = Date.today();
                for(club_product__c s:[select id,name,Product_Detail__c,(select Price__c from Prices__r where Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null) order by Start_Date__c) from club_product__c where recordtype.name='Section' order by name]){
                	List<price__c> pr = s.prices__r;
                	if(pr.size()>0){
                    	sections.add(new sectionSelectWrapper(s,s.prices__r[0].price__c));
                	}
                }
            }
            return sections;
        }
        set;
    }
 
}