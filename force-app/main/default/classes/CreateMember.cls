public with sharing class CreateMember {

    public constants sc = new constants();
    
    public void CreateMember(){}
    
    public Database.LeadConvertResult createMembershipfromLead(Lead lea,String token,String acode){

        if(lea.id!=null && lea.sections__c!=null ){
            List<String> msections = lea.sections__c.split(':',-2);
            Set<String> ssections = new Set<String>();
            ssections.addall(msections);
    
            for (sectionSelectWrapper s:sections){
                if(ssections.contains(s.s.name))s.selected=true;
            }
        }
        
        System.debug('------------- LEAD: ' + lea);

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lea.id);
        if(lea.Joining_Date__c==null){
            lea.Joining_Date__c=Date.today();
            update lea;
        }
        

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setOpportunityName('New Membership');

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Contact c = [select id,recordtypeid,email,mobilephone from Contact where id=:lcr.contactid];
        c.recordtypeid = sc.leadContactRecordTypeId;
        c.Date_Joined__c = lea.Joining_Date__c;
        c.online_account_created__c = lea.lead_member_online_account__c;
        c.birthdate = lea.Lead_Member_Date_of_Birth__c;
        c.Age_Concession__c = lea.Age_Concession__c;
        
        update c;
        Contact c1;
        Contact c2;
        Contact c3;
        Contact c4;
        Contact c5;
        Contact c6;
        Contact secContact;
        Contact assocContact;
        if(lea.Number_of_Children__c!=null)
        {
            if(Integer.valueof(lea.Number_of_Children__c)>=1)
            {
                c1 = new Contact(recordtypeid=sc.childContactRecordTypeId,
                                        Accountid = lcr.accountId, 
                                        Date_Joined__c = lea.Joining_Date__c,
                                        firstname=lea.Child_1_First_Name__c,
                                        lastname=lea.Child_1_Surname__c,
                                        Salutation = lea.Child_1_Title__c,
                                        Birthdate = lea.Child_1_Date_of_Birth__c);
                insert c1;
            }
            if(Integer.valueof(lea.Number_of_Children__c)>=2)
            {
                c2 = new Contact(recordtypeid=sc.childContactRecordTypeId,
                                        Accountid = lcr.accountId, 
                                        Date_Joined__c = lea.Joining_Date__c,
                                        firstname=lea.Child_2_First_Name__c,
                                        lastname=lea.Child_2_Surname__c,
                                        Salutation = lea.Child_2_Title__c,
                                        Birthdate = lea.Child_2_Date_of_Birth__c);
                insert c2;
            }
            if(Integer.valueof(lea.Number_of_Children__c)>=3)
            {
                c3 = new Contact(recordtypeid=sc.childContactRecordTypeId,
                                        Accountid = lcr.accountId, 
                                        Date_Joined__c = lea.Joining_Date__c,
                                        firstname=lea.Child_3_First_Name__c,
                                        lastname=lea.Child_3_Surname__c,
                                        Salutation = lea.Child_3_Title__c,
                                        Birthdate = lea.Child_3_Date_of_Birth__c);
                insert c3;
            }
            if(Integer.valueof(lea.Number_of_Children__c)>=4)
            {
                c4 = new Contact(recordtypeid=sc.childContactRecordTypeId,
                                        Accountid = lcr.accountId, 
                                        Date_Joined__c = lea.Joining_Date__c,
                                        firstname=lea.Child_4_First_Name__c,
                                        lastname=lea.Child_4_Surname__c,
                                        Salutation = lea.Child_4_Title__c,
                                        Birthdate = lea.Child_4_Date_of_Birth__c);
                insert c4;
            }
            if(Integer.valueof(lea.Number_of_Children__c)>=5)
            {
                c5 = new Contact(recordtypeid=sc.childContactRecordTypeId,
                                        Accountid = lcr.accountId, 
                                        Date_Joined__c = lea.Joining_Date__c,
                                        firstname=lea.Child_5_First_Name__c,
                                        lastname=lea.Child_5_Surname__c,
                                        Salutation = lea.Child_5_Title__c,
                                        Birthdate = lea.Child_5_Date_of_Birth__c);
                insert c5;
            }
            if(Integer.valueof(lea.Number_of_Children__c)>=6)
            {
                c6 = new Contact(recordtypeid=sc.childContactRecordTypeId,
                                        Accountid = lcr.accountId, 
                                        Date_Joined__c = lea.Joining_Date__c,
                                        firstname=lea.Child_6_First_Name__c,
                                        lastname=lea.Child_6_Surname__c,
                                        Salutation = lea.Child_6_Title__c,
                                        Birthdate = lea.Child_6_Date_of_Birth__c);
                insert c6;
            }
        }
        if(lea.hasPartner__c)
        {
            secContact = new Contact(recordtypeid=sc.secondaryContactRecordTypeId,
                                    Accountid = lcr.accountId, 
                                    online_account_created__c = lea.Secondary_Member_online_account__c,
                                    Date_Joined__c = lea.Joining_Date__c,
                                    firstname=lea.Secondary_Member_First_Name__c,
                                    lastname=lea.Secondary_Member_Surname__c,
                                    email = lea.Secondary_Member_Email__c,
                                    Salutation = lea.Secondary_Member_Title__c,
                                    Phone=lea.Phone,
                                    MobilePhone = lea.Secondary_Member_Mobile_Number__c,
                                    Birthdate = lea.Secondary_Member_Date_of_Birth__c,
                                    Age_Concession__c = lea.SM_Age_Concession__c
                                    );
            						
            insert secContact;
        }
        if(lea.hasAssociate__c)
        {
            assocContact = new Contact(recordtypeid=sc.associateContactRecordTypeId,
                                    Accountid = lcr.accountId,
                                    Date_Joined__c = lea.Joining_Date__c,
                                    firstname=lea.Associate_Member_First_Name__c,
                                    lastname=lea.Associate_Member_Surname__c,
                                    Salutation = lea.Associate_Member_Title__c,
                                    Birthdate = lea.Associate_Member_Date_of_Birth__c);
            insert assocContact;
        }

        Account acct = [select id,BillingPostalCode,Membership_Status__c,Date_Joined__c from Account where id=:lcr.accountId];
        Opportunity oppty = [select id,closedate from Opportunity where id=:lcr.opportunityId];
        
        if(acct.BillingPostalCode!=null){
            List<String> parts = acct.BillingPostalCode.split(' ');
            if(parts.size()>1){
                String pcodeout = parts[0];
                String pcodein = parts[1].substring(0, 1); 
         
                List<DA_Postcode__c> dap = new List<DA_Postcode__c>();
                
                dap = [select Association_Name__c,Postcode_Part_1__c,Postcode_Part_2__c
                        from DA_Postcode__c where Postcode_Part_1__c =:pcodeout
                        and (Postcode_Part_2__c = :pcodein or Postcode_Part_2__c = null ) limit 1];
                        
                if(dap.size()>0)
                {
                    acct.District_Association__c = dap[0].Association_Name__c;
                }
                else
                {
                    acct.District_Association__c = null;
                }
            }
        }
        if(token!=null){
            acct.Membership_Status__c='Paid';
        }

        Promotional_Code__c voucher;
        try{
            voucher = [select id,name,Description__c,Expiry_Date__c,Number_Allowed__c,Number_of_Valid_Codes__c,Number_Used__c,Valid_for_Memberships__c,Valid_From__c
                from Promotional_Code__c
                where name = :lea.voucher_code__c];
        }
        catch (exception ex){
            voucher = new Promotional_Code__c();
        }

        Dealer_Advert__c dealercode;
        try{
            dealercode = [select id,name,Active__c,Valid_Show__c,Show_Start_Date__c,Show_End_Date__c
                from Dealer_Advert__c
                where id = :lea.Dealer_Ad_Code__c];
        }
        catch (exception ex){dealercode = new Dealer_Advert__c();}

        List<Club_Opportunity_Product__c> copList = new List<Club_Opportunity_Product__c>();
        List<Member_Section__c> mcList = new List<Member_Section__c>();
       

        Date now = Date.today();
        List<Club_Product__c> mtList = [select id,name,recordtypeid,Product_Detail__c,Membership_Length__c,renewable__c,(select Price__c,Joining_Fee__c, Payment_Type__c from Prices__r where Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null) order by Start_Date__c) from club_product__c where recordtype.name='Membership Code' and Show_in_New_Membership_Picklist__c=true order by name];
        List<Club_Product__c> pList = [select id,name,recordtypeid,Product_Detail__c,(select Price__c from Prices__r where Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null) order by Start_Date__c) from club_product__c where recordtype.name='Associate Membership' order by name];

        Decimal totalcost=0;

        
        if(lea.hasAssociate__c){ 
            System.debug('[CreateMember.createMembershipfromLead] lea.hasAssociate__c: ' + lea.hasAssociate__c);
            for(Club_Product__c p:plist){
                System.debug('[CreateMember.createMembershipfromLead] product: ' + p);
                System.debug('[CreateMember.createMembershipfromLead] p.prices__r: ' + p.prices__r);
                totalcost+=p.prices__r[0].Price__c;
                Club_Opportunity_Product__c ma = new Club_Opportunity_Product__c(recordtypeid=sc.amsectRecordTypeId,Account__c = lcr.accountid, Product__c = p.id,price__c = p.prices__r[0].Price__c,Opportunity__c=oppty.id,status__c=sc.active);
                copList.add(ma);
            }
        }

        for(Club_Product__c m:mtList){
            if(m.Name == lea.Membership_Code__c){
                acct.Membership_Code__c = m.id; 
                //acct.Renewal_Date__c = acct.Date_Joined__c.addmonths(Integer.valueof(m.Membership_Length__c));
                acct.Renewal_Date__c = getRenewalDate(acct, lea, m);
                Club_Opportunity_Product__c ma = new Club_Opportunity_Product__c(recordtypeid=sc.mtsectRecordTypeId,Account__c = lcr.accountid, Product__c = m.id,Opportunity__c=oppty.id,status__c=sc.active);
                ma.Price__c = 0; 
                if(voucher.id == null){
                    for(Price__c p:m.prices__r){
                        if(p.Payment_Type__c == lea.Payment_Method__c){
                            totalcost+=p.Price__c;
                            ma.price__c = p.Price__c;
                            if(!lea.Joining_Fee_Waived__c){
                                totalcost+=p.Joining_Fee__c;
                                ma.price__c += p.Joining_Fee__c;
                            }
                        }
                    }
                }
                copList.add(ma);
            }
        }

        for (sectionSelectWrapper s:sections){
            if(s.selected){
                Club_Opportunity_Product__c ma = new Club_Opportunity_Product__c(recordtypeid=sc.cpsectRecordTypeId,Account__c = lcr.accountid, Product__c = s.s.id,Opportunity__c=oppty.id,status__c=sc.active);
                ma.price__c = s.price;
                if(dealercode.valid_show__c && dealercode.Show_Start_Date__c <= date.today() && dealercode.Show_End_Date__c >= date.today()){
                    ma.price__c=0;
                }
                copList.add(ma);
                totalcost+=ma.price__c;
            }
        }

        List<RecordType> pmrt = [SELECT Description,DeveloperName,Id,Name,SobjectType FROM RecordType where SobjectType='Payment_Method__c' ];

        Payment_Method__c pm = new Payment_Method__c();
        pm.Membership__c = acct.id;

        system.debug(pmrt);
        system.debug(lea.Payment_Method__c);
        for(RecordType r:pmrt){
            system.debug(r);
            if(r.Name==lea.Payment_Method__c){
                system.debug('Found');
                pm.recordtypeid = r.id;
            }
        }

        if(lea.Payment_Method__c=='Debit/Credit Card'){
            pm.CC_Token__c = token;
//          pm.recordtypeid = sc.CcardRecordTypeId;
            pm.Authorization_code__c = acode;
            if(token!=null){
                acct.Membership_Status__c='Paid';
            }
            else
            {
                acct.Membership_Status__c='Unpaid';
            }
        }
        else if(lea.Payment_Method__c=='Direct Debit'){
//          pm.recordtypeid = sc.ddebitRecordTypeId;
            pm.Bank_Account_Name__c = lea.Bank_Account_Name__c;
            pm.Bank_Account_Number__c = lea.Bank_Account_Number__c;
            pm.Bank_Name__c = lea.Bank_Name__c;
            pm.Sort_Code__c = lea.Sort_Code__c.replaceAll('[^0-9]', '');
            pm.Mandate_Amount__c = totalCost;
            pm.Membership_Email__c = lea.Email;
            if(pm.Mandate_Amount__c > 0){
            	acct.Membership_Status__c='DD Pending';
            }
            else if (pm.Mandate_Amount__c == 0){
            	acct.Membership_Status__c = 'Paid';
            }
        }
        else if (lea.Payment_Method__c=='Cash/Cheque'){
//          pm.recordtypeid = sc.cashRecordTypeId;
            acct.Membership_Status__c='Paid';
        }
        pm.Status__c = 'Active';
        pm.start_date__c = Date.today();
        insert pm;

        oppty.Payment_Method__c = pm.id;
        oppty.closedate = date.today();
        oppty.StageName =sc.complete;
        oppty.amount = totalCost;
         if(voucher.id!=null){
            oppty.Promotional_Code__c = voucher.id;
            if(voucher.Number_Used__c == null ) voucher.Number_Used__c =0;
            voucher.Number_Used__c +=1;
            update voucher;
        }
        Dealer_Advert__c da;
        if(lea.Dealer_Code__c != null){
            //da= [Select Id FROM Dealer_Advert__c WHERE Name = :lea.Dealer_Code__c];
            oppty.Dealer_Ad_Code__c = lea.Dealer_Ad_Code__c;
        }
        update oppty;

        Transaction__c tr;
        if(lea.Payment_Method__c=='Debit/Credit Card'){
            tr = new Transaction__c(Amount__c=totalCost);
            tr.Payment_Method__c = pm.id;
            tr.recordtypeid = sc.trCcardRecordTypeId;
            tr.Authorization_code__c = acode;
            if(token!=null){
                tr.Transaction_Date__c = date.today();
            }
        }
        else if (lea.Payment_Method__c=='Cash/Cheque'){
            tr = new Transaction__c(Amount__c=totalCost);
            tr.Payment_Method__c = pm.id;
            tr.recordtypeid = sc.trcashRecordTypeId;
        }
        
        if(tr!=null)insert tr;
       /* if(voucher.id!=null){
            acct.Promotional_Code__c = voucher.id;
            if(voucher.Number_Used__c == null ) voucher.Number_Used__c =0;
            voucher.Number_Used__c +=1;
            update voucher;
        }*/

        acct.Email__c = c.email;
        acct.Mobile_Phone__c = c.mobilephone;
        //acct.Renewal_Date__c = acct.Date_Joined__c.addmonths(12);
        acct.Payment_Method2__c = lea.Payment_Method__c;
        update acct;

        if(copList.size()>0)insert copList;
        
        for(Club_Opportunity_Product__c cp:coplist){
            Member_Section__c mc = new Member_Section__c(Member__c = lcr.contactid, Club_Opportunity_Product__c = cp.id);
            mcList.add(mc);
            if(lea.hasPartner__c){
                Member_Section__c mcs = new Member_Section__c(Member__c = secContact.id, Club_Opportunity_Product__c = cp.id);
                mcList.add(mcs);
            }
        }
        if(mcList.size()>0)insert mcList;

        if(lea.Existing_Members_Number__c!=null){ 
            system.debug(lea.Existing_Members_Number__c);
            system.debug(lcr.accountid);
            Contact cn = [select id from Contact where account.Hybrid_Membership_Number__c = :lea.Existing_Members_Number__c
                         and recordtypeid=:sc.leadContactRecordTypeId];
            Member_Get_Member__c mgm = new Member_Get_Member__c(Existing_Member__c = cn.id,Gift__c = lea.Gift__c,Introduced_Membership__c = lcr.accountid);
            insert mgm;
        }

        return lcr;
    }

    public List<sectionSelectWrapper> sections {
        get{
            if(sections==null){
                sections = new List<sectionSelectWrapper>();
                Date now = Date.today();
                for(club_product__c s:[select id,recordtypeid,name,Product_Detail__c,(select Price__c from Prices__r where Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null) order by Start_Date__c) from club_product__c where recordtype.name='Section' order by name]){
                    List<price__c> pr = s.prices__r;
                    if(pr.size()>0){
                        sections.add(new sectionSelectWrapper(s,s.prices__r[0].price__c));
                    }
                }
            }
            return sections;
        } 
        set;
    }

    /**
     * Get Renewal Date for Membership (Account) which depends on some circumstances
     *
     * @param acc - Account record for which it calculates Renewal Date
     * @param theLead - Lead record which is origin for acc parameter
     * @param clubProduct - Club Product record
     *
     * @return Renewal Date
     */
    public Date getRenewalDate(Account acc, Lead theLead, Club_Product__c clubProduct) {
        // Prepare Renewal Date in case of Young Camper Membership Type
        if (theLead.Membership_Code__c == constants.YOUNG_CAMPER_MEMBERSHIP_TYPE && theLead.Lead_Member_Date_of_Birth__c != null) {
            Date today = Date.today();
            Date leadBirthDateThisYear = Date.newInstance(
                    today.year(),
                    theLead.Lead_Member_Date_of_Birth__c.month(),
                    theLead.Lead_Member_Date_of_Birth__c.day()
            );
            //Check if member's birthday has already passed or not
            Date nextRenewalBatchRunDate = today.addMonths(1).toStartOfMonth();
            Integer renewalYear = nextRenewalBatchRunDate.monthsBetween(leadBirthDateThisYear) >= 0 ? today.year() : today.year() + 1;

            return Date.newInstance(
                    renewalYear,
                    theLead.Lead_Member_Date_of_Birth__c.month(),
                    theLead.Lead_Member_Date_of_Birth__c.day()
            );
        }
        // Default value
        return acc.Date_Joined__c.addMonths(Integer.valueOf(clubProduct.Membership_Length__c));
    }

}