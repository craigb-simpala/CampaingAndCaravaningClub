Public class VIYouth implements ValidationInterface {
    public void validate(lead l) {
        Constants sc = new Constants();
        System.debug ('-------Inside  Youth validate-------');
        system.debug(l.company);
        if(l.company!=null){
        	Contact c;
        	if(l.company.startswith('001')){
            	c = [select id,name,birthdate,Youth_Test_Passed_Date__c from contact where recordtypeid=:sc.leadContactRecordTypeId and accountid=:l.company];
        	}
        	else if (l.company.startswith('006')){
        		Opportunity  o = [select id,closedate,accountid from opportunity where id=:l.company];
            	c = [select id,name,birthdate,Youth_Test_Passed_Date__c from contact where recordtypeid=:sc.leadContactRecordTypeId and accountid=:o.accountid];
				if(c.birthdate.addyears(21)<date.today()){
					l.adderror('Member is over 21 years old');
				}				
				else if(o.closedate > c.birthdate.addmonths(12*18)){
					if(c.Youth_Test_Passed_Date__c==null)l.adderror('Member is over 18 and youth test not passed');
				}        	
			}
            system.debug(c);
        }
    }
    public void validateAtRenewal(lead l){
    	validate(l); 
    }
	public id autoswitch(Account a,Contact c,Opportunity o,ID clubProduct,ID clubProductto){
		return clubProduct; 
	}
}