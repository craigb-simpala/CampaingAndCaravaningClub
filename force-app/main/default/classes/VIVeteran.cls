Public class VIVeteran implements ValidationInterface {
    public void validate(lead l) {
        System.debug ('-------Inside vet validate-------');
        Account a;
        if(l.Company.startswith('006')){
        	Opportunity o = [select accountid from opportunity where id=:l.company limit 1];
        	a = [select id,Tenure2__c,(select id,name,birthdate from contacts where recordtype.name='Lead' limit 1) from account where id=:o.accountid];
        }
        else{
	        a = [select id,Tenure2__c,(select id,name,birthdate from contacts where recordtype.name='Lead' limit 1) from account where id=:l.company];
        }
        if(a.Tenure2__c<25){
            l.adderror('Tenure is '+a.Tenure2__c+' years, must be 25 years or more');    
        }
        if(a.contacts[0].birthdate.addmonths(65*12)>date.today()){
            l.adderror('Member must be over 65 yeaars of age'); 
        }
    }
    public void validateAtRenewal(lead l){
    	system.debug(l);
        validate(l);
    } 
	public id autoswitch(Account a,Contact c,Opportunity o,ID clubProduct,ID clubProductto){
		return clubProduct;
	} 
}