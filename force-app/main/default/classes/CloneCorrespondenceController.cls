public with sharing class CloneCorrespondenceController {

    private final Correspondence__c corr;
    ApexPages.StandardController sController;  

    public CloneCorrespondenceController(ApexPages.StandardController stdController) {
        sController = stdController;  

		List<String> corrfields = new list<String>();

		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Correspondence__c').getDescribe().fields.getMap();
		for(String s : objectFields.keySet()) {
			corrfields.add(s);
		}
		if(!test.isRunningTest()) 
			stdController.addFields(corrfields);

        this.corr = (Correspondence__c)stdController.getRecord();
    }

	public PageReference cloneCorr(){
		Correspondence__c cloned_corr = corr.clone(false,true,false,false);
		cloned_corr.Re_issue__c = true;
		cloned_corr.Re_issue_Date__c = system.now();
		cloned_corr.Date_Processed__c = null;
		insert cloned_corr;
		return new PageReference('/'+cloned_corr.id); 
	}
}