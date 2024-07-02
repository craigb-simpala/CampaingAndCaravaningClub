/*
* @who   Patrick Duncan <patrick.duncan@weare4c.com>
* @what  Apex class to be ran on sandbox refresh to invalidate all email fields specified by records on the metadata type Email_Field__mdt
* @when  2/8/2019
*/
global class SandboxRefreshEmailInvalidator implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        invalidateEmailAddresses(getEmailQueries());
    } 

    /*
    *  @description Function that queries for all email fields to be invalidated, given by the custom metadatatype Email_Field__mdt and creates a SOQL query for each object
    *  @return The map of Email field query -> List<string> of email fields being queried for
    */
    public static Map<String,List<String>> getEmailQueries(){
        //
        List<Email_Field__mdt> emailFields = [SELECT Id, Label, Object_Fields__c FROM Email_Field__mdt];

        String baseQuery = 'SELECT Id, ';
        Map<String,List<String>> emailQueries = new Map<String,List<String>>();

        for(Email_Field__mdt fieldSet:emailFields){
            String fullQuery = baseQuery;
            List<String> objectFields;
            //Objects with multiple email fields are seperated by a ','
            if(fieldSet.Object_Fields__c.contains(',')){
                objectFields = fieldSet.Object_Fields__c.split(',');
            }
            else{
                objectFields = new List<String>{fieldSet.Object_Fields__c};
            }

            //Build query select clause
            for(String emailField:objectFields){
                fullQuery += emailField + ', ';
            }
            fullQuery = fullQuery.removeEnd(', ');
            fullQuery += ' FROM ' + fieldSet.Label;
            emailQueries.put(fullQuery,objectFields);
        }
        return emailQueries;
    }

    /*
    *  @description Function that searches and generates a quote line item for a given search term
    *  @param  queryToEmailFields   A map of Email field query -> List<string> of email fields being queried for, to be fed into batch clas 
    */
    public static void invalidateEmailAddresses(Map<String,List<String>> queryToEmailFields){
        for(String query:queryToEmailFields.keySet()){
            SObjectEmailInvalidatorBatch invalidatorBatch = new SObjectEmailInvalidatorBatch(query,queryToEmailFields.get(query));
            Database.executeBatch(invalidatorBatch);
        }
    }


  
}