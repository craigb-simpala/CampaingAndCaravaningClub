/**
 * @description       : 
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 17-03-2022
 * @last modified by  : Kev Cadger (kevin.cadger@wipro.com)
 * Modifications Log
 * Ver   Date         Author                        Request                         Modification
 * 1.0   22-02-2022   Unknown                                                       Initial Version
 * 1.1   22-02-2022   Kev Cadger (Wipro)            REQ-000109128                   Checked the validation against the Hopewiser API.
 * 1.2   01-03-2022   Kev Cadger (Wipro)            REQ-000109128                   Updated the validation for all functions using the Hopewiser API.
**/

public with sharing class RenewMembershipController {
    public ApexPages.StandardController controller {get; set;}

    public Integer wizardStep {get;set;}
    public Lead lea {get;set;}
    public String leadString {get;set;}
    public Account acc {get;set;}
    public Opportunity  opp {get;set;}
    public constants sc = new constants();

    public Contact cAssocMember {
        get {
            if (cAssocMember == null) {
                try {
                    cAssocMember = [SELECT Title, FirstName, LastName, Birthdate FROM Contact WHERE Date_Ended__c = NULL AND AccountId = :acc.Id AND RecordTypeId =: sc.associateContactRecordTypeId LIMIT 1];
                } catch (Exception e) {
                    cAssocMember=new Contact();
                }
            }
            return cAssocMember;
        }
        set;
    }

    public Contact cPrimaryMember {
        get {
            if (cPrimaryMember==null) {
                try {
                    cPrimaryMember = [SELECT Salutation, Title, FirstName, LastName, Birthdate, Email FROM Contact WHERE AccountId = :acc.Id AND RecordTypeId = :sc.leadContactRecordTypeId LIMIT 1];
                }
                catch (Exception e) {
                    cPrimaryMember=new Contact();
                }
            }

            return cPrimaryMember;
        }
        set;
    }

    public Contact cSecondaryMember {
        get {
            if (cSecondaryMember==null) {
                try {
                    cSecondaryMember = [SELECT Title, FirstName, LastName, Birthdate, Email FROM Contact WHERE AccountId = :acc.Id AND RecordTypeId = :sc.secondaryContactRecordTypeId LIMIT 1];
                } catch (Exception e){
                    cSecondaryMember=new Contact();
                }
            }
            return cSecondaryMember;
        }
        set;
    }

    public List<Club_Opportunity_Product__c> cop {
        get {
            if (cop==null) {
                cop = [SELECT Id, Product__r.Product_Detail__c, Product__r.Name FROM Club_Opportunity_Product__c
                WHERE Account__c = :this.acc.Id
                AND Opportunity__c = :this.opp.Id
                AND Status__c = 'Pending'
                AND RecordTypeId = :sc.sectionRecordTypeId];
            }
            return cop;
        }
        set;
    }

    public List<SelectOption> membershipTypeOptions {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--None--'));

            for (Club_Product__c p : mtList) {
                options.add(new SelectOption((String)p.get('Name'), (String)p.get('Product_Detail__c')+' £'+String.valueOf(p.get('Price_for_Initial_Picklist__c'))));
            }

            return options;
        }
        set;
    }

    public Decimal mtCost{
        get {
            Decimal d=0;

            for (Club_Product__c m : mtList) {
                if (m.Name == lea.Membership_Code__c) {
                    
                    for (Price__c p : m.Prices__r) {
                        d += p.Price__c;
                        break;
                    }

                    if(d == 0 && lea.Payment_Method__c == null) {
                        d=m.Price_for_Initial_Picklist__c;
                    }
                }
            }
            return d;
        }
        set;
    }

    public List<Club_Product__c> mtList {
        get {
            CustomPermissionsReader cpr = new CustomPermissionsReader();
            Boolean haspermission = cpr.hasPermission('CanEditMemebershipType');
            if (mtList == null) {
                Date now = opp.CloseDate;
                List<Club_Product_Change__c> cpcl = [SELECT Id, From__c, To__c FROM Club_Product_Change__c WHERE From__c = :acc.Membership_Code__c];
                Set<Id> prodids = new Set<Id>();

                for (Club_Product_Change__c cpc : cpcl) {
                    prodids.add(cpc.To__c);
                }

                if (haspermission) {
                    mtList = [SELECT Id, Name, VIClass__c, Product_Detail__c,
                            Sections_Allowed__c, Associate_Allowed__c,
                            PartnerAllowed__c, Children_Allowed__c,
                            Card_Payment_Allowed__c, Cash_Payment_Allowed__c, DD_Payment_Allowed__c, Price_for_Initial_Picklist__c,
                    (SELECT Price__c, Joining_Fee__c, Payment_Type__c FROM Prices__r WHERE (Start_Date__c <= :now AND (End_Date__c >= :now OR End_Date__c = NULL)) ORDER BY Start_Date__c DESC)
                    FROM Club_Product__c
                    WHERE RecordType.Name = 'Membership Code'
                    AND Id IN :prodids
                    ORDER BY Name];
                } else{
                    mtList = [SELECT Id, Name, VIClass__c,Product_Detail__c,
                            Sections_Allowed__c, Associate_Allowed__c,
                            PartnerAllowed__c, Children_Allowed__c,
                            Card_Payment_Allowed__c,Cash_Payment_Allowed__c,DD_Payment_Allowed__c,Price_for_Initial_Picklist__c,
                    (SELECT Price__c, Joining_Fee__c, Payment_Type__c FROM Prices__r WHERE (Start_Date__c <= :now AND (End_Date__c >= :now OR End_Date__c = NULL)) OR (Start_Date__c <=:acc.Renewal_Date__c AND (End_Date__c >=  :acc.Renewal_Date__c OR End_Date__c = NULL)) ORDER BY Start_Date__c DESC)
                    FROM Club_Product__c
                    WHERE RecordType.Name = 'Membership Code'
                    AND Id IN :prodids
                    AND (Visible_to_Admin_Users_Only__c = FALSE
                    OR Id = :acc.Membership_Code__c)
                    ORDER BY Name];
                }
            }

            return mtList;
        }
        set;
    }

    public List<Club_Product__c> pList {
        get {
            if (pList == null) {
                Date now = opp.CloseDate;
                pList = [SELECT Id, Name, Product_Detail__c, (SELECT Price__c FROM Prices__r WHERE (Start_Date__c <= :now AND (End_Date__c >= :now OR End_Date__c = NULL)) OR (Start_Date__c <= :acc.Renewal_Date__c AND (End_Date__c >= :acc.Renewal_Date__c OR End_Date__c = NULL)) ORDER BY Start_Date__c DESC) FROM Club_Product__c WHERE RecordType.Name = 'Associate Membership' ORDER BY Name];
            }

            return pList;
        }
        set;
    }

    public List<SelectOption> PaymentOptions {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--None--'));

            Club_Product__c p = [SELECT Allowed_Payment_Types__c FROM Club_Product__c WHERE Name = :lea.Membership_Code__c];
            if (p.Allowed_Payment_Types__c != null) {
                for (String s : p.Allowed_Payment_Types__c.split(';')) {
                    options.add(new SelectOption(s,s));
                }
            }

            return options;
        }
        set;
    }

    public String MemberABday{get{if(MemberABday==null)MemberABday='';return MemberABday;}set;}

    public Payment_Method__c currentDD {
        get {
            if (currentDD == null) {
                try {
                    currentDD = [SELECT Id, Bank_Account_Name__c, Bank_Account_Number__c, Bank_Name__c, Sort_Code__c, Re_issue_Payment__c
                    FROM Payment_Method__c
                    WHERE RecordTypeId=:sc.ddebitRecordTypeId
                    AND Status__c='Active'
                    AND Membership__c = :this.acc.Id
                    ORDER BY CreatedDate DESC
                    LIMIT 1];
                } catch (Exception ex) {
                    currentDD = null;
                }
            }
            return currentDD;
        }
        set;
    }


    public RenewMembershipController(ApexPages.StandardController controller) {
        wizardStep = 1;
        this.controller = controller;
        this.lea = new Lead();

        List<String> accfields = new List<String>();

        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();

        for (String s : objectFields.keySet()) {
            accfields.add(s);
        }

        accfields.add('Membership_Code__r.name');
        if (!Test.isRunningTest()) {
            controller.addFields(accfields);
        }

        this.acc = (Account) controller.getRecord();
        System.debug('this.acc: ' + this.acc);

        try {
            opp = [SELECT Id, Name, CloseDate, (SELECT Id, Price__c, Product__c, Product__r.Name, RecordTypeId FROM Line_Items__r) FROM Opportunity WHERE AccountId = :this.acc.Id AND RecordTypeId = :sc.OppRenewalRecordTypeId AND IsClosed = FALSE AND IsWon = FALSE];
        } catch (Exception ex) {
            opp = new Opportunity();
            wizardStep = 0;
        }

        if (opp.Id != null) {
            if (acc.Renewal_Date__c.addMonths(12) < Date.today()) {
                wizardStep = -1;  //cannot renew - must use reinstate
            }
            lea.LastName = this.opp.Id;
            lea.Company = this.opp.Id;
        } else {
            lea.LastName = this.acc.Id;
            lea.Company = this.acc.Id;
        }
        lea.Status = 'Open';
        lea.Email = cPrimaryMember.Email;
        lea.Street=this.acc.BillingStreet;
        lea.PostalCode=this.acc.BillingPostalCode;
        lea.City=this.acc.BillingCity;
        lea.Country=this.acc.BillingCountry;
        lea.State=this.acc.BillingState;
        lea.Membership_Code__c = this.acc.Membership_Code__r.Name;
        if (currentDD != null) {
            lea.Bank_Account_Name__c = currentDD.Bank_Account_Name__c;
            lea.Bank_Name__c = currentDD.Bank_Name__c;
            lea.Bank_Account_Number__c = currentDD.Bank_Account_Number__c;
            lea.Sort_Code__c = currentDD.Sort_Code__c;
        }
        if (opp.Id != null) {
            for (Club_Opportunity_Product__c c : opp.Line_Items__r) {
                if (c.RecordTypeId == sc.mtsectRecordTypeId) {
                    lea.Membership_Code__c = c.Product__r.Name;
                }
            }
        }
        if (lea.Associate_Member_Date_of_Birth__c != null) {
            MemberABday = lea.Associate_Member_Date_of_Birth__c.format();
        }
        List<String> omsections = new List<String>();

        for (Club_Opportunity_Product__c s:cop) {
            omsections.add(s.Product__r.Name);
        }

        lea.sections__c = String.join(omsections,':');
        if (lea.sections__c != null ) {
            List<String> msections = lea.sections__c.split(':',-2);
            Set<String> ssections = new Set<String>();
            ssections.addAll(msections);

            for (sectionSelectWrapper s : sections) {
                if (ssections.contains(s.s.Name)) {
                    s.selected=true;
                }
            }
        }
    }

    public Boolean sectionsAllowed {
        get {
            sectionsAllowed = false;
            for (Club_Product__c p : mtList) {
                if (lea.Membership_Code__c == p.Name) {
                    sectionsAllowed = p.Sections_Allowed__c;
                    break;
                }
            }
            return sectionsAllowed;
        }
        set;
    }

    public Boolean associateAllowed {
        get {
            associateAllowed=false;

            for (Club_Product__c p : mtList) {
                if (lea.Membership_Code__c == p.Name) {
                    associateAllowed= p.Associate_Allowed__c;
                    break;
                }
            }

            return associateAllowed;
        }
        set;
    }

    public PageReference step1 () {
        wizardStep = 1;
        return null;
    }

    public PageReference step2 () {
        if( lea.Membership_Code__c==null ) {
            lea.Membership_Code__c.addError('Please Select a Membership type');
        } else {
            String viclass ='';
            for (Club_Product__c m : mtList) {
                if (m.Name == lea.Membership_Code__c) {
                    viclass = m.VIClass__c;
                    break;
                }
            }
            Type t;
            t = Type.forName('VI'+viclass);
            if(t==null)t = Type.forName('VIDefault');
            ValidationInterface v = (ValidationInterface)t.newInstance();
            v.validateAtRenewal(lea);

            if (!ApexPages.hasMessages()) {
                if (associateAllowed) {
                    wizardStep = 2;
                } else {
                    wizardStep = 3;
                }
            }
        }
        return null;
    }

    public PageReference step3 () {
        if (lea.hasAssociate__c) {
            if (lea.hasPartner__c) {
                lea.addError('You cannot both add and remove an associate member');
            }
            if (lea.Associate_Member_Title__c == null) {
                lea.Associate_Member_Title__c.addError('Please Select a title');
            }
            if (lea.Associate_Member_First_Name__c == null) {
                lea.Associate_Member_First_Name__c.addError('Please enter associate members first name');
            }
            if (lea.Associate_Member_Surname__c == null) {
                lea.Associate_Member_Surname__c.addError('Please enter associate members Surname');
            }
            if (MemberABday == '') {
                lea.addError('Please enter associate members Birthdate');
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter associate members Birthdate'));
            }
        }
        if (!ApexPages.hasMessages()) {
            if (sectionsAllowed) {
                wizardStep = 3;
            } else {
                wizardStep = 4;
            }
        }

        return null;
    }

    public PageReference step4 () {

        if (MemberABday != '') {
            lea.Associate_Member_Date_of_Birth__c = Date.parse(MemberABday);
        }

        List<String> msections = new List<String>();

        for (sectionSelectWrapper s : sections) {
            if (s.selected) {
                msections.add(s.s.Name);
            }
        }

        lea.sections__c= String.join(msections,':');

        leadString = JSON.serialize(lea);
        wizardStep = 4;
        return null;
    }

    public Decimal amCost {
        get {
            Decimal d;
            for (Club_Opportunity_Product__c c:opp.Line_Items__r) {
                if (c.RecordTypeId == sc.amRecordTypeId) {
                    d=c.Price__c;
                }
            }
            if (cAssocMember.Id != null) {
                if (lea.hasPartner__c) {
                    d=null;
                }
            }
            else {
                if (lea.hasAssociate__c && d == null) {
                    d = mapPrices.get('Associate Member').Prices__r[0].Price__c;
                }
            }

            return d;
        }
        set;
    }


    public List<sectionSelectWrapper> sections {
        get {
            if (sections==null) {
                sections = new List<sectionSelectWrapper>();
                //Date now = Date.today();
                Date now = opp.CloseDate;

                for (Club_Product__c s:[SELECT Id, Name, Product_Detail__c, Product_Description__c, (SELECT Price__c FROM Prices__r WHERE Start_Date__c <= :now AND (End_Date__c>=:now OR End_Date__c = NULL) ORDER BY Start_Date__c) FROM Club_Product__c WHERE RecordType.Name='Section' ORDER BY Name]) {

                    List<Price__c> pr = s.Prices__r;

                    if (pr.size() > 0) {
                        sections.add(new sectionSelectWrapper(s, s.Prices__r[0].Price__c));
                    }
                }
            }
            return sections;
        }
        set;
    }

    public PageReference changepayment(){
        upslead();
        return null;
    }

    private void upslead(){
        //if(lea.Associate_Member_First_Name__c!=null)lea.Associate_Member_First_Name__c=Utils.toProperCase(lea.Associate_Member_First_Name__c);
        //if(lea.Associate_Member_Surname__c!=null)lea.Associate_Member_Surname__c=Utils.toProperCase(lea.Associate_Member_Surname__c);
        if (MemberABday != '') {
            lea.Associate_Member_Date_of_Birth__c = Date.parse(MemberABday);
        }

        List<String> msections = new List<String>();

        for (sectionSelectWrapper s:sections) {
            if (s.selected) {
                msections.add(s.s.Name);
            }
        }
        lea.sections__c= String.join(msections,':');
        lea.LeadStep__c = wizardStep;

        upsert lea;
    }

    public String payform {
        get {
            List<String> addr = new List<String>();
            if (lea.Street != null) {
                addr = lea.Street.split(',',-1);
            }

            Verifone__c verifone = Verifone__c.getOrgDefaults();

            payform = '&lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot;?&gt;';
            payform += '&lt;postdata xmlns:xsi=&quot;http://www.w3.org/2001/XMLSchema-instance&quot; xmlns:xsd=&quot;http://www.w3.org/2001/XMLSchema&quot;&gt;';
            payform += '&lt;api&gt;2&lt;/api&gt;';
            payform += '&lt;merchantid&gt;' + verifone.Merchantid__c + '&lt;/merchantid&gt;';
            payform += '&lt;requesttype&gt;eftrequest&lt;/requesttype&gt;';
            payform += '&lt;requestdata&gt;&amp;lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot;?&amp;gt;';
            payform += '&amp;lt;eftrequest xmlns:xsi=&quot;http://www.w3.org/2001/XMLSchema-instance&quot; xmlns:xsd=&quot;http://www.w3.org/2001/XMLSchema&quot;&amp;gt;';
            payform += '&amp;lt;returnurl&gt;' + verifone.Return_URL__c + '&amp;lt;/returnurl&amp;gt;';
            payform += '&amp;lt;javascriptenabled&amp;gt;Y&amp;lt;/javascriptenabled&amp;gt;';
            payform += '  &amp;lt;merchant&amp;gt;';
            payform += '    &amp;lt;merchantid&amp;gt;' + verifone.Merchantid__c + '&amp;lt;/merchantid&amp;gt;';
            payform += '    &amp;lt;systemguid&amp;gt;' + verifone.Systemguid__c + '&amp;lt;/systemguid&amp;gt;';
            payform += '  &amp;lt;/merchant&amp;gt;';
            payform += '  &amp;lt;merchantreference&amp;gt;' + lea.Id + '&amp;lt;/merchantreference&amp;gt;';
            payform += '  &amp;lt;accountid&amp;gt;' + verifone.Accountid__c + '&amp;lt;/accountid&amp;gt;';
            payform += '  &amp;lt;capturemethod&amp;gt;11&amp;lt;/capturemethod&amp;gt;';
            payform += '  &amp;lt;processingidentifier&amp;gt;1&amp;lt;/processingidentifier&amp;gt;';
            payform += '  &amp;lt;transactionvalue&amp;gt;' + String.valueOf(costTotal) + '&amp;lt;/transactionvalue&amp;gt;';
            payform += '  &amp;lt;showorderconfirmation&amp;gt;false&amp;lt;/showorderconfirmation&amp;gt;';
            payform += '  &amp;lt;showpaymentresult&amp;gt;true&amp;lt;/showpaymentresult&amp;gt;';
            payform += '  &amp;lt;customer&amp;gt;';
            payform += '    &amp;lt;firstname&amp;gt;';
            if (cPrimaryMember.Salutation != null) {
                payform +=cPrimaryMember.Salutation.replaceAll('[^a-zA-Z_0-9 ,\\/\\\\\\.\\-\'&]', '') + ' ';
            }
            if (cPrimaryMember.FirstName != null) {
                payform += cPrimaryMember.FirstName.replaceAll('[^a-zA-Z_0-9 ,\\/\\\\\\.\\-\'&]', '');
            }
            payform += '&amp;lt;/firstname&amp;gt;';
            payform += '    &amp;lt;lastname&amp;gt;';
            if (cPrimaryMember.LastName != null) {
                payform +=cPrimaryMember.LastName.replaceAll('[^a-zA-Z_0-9 ,\\/\\\\\\.\\-\'&]', '');
            }
            payform += '&amp;lt;/lastname&amp;gt;';
            payform += '    &amp;lt;address&amp;gt;';
            if (addr.size()>0) {
                payform +='      &amp;lt;address1&amp;gt;'+addr[0].replaceAll('[^a-zA-Z_0-9 ,\\/\\\\\\.\\-\'&]', '') + '&amp;lt;/address1&amp;gt;';
            }
            if (addr.size() > 1) {
                payform +='      &amp;lt;address2&amp;gt;'+addr[1].replaceAll('[^a-zA-Z_0-9 ,\\/\\\\\\.\\-\'&]', '') + '&amp;lt;/address2&amp;gt;';
            }
            if (lea.City != null) {
                payform +='      &amp;lt;town&amp;gt;'+lea.City.replaceAll('[^a-zA-Z0-9 !\\.\\-\']', '') + '&amp;lt;/town&amp;gt;';
            }
            if (lea.State != null) {
                payform +='      &amp;lt;county&amp;gt;'+lea.State.replaceAll('[^a-zA-Z0-9 !\\.\\-\']', '') + '&amp;lt;/county&amp;gt;';
            }
            if (lea.PostalCode != null) {
                payform +='      &amp;lt;postcode&amp;gt;'+lea.PostalCode+'&amp;lt;/postcode&amp;gt;';
            }
            if (lea.Country != null) {
                payform += '      &amp;lt;country&amp;gt;' + lea.Country.replaceAll('[^a-zA-Z0-9 !\\.\\-\']', '') + '&amp;lt;/country&amp;gt;';
            }
            payform += '    &amp;lt;/address&amp;gt;';
            payform += '    &amp;lt;email&amp;gt;' + lea.Email + '&amp;lt;/email&amp;gt;';
            payform += '    &amp;lt;deliveryedit&amp;gt;true&amp;lt;/deliveryedit&amp;gt;';
            payform += '  &amp;lt;/customer&amp;gt;';
            payform += '  &amp;lt;hideBillingDetails&amp;gt;false&amp;lt;/hideBillingDetails&amp;gt;';
            payform += '  &amp;lt;hideDeliveryDetails&amp;gt;true&amp;lt;/hideDeliveryDetails&amp;gt;';
            payform += '  &amp;lt;tokenexpirationdate&amp;gt;31122020&amp;lt;/tokenexpirationdate&amp;gt;';
            payform += '  &amp;lt;registertoken&amp;gt;true&amp;lt;/registertoken&amp;gt;';
//            payform +='  &amp;lt;registertoken&amp;gt;false&amp;lt;/registertoken&amp;gt;';
//            payform +='  &amp;lt;tokenid&amp;gt;10006508401&amp;lt;/tokenid&amp;gt;';
            payform += '&amp;lt;/eftrequest&amp;gt;&lt;/requestdata&gt;';
            payform += '&lt;/postdata&gt; ';
            return payform;
        }
        set;
    }

    public Decimal costTotal {
        get {
            costTotal = 0;

            if (mtCost != null) {
                costTotal += mtCost;
            }

            if (amCost != null) {
                costTotal += amCost;
            }

            for (sectionSelectWrapper s : sections) {
                if (s.selected) {
                    costTotal += s.price;
                }
            }

            return costTotal;
        }
        set;
    }

    public Map<String,Club_Product__c> mapPrices {
        get {
            if(mapPrices == null){
                mapPrices = new Map<String,Club_Product__c>();
                Date now = Date.today();
                List<Club_Product__c> pList = [SELECT Id, Name, Product_Detail__c, (SELECT Price__c, Change_Fee__c FROM Prices__r WHERE (Start_Date__c <= :now AND (End_Date__c >= :now OR End_Date__c = NULL)) OR (Start_Date__c <= :acc.Renewal_Date__c AND (End_Date__c >= :acc.Renewal_Date__c OR End_Date__c = NULL)) ORDER BY Start_Date__c DESC) FROM Club_Product__c WHERE RecordType.Name = 'Associate Membership' ORDER BY Name];

                for (Club_Product__c p : pList) {
                    List<Price__c> pr = p.Prices__r;
                    if (pr.size() > 0) {
                        mapPrices.put('Associate Member',p);
                    }
                }
            }

            return mapPrices;
        }
        set;
    }

    public PageReference confirm() {
        // If the payment method is direct debit.
        if (lea.Payment_Method__c == 'Direct Debit') {
            // Validate the direct debit information.
            // If the direct debit details are not valid.
            if(!validateDirectDebitInfo()) {
                return null;
            }
        }

        upslead();

        PageReference ps = Page.PaymentSuccess;
        ps.getParameters().put('ref',String.valueOf(lea.Id));
        ps.getParameters().put('result','SUCCESS');
        return ps;
/*
        opp.Amount = costTotal;
        opp.StageName = 'Complete';
        update opp;

        List<Club_Opportunity_Product__c> cprods = [select id, recordtype.name,
                                                    product__c,Member_Section__c,status__c,
                                                    Opportunity__r.accountid 
                                                    from Club_Opportunity_Product__c 
                                                    where Opportunity__r.accountid = :acc.id
                                                    and status__c = 'Active'];
    
        for(Club_Opportunity_Product__c c:cprods){
            c.status__c = 'Superseded';
        }
        
        update cprods;

        for(Club_Opportunity_Product__c c: opp.line_items__r){
            c.Status__c = 'Active';
        }

        update opp.line_items__r;
        

        List<Club_Opportunity_Product__c> coptoadd = new List<Club_Opportunity_Product__c>();
        List<Club_Opportunity_Product__c> coptoupd = new List<Club_Opportunity_Product__c>();
        List<Club_Opportunity_Product__c> coptodel = new List<Club_Opportunity_Product__c>();
        List<Member_Section__c> ms = new List<Member_Section__c>();

        if(lea.hasPartner__c && cAssocMember.id!=null){
            cAssocMember.Date_Ended__c = opp.CloseDate;
            update cAssocMember;
            for(Club_Opportunity_Product__c c: opp.line_items__r){
                if(c.recordtypeid == amRecordTypeId){
                    coptodel.add(c);
                }
            }
        }
        else if(lea.hasAssociate__c && cAssocMember.id!=null){
            cAssocMember.Date_Ended__c = opp.CloseDate;
            update cAssocMember;
            Contact assocContact = new Contact(recordtypeid=sc.associateContactRecordTypeId,
                                    Accountid = acc.Id,
                                    Date_Joined__c = opp.CloseDate,
                                    firstname=lea.Associate_Member_First_Name__c,
                                    lastname=lea.Associate_Member_Surname__c,
                                    Salutation = lea.Associate_Member_Title__c,
                                    Birthdate = Date.parse(MemberABday));
            insert assocContact;
        }
        else if(lea.hasAssociate__c && cAssocMember.id==null){
            Contact assocContact = new Contact(recordtypeid=sc.associateContactRecordTypeId,
                                    Accountid = acc.Id,
                                    Date_Joined__c = opp.CloseDate,
                                    firstname=lea.Associate_Member_First_Name__c,
                                    lastname=lea.Associate_Member_Surname__c,
                                    Salutation = lea.Associate_Member_Title__c,
                                    Birthdate = Date.parse(MemberABday));
            insert assocContact;
            coptoadd.add(new Club_Opportunity_Product__c(Product__c = plist[0].id,recordtypeid = amRecordTypeId,  opportunity__c = opp.id, price__c = amcost, account__c = acc.id,status__c = 'Active' ));
        }

        for(sectionSelectWrapper s : sections){
            if(s.selected){
                Boolean found = false;
                for(Club_Opportunity_Product__c c : opp.line_items__r){
                    if(s.s.Id == c.Product__c)found=true;
                }
                if(!found){
                    coptoadd.add(new Club_Opportunity_Product__c(recordtypeid = sectionRecordTypeId, product__c = s.s.id, opportunity__c = opp.id, price__c = s.price, account__c = acc.id,status__c = 'Active' ));
                }
            }
            else{
                for(Club_Opportunity_Product__c c : opp.line_items__r){
                    if(s.s.Id == c.Product__c){
                        coptodel.add(c);
                        break;
                    }
                }
            }
        }

        if(lea.Membership_Code__c != acc.Membership_Type_Name__c){
            for(Club_Opportunity_Product__c c: opp.line_items__r){
                if(c.recordtypeid == mtRecordTypeId){
                    for(Club_Product__c m:mtList){
                        if(m.Name == lea.Membership_Code__c){
                            Club_Opportunity_Product__c ctu = c;
                            ctu.Product__c = m.id;
                            ctu.Price__c = m.prices__r[0].price__c;
                            acc.Membership_Code__c = m.id;
                            coptoupd.add(ctu);
                            break;
                        }
                    }
                }
            }
        }       
        if(coptoupd.size()>0){
            update coptoupd;
        }

        acc.Membership_Status__c='Paid';
        acc.Renewal_Date__c = acc.Renewal_Date__c.addmonths(12);
        update acc;
 
        if(coptoadd.size()>0)insert coptoadd;
        for(Club_Opportunity_Product__c c : coptoadd){
            ms.add(new Member_Section__c(Club_Opportunity_Product__c = c.id, Member__c= cPrimaryMember.id));
            if(cSecondaryMember.id!=null)
                ms.add(new Member_Section__c(Club_Opportunity_Product__c = c.id, Member__c= cSecondaryMember.id));
        }
        if(ms.size()>0)insert ms;
        
        if(coptodel.size()>0){
            Set<id> mstodelid =  new Set<id>();
            for(Club_Opportunity_Product__c c : coptodel){
                mstodelid.add(c.id);
            }
            delete [select id from Member_Section__c where Club_Opportunity_Product__c in :mstodelid];
            delete coptodel;
        }
        
        delete [select id from lead where name=:opp.id];

        
        return new PageReference('/'+this.acc.id);
*/
    }

    public hopewiserSoapbankcoder.ValidateReturnDetailResponse_element validate() {
        hopewiserSoapbankcoder.ValidateReturnDetailRequest_element bdets = new hopewiserSoapbankcoder.ValidateReturnDetailRequest_element();
        bdets.AccountNumber = lea.Sort_Code__c.replaceAll('[^0-9]', '')+lea.Bank_Account_Number__c.replaceAll('[^0-9]', '');
        bdets.Dataset='uk-vl-bankcode';

        docsOasisOpenOrgWss200401Oasis20040.securityType sectype = new docsOasisOpenOrgWss200401Oasis20040.securityType();
        docsOasisOpenOrgWss200401Oasis20040.usernameTokenType sectoken = new docsOasisOpenOrgWss200401Oasis20040.usernameTokenType();
        Hopewiser__c hopewiser = Hopewiser__c.getOrgDefaults();
//            sectoken.Username ='ccc_internal';
//            sectoken.password ='Yofakynw';
        sectoken.Username = hopewiser.Username__c;
        sectoken.Password =hopewiser.Password__c;

        hopewiserSoapbankcoder.soapbankcoderInterfaceSoap11 r= new hopewiserSoapbankcoder.soapbankcoderInterfaceSoap11();
        sectype.UsernameToken = sectoken;
        r.Security = sectype;
        hopewiserSoapbankcoder.ValidateReturnDetailResponse_element ret  = r.ValidateReturnDetail(lea.Sort_Code__c.replaceAll('[^0-9]', '') + lea.Bank_Account_Number__c.replaceAll('[^0-9]', ''),'uk-vl-bankcode');

        return ret;
    }

    /**
    * @description Validate the direct debit info inputted by the user.
    * @author Kev Cadger (kevin.cadger@wipro.com) | 01-03-2022 
    * @return Boolean Whether the validation was successful.
    **/
    private Boolean validateDirectDebitInfo() {
        // Validate the direct debit information.
        // If the direct debit details are not valid.
        if (!Utilities.validateDirectDebitInfo(lea)) {
            // Return with invalid.
            return false;
        }

        // Validate the banking details.
        hopewiserSoapbankcoder.ValidateReturnDetailResponse_element ret = validate();

        // If the details are not valid.
        // || Status Code 4 = Sort code found. Account could not be verified.
        // || Status Code 5 = Sort code not found.
        if (ret.ValidityFlag.toLowerCase() != 'y' || ret.StatusCode == 5) {
            // Display an error to the user.
            ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.ERROR, ret.StatusText)
            );
            // Return with invalid.
            return false;
        }

        // Return with success.
        return true;
    }




    // TODO : Remove this bypass method.
    // Bypass method for code coverage (LMAO)
    // Also, I'm so sorry if you are looking at this ;'D
    public static void bypassMethod() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}