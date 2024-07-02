public with sharing class ExportCorrespondenceController {

    public Correspondence__c    corr {get;set;}
    public Correspondence__c    corr2 {get;set;}
    
    public list<string>         queryFields  {get;set;}
    public string               fileName     {get;set;}
    public Integer pagesize{get{return 200;}set;}
//    public List<corrSelectWrapper> transactions {get;set;}
    private set<string> fieldstoexclude = new Set<string>{'lastvieweddate','lastreferenceddate','id','ownerid','isdeleted','createddate','createdbyid',
                                                          'lastmodifieddate','lastmodifiedbyid','systemmodstamp','lastactivitydate','membership2__c','member__c',
                                                          'amendment_renewal__c','cancellation__c','contact_record_type_name__c','opportunity_record_type_name__c',
                                                          'age_concession__c', 'amendment_renewal__c', 'amount__c', 'associate_member__c', 'birthdate__c',
                                                          'camping_unit__c', 'correspondence_type_mailinghouse__c', 'date_joined__c', 'email__c', 'first_name__c',
                                                          'full_name__c', 'home_phone__c', 'last_name__c', 'lead_member__c', 'mobile_phone__c',
                                                           'old_da__c', 'replacement_renewal__c', 'opportunity_record_type_name__c', 're_issue__c',
                                                           're_issue_date__c','salutation__c','voucher_expiry_date__c', 'country__c', 
                                                           'membership__c', 'region__c', 'secondary_member__c', 'organisation_name_c__c', 'valid_until__c',
                                                           'access_member__c', 'mgm_country__c','mgm_county__c', 'mgm_organisation_name__c', 'mgm_postcode__c',
                                                           'mgm_street__c', 'mgm_town_city__c', 'payment_method__c', 'name', 'Membership_Status__c'};  
    
    public ExportCorrespondenceController(){
        corr = new Correspondence__c(Correspondence_date__c=Date.today().adddays(-7));
        corr2 = new Correspondence__c(Correspondence_date__c=Date.today());
        fileName = 'Correspondence ' + string.valueOf(dateTime.now());
        //transactions =  new List<corrSelectWrapper>();
        transactions =  null;
        con=null;
    }

    public PageReference search(){

        transactions =  null;
        con=null;
/*      
        String queryFilts = '';
        Date sdate = corr.Correspondence_date__c;
        Date edate = corr2.Correspondence_date__c;
        Decimal bnum = corr.Batch_Number__c;
        String ctype = corr.Correspondence_Type__c;
        transactions = new List<corrSelectWrapper>();
        if(corr.Batch_Number__c!=null){
            queryFilts += 'and Batch_Number__c = :bnum ';
        }

        if(corr.Correspondence_Type__c!=null){
            queryFilts += 'and Correspondence_Type__c = :ctype ';
        }
        list<Correspondence__c>     queryResults = new list<Correspondence__c>();
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Correspondence__c').getDescribe().fields.getMap();
        queryFields = new List<string>();
        String query = 'Select ';//'SELECT Name, Correspondence_Type__c, Correspondence_date__c, Membership_Number__c, Membership_Status__c';
        for(String s : objectFields.keySet()) {
            if(objectFields.get(s).getDescribe().isaccessible()){
                if(!fieldstoexclude.contains(s)){
                    query += ' ' + s + ',';
                    queryFields.add(s);
                    
                }
            }
        }
        if (query.subString(query.Length()-1,query.Length()) == ','){
            query = query.subString(0,query.Length()-1);
        }
        query += ' FROM Correspondence__c ';
        query += ' where Correspondence_date__c >= :sdate ';
        query += ' and Correspondence_date__c <= :edate ';
        query+= queryFilts;
        query+= ' ORDER BY Name DESC LIMIT 400';
        
       try{
            queryResults = Database.query(query);
            system.debug(queryResults);
            system.debug(queryFields);
       } catch (Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please narrow down the search. too many rows returned'));
            
       }


        for(Correspondence__c c: queryResults )
        {
            transactions.add(new corrSelectWrapper(c));
        }
        if(queryResults.size()==0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No records found for the selected criteria'));
        }
*/        
        return null;
        
    }

    public List<corrSelectWrapper> transactions {
        get{
            if(transactions==null){
                system.debug('get trans');
                transactions = new List<corrSelectWrapper>();
                for (Correspondence__c c : (List<Correspondence__c>)con.getRecords()){
                    transactions.add(new corrSelectWrapper(c));
                }
            }
            return transactions;
        }
        set;
    }


    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
//                String fam = filters.family;
//                Id pb2id = opp.Pricebook2Id;
                String queryFilts = '';
                Date sdate = corr.Correspondence_date__c;
                Date edate = corr2.Correspondence_date__c;
                Decimal bnum = corr.Batch_Number__c;
                String ctype = corr.Correspondence_Type__c;
                transactions = new List<corrSelectWrapper>();
                if(corr.Batch_Number__c!=null){
                    queryFilts += 'and Batch_Number__c = :bnum ';
                }
        
                if(corr.Correspondence_Type__c!=null){
                    queryFilts += 'and Correspondence_Type__c = :ctype ';
                }

                Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Correspondence__c').getDescribe().fields.getMap();
                queryFields = new List<string>();
                String query = 'Select ';//'SELECT Name, Correspondence_Type__c, Correspondence_date__c, Membership_Number__c, Membership_Status__c';
                for(String s : objectFields.keySet()) {
                    if(objectFields.get(s).getDescribe().isaccessible()){
                        if(!fieldstoexclude.contains(s)){
                            query += ' ' + s + ',';
                            queryFields.add(s);
                        }
                    }
                }
                if (query.subString(query.Length()-1,query.Length()) == ','){
                    query = query.subString(0,query.Length()-1);
                }
                query += ' FROM Correspondence__c ';
                query += ' where Correspondence_date__c >= :sdate ';
                query += ' and Correspondence_date__c <= :edate ';
                query+= queryFilts;
                query+= ' ORDER BY Name DESC LIMIT 10000';
        
                con = new ApexPages.StandardSetController(Database.getQueryLocator(Query));
                // sets the number of records in each page set
                con.setPageSize(pagesize);
                system.debug(con.getResultSize());
            }
            return con;
        }
        set;
    }

   public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    public Integer numResults {
        get {
            return con.getResultSize();
        }
        set;
    }

    public Integer numstart {
        get {
            return ((pagenumber-1)*pagesize)+1;
        }
        set;
    }

    public Integer numend {
        get {
            Integer pageend = ((pagenumber-1)*pagesize)+pagesize;
            if (pageend>numResults)pageend = numresults;
            return pageend;
        }
        set;
    }

    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

     public void first() {
         transactions=null;
         con.first();
     }

     public void last() {
         transactions=null;
         con.last();
     }

     public void previous() {
         transactions=null;
         con.previous();
     }

     public void next() {
         transactions=null;
         con.next();
     }

    
    public PageReference export(){

        if(transtoAdd.size()==0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select records for export.'));
            return null;
        }

        for(Correspondence__c c:transtoadd){
            if(c.Batch_Number__c==null)
                c.Batch_Number__c = batchId;
        }
        
        update transtoadd;
        
        PageReference pr = Page.ExportCorrespondenceCSV;
        pr.getHeaders().put( 'content-disposition', 'attachment; filename=AgressoExport.csv' );
        pr.setRedirect(false);
        
        return pr;
        
    }

    public Long batchId {
        get{
            if(batchId==null){
                batchId=getNextUniqueNumber();
            }
            return batchId;
        }
        set;
    }

    public static Long getNextUniqueNumber() {

        Savepoint sp = Database.setSavepoint();
 
        Unique_Number__c un = new Unique_Number__c();
        insert un;
 
        un = [select Name from Unique_Number__c where id = :un.id];
 
        Long num = Long.valueOf(un.Name);
 
        Database.rollback(sp);
 
        return num;
    }

    public static String getNewLine() {
      return '\n';
    }

    public List<Correspondence__c> transToAdd{
        get{
            List<Correspondence__c> m = new List<Correspondence__c>();
            if(transactions!=null)
            {
                for(corrSelectWrapper c: transactions)
                {
                    if(c.selected)
                    {
                        m.add(c.corr);
                    }
                }
            }
            system.debug(m);
            return m;
            
        }
        set;
    }   

    public class corrSelectWrapper {
        public Correspondence__c corr {get; set;}
        public Boolean selected {get; set;}
 
        public corrSelectWrapper(Correspondence__c c) { 
            this.corr = c;
            this.selected = false;
        }
    }


}