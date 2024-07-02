public class SectionsForCorrespondence {
	
	public List<Club_Opportunity_Product__c> purchasedPorductList =  new List<Club_Opportunity_Product__c>();
	public String sections = '';
	public double sectionsPrice;
	public constants sc = new constants();
	
	public List<Club_Opportunity_Product__c> GetpurchasedPorductList(Account acc, Opportunity opp){
		if(purchasedPorductList==null){
				system.debug('this.acc.id this.acc.id sc.sectionRecordTypeId ' + acc.id + ' ' + opp.id + ' '+ sc.sectionRecordTypeId);
				purchasedPorductList = [select id, Hybrid_Membership_Number__c, Member_Section__c, Non_Renewer_flag__c, Opportunity__c, Member_Section__r.name,
										Product__c, product__r.Name, Price__c, account__r.Membership_Code__c, Status__c
										from Club_Opportunity_Product__c 
										where Account__c = :acc.id
										and Opportunity__c = :opp.id
										and RecordTypeId = :sc.sectionRecordTypeId
										];
			system.debug('getting purchasedPorductList ' + purchasedPorductList.size());
			}
			return purchasedPorductList;
	}

}