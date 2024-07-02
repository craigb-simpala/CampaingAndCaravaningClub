Public class VIPaper implements ValidationInterface {
	//private Id adminProfileId = [SELECT Id FROM Profile WHERE Name like '%System Administrator%' LIMIT 1];
	//private Id memDdminProfileId = [SELECT Id FROM Profile WHERE Name like '%Membership Admin%' LIMIT 1];
    public void validateAtRenewal(lead l){}
    public void validate(lead l) {
        System.debug ('-------Inside paper validate-------');
        Account a;
        if(l.Company.startswith('006')){
        	Opportunity o = [select accountid from opportunity where id=:l.company limit 1];
        	a = [select id,Membership_Code__c,Date_Joined__c,renewal_date__c,(select id,name,closedate from opportunities where recordtype.name='Renewal' and stagename='Complete' order by CloseDate desc) from account where id=:o.accountid];
        }
        else{
	        a = [select id,Membership_Code__c,Date_Joined__c,renewal_date__c,(select id,name,closedate from opportunities where recordtype.name='Renewal' and stagename='Complete' order by CloseDate desc) from account where id=:l.company];
        }

//        Account a = [select id,Membership_Code__c,Date_Joined__c,(select id,name,closedate from opportunities where recordtype.name='Renewal' and stagename='Complete' order by CloseDate desc) from account where id=:l.company];
        Club_Product__c digi = [select id from Club_Product__c where recordtype.name='Membership Code' and Name='Digital' limit 1];
        system.debug(digi);
        system.debug(a);
        system.debug(a.opportunities); 
        CustomPermissionsReader cpr = new CustomPermissionsReader();
        Boolean hasPermission = cpr.hasPermission('Ignore_8_Week_Rule');
        if(a.Membership_Code__c==digi.id ){
            if(a.opportunities.size()>0){
		        Opportunity o = [select account.id,account.Membership_Code__c,account.Date_Joined__c,id,name,closedate,(select id,name,product__r.name,product__r.Membership_Length__c from Line_Items__r where recordtype.name='Membership Code') from opportunity where accountid = :a.id and recordtype.name='Renewal' and stagename='Complete' order by CloseDate desc limit 1];
//                if(a.opportunities[0].closedate.adddays(56)<system.now() && !hasPermission){
                if(a.renewal_date__c.addmonths(-1*integer.valueof(o.Line_Items__r[0].product__r.Membership_Length__c)).adddays(56)<system.now().date() && !hasPermission){
                    l.adderror('Cannot change from Digital to Paper membership after 8 weeks, please use change at renewal',true);      
                }   
            }
            else{
                if(a.Date_Joined__c.adddays(56)<system.now() && !hasPermission){
                    l.adderror('Cannot change from Digital to Paper membership after 8 weeks, please use change at renewal',true);      
                } 
            }
                
        }
    }
    
    public id autoswitch(Account a,Contact c,Opportunity o,ID clubProduct,ID clubProductto){
        if(c.Birthdate.addyears(18)<a.Renewal_Date__c && c.birthdate.addyears(21)> a.Renewal_Date__c && c.Youth_Test_Passed_Date__c==null){
            return clubProductto;
        }
        return clubProduct;
    } 
}