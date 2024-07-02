public with sharing class DAPostcodeWrapper {
	 public DA_Postcode__c pc{get; set;}
     public Boolean selected {get; set;}
 
    

    public DAPostcodeWrapper(DA_Postcode__c p, boolean selected) {
        system.debug(p);
        this.pc = p;
        this.selected = selected;
    }
}