Public class VIDigital implements ValidationInterface {
    private static final String YOUTH_DIGITAL_MEMBERSHIP_TYPE = 'Youth - Digital';
    private static final String YOUNG_CAMPER_MEMBERSHIP_TYPE = 'Young Camper';

	//private Id adminProfileId = [SELECT Id FROM Profile WHERE Name like '%System Administrator%' LIMIT 1];
	//private Id memDdminProfileId = [SELECT Id FROM Profile WHERE Name like '%Membership Admin%' LIMIT 1];
    public void validateAtRenewal(lead l){}
    public void validate(lead l) {
        System.debug ('-------Inside digital validate-------');
        Account a;
        if(l.Company.startswith('006')){
        	Opportunity o = [select accountid from opportunity where id=:l.company limit 1];
        	a = [select id,Membership_Code__c,Date_Joined__c,renewal_date__c,(select id,name,closedate from opportunities where recordtype.name='Renewal' and stagename='Complete' order by CloseDate desc) from account where id=:o.accountid];
        }
        else{
	        a = [select id,Membership_Code__c,Date_Joined__c,renewal_date__c,(select id,name,closedate from opportunities where recordtype.name='Renewal' and stagename='Complete' order by CloseDate desc) from account where id=:l.company];
        }
        
//        Account a = [select id,Membership_Code__c,Date_Joined__c,(select id,name,closedate from opportunities where recordtype.name='Renewal' and stagename='Complete' order by CloseDate desc) from account where id=:l.company];
        Club_Product__c paper = [select id from Club_Product__c where recordtype.name='Membership Code' and Name='Paper' limit 1];
        system.debug(Paper);
        system.debug(a);
        system.debug(a.opportunities); 
        CustomPermissionsReader cpr = new CustomPermissionsReader();
        Boolean hasPermission = cpr.hasPermission('Ignore_8_Week_Rule');
        if(a.Membership_Code__c==paper.id ){
            if(a.opportunities.size()>0){
		        Opportunity o = [select account.id,account.Membership_Code__c,account.Date_Joined__c,id,name,closedate,(select id,name,product__r.name,product__r.Membership_Length__c from Line_Items__r where recordtype.name='Membership Code') from opportunity where accountid = :a.id and recordtype.name='Renewal' and stagename='Complete' order by CloseDate desc limit 1];
//                if(a.opportunities[0].closedate.adddays(56)<system.now() && !hasPermission){
				system.debug(a.renewal_date__c.addmonths(-1*integer.valueof(o.Line_Items__r[0].product__r.Membership_Length__c)).adddays(56));
                if(a.renewal_date__c.addmonths(-1*integer.valueof(o.Line_Items__r[0].product__r.Membership_Length__c)).adddays(56)<system.now().date()&& !hasPermission){
                    l.adderror('Cannot change from Paper to Digital membership after 8 weeks, please use change at renewal',true);      
                }   
            }
            else{
                if(a.Date_Joined__c.adddays(56)<system.now().date() && !hasPermission){
                    l.adderror('Cannot change from Paper to Digital membership after 8 weeks, please use change at renewal',true);      
                }
            } 
            
        }
    }
    public Id autoswitch(Account acc, Contact con, Opportunity opp, Id clubProductFromId, Id clubProductToId) {
        Integer membersAgeOnRenewalDate = con.Birthdate != null ? con.Birthdate.monthsBetween(acc.Renewal_Date__c) / 12 : null;
        if (acc.Membership_Type_Name__c == YOUNG_CAMPER_MEMBERSHIP_TYPE
                && membersAgeOnRenewalDate >= 25) {
            return clubProductToId;
        }
        if (acc.Membership_Type_Name__c == YOUTH_DIGITAL_MEMBERSHIP_TYPE
                && membersAgeOnRenewalDate >= 18 && con.Youth_Test_Passed_Date__c == null) {
            return clubProductToId;
        }
        return clubProductFromId;
    } 
}