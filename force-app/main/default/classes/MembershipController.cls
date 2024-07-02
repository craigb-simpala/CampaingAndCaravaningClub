/*
* @who   Patrick Duncan <patrick.duncan@weare4c.com>
* @what  Controller class for MembershipTypeAndSelectionSelector component 
* @when  12/7/2019
*/
public with sharing class MembershipController {

    /* 
     * @description Returns all Club_Product__c's of type Membership code
     * @return The list of Club_Product__c's
     */
    @AuraEnabled
    public static List<Club_Product__c> getMembershipTypes() {
        String query = 'SELECT Id, Name, Section_Code__c, Product_Detail__c, Sections_Allowed__c, Price_for_Initial_Picklist__c, RecordType.Name ';
        query += 'FROM Club_Product__c ';
        query += 'WHERE RecordType.Name = \'Membership Code\' AND Show_in_New_Membership_Picklist__c = true';

        Id userProfileId = UserInfo.getProfileId();
        if (!getAdminProfileIds().contains(userProfileId)) {
            query += ' AND Visible_to_Admin_Users_Only__c = false';
        }

        System.debug('QUERY: ' + query);

        List<Club_Product__c> memberships = Database.query(query);
        System.debug('Memberships: ' + memberships);

        return memberships;
    }
    
    /*
     *    getAdminProfileIds
     *    Method to get specific admin profile ids
     *    Return Set<Id>
     */
    private static Set<Id> getAdminProfileIds(){
        // profile names
        List<String> adminProfiles = new List<String>{
            'System Administrator',
            'Membership Admin'
        };
        
        // get profile ids
        Set<Id> profileIds = new Map<Id, Profile>([SELECT Id FROM Profile WHERE Name IN :adminProfiles]).keySet();
        
        return profileIds;
    }

    /* 
     * @description Returns the Membership type lookup of a specific record, if not populated, default to digital
     * @param  recordId             Id used to identify the record
     * @return the Club_Product__c of the lookup
     */
    @AuraEnabled 
    public static Club_Product__c getSelectedMembershipType(Id recordId){
        System.debug('hereeee');
        List<Lead> currentRecord = [SELECT Id, sections__c, Membership_Type__r.Id FROM Lead WHERE Id = :recordId];
        if(currentRecord.get(0).Membership_Type__r == null){
            return [SELECT Id, Name, Section_Code__c, Product_Detail__c, Sections_Allowed__c FROM Club_Product__c WHERE Name = 'Digital'];

        }
        else{
            return [SELECT Id, Name, Section_Code__c, Product_Detail__c, Sections_Allowed__c FROM Club_Product__c WHERE Id = :currentRecord.get(0).Membership_Type__r.Id];
        }
    }

    /* 
     * @description Gets all the sections and whether a new membership contains those sections
     * @param  recordId  Id of the new membership
     * @return list of section inner classes
     */
    @AuraEnabled 
    public static List<Section> getSections(Id recordId){
        List<Section> results = new List<Section>();
        List<Lead> currentRecord = [SELECT Id, sections__c FROM Lead WHERE Id = :recordId];
        String[] sectionAbbreviations;
        if(currentRecord.get(0).sections__c==null || currentRecord.get(0).sections__c==''){
            sectionAbbreviations = new String[]{};
        }
        else{
            sectionAbbreviations = currentRecord.get(0).sections__c.split(':');
        }
        List<Club_Product__c> allSections = [SELECT Id, Name, Section_Code__c, Product_Detail__c, (SELECT Id, Price__c FROM Prices__r 
            WHERE (Start_Date__c < :Date.today() AND End_Date__c > :Date.today()) 
                OR (Start_Date__c = NULL AND End_Date__c > :Date.today())
                OR (Start_Date__c < :Date.today() AND End_Date__c = NULL)) FROM Club_Product__c WHERE RecordType.Name = 'Section' ORDER BY Product_Detail__c];
        
        for(Club_Product__c prod:allSections){
            Section section = new Section(prod.Product_Detail__c,prod.Section_Code__c,prod.Name,prod.Prices__r.isEmpty()?'':String.valueOf(prod.Prices__r.get(0).Price__c));
            if(sectionAbbreviations.contains(prod.Name)){
                section.selected = true;
            }
            else{
                section.selected = false;
            }
            results.add(section);
        }
        return results;
    }

    /* 
     * @description saves the changes made by this component 
     * @param  recordId             Id of the new membership
     * @param  sections             List of section inner class
     * @param  recordId             Name of selected membership type
     */
    @AuraEnabled 
    public static void saveChanges(Id recordId, List<Object> sections, String membershipType){
        List<Lead> currentRecord = [SELECT Id, sections__c FROM Lead WHERE Id = :recordId];
        String sectionString = '';
        if(sections != null){
        	for(Object section: sections){
	            Map<Object,Object> currentSection = (Map<Object,Object>) section;
                
	            if(currentSection.get('selected') == true){
	                if(sectionString==''){
	                    sectionString+=currentSection.get('abbreviation');
	                }
	                else{
	                    sectionString+=':'+currentSection.get('abbreviation');
	                }
	            }
	        }
        }

        if(!currentRecord.isEmpty()){
            System.debug('currentRecord: ' + currentRecord);
            currentRecord.get(0).sections__c=sectionString;
            for(Club_Product__c prod:[SELECT Id, Name, Section_Code__c, Product_Detail__c, Sections_Allowed__c, RecordType.Name 
                                      FROM Club_Product__c 
                                      WHERE RecordType.Name = 'Membership Code']){
                if(prod.Name==membershipType){
                    currentRecord.get(0).Membership_Type__c=prod.Id;
                }
            }
            try{
                update currentRecord;
            }
            catch(Exception e){
                CustomExceptionData data = new CustomExceptionData('Update Membership types error', e.getMessage(), 123);
                throw new AuraHandledException(JSON.serialize(data));
            }
        }
    }

    public class Section {
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String code {get;set;}
        @AuraEnabled public String price {get;set;}
        @AuraEnabled public Boolean selected {get;set;}
        @AuraEnabled public String abbreviation {get;set;}

        public Section(String name, String code, String abbreviation, String price){
            this.name = name;
            this.code = code;
            this.abbreviation = abbreviation;
            this.price = price;
        }
  }
    public class CustomExceptionData {
        public String name;
        public String message;
        public Integer code;

        public CustomExceptionData(String name, String message, Integer code) {
            this.name = name;
            this.message = message;
            this.code = code;
            }
        }
    
}