/*
* @who   Patrick Duncan <patrick.duncan@weare4c.com>
* @what  Batch class to be called by the class SandboxRefreshEmailInvalidator to invalidate email fields on a variety of different SObjects
* @when  2/8/2019
*/
global class SObjectEmailInvalidatorBatch implements Database.Batchable<sObject> {
    public String query;
    public List<String> emailFields;
    public String invalidString;

    global SObjectEmailInvalidatorBatch(String query, List<String> emailFields) {
        this.query = query;
        this.emailFields = emailFields;
        this.invalidString = '.invalid';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        for(sObject obj:scope){
            //For each email field on the sobject that is to be invalidated
            for(String field:emailFields){
                String emailFieldValue = (String) obj.get(field);
                if(emailFieldValue != null && !emailFieldValue.endsWith(invalidString)){
                    obj.put(field, emailFieldValue+invalidString);
                }
            }
        }
        try{
            update scope;
        }
        catch(DMLException e){
            throw new DMLException('Error updating email fields: '+e.getMessage());
        }
        
        
    }

    global void finish(Database.BatchableContext BC) {

    }
}