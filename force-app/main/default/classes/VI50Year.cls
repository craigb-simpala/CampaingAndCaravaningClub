Public class VI50Year implements ValidationInterface {
    public void validate(lead l) {
        System.debug ('-------Inside 50 validate-------');
        Account a;
        if(l.Company.startswith('006')){
        	Opportunity o = [select accountid from opportunity where id=:l.company limit 1];
        	a = [select id,Tenure2__c,(select id,name,birthdate from contacts where recordtype.name='Lead' limit 1) from account where id=:o.accountid];
        }
        else{
	        a = [select id,Tenure2__c,(select id,name,birthdate from contacts where recordtype.name='Lead' limit 1) from account where id=:l.company];
        }
        if(a.Tenure2__c<50){
            l.adderror('Tenure is '+a.Tenure2__c+' years, must be 50 years or more');    
        }
    }
    public void validateAtRenewal(lead l){
        validate(l);
    } 
	public id autoswitch(Account a,Contact c,Opportunity o,ID clubProduct,ID clubProductto){
		if(a.Tenure2__c>=50)return clubProductto;
		return clubProduct;
	} 
}