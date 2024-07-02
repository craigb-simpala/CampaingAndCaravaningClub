public class cancExtension {
public Cancellation__c canc{get; set;}
public Account acc{get; set;}
    public cancExtension(ApexPages.StandardController stdController){
       if(canc == null) canc = new Cancellation__c();
       this.canc = (Cancellation__c)stdController.getRecord(); 
        system.debug('canc Par: ' + canc);
       if(!test.isRunningTest()) 
       		canc.Membership__c = ApexPages.currentPage().getParameters().get('Membership__c');
       canc.Cancellation_Date__c = system.TODAY();
        acc = [select id,membership_number__c from account where id=:canc.Membership__c];
        
       system.debug(canc.Membership__c);
       
       
    }
    
    public PageReference back(){
        
        return new PageReference('/'+this.acc.id);
    }
}