public with sharing class ChangeDetailsController {
    
         public ApexPages.StandardController stdCntrlr {get; set;}
            public ChangeDetailsController(ApexPages.StandardController controller) {
            if (!Test.isRunningTest())
            {
                controller.addFields(new List<String>{'Membership_Code__c'});
            }
            stdCntrlr = controller;
            this.acc = (Account) controller.getRecord();
        }
        
        public Account acc {get;set;}
    
        
       String ids = ApexPages.currentPage().getParameters().get('id');
       public constants sc = new constants();
        
        public club_product__c cp {
            get{
                if(cp==null){
                    cp = [select id,name,access_member_allowed__c,PartnerAllowed__c,children_allowed__c from club_product__c where id=:acc.Membership_Code__c];
                }
                return cp;
            }
            private set;
        }
        
        public PageReference ChangePaymentDetails()
        {
        PageReference pr = new PageReference('/apex/ChangePaymentDetails');
        pr.getParameters().put('id',ApexPages.currentPage().getParameters().get('id'));
        return pr;
        }
    	public PageReference ChangeMem(){
	    	PageReference pr = new PageReference('/apex/MiddleDetailPage');
	        pr.getParameters().put('id',ApexPages.currentPage().getParameters().get('id'));
	        return pr;
    	}
        public PageReference ChangeMembership()
        {
        PageReference pr = new PageReference('/apex/ChangeMembership');
        pr.getParameters().put('id',ApexPages.currentPage().getParameters().get('id'));
        return pr;
        }
        
        public PageReference AddAssocSections(){
        	PageReference pr = new PageReference('/apex/ChangeAssociationSections');
        	pr.getParameters().put('id', ApexPages.currentPage().getParameters().get('id'));
        	return pr;
        }
    
        
        public PageReference ChangeAtRenewal()
        {
        PageReference pr = new PageReference('/apex/ChangeAtRenewal');
        pr.getParameters().put('id',ApexPages.currentPage().getParameters().get('id'));
        return pr;
        }
        
        public PageReference ChangeAddress()
        {
        PageReference pr = new PageReference('/apex/ChangeAddressDetails');
        pr.getParameters().put('id',ApexPages.currentPage().getParameters().get('id'));
        return pr;
        }
        
        public PageReference NewChildMember()
        {
        Pagereference retpage;
        
        retpage = new pagereference('/apex/NewChildMember');
        retpage.getParameters().put('rtid',sc.childContactRecordTypeId);
        //retpage.getParameters().put('ent','Contact');
        retpage.getParameters().put('accid',ApexPages.currentPage().getParameters().get('id'));
        retpage.getParameters().put('accName',ApexPages.currentPage().getParameters().get('name'));
        //retpage.getParameters().put('id',con.Id);
        retpage.getParameters().put('retURL','/'+ApexPages.currentPage().getParameters().get('id'));
        retpage.setRedirect(true);
        return retpage;
        }
        
        public PageReference NewSecondarymember()
        {
        Pagereference retpage;
        
        retpage = new pagereference('/apex/NewSecondaryMember');
        retpage.getParameters().put('rtid',sc.secondaryContactRecordTypeId);
        //retpage.getParameters().put('ent','Contact');
        retpage.getParameters().put('accid',ApexPages.currentPage().getParameters().get('id'));
        //retpage.getParameters().put('id',con.Id);
        retpage.getParameters().put('retURL','/'+ApexPages.currentPage().getParameters().get('id'));
        retpage.setRedirect(true);
        return retpage;
        }
        
        public PageReference NewAccessMember()
        {
        Pagereference retpage;
        
        retpage = new pagereference('/apex/NewAccessMember');
        retpage.getParameters().put('rtid',sc.accessContactRecordTypeId);
        //retpage.getParameters().put('ent','Contact');
        retpage.getParameters().put('accid',ApexPages.currentPage().getParameters().get('id'));
        //retpage.getParameters().put('id',con.Id);
        retpage.getParameters().put('retURL','/'+ApexPages.currentPage().getParameters().get('id'));
        retpage.setRedirect(true);
        return retpage;
        }
    
    
}