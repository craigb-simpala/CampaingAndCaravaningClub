public with sharing class NewMemberController {

    public apexpages.standardController controller {get; set;}
    
    //public apexpages.standardController accController {get; set;}
    
    public Contact con {get;set;}
    
     //public Contact cont {get;set;}
         
     Constants sc = new Constants();
    
    private String returl {get;set;}
   
    public String Bday{get{if(Bday==null)Bday='';return Bday;}set;}
	
    public NewMemberController(apexpages.standardController controller) {
        this.controller = controller;
        this.con = (Contact) controller.getRecord();
        this.con.recordtypeid = ApexPages.currentPage().getParameters().get('rtid');
        this.con.Accountid = ApexPages.currentPage().getParameters().get('accid');
        returl = ApexPages.currentPage().getParameters().get('returl');
        
        System.debug(ApexPages.currentPage().getParameters().get('msg'));
        
         if(ApexPages.currentPage().getParameters().get('msg')!=null)
            {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Record saved'));
            }
        
        Account Acc = [select Name from Account where id = :con.AccountId][0];
        
        // accController = new ApexPages.StandardController(Acc);
        
        //cont  = [Select lastname from Contact where AccountId = :con.AccountId and recordtypeid= :sc.leadContactRecordTypeId and Status__c = 'Active' ] ;
        
        //accController = new ApexPages.StandardController(cont);
        
        con.LastName = acc.name;                        
    }

    public pagereference saverec(){
        //if(Con.FirstName!=null)Con.FirstName=Utils.toProperCase(Con.FirstName);
        //if(Con.LastName!=null)Con.LastName=Utils.toProperCase(Con.LastName);
        system.debug(this.con.recordtypeid+ ' ' + sc.secondaryContactRecordTypeId);
        if(this.con.recordtypeid == sc.secondaryContactRecordTypeId ){
        	Contact Leadmem =[select id,email from Contact where accountid=:this.con.Accountid and recordtypeid = :sc.leadContactRecordTypeId limit 1]; 
	        if(this.con.email!=null && Leadmem.Email!=null){
	        	if(!this.con.email.contains('@example.com') && !Leadmem.Email.contains('@example.com') && this.con.email==Leadmem.Email){
	        		this.con.email.adderror('Cannot have the same email as Lead member');
	        		return null;
	        	}
	        }
        }
        if(Bday!='')Con.Birthdate = Date.parse(Bday);
        con.Date_Joined__c = date.today();
        insert con;
        return new Pagereference(returl);
    }        
    
    public pagereference newRec(){
        //if(Con.FirstName!=null)Con.FirstName=Utils.toProperCase(Con.FirstName);
        //if(Con.LastName!=null)Con.LastName=Utils.toProperCase(Con.LastName);
        if(Bday!='')Con.Birthdate = Date.parse(Bday);
        insert con;
        
        system.debug(getVFPageName());
        system.debug(ApexPages.currentPage());
        system.debug(ApexPages.currentPage().getUrl());
        system.debug(ApexPages.currentPage().getParameters());
        for (String s:ApexPages.currentPage().getParameters().keyset()){
            system.debug(s+'->'+ApexPages.currentPage().getParameters().get(s));
        }
        PageReference p = new PageReference(getVFPageName());
        p.getParameters().put('accid',ApexPages.currentPage().getParameters().get('accid'));
        p.getParameters().put('rtid',ApexPages.currentPage().getParameters().get('rtid'));
        p.getParameters().put('retURL',ApexPages.currentPage().getParameters().get('retURL'));
        p.setRedirect(true);
        p.getParameters().put('msg','123');
        system.debug(p);
        return p;
    }    

    public pagereference cancl(){
        return new Pagereference(returl);
    }
    
    public string getVFPageName() {
        String pageName = ApexPages.CurrentPage().getUrl();
        //pageName = pageName.replaceFirst('/apex/', '');
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
        string[] pageNameExtra = pageName.split('%3F', 0);
        pageName = pageNameExtra[0];
        pageName = EncodingUtil.urlDecode(pageName, 'UTF-8');
        system.debug('pageName-->' + pageName);
        return pageName;
    }           
}