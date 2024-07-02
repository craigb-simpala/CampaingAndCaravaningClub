public with sharing class CreateCorrespondenceController {

    public apexpages.standardController controller {get; set;}
    public Account acc {get;set;}
    public Correspondence__c corr {get;set;}
    public constants sc = new constants();
    
    public CreateCorrespondenceController(apexpages.standardController controller) {
        this.controller = controller;

        List<String> accfields = new list<String>();
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        for(String s : objectFields.keySet()) {
            accfields.add(s);
            //system.debug(s);
        }
        accfields.add('Membership_Code__r.name');
        if(!test.isRunningTest()) 
            controller.addFields(accfields);

        this.acc = (Account) controller.getRecord();
        corr = new Correspondence__c(Membership__c = this.acc.id, Payment_Method__c = this.acc.Payment_Method2__c);
        
    }

    Public Opportunity opp {
        get{
            if(opp==null){
                try{
                    opp = [select id,name,closedate,(select id,price__c,product__c,recordtypeid from Line_Items__r) from Opportunity where accountid =:this.acc.id and recordtypeid= :sc.OppRenewalRecordTypeId and isclosed=false and iswon=false];
                }
                catch(exception ex){
                    opp = new Opportunity();
                }
            }
            return opp;
        }
        set;
    }

    public List<Cancellation__c> canclist {
        get{
            if(canclist==null){
                canclist = [select id from Cancellation__c 
                            where Membership__c = :this.acc.id
                            order by name desc];
            }
            return canclist;
        }
        set;
    }
    
    

    public List<Club_Opportunity_Product__c> purchasedPorductList {
        get{
            if(purchasedPorductList==null){
                system.debug('this.acc.id this.opp.id sc.sectionRecordTypeId ' + this.acc.id + ' ' + this.opp.id + ' '+ sc.sectionRecordTypeId);
                purchasedPorductList = [select id, Hybrid_Membership_Number__c, Member_Section__c, Non_Renewer_flag__c, Opportunity__c, Member_Section__r.name,
                                        Product__c, product__r.Name, Price__c, account__r.Membership_Code__c, Status__c
                                        from Club_Opportunity_Product__c 
                                        where Account__c = :this.acc.id
                                        and Opportunity__c = :this.opp.id
                                        and RecordTypeId = :sc.sectionRecordTypeId
                                        ];
            system.debug('getting purchasedPorductList ' + purchasedPorductList.size());
            }
            return purchasedPorductList;
        }
        set;
    }
    
    public double membershipFee{
        get{
            Date todaysDate = Date.today();
            if (membershipFee == null){
                system.debug(acc.Membership_Code__c);
                system.debug(acc.Payment_Method2__c);
                Price__c p = [SELECT id, Price__c FROM Price__c WHERE Product__c = :acc.Membership_Code__c AND Start_Date__c <:todaysDate AND (End_Date__c = null OR End_Date__c >:todaysDate) AND Payment_Type__c = :acc.Payment_Method2__c];
                system.debug(p);
                membershipFee = p.price__c; 
            }
            return membershipFee;
        }
        set;
    }
    
    public double associateFee{
        get{
            //|| End_Date__c >= :Date.today() system.debug([SELECT id, Price__c, Product__r.RecordTypeId FROM Price__c WHERE Product__r.RecordTypeId =: sc.clubProdAssociateRecordTypeId AND End_Date__c = null ]);
            if (membershipFee == null){
                try{
                system.debug(sc.clubProdAssociateRecordTypeId);
                Date todaysDate = Date.today();
                Price__c p = [SELECT id, Price__c, Product__r.RecordTypeId FROM Price__c WHERE Product__r.RecordTypeId =: sc.clubProdAssociateRecordTypeId AND Start_Date__c <:todaysDate AND (End_Date__c = null OR End_Date__c >:todaysDate)];
                associateFee = p.price__c;
                }catch(Exception e){
                    associateFee = 0;
                }
            }
            return associateFee;
        }
        set;
    }
    
    public String sections{
        get{
            sections = '';
            system.debug('getting purchasedPorductList sections' + purchasedPorductList.size());
            for(Club_Opportunity_Product__c cop : purchasedPorductList){
                if(cop.Status__c == 'Active'){
                    if(sections != null){
                        sections += cop.product__r.Name + ',';
                    } else {
                        if(purchasedPorductList.size() > 1){
                            sections = cop.product__r.Name + ',';
                        } else if (purchasedPorductList.size()== 1){
                            sections = cop.product__r.Name;                     
                        }
                    }
                    system.debug('getting cop.product__r.Name Status__c ' + cop.product__r.Name + ' '+ cop.Status__c);
                }
            }
            system.debug('sections Status__c ' + sections);
            sections = sections.removeEnd(',');
            return sections;
        }
        set;
    }
    
    public double nonRenewalSectionPrice;
    
    public String nonRenewalSections{
        get{
            nonRenewalSections='';
            system.debug('getting purchasedPorductList sections' + nonRenewalLeadMember.Member_Sections__r.size());
            nonRenewalSectionPrice=0;
            for(Member_Section__c cop : nonRenewalLeadMember.Member_Sections__r){
                if(cop.Status__c == 'Active'){
                    if(nonRenewalSections != null){
                        nonRenewalSections += cop.Club_Opportunity_Product__r.Product__r.Name + ',';
                    } else {
                        if(nonRenewalLeadMember.Member_Sections__r.size() > 1){
                            nonRenewalSections = cop.Club_Opportunity_Product__r.Product__r.Name + ',';
                        } else if (nonRenewalLeadMember.Member_Sections__r.size()== 1){
                            nonRenewalSections = cop.Club_Opportunity_Product__r.Product__r.Name;                       
                        }
                    }
                    system.debug('getting cop.product__r.Name Status__c ' + cop.Club_Opportunity_Product__r.Product__r.Name + ' '+ cop.Status__c);
                    if(nonRenewalSectionPrice != 0){
                        nonRenewalSectionPrice += cop.Price__c;
                    } else {
                        nonRenewalSectionPrice = cop.Price__c;                  
                    }
                    system.debug('getting cop.Price__c ' + cop.Price__c);
                }
            }
            system.debug('nonRenewalSections Status__c ' + nonRenewalSections);
            nonRenewalSections = nonRenewalSections.removeEnd(',');
            return nonRenewalSections;
            
        }
        set;
    }
    
    public double sectionsPrice{
        get{
            sectionsPrice = 0;
            system.debug('getting purchasedPorductList ' + purchasedPorductList.size());
            for(Club_Opportunity_Product__c cop : purchasedPorductList){
                if(sectionsPrice != 0){
                    sectionsPrice += cop.Price__c;
                } else {
                    sectionsPrice = cop.Price__c;                   
                }
                system.debug('getting cop.Price__c ' + cop.Price__c);
            }
            system.debug('sectionsPrice ' + sectionsPrice);
            return sectionsPrice;
        }
        set;
    }
    
    public Contact leadMember {
        get{
            leadMember = new Contact();
            leadMember =[Select Id, Salutation,FirstName,LastName, Tenure2__c, Age_Concession__c, Youth_Test_Passed_Date__c from Contact where RecordTypeId = :sc.leadContactRecordTypeId
                                        AND accountId = :acc.Id];
            return leadMember;
        }
        set;
    }
    
    
    public Contact nonRenewalLeadMember {
        get{
            nonRenewalLeadMember = new Contact();
            nonRenewalLeadMember =[Select Id, Salutation,FirstName,LastName, Tenure2__c,Age_Concession__c, Youth_Test_Passed_Date__c, (SELECT Id,Price__c, Club_Opportunity_Product__c,
                         Club_Opportunity_Product__r.Hybrid_Membership_Number__c, Club_Opportunity_Product__r.Non_Renewer_flag__c, Club_Opportunity_Product__r.Opportunity__c, 
                         name,Club_Opportunity_Product__r.Product__c, Product_Name__c, Club_Opportunity_Product__r.account__r.Membership_Code__c, 
                         Status__c, Member__c, Membership_Number__c, Club_Opportunity_Product__r.RecordTypeId, Club_Opportunity_Product__r.Product__r.Name
                         FROM Member_Sections__r 
                         WHERE Club_Opportunity_Product__r.RecordTypeId  = :sc.sectionRecordTypeId) from Contact where RecordTypeId = :sc.leadContactRecordTypeId
                                        AND accountId = :acc.Id];
            return nonRenewalLeadMember;
        }
        set;
    }
    
    public List<Contact> secMember {
        get{
            secMember = new List<Contact>();
            secMember = [Select Id, Salutation,FirstName,LastName, Tenure2__c, Age_Concession__c from Contact where RecordTypeId = :sc.secondaryContactRecordTypeId
                                        AND accountId = :acc.Id AND Status__c = 'Active'];
            return secMember;
        }
        set;
    }
    
    public List<Contact> accessMember {
        get{
            accessMember = new List<Contact>();
            accessMember = [Select Id, Salutation,FirstName,LastName, Tenure2__c, Age_Concession__c from Contact where RecordTypeId = :sc.accessContactRecordTypeId
                                        AND accountId = :acc.Id AND Status__c = 'Active'];
            return accessMember;
        }
        set;
    }
    
    public List<Contact> assocMember {
        get{
            assocMember = new List<Contact>();
            assocMember = [Select Id, Salutation,FirstName,LastName, Tenure2__c, Age_Concession__c from Contact where RecordTypeId = :sc.associateContactRecordTypeId
                                        AND accountId = :acc.Id AND Status__c = 'Active'];
            return assocMember;
        }
        set;
    }
    
    
    public List<Correspondence__c> amendCorr {
        get{
            amendCorr = new List<Correspondence__c>();
            amendCorr = [SELECT Id, name, Amendment_Renewal__c FROM Correspondence__c WHERE Amendment_Renewal__c = :opp.Id 
                    AND Correspondence_Type__c = 'Renewal'];
            return amendCorr;
        }set;}
        
        
        
    public List<Member_Get_Member__c> mgmList {
        get{
            mgmList = new List<Member_Get_Member__c>();
            /*mgmList = [SELECT Id, Existing_Member__c, Existing_Member__r.Salutation,Existing_Member__r.FirstName, 
                    Existing_Member__r.LastName, Existing_Member__r.Account.BillingStreet, Existing_Member__r.Account.BillingCountry,
                    Existing_Member__r.Account.BillingState, Existing_Member__r.Account.Organisation_Name__c,
                    Existing_Member__r.Account.BillingCity, Existing_Member__r.Account.BillingPostalCode
                    FROM  Member_Get_Member__c WHERE Existing_Member__c = : leadMember.Id];   */
            mgmList = [SELECT Id, Existing_Member__c, Existing_Member__r.Salutation,Existing_Member__r.FirstName, Existing_Member__r.AccountId,
                        Existing_Member__r.LastName, Existing_Member__r.Account.BillingStreet, Existing_Member__r.Account.BillingCountry,
                        Existing_Member__r.Account.BillingState, Existing_Member__r.Account.Organisation_Name__c,
                        Existing_Member__r.Account.BillingCity, Existing_Member__r.Account.BillingPostalCode, Introduced_Membership__c
                         FROM  Member_Get_Member__c WHERE Existing_Member__c = : leadMember.Id AND Introduced_Membership__c = : acc.Id];
            return mgmList;
        }
        set;
    } 

    public PageReference saveCorr(){
        if(corr.Correspondence_Type_MailingHouse__c==null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select a correspondence type'));
        }
        if(corr.Correspondence_Type_MailingHouse__c=='Renewal' && opp.id==null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'This Membership does not have an active renewal'));
        }
        if(corr.Correspondence_Type_MailingHouse__c=='Cancellation' && canclist.size()==0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'This Membership has no cancellations'));
        }
        if(corr.Correspondence_Type_MailingHouse__c=='Replacement AM' && assocMember.size()==0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'This Membership has no Associate Members'));
        }
        if (!ApexPages.hasMessages()) {
            Contact lc = [SELECT id from contact where accountid=:this.acc.id and recordtypeid=:sc.leadContactRecordTypeId];
            corr.Member__c = lc.id;
            corr.Correspondence_date__c = Date.today();

            if (corr.Correspondence_Type_MailingHouse__c=='Replacement Renewal') {
                    corr.Correspondence_Type__c = 'Replacement Renewal';
                    corr.Replacement_renewal__c = opp.id;   
                    corr.Lead_Member__c = leadMember.Id;
                    corr.Lead_Member_Salutation__c =  leadMember.Salutation;
                    corr.Lead_Member_First_Name__c =  leadMember.FirstName;
                    corr.Lead_Member_Last_Name__c =  leadMember.LastName;
                    corr.Youth_Test_Passed_Date__c = leadMember.Youth_Test_Passed_Date__c;
                    corr.Renewal_Date__c = acc.Renewal_Date__c;

                    if (amendCorr.size() > 0) {
                        corr.Amendment_Renewal__c =  amendCorr[0].Amendment_Renewal__c;
                    }

                    corr.Tenure__c = leadMember.Tenure2__c == null ? 1 : leadMember.Tenure2__c + 1;

                    if (secMember.size() > 0) {
                        corr.Secondary_Member__c =  secMember[0].Id;
                        corr.Second_Member_Salutation__c =  secMember[0].Salutation;
                        corr.Second_Member_First_Name__c =  secMember[0].FirstName;
                        corr.Second_Member_Last_Name__c =  secMember[0].LastName;

                        if (secMember[0].Tenure2__c != null) {
                            corr.Tenure_Secondary__c = secMember[0].Tenure2__c + 1;
                        } else {
                            corr.Tenure_Secondary__c = 1.0;
                        }
                    }

                    corr.Sections__c = this.sections;
                    corr.Sections_fee__c = this.sectionsPrice;
                    corr.Membership_Subscription_Fee__c = membershipFee;
                    corr.Associate_Member_Fee__c = associateFee;
            }
            else if(corr.Correspondence_Type_MailingHouse__c=='New Second Member'){
                    corr.Correspondence_Type__c = 'New Second Member';
                    corr.Membership__c = this.acc.id;
                    corr.Lead_Member__c = leadMember.Id;
                    corr.Lead_Member_Salutation__c =  leadMember.Salutation;
                    corr.Lead_Member_First_Name__c =  leadMember.FirstName;
                    corr.Lead_Member_Last_Name__c =  leadMember.LastName;
                    corr.Renewal_Date__c = acc.Renewal_Date__c;
                    corr.Tenure__c = leadMember.Tenure2__c;
                    if(secMember.size() > 0){
                        corr.Secondary_Member__c =  secMember[0].Id;
                        corr.Second_Member_Salutation__c =  secMember[0].Salutation;
                        corr.Second_Member_First_Name__c =  secMember[0].FirstName;
                        corr.Second_Member_Last_Name__c =  secMember[0].LastName;
                        system.debug('secMember[0].Tenure2__c ' + secMember[0].Tenure2__c);
                        if(secMember[0].Tenure2__c != null)
                            corr.Tenure_Secondary__c = secMember[0].Tenure2__c;
                        else 
                            corr.Tenure_Secondary__c = 1.0;
                    }
                    corr.Sections__c = this.nonRenewalSections; 
                    corr.Sections_fee__c = this.nonRenewalSectionPrice; 
            }
            else if(corr.Correspondence_Type_MailingHouse__c=='Replacement Card'){
                    corr.Correspondence_Type__c = 'Replacement Card';
                    corr.Membership__c = this.acc.id;
                    corr.Lead_Member__c = nonRenewalLeadMember.Id;
                    corr.Lead_Member_Salutation__c =  nonRenewalLeadMember.Salutation;
                    corr.Lead_Member_First_Name__c =  nonRenewalLeadMember.FirstName;
                    corr.Lead_Member_Last_Name__c =  nonRenewalLeadMember.LastName;
                    corr.Youth_Test_Passed_Date__c =  nonRenewalLeadMember.Youth_Test_Passed_Date__c;
                    corr.Tenure__c = nonRenewalLeadMember.Tenure2__c;
                    corr.Renewal_Date__c = acc.Renewal_Date__c;
                    if(secMember.size() > 0){
                        corr.Secondary_Member__c =  secMember[0].Id;
                        corr.Second_Member_Salutation__c =  secMember[0].Salutation;
                        corr.Second_Member_First_Name__c =  secMember[0].FirstName;
                        corr.Second_Member_Last_Name__c =  secMember[0].LastName;
                        system.debug('secMember[0].Tenure2__c ' + secMember[0].Tenure2__c);
                        if(secMember[0].Tenure2__c != null)
                            corr.Tenure_Secondary__c = secMember[0].Tenure2__c;
                        else 
                            corr.Tenure_Secondary__c = 1.0;
                    }
                    corr.Sections__c = this.nonRenewalSections; 
                    //corr.Sections_fee__c = this.nonRenewalSectionPrice;   
            }
            
            //not a manual process anymore
           /* else if(corr.Correspondence_Type_MailingHouse__c=='Site Directory'){
                    corr.Correspondence_Type__c = 'Site Directory';
                    corr.Membership__c = this.acc.id;
                    corr.Lead_Member__c = leadMember.Id;
                    corr.Lead_Member_Salutation__c =  leadMember.Salutation;
                    corr.Lead_Member_First_Name__c =  leadMember.FirstName;
                    corr.Lead_Member_Last_Name__c =  leadMember.LastName;
                    corr.Renewal_Date__c = acc.Renewal_Date__c;
                    corr.Description_of_Item_Requested__c = 'Site Directory';
                    //TODO Sections bit need populating         
            }*/
            /*else if(corr.Correspondence_Type_MailingHouse__c=='Monthly Magazine'){
                    corr.Correspondence_Type__c = 'Monthly Magazine';
                    corr.Membership__c = this.acc.id;
                    corr.Lead_Member__c = leadMember.Id;
                    corr.Lead_Member_Salutation__c =  leadMember.Salutation;
                    corr.Lead_Member_First_Name__c =  leadMember.FirstName;
                    corr.Lead_Member_Last_Name__c =  leadMember.LastName;
                    corr.Renewal_Date__c = acc.Renewal_Date__c;
                    corr.Description_of_Item_Requested__c = 'Monthly Magazine';
                    //TODO Sections bit need populating         
            }*/
            else if(corr.Correspondence_Type_MailingHouse__c=='New Access Member'){
                    corr.Correspondence_Type__c = 'New Access Member';
                    corr.Membership__c = this.acc.id;
                    corr.Lead_Member__c = leadMember.Id;
                    corr.Lead_Member_Salutation__c =  leadMember.Salutation;
                    corr.Lead_Member_First_Name__c =  leadMember.FirstName;
                    corr.Lead_Member_Last_Name__c =  leadMember.LastName;
                    corr.Renewal_Date__c = acc.Renewal_Date__c;
                    System.debug('accessMember.size(): ' + accessMember.size());
                    if(accessMember.size() > 0){
                        corr.Access_Member__c = accessMember[0].Id;
                        corr.Access_Salutation__c = accessMember[0].Salutation;
                        corr.Access_First_Name__c = accessMember[0].FirstName;
                        corr.Access_Last_Name__c =accessMember[0].LastName;
                    }       
            }
            else if(corr.Correspondence_Type_MailingHouse__c=='Replacement AM'){
                    corr.Correspondence_Type__c = 'Replacement AM';
                    corr.Membership__c = this.acc.id;
                    corr.Lead_Member__c = leadMember.Id;
                    corr.Lead_Member_Salutation__c =  leadMember.Salutation;
                    corr.Lead_Member_First_Name__c =  leadMember.FirstName;
                    corr.Lead_Member_Last_Name__c =  leadMember.LastName;
                    corr.Renewal_Date__c = acc.Renewal_Date__c;
                    if(assocMember.size() > 0){
                        corr.Associate_Member__c = assocMember[0].Id; 
                    }       
            }
            /*else if(corr.Correspondence_Type_MailingHouse__c=='Member Get Member'){             
                for(Member_Get_Member__c mgm: mgmList){
                    corr.Correspondence_Type__c = 'Member Get Member';
                    corr.Correspondence_date__c =  system.today();
                    corr.Renewal_Date__c = acc.Renewal_Date__c;
                    corr.Membership__c = mgm.Existing_Member__r.AccountId;
                    corr.Lead_Member__c = mgm.Existing_Member__r.Id;
                    corr.Gift_Code__c = mgm.Gift__c;
                    corr.Lead_Member_Salutation__c =  mgm.Existing_Member__r.Salutation;
                    corr.Lead_Member_First_Name__c =  mgm.Existing_Member__r.FirstName;
                    corr.Lead_Member_Last_Name__c =  mgm.Existing_Member__r.LastName;   
                    corr.MGM_Street__c = mgm.Existing_Member__r.Account.BillingStreet;
                    corr.MGM_Country__c = mgm.Existing_Member__r.Account.BillingCountry;
                    corr.MGM_County__c = mgm.Existing_Member__r.Account.BillingState;
                    corr.MGM_Organisation_Name__c = mgm.Existing_Member__r.Account.Organisation_Name__c;
                    corr.MGM_Postcode__c = mgm.Existing_Member__r.Account.BillingPostalCode;
                    corr.MGM_Town_City__c = mgm.Existing_Member__r.Account.BillingCity;     
                }
            }*/
            //try{
                upsert corr;
            /*} catch (Exception ex){
                System.debug('The following exception has occurred: ' + ex.getMessage());
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The following exception has occurred: ' + ex.getMessage()));
            }*/
            return controller.cancel();
        }
        return null;
    }
}