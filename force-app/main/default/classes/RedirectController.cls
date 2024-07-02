public with sharing class RedirectController {
    
    
     public apexpages.standardController controller {get; set;}
     public Account acc {get;set;}
     public Contact con {get;set;}
     public constants sc = new constants();
     
     public RedirectController(apexpages.standardController controller) {
     	
     	this.controller = controller;
     	this.acc = (Account) controller.getRecord();
     	
     }
     
    
    public pagereference hpredirectC(){
		Pagereference retpage;
		
		retpage = new pagereference('/003/e');
		retpage.getParameters().put('RecordType',sc.childContactRecordTypeId);
		retpage.getParameters().put('ent','Contact');
		retpage.getParameters().put('accid',acc.Id);
		//retpage.getParameters().put('id',con.Id);
		retpage.getParameters().put('retURL','/'+acc.Id);
		retpage.setRedirect(true);
		return retpage;

	}
	
	    public pagereference hpredirectS(){
		Pagereference retpage;
		
		retpage = new pagereference('/003/e');
		retpage.getParameters().put('RecordType',sc.secondaryContactRecordTypeId);
		retpage.getParameters().put('ent','Contact');
		retpage.getParameters().put('accid',acc.Id);
		//retpage.getParameters().put('id',con.Id);
		retpage.getParameters().put('retURL','/'+acc.Id);
		retpage.setRedirect(true);
		return retpage;

	}
    
    
    
    
    
     /** public PageReference getRedir() {
     	   
     	    PageReference newPage;

        if (ApexPages.currentPage().getParameters().get('RecordType') == 'Child') {
            newPage = Page.RedirectMemberPageC;
            return newPage.setRedirect(true);
       	 } else {
       	 	
            return null;
        }

    }*/
	
     
     
    
}