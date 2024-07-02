Public class VISeniorYouth implements ValidationInterface {
    public void validate(lead l) {
        Constants sc = new Constants();
        System.debug ('-------Inside senior Youth validate-------');
        system.debug(l.company);
        if(l.company!=null){
        	Contact c;
        	if(l.company.startswith('001')){
            	c = [select id,name,birthdate,Youth_Test_Passed_Date__c from contact where recordtypeid=:sc.leadContactRecordTypeId and accountid=:l.company];
        	}
        	else if (l.company.startswith('006')){
        		Opportunity  o = [select id,closedate,accountid from opportunity where id=:l.company];
            	c = [select id,name,birthdate,Youth_Test_Passed_Date__c from contact where recordtypeid=:sc.leadContactRecordTypeId and accountid=:o.accountid];
								
        	}
            system.debug(c);
            if(c.Youth_Test_Passed_Date__c==null)l.adderror('Youth test not passed');
            if(c.birthdate.addyears(30)<=date.today())l.adderror('Member is over 29 years old');
            if(c.birthdate.addyears(21)>date.today())l.adderror('Member is under 21 years old');
        }
    }
    public void validateAtRenewal(lead l){
    	validate(l); 
    }
	public id autoswitch(Account a,Contact c,Opportunity o,ID clubProduct,ID clubProductto){
		if(c.birthdate.addyears(21)< a.Renewal_Date__c && c.Youth_Test_Passed_Date__c!=null){
			return clubProductto;
		}
		return clubProduct;
	} 
}