public with sharing class CreateClientCorrespondenceController {

    public apexpages.standardController controller {get; set;}
    public Account acc {get;set;}
    public Contact con {get;set;}
	public Correspondence__c corr {get;set;}
    public constants sc = new constants();
	
    public CreateClientCorrespondenceController(apexpages.standardController controller) {
		this.controller = controller;

		List<String> confields = new list<String>();
		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
	    for(String s : objectFields.keySet()) {
	        confields.add(s);
	        //system.debug(s);
	    }
	    //confields.add('Membership_Code__r.name');
	    if(!test.isRunningTest()) 
	    	controller.addFields(confields);

	    this.con = (Contact) controller.getRecord();
	    
	    Id conid = this.con.accountid;

		String query = 'SELECT';
		objectFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
		for(String s : objectFields.keySet()) {
			query += ' ' + s + ',';
		}
		if (query.subString(query.Length()-1,query.Length()) == ','){
			query = query.subString(0,query.Length()-1);
		}
		query += ' FROM Account where id = :conid';
                

	    this.acc = Database.query(query);
	    corr = new Correspondence__c(Membership__c = this.acc.id, Payment_Method__c = this.acc.Payment_Method2__c);
    	
    }

	Public Opportunity opp {
		get{
			if(opp==null){
				try{
					opp = [select id,name,closedate,(select id,price__c,product__c,recordtypeid from Line_Items__r) from Opportunity where accountid =:this.acc.id and recordtypeid= :sc.OppRenewalRecordTypeId and isclosed=false and iswon=false];
				}
				catch(exception ex){
					opp = new Opportunity();
				}
			}
			return opp;
		}
		set;
	}

	public List<Cancellation__c> canclist {
		get{
			if(canclist==null){
				canclist = [select id from Cancellation__c 
							where Membership__c = :this.acc.id
							order by name desc];
			}
			return canclist;
		}
		set;
	}

	public PageReference saveCorr(){
		if(corr.Correspondence_Type__c==null){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select a correspondence type'));
		}
		if(corr.Correspondence_Type__c=='Renewal' && opp.id==null){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'This Membership does not have an active renewal'));
		}
		if(corr.Correspondence_Type__c=='Cancellation' && canclist.size()==0){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'This Membership has no cancellations'));
		}
		if(!ApexPages.hasMessages()){
			corr.Member__c = con.id;
			corr.Correspondence_date__c = Date.today();
			if(corr.Correspondence_Type__c=='Renewal'){
					corr.Amendment_Renewal__c = opp.id;
			}
			else if(corr.Correspondence_Type__c=='Cancellation'){
					corr.Cancellation__c = canclist[0].id;			
			}
			insert corr;
			return controller.cancel();
		}
		return null;
	}
}