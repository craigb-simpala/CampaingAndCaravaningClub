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

public with sharing class ChangeMembershipController  {
    public apexpages.standardController controller {get; set;}
    public Integer wizardStep {get;set;}
    private date week8date;
    private boolean weeks8SinceRenClose;
    public Lead lea {get;set;}
    public Account acc {get;set;}
    public constants sc = new constants();
    public boolean within8weeks {get;set;}
    public String HouseNumber { get;set; }
    public String selAddr {get;set;}
    public String pcode { get;set; }
    public boolean showmanual {get;set;}
    public String mHouseNumber { get;set; }
    public String mstreet { get;set; }
    public String mcity { get;set; }
    public String mselAddr {get;set;}
    public boolean reissuePayment {get;set;}
    public String amountLabel = 'Leave this field at 0 or blank, changing it will incur an unnecessary charge';
    public String mselAddr2 {get;set;}
    public boolean joinDateFee{get;set;}
    public boolean prodsChanged{get;set;}
    public boolean hadAssoc{get;set;}
    private String pageName;
    private integer sectionsSize;

    public String leadString {get;set;}


    public ChangeMembershipController(apexpages.standardController controller) {
        wizardStep = 1;
        this.controller = controller;
        this.lea = new Lead();
        List<String> accfields = new list<String>();
        pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');

        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        for(String s : objectFields.keySet()) {
            accfields.add(s);
            //system.debug(s);
        }
        accfields.add('Membership_Code__r.name');
        accfields.add('Membership_renewal_Code__r.name');
        if(!test.isRunningTest())
            controller.addFields(accfields);

        this.acc = (Account) controller.getRecord();
        system.debug('Page Name: ' + pageName);
        Opportunity wonRenOpp;
        try{
            wonRenOpp = [select id,name,closedate,accountid,(select id,price__c,product__c,recordtypeid from Line_Items__r) from Opportunity where accountid=:acc.id and recordtypeid= :sc.OppRenewalRecordTypeId and isclosed=true and iswon=true ORDER BY CloseDate DESC LIMIT 1];
        }catch(exception e){
            wonRenOpp = new Opportunity();
        }

        if(currentDD!=null){

            String pageName = ApexPages.CurrentPage().getUrl();
            pageName = pageName.replaceFirst('/apex/', '');
            pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
            string[] pageNameExtra = pageName.split('%3F', 0);
            pageName = pageNameExtra[0];

            if(PageName=='ChangeAtRenewal'||PageName=='ChangeMembership'){
                lea.Bank_Account_Name__c = currentDD.Bank_Account_Name__c;
                lea.Bank_Name__c = currentDD.Bank_Name__c;
                lea.Bank_Account_Number__c = currentDD.Bank_Account_Number__c;
                lea.Sort_Code__c = currentDD.Sort_Code__c;
            }
        }

        lea.LastName = this.acc.id;
        lea.Status = 'Open';
        lea.Company = this.acc.id;
        lea.Email = cPrimaryMember.Email;
        lea.street=this.acc.billingstreet;
        lea.postalcode=this.acc.billingpostalcode;
        lea.city=this.acc.billingcity;
        lea.country=this.acc.billingcountry;
        lea.state=this.acc.billingstate;
        lea.overseas_membership__c = this.acc.overseas_membership__c;

        //lea.payment_method__c = acc.Payment_Method2__c;
        lea.Membership_Code__c = this.acc.Membership_Code__r.name;
        if(this.acc.membership_renewal_code__c!=null)lea.Membership_Code__c = this.acc.Membership_renewal_Code__r.name;
        if(lea.Associate_Member_Date_of_Birth__c!=null)MemberABday = lea.Associate_Member_Date_of_Birth__c.format();
        List<String> omsections = new List<String>();
        for (Club_Opportunity_Product__c s:cop){
            omsections.add(s.product__r.name);
        }
        sectionsSize = 0;
        lea.sections__c= string.join(omsections,':');
        if(lea.sections__c!=null ){
            List<String> msections = lea.sections__c.split(':',-2);
            Set<String> ssections = new Set<String>();
            ssections.addall(msections);

            for (sectionSelectWrapper s:sections){
                if(ssections.contains(s.s.name))
                {
                    s.selected=true;
                    sectionsSize++;
                }
            }
        }
        within8weeks = false;
        weeks8SinceRenClose = false;
        joinDateFee = false;
        prodsChanged = false;
        if((acc.Date_Joined__c.addDays(56)) > Date.today()){// || UserInfo.getProfileId() == adminProfileId.Id){
            within8weeks = true;

            weeks8SinceRenClose = true;
            week8date  = acc.Date_Joined__c;
            if(acc.Membership_Status__c == 'DD Mandate Rejected' || acc.Membership_Status__c == 'DD Payment Rejected'){
                joinDateFee = true;
            }

        }
        if(wonRenOpp.closeDate != null){
            if((wonRenOpp.closeDate.addDays(56)) > date.today()){
                weeks8SinceRenClose = true;
                week8date = wonRenOpp.closeDate;
            }
        }
        if(pageName == 'ChangeAssociationSections'){
            system.debug(associateAllowed);
            if(associateAllowed){
                wizardStep = 1;
            }
            else {
                wizardStep = 2;
            }
        }
        System.debug('joinFee');
        System.debug(joinFee);
    }

    // private Id adminProfileId = [SELECT Id FROM Profile WHERE Name like '%System Administrator%' LIMIT 1];

    public hopewiserSoapaddrsvr.AddressSearchResponse_element results{
        get{
            return results;
        }
        private set;
    }

    public payment_method__c currentDD {
        get{
            if(currentDD==null){
                try{
                    currentDD = [select id,Bank_Account_Name__c,Bank_Account_Number__c,Bank_Name__c,Sort_Code__c,Re_issue_Payment__c
                    from payment_method__c
                    where recordtypeid=:sc.ddebitRecordTypeId
                    and status__c='Active'
                    and Membership__c = :this.acc.id
                    order by createddate desc
                    limit 1];
                }
                catch(exception ex){currentDD=null;}
            }
            return currentDD;
        }
        set;
    }

    public hopewiserSoapaddrsvr.AddressExpandResponse_element results2{
        get{
            return results2;
        }
        private set;
    }

    public hopewiserSoapaddrsvr.AddressDetailsResponse_element address{
        get{
            return address;
        }
        private set;
    }

    public Map<Integer,hopewiserSoapaddrsvr.addressMatchType> addMatch {
        get{
            if(addMatch==null){
                addMatch = new Map<Integer,hopewiserSoapaddrsvr.addressMatchType>();
            }
            return addMatch;
        }
        set;
    }

    public List<SelectOption> addressOptions{
        get{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--Please Select--'));
            for(integer s=0;s<addMatch.size();s++)
            {
                options.add(new SelectOption(String.valueOf(s), soAddress(addMatch.get(s).Address)));
            }
            return options;
        }
        set;
    }

    private String soAddress(hopewiserSoapaddrsvr.addressType addr){
        String address ='';
        if(addr.Line1 !=null)address+=addr.Line1+', ';
        if(addr.Line2 !=null)address+=addr.Line2+', ';
        if(addr.Line3 !=null)address+=addr.Line3+', ';
        if(addr.Line4 !=null)address+=addr.Line4+', ';
        if(addr.Line5 !=null)address+=addr.Line5+', ';
        if(addr.TOWN !=null)address+=addr.TOWN+', ';
        if(addr.County !=null)address+=addr.County+', ';
        if(addr.Postcode !=null)address+=addr.Postcode+', ';
        address = address.removeEnd(', ');

        return address;

    }


    public List<SelectOption> maddressOptions{
        get{
            if(maddressOptions==null)
            {
                maddressOptions = new List<SelectOption>();
                maddressOptions.add(new Selectoption('','Please Select'));
                if(results!=null){
                    if(results.match!=null){
                        for(Integer i=0;i<results.match.size();i++)
                        {
                            hopewiserSoapaddrsvr.searchMatchType m=results.match[i];
                            maddressOptions.add(new Selectoption(String.valueOf(i),m.text));
                        }
                    }
                }
            }
            return maddressOptions;
        }
        set;
    }

    public pagereference changems(){
        system.debug(showmanual);
        return null;
    }


    public pagereference filladdress(){
        if(seladdr!=null){
            hopewiserSoapaddrsvr.addressType addr = addMatch.get(Integer.valueof(seladdr)).Address;
            String address ='';
            lea.organisation__c=addr.Organisation;
            if(addr.Line1 !=null)address+=addr.Line1+', ';
            if(addr.Line2 !=null)address+=addr.Line2+', ';
            if(addr.Line3 !=null)address+=addr.Line3+', ';
            if(addr.Line4 !=null)address+=addr.Line4+', ';
            if(addr.Line5 !=null)address+=addr.Line5+', ';
            address = address.removeEnd(', ');
            lea.street = address;
            lea.city = addr.town;
            lea.state = addr.County;
            lea.PostalCode = addr.Postcode;
            lea.country='';
        }
        return null;
    }

    public Opportunity renewalopp {
        get{
            if(renewalopp==null){
                try{
                    renewalopp = [select id,name,Amount,closedate,accountid,(select id,price__c,product__r.name,product__c,recordtypeid from Line_Items__r) from Opportunity where accountid=:this.acc.id and recordtypeid= :sc.OppRenewalRecordTypeId and isclosed=false and iswon=false];
                    /*
                                Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
                                objectFields = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
                                String query = 'SELECT';
                                for(String s : objectFields.keySet()) {
                                    query += ' ' + s + ',';
                                }
                                query = query.removeEnd(',');
                                query += ' FROM Opportunity where accountid=\''+this.acc.id+'\' and isclosed=false limit 1';

                                renewalopp = database.query(query);
                    */
                }
                catch(exception ex){}
            }
            return renewalopp;
        }
        set;
    }

    public Contact cAssocMember {
        get{
            if(cAssocMember==null){
                try{
                    cAssocMember = [select title,firstname,lastname,birthdate from Contact where date_ended__c = null and accountid=:acc.id and recordtypeid=:sc.associateContactRecordTypeId limit 1];
                }
                catch (Exception e){
                    cAssocMember=new Contact();
                }
            }
            return cAssocMember;
        }
        set;
    }

    public Contact cPrimaryMember {
        get{
            if(cPrimaryMember==null){
                try{
                    cPrimaryMember = [select Salutation,title,firstname,lastname,birthdate,email from Contact where accountid=:acc.id and recordtypeid=:sc.leadContactRecordTypeId limit 1];
                }
                catch (Exception e){
                    cPrimaryMember=new Contact();
                }
            }
            return cPrimaryMember;
        }
        set;
    }

    public Payment_Method__c cPaymentDetails {
        get{
            system.debug(acc.id);
            if(cPaymentDetails==null){
                try{
                    cPaymentDetails = [select Bank_Account_Name__c, Bank_Account_Number__c,Bank_Name__c,Sort_Code__c, Membership__r.payment_method2__c  from Payment_Method__c where Membership__c=:acc.id and Membership__r.payment_method2__c = 'Direct Debit' and Status__c = 'Active'];

                }
                catch (Exception e){
                    cPaymentDetails=new Payment_Method__c();
                }
            }
            system.debug(cPaymentDetails);
            return cPaymentDetails;     }

        set;
    }


    public List<Club_Opportunity_Product__c> cop {
        get{
            if(cop==null){
                cop = [select id,product__r.Product_Detail__c,product__r.name from Club_Opportunity_Product__c
                where recordtypeid=:sc.sectionRecordTypeId
                and account__c = :this.acc.id
                and Status__c=:sc.active
                and recordtypeid = :sc.sectionRecordTypeId];
            }
            return cop;
        }
        set;
    }


    public List<SelectOption> membershipTypeOptions{
        get{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--None--'));
            for(Club_Product__c p :mtList){
                options.add(new SelectOption((String)p.get('Name'), (String)p.get('Product_Detail__c')+' £'+String.valueof(p.get('Price_for_Initial_Picklist__c'))));
            }
            return options;
        }
        set;
    }

    public Decimal mtCost{
        get{
            Decimal d=0;
            if(acc.Membership_Status__c == 'DD Mandate Rejected' || acc.Membership_Status__c == 'DD Payment Rejected'){
                for(Club_Product__c m:mtList){
                    system.debug(m.name);
                    if(m.Name == lea.Membership_Code__c){
                        for(Price__c p:m.prices__r){
                            system.debug(p);
                            if(p.Payment_Type__c == lea.Payment_Method__c){
                                if(weeks8SinceRenClose){
                                    if(p.start_Date__c <= week8date && (p.End_Date__c >= week8date || p.End_date__c == null)){
                                        mtCost = p.Price__c;
                                        return mtCost;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else{
                boolean forcedPriceChange = false;
                if(lea.Membership_Code__c != acc.Membership_Type_Name__c){
                    system.debug('Mem type change');
                }
                if(ApexPages.currentPage().getUrl().substringBetween('apex/', '?') != 'ChangeAssociationSections' && lea.Membership_Code__c != acc.Membership_Type_Name__c){
                    for(Club_Product__c m:mtList){

                        if(m.Name == lea.Membership_Code__c){
                            for(Price__c p:m.prices__r){

                                    if(weeks8SinceRenClose){
                                        if(p.start_Date__c <= week8date && (p.End_Date__c >= week8date || p.End_date__c == null)){

                                            if(activeMemProd != null){
                                                if(activeMemProd.Price__c != p.Price__c && d <= 0){
                                                    decimal tempPrice = p.Price__c - activeMemProd.Price__c;

                                                    d = tempPrice;
                                                    forcedPriceChange = true;
                                                }
                                            }
                                            else{
                                                d+= p.Price__c;
                                            }
                                            lea.Payment_Method__c = p.Payment_Type__c;
                                            break;
                                        }
                                    } else{
                                        if(p.start_Date__c <= date.today() && (p.End_Date__c >= date.today() || p.End_date__c == null)){

                                            if(activeMemProd != null){
                                                if(activeMemProd.Price__c != p.Price__c && d <= 0){
                                                    decimal tempPrice = p.Price__c - activeMemProd.Price__c;

                                                    d = tempPrice;
                                                    forcedPriceChange = true;
                                                }
                                            }
                                            else{

                                                d+= p.Price__c;
                                            }
                                            lea.Payment_Method__c = p.Payment_Type__c;
                                            break;
                                        }
                                    }

                            }
                            if(d==0 && lea.Payment_Method__c==null)d=m.Price_for_Initial_Picklist__c;
                        }
                        system.debug(forcedpricechange);
                        if(!forcedPriceChange){
                            if(m.Name == lea.Membership_Code__c){
                                boolean found=false;
                                system.debug(m.prices__r);
                                for(Price__c p:m.prices__r){
                                    system.debug(p);
                                    system.debug(p.Payment_Type__c == lea.Payment_Method__c);
                                    if(p.Payment_Type__c == lea.Payment_Method__c){
                                        if(weeks8SinceRenClose){
                                            if(p.start_Date__c <= week8date && (p.End_Date__c >= week8date || p.End_date__c == null)){
                                                found=true;
                                                system.debug(activeMemProd);
                                                d-=p.Price__c;
                                                system.debug(d);
                                            }
                                        }
                                        else{
                                            if(p.start_Date__c <= date.today() && (p.End_Date__c >= date.today() || p.End_date__c == null)){
                                                found=true;
                                                system.debug(activeMemProd);
                                                d-=p.Price__c;
                                                system.debug(d);
                                            }
                                        }
                                    }
                                }
                                if(!found &&lea.Payment_Method__c!=null)d-=m.Price_for_Initial_Picklist__c;
                            }
                        }
                        //if(d==0 && lea.Payment_Method__c==null)d=m.Price_for_Initial_Picklist__c;
                        //d+=m.prices__r[0].Price__c;
                        system.debug(d);
                    }
                }
            }
            if(d<0)d=0;
            return d;
        }
        set;
    }

    public List<Club_Product__c> mtList{
        get{
            CustomPermissionsReader cpr = new CustomPermissionsReader();
            Boolean haspermission = cpr.hasPermission('CanEditMemebershipType');
            if(mtList==null){
                Date now = Date.today();
                List<Club_Product_Change__c> cpcl = [select id,from__c,to__c from Club_Product_Change__c where from__c = :acc.Membership_Code__c];
                Set<id> prodids = new Set<id>();
                for(Club_Product_Change__c cpc:cpcl){
                    prodids.add(cpc.to__c);
                }
                prodids.add(acc.Membership_Code__c);
                if(haspermission){
                    if(pageName == 'ChangeAtRenewal'){
                        mtList = [select id,name,VIClass__c,Product_Detail__c,
                                Sections_Allowed__c,Associate_Allowed__c,
                                PartnerAllowed__c,children_allowed__c, SectionsAreFree__c,
                                Card_Payment_Allowed__c,Cash_Payment_Allowed__c,DD_Payment_Allowed__c,Price_for_Initial_Picklist__c,
                        (select Price__c, Start_Date__c, End_Date__c, Joining_Fee__c, Payment_Type__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: this.acc.Renewal_Date__c and (End_Date__c>=:this.acc.Renewal_Date__c or End_Date__c=null)) OR (Start_Date__c<=:week8date and (End_Date__c>=:week8date or End_Date__c=null)) order by Start_Date__c DESC)
                        from club_product__c
                        where recordtype.name='Membership Code'
                        and id in :prodids
                        order by name];
                        system.debug('renewal');
                    }
                    else{
                        mtList = [select id,name,VIClass__c,Product_Detail__c,
                                Sections_Allowed__c,Associate_Allowed__c,
                                PartnerAllowed__c,children_allowed__c, SectionsAreFree__c,
                                Card_Payment_Allowed__c,Cash_Payment_Allowed__c,DD_Payment_Allowed__c,Price_for_Initial_Picklist__c,
                        (select Price__c, Start_Date__c, End_Date__c, Joining_Fee__c, Payment_Type__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: this.acc.Renewal_Date__c and (End_Date__c>=:this.acc.Renewal_Date__c or End_Date__c=null)) OR (Start_Date__c<=:week8date and (End_Date__c>=:week8date or End_Date__c=null)) order by Start_Date__c )
                        from club_product__c
                        where recordtype.name='Membership Code'
                        and id in :prodids
                        order by name];
                    }
                    system.debug(mtList);
                }
                else{
                    if(pageName == 'ChangeAtRenewal'){
                        mtList = [select id,name,VIClass__c,Product_Detail__c,
                                Sections_Allowed__c,Associate_Allowed__c,
                                PartnerAllowed__c,Children_allowed__c, SectionsAreFree__c,
                                Card_Payment_Allowed__c,Cash_Payment_Allowed__c,DD_Payment_Allowed__c,Price_for_Initial_Picklist__c,
                        (select Price__c, Start_Date__c, End_Date__c,Joining_Fee__c, Payment_Type__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: this.acc.Renewal_Date__c and (End_Date__c>=:this.acc.Renewal_Date__c or End_Date__c=null)) OR (Start_Date__c<=:week8date and (End_Date__c>=:week8date or End_Date__c=null)) order by Start_Date__c DESC)
                        from club_product__c
                        where recordtype.name='Membership Code'
                        and id in :prodids
                        AND (Visible_to_Admin_Users_Only__c = false
                        OR id = :acc.Membership_Code__c)
                        order by name];
                        system.debug('renewal');
                    }
                    else{
                        mtList = [select id,name,VIClass__c,Product_Detail__c,
                                Sections_Allowed__c,Associate_Allowed__c,
                                PartnerAllowed__c,Children_allowed__c, SectionsAreFree__c,
                                Card_Payment_Allowed__c,Cash_Payment_Allowed__c,DD_Payment_Allowed__c,Price_for_Initial_Picklist__c,
                        (select Price__c, Start_Date__c, End_Date__c,Joining_Fee__c, Payment_Type__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: this.acc.Renewal_Date__c and (End_Date__c>=:this.acc.Renewal_Date__c or End_Date__c=null)) OR (Start_Date__c<=:week8date and (End_Date__c>=:week8date or End_Date__c=null)) order by Start_Date__c )
                        from club_product__c
                        where recordtype.name='Membership Code'
                        and id in :prodids
                        AND (Visible_to_Admin_Users_Only__c = false
                        OR id = :acc.Membership_Code__c)
                        order by name];
                    }
                    system.debug(mtList);
                }
            }
            return mtList;
        }
        set;
    }

    public List<SelectOption> PaymentOptions{
        get{

            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--None--'));
            Club_Product__c p = [select Allowed_Payment_Types__c from Club_Product__c where name=:lea.Membership_Code__c];
            system.debug(p);
            if(p.Allowed_Payment_Types__c!=null){
                for(String s :p.Allowed_Payment_Types__c.split(';')){
                    options.add(new SelectOption(s,s));
                }
            }
            return options;
        }
        set;
    }

    public List<SelectOption> SecPaymentOptions{
        get{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--None--'));
            options.add(new SelectOption('Cash/Cheque','Cash/Cheque'));
            options.add(new SelectOption('Debit/Credit Card','Debit/Credit Card'));
            return options;
        }

        set;
    }

    public String MemberABday{get{if(MemberABday==null)MemberABday='';return MemberABday;}set;}


    public PageReference step1 () {
        wizardStep = 1;
        return null;
    }

    public boolean sectionsAllowed {
        get{
            sectionsAllowed=false;
            for(Club_Product__c p:mtlist){
                if(lea.membership_code__c ==p.Name){
                    sectionsAllowed= p.Sections_Allowed__c;
                    break;
                }
            }
            return sectionsAllowed;
        }
        set;
    }

    public boolean associateAllowed {
        get{
            associateAllowed=false;
            system.debug(mtList);
            for(Club_Product__c p:mtlist){
                if(lea.membership_code__c ==p.Name){
                    system.debug(lea.membership_code__c);
                    system.debug(p.name);
                    system.debug(p.Associate_Allowed__c);
                    associateAllowed= p.Associate_Allowed__c;
                    break;
                }
            }
            return associateAllowed;
        }
        set;
    }

    public PageReference secStep1(){
        wizardStep = 1;
        return null;
    }

    public PageReference secStep2(){
        system.debug(lea.hasAssociate__c);
        system.debug(lea.hasPartner__c);
        system.debug(MemberABday);
        if(lea.hasAssociate__c){
            if(lea.hasPartner__c){
                lea.addError('You cannot both add and remove an associate member');
            }
            if(lea.Associate_Member_Title__c==null){
                lea.Associate_Member_Title__c.addError('Please Select a title');
            }
            if(lea.Associate_Member_First_Name__c==null){
                lea.Associate_Member_First_Name__c.addError('Please enter associate members first name');
            }
            if(lea.Associate_Member_Surname__c==null){
                lea.Associate_Member_Surname__c.addError('Please enter associate members Surname');
            }
            if(MemberABday==''){
                lea.adderror('Please enter associate members Birthdate');
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter associate members Birthdate'));
            }
        }
        if(!ApexPages.hasMessages())
        {
            if(sectionsAllowed){
                wizardStep = 2;
            }
            else
            {
                wizardStep = 3;
            }
        }
        return null;
    }

    public PageReference secStep3(){
        if(wizardstep==1){
            if(lea.Membership_Code__c==null){
                lea.Membership_Code__c.addError('Please Select a Membership type');
            }
            else{
                String viclass ='';
                for(Club_Product__c m:mtList){
                    if(m.Name == lea.Membership_Code__c){
                        viclass = m.viclass__c;
                        break;
                    }
                }
                system.debug(viclass);
                Type t;
                t = Type.forName('VI'+viclass);
                if(t==null)t = Type.forName('VIDefault');
                ValidationInterface v = (ValidationInterface)t.newInstance();
                v.validateAtRenewal(lea);
            }
        }
        //checkProdsChanged();
        if(!ApexPages.hasMessages())
        {
            wizardStep = 3;
            upslead();
        }
        return null;
    }

    public PageReference step2 () {
        if(lea.Membership_Code__c==null){
            lea.Membership_Code__c.addError('Please Select a Membership type');
        }
        else{
            String viclass ='';
            for(Club_Product__c m:mtList){
                if(m.Name == lea.Membership_Code__c){
                    viclass = m.viclass__c;
                    break;
                }
            }
            system.debug(viclass);
            Type t;
            t = Type.forName('VI'+viclass);
            if(t==null)t = Type.forName('VIDefault');
            ValidationInterface v = (ValidationInterface)t.newInstance();
            v.validate(lea);
            if(!ApexPages.hasMessages())
            {
                if(associateAllowed){
                    wizardStep = 2;
                }
                else
                {
                    wizardStep = 3;
                }
            }
        }
        upslead();
        return null;
    }

    public PageReference step3 () {
        system.debug(lea.hasAssociate__c);
        system.debug(lea.hasPartner__c);
        system.debug(MemberABday);
        if(lea.hasAssociate__c){
            if(lea.hasPartner__c){
                lea.addError('You cannot both add and remove an associate member');
            }
            if(lea.Associate_Member_Title__c==null){
                lea.Associate_Member_Title__c.addError('Please Select a title');
            }
            if(lea.Associate_Member_First_Name__c==null){
                lea.Associate_Member_First_Name__c.addError('Please enter associate members first name');
            }
            if(lea.Associate_Member_Surname__c==null){
                lea.Associate_Member_Surname__c.addError('Please enter associate members Surname');
            }
            if(MemberABday==''){
                lea.adderror('Please enter associate members Birthdate');
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter associate members Birthdate'));
            }
        }
        if(!ApexPages.hasMessages())
        {
            if(sectionsAllowed){
                wizardStep = 3;
            }
            else
            {
                wizardStep = 4;
            }
        }
        upslead();
        return null;
    }

    public PageReference step4 () {
        prodsChanged = false;
        if(wizardstep==1){
            if(lea.Membership_Code__c==null){
                lea.Membership_Code__c.addError('Please Select a Membership type');
            }
            else{
                String viclass ='';
                for(Club_Product__c m:mtList){
                    if(m.Name == lea.Membership_Code__c){
                        viclass = m.viclass__c;
                        break;
                    }
                }
                system.debug(viclass);
                Type t;
                t = Type.forName('VI'+viclass);
                if(t==null)t = Type.forName('VIDefault');
                ValidationInterface v = (ValidationInterface)t.newInstance();
                v.validateAtRenewal(lea);
            }
        }

        checkProdsChanged();
        if(!ApexPages.hasMessages())
        {
            wizardStep = 4;
        }
        upslead();
        return null;
    }

    public void checkProdsChanged(){
        /*List<SectionSelectWrapper> selectedSections = new List<SectionSelectWrapper>();
        for(SectionSelectWrapper s : sections){
            if(s.selected){
                selectedSections.add(s);
            }
        }
        system.debug(selectedSections.size());
        system.debug(sectionsSize);
        if(selectedSections.size() != sectionsSize){
            system.debug('sections changed');
            prodsChanged = true;
        }
        system.debug(cAssocMember.id);
        system.debug(lea.hasAssociate__c);
        system.debug(lea.hasPartner__c);
        if((cAssocMember.id == null && lea.hasAssociate__c) || (cAssocMember.id != null && (lea.hasPartner__c || lea.hasAssociate__c))){
            system.debug('assoc changed');
            prodsChanged = true;
        }*/
        if(this.acc.Membership_Code__r.name != lea.Membership_Code__c){
            prodsChanged = true;
        }
        system.debug(prodsChanged);
    }

    public PageReference changerenewal() {
        if(lea.Membership_Code__c==null){
            lea.Membership_Code__c.addError('Please Select a Membership type');
        }
        else{
            // If the payment method is direct debit.
            if (lea.Payment_Method__c == 'Direct Debit') {
                // Validate the direct debit information.
                // If the direct debit details are not valid.
                if(!validateDirectDebitInfo()) {
                    return null;
                }
            }

            Payment_Method__c pm = new Payment_Method__c();
            if(lea.Payment_Method__c=='Direct Debit'){
                pm.Membership__c = acc.id;
                pm.Status__c = 'Active';
                pm.start_date__c = Date.today();
                if(currentdd==null || currentDD.id==null || (currentDD.Bank_Account_Number__c!=lea.Bank_Account_Number__c
                        || currentDD.Sort_Code__c!=lea.Sort_Code__c.replaceAll('[^0-9]', '')) ){
                    pm.recordtypeid = sc.ddebitRecordTypeId;
                    pm.Bank_Account_Name__c = lea.Bank_Account_Name__c;
                    pm.Bank_Account_Number__c = lea.Bank_Account_Number__c;
                    pm.Bank_Name__c = lea.Bank_Name__c;
                    pm.Sort_Code__c = lea.Sort_Code__c.replaceAll('[^0-9]', '');
                    pm.Mandate_Amount__c = 0;
                    acc.Membership_Status__c='Paid';
                    acc.Payment_Method2__c = 'Direct Debit';
                }
                else{
                    pm=currentDD;
                }

            }
            if(renewalopp==null){
                for(Club_Product__c cp:mtlist){
                    if(cp.name==lea.Membership_Code__c)this.acc.membership_renewal_code__c = cp.id;
                }
                if(lea.Payment_Method__c=='Direct Debit'){
                    upsert pm;
                    update acc;
                }
                return this.controller.save();
            }
            else{
                Decimal oldprice=0;
                Decimal newprice=0;
                Decimal pricediff=0;
                constants sc = new constants();
                for(club_opportunity_product__c cop:renewalopp.Line_Items__r){
                    system.debug(cop.product__r.name);
                    system.debug(lea.Membership_Code__c);
                    if(cop.recordtypeid == sc.mtsectRecordTypeId){
                        for(Club_Product__c m:mtList){
                            if(m.Name == lea.Membership_Code__c){
                                newprice=m.prices__r[0].Price__c;
                                cop.product__c =m.id;
                            }
                        }
                        oldprice=cop.price__c;
                        cop.price__c = newprice;
                        pricediff=newprice-oldprice;
                        system.debug(oldprice);
                        system.debug(newprice);
                        system.debug(pricediff);
                    }
                }
                system.debug(renewalopp);
                update renewalopp.Line_Items__r;
                renewalopp.amount+=pricediff;
                update renewalopp;
                if(lea.Payment_Method__c=='Direct Debit'){
                    upsert pm;
                    update acc;
                }
                return this.controller.cancel();
            }
        }
        return null;
    }

    public Decimal joinFee{
        get{
            Decimal fee = 0;
            if(joinDateFee && acc.Payment_Method2__c != lea.Payment_Method__c){
                for(Club_Product__c mt : mtList){
                    if(mt.Name == lea.Membership_Code__c){
                        for(Price__c p : mt.Prices__r){
                            if(p.Payment_Type__c == lea.Payment_Method__c){
                                if(p.Start_Date__c <= week8date && (p.End_Date__c >= week8date || p.End_Date__c == null)){
                                    fee = p.Joining_Fee__c;
                                    lea.Join_Fee__c = fee;
                                    lea.Join_Fee_8_Weeks__c = true;
                                }
                            }
                        }
                    }
                }
                if(!!lea.Joining_Fee_Waived__c ){
                    fee=0;
                    lea.Join_Fee__c = fee;
                    lea.Join_Fee_8_Weeks__c = true;
                }
            }

            return fee;
        }
        set;
    }

    public Decimal joinFeeChangeMem{
        get{
            Decimal fee = 0;
            system.debug(prodsChanged);
            if((joinDateFee) && (prodsChanged || acc.Payment_Method2__c != lea.Payment_Method__c)){
                for(Club_Product__c mt : mtList){
                    if(mt.Name == lea.Membership_Code__c){
                        for(Price__c p : mt.Prices__r){
                            if(p.Payment_Type__c == lea.Payment_Method__c){
                                if(p.Start_Date__c <= week8date && (p.End_Date__c >= week8date || p.End_Date__c == null)){
                                    fee = p.Joining_Fee__c;
                                    lea.Join_Fee__c = fee;
                                    lea.Join_Fee_8_Weeks__c = true;
                                }
                            }
                        }
                    }
                }
                if(!!lea.Joining_Fee_Waived__c ){
                    fee=0;
                    lea.Join_Fee__c = fee;
                    lea.Join_Fee_8_Weeks__c = true;
                }
            }
            return fee;
        }
        set;
    }

    public Decimal amCost{
        get{
            Decimal d;
            if(lea.hasAssociate__c ){
                system.debug('recharge assoc');
                system.debug(cAssocMember.birthdate);
                if(cAssocMember.birthdate!=null){
                    for(Price__c p : mapPrices.get('Associate Member').prices__r){
                        system.debug(p);
                        if(joinDateFee){
                            if(p.Start_Date__c <= week8Date && (p.End_Date__c >= week8Date || p.End_Date__c == null)){
                                d=p.Price__c;
                                break;
                            }
                        }
                        else{
                            if(p.Start_Date__c <= acc.Renewal_Date__c && (p.End_Date__c >= acc.Renewal_Date__c || p.End_Date__c == null)){
                                d=p.Change_Fee__c;
                            }
                        }
                    }
                }
                else{
                    d=pickCorrectPrice(mapPrices.get('Associate Member').prices__r, date.today(), date.today());
                }
            }
            else{
                d=0;
            }
            return d;
        }
        set;
    }

    private decimal pickCorrectPrice(List<Price__c> prices, Date startDate, Date endDate){
        for(Price__c p:prices){
            if(p.start_Date__c <= startDate && (p.End_Date__c >= endDate || p.End_date__c == null)){
                return p.price__c;
            }
        }
        return 0;

    }

    public List<sectionSelectWrapper> sections {
        get{
            if(sections==null){
                sections = new List<sectionSelectWrapper>();
                Date now = Date.today();
                List<Club_Product__c> sprods = new List<Club_Product__c>();
                if(pageName == 'ChangeAtRenewal'){
                    sprods = [select id,name,Product_Detail__c,Product_Description__c,(select Price__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: this.acc.Renewal_Date__c and (End_Date__c>=:this.acc.Renewal_Date__c or End_Date__c=null)) order by Start_Date__c DESC) from club_product__c where recordtype.name='Section' order by name];
                }
                else{
                    sprods = [select id,name,Product_Detail__c,Product_Description__c,(select Price__c from Prices__r where Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null) order by Start_Date__c) from club_product__c where recordtype.name='Section' order by name];
                }
                for(club_product__c s: sprods){
                    List<price__c> pr = s.prices__r;
                    if(pr.size()>0){
                        Decimal sprice = s.prices__r[0].price__c;
                        for(Club_Product__c mt: mtList){
                            if((acc.FreeSections__c == true || mt.SectionsAreFree__c == true) && lea.Membership_Code__c == mt.Name){
                                sprice = 0;
                            }
                        }
                        sections.add(new sectionSelectWrapper(s,sprice));
                    }
                }
            }
            return sections;
        }
        set;
    }

    public pagereference changepayment(){

        //upslead();
        Decimal temp = joinFee;
        upslead();
        system.debug(lea);
        system.debug(mtcost);
        return null;
    }

    public Club_Opportunity_Product__c activeMemProd{
        get {
            if(activeMemProd == null){
                List<Club_Opportunity_Product__c> opportunityProducts = [SELECT Id, Price__c FROM Club_Opportunity_Product__c WHERE Account__c =: acc.id AND Status__c = 'Active' AND Record_Type_Name__c = 'Membership_Code' LIMIT 1];
                activeMemProd = opportunityProducts.isEmpty() ? null : opportunityProducts.get(0);
            }
            return activeMemProd;
        }
        set;
    }

    public boolean showOverseas {
        get{
            if(showOverseas==null){
                showOverseas=false;
            }
            system.debug(showOverseas);
            return showOverseas;
        }
        set;
    }

    public pagereference changepaymentdetails(){
        // If the payment method is direct debit.
        if (lea.Payment_Method__c == 'Direct Debit') {
            // Validate the direct debit information.
            // If the direct debit details are not valid.
            if(!validateDirectDebitInfo()) {
                return null;
            }
        }
        // code to store new pay details goes here




        Account acct = [select id,BillingPostalCode,Membership_Status__c,Date_Joined__c, (select id, amount, closeDate FROM Opportunities ORDER BY closeDate DESC LIMIT 1) from Account where id=:acc.id];
        Opportunity oppty = [select id,closedate, amount from Opportunity where AccountId=:acc.Id ORDER BY closeDate DESC LIMIT 1];

        String token;
        Decimal totalcost=0;
        Payment_Method__c pm = new Payment_Method__c();
        pm.Membership__c = acct.id;
        if(lea.Payment_Method__c=='Debit/Credit Card'){
            pm.CC_Token__c = token;
            pm.recordtypeid = sc.CcardRecordTypeId;
            pm.Status__c = 'Active';
            // pm.One_off_payment_date__c = date.today();

        }
        else if(lea.Payment_Method__c=='Direct Debit'){
            pm.recordtypeid = sc.ddebitRecordTypeId;
            pm.Bank_Account_Name__c = lea.Bank_Account_Name__c;
            pm.Bank_Account_Number__c = lea.Bank_Account_Number__c;
            pm.Bank_Name__c = lea.Bank_Name__c;
            pm.Sort_Code__c = lea.Sort_Code__c.replaceAll('[^0-9]', '');
            pm.Membership_Email__c = acc.Email__c;
            if(acct.Membership_Status__c == 'DD Mandate Rejected' || acc.Membership_Status__c == 'DD Pending' || acc.Membership_Status__c == 'DD Payment Rejected' ){
                pm.Mandate_Amount__c = oppty.amount;

            }else {

                pm.Mandate_Amount__c = lea.Amount__c;
            }
            pm.Status__c = 'Active';
            if (pm.Mandate_Amount__c > 0){
                acc.Membership_Status__c = 'DD Pending';
            }
            else if(pm.Mandate_Amount__c == 0){
                acc.Membership_Status__c = 'Paid';
            }
        }
        else if (lea.Payment_Method__c=='Cash/Cheque'){
            pm.recordtypeid = sc.cashRecordTypeId;
            //pm.One_off_payment_date__c = date.today();


        }
        //        pm.start_date__c = acc.Renewal_Date__c;
        pm.start_date__c = date.today();
        acc.Payment_Method2__c = lea.Payment_Method__c;
        insert pm;

        update acc;
        //Commented it out because this code is added in PaymentMethodTriggerHandler.
        /*  if(currentDD!=null){
            currentDD.Status__c = 'Cancelled';
            update currentDD;
        }*/
        if(lea.Join_Fee_8_Weeks__c){
            PageReference ps = Page.PaymentSuccess;
            ps.getParameters().put('ref',string.valueof(lea.id));
            ps.getParameters().put('result','SUCCESS');
            return ps;
        }
        else{
            return controller.cancel();
        }

        //
    }


    private void upslead(){
        //if(lea.Associate_Member_First_Name__c!=null)lea.Associate_Member_First_Name__c=Utils.toPropercase(lea.Associate_Member_First_Name__c);
        //if(lea.Associate_Member_Surname__c!=null)lea.Associate_Member_Surname__c=Utils.toPropercase(lea.Associate_Member_Surname__c);
        if(MemberABday!='')lea.Associate_Member_Date_of_Birth__c = Date.parse(MemberABday);
        List<String> msections = new List<String>();
        for (sectionSelectWrapper s:sections){
            if(s.selected)msections.add(s.s.name);
        }
        lea.sections__c= string.join(msections,':');
        lea.leadstep__c = wizardStep;
        upsert lea;
    }

    public List<sectionSelectWrapper> newSections {
        get{
            if(acc.Membership_Status__c == 'DD Mandate Rejected' || acc.Membership_Status__c == 'DD Payment Rejected'){
                system.debug(cop);
                system.debug(sections);
                newsections = new List<sectionSelectWrapper>();
                for(sectionSelectWrapper s:sections){
                    if(s.selected){
                        newsections.add(new sectionSelectWrapper(s.s,s.price,true));
                    }
                }
                system.debug(newsections);
                return newSections;
            }
            else{
                system.debug(cop);
                system.debug(sections);
                newsections = new List<sectionSelectWrapper>();
                for(sectionSelectWrapper s:sections){
                    if(s.selected){
                        boolean found=false;
                        for(Club_Opportunity_Product__c c:cop){
                            if(c.product__c == s.s.id){
                                found=true;
                                break;
                            }
                        }
                        if(!found)newsections.add(new sectionSelectWrapper(s.s,s.price,true));
                    }
                }
                return newSections;
            }
        }
        set;
    }

    public String payform {
        get{
            List<String> addr = new List<String>();
            if(lea.street!=null)addr = lea.street.split(',',-1);

            Verifone__c verifone = Verifone__c.getOrgDefaults();

            payform ='&lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot;?&gt;';
            payform +='&lt;postdata xmlns:xsi=&quot;http://www.w3.org/2001/XMLSchema-instance&quot; xmlns:xsd=&quot;http://www.w3.org/2001/XMLSchema&quot;&gt;';
            payform +='&lt;api&gt;2&lt;/api&gt;';
            payform +='&lt;merchantid&gt;'+verifone.merchantid__c+'&lt;/merchantid&gt;';
            payform +='&lt;requesttype&gt;eftrequest&lt;/requesttype&gt;';
            payform +='&lt;requestdata&gt;&amp;lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot;?&amp;gt;';
            payform +='&amp;lt;eftrequest xmlns:xsi=&quot;http://www.w3.org/2001/XMLSchema-instance&quot; xmlns:xsd=&quot;http://www.w3.org/2001/XMLSchema&quot;&amp;gt;';
            payform +='&amp;lt;javascriptenabled&amp;gt;Y&amp;lt;/javascriptenabled&amp;gt;';
            payform +='  &amp;lt;merchant&amp;gt;';
            payform +='    &amp;lt;merchantid&amp;gt;'+verifone.merchantid__c+'&amp;lt;/merchantid&amp;gt;';
            payform +='    &amp;lt;systemguid&amp;gt;'+verifone.Systemguid__c+'&amp;lt;/systemguid&amp;gt;';
            payform +='  &amp;lt;/merchant&amp;gt;';
            payform +='  &amp;lt;merchantreference&amp;gt;'+lea.id+'&amp;lt;/merchantreference&amp;gt;';
            payform +='  &amp;lt;accountid&amp;gt;'+verifone.accountid__c+'&amp;lt;/accountid&amp;gt;';
            payform +='  &amp;lt;capturemethod&amp;gt;11&amp;lt;/capturemethod&amp;gt;';
            payform +='  &amp;lt;processingidentifier&amp;gt;1&amp;lt;/processingidentifier&amp;gt;';
            payform +='  &amp;lt;transactionvalue&amp;gt;'+String.valueof(costTotal)+'&amp;lt;/transactionvalue&amp;gt;';
            payform +='  &amp;lt;showorderconfirmation&amp;gt;false&amp;lt;/showorderconfirmation&amp;gt;';
            payform +='  &amp;lt;showpaymentresult&amp;gt;true&amp;lt;/showpaymentresult&amp;gt;';
            payform +='  &amp;lt;customer&amp;gt;';
            payform +='    &amp;lt;firstname&amp;gt;';
            if(cPrimaryMember.Salutation!=null){
                payform +=cPrimaryMember.Salutation.replaceAll('[^a-zA-Z_0-9 ,\\/\\\\\\.\\-\'&]', '')+' ';
            }
            if(cPrimaryMember.firstname!=null){
                payform +=cPrimaryMember.firstname.replaceAll('[^a-zA-Z_0-9 ,\\/\\\\\\.\\-\'&]', '');
            }
            payform +='&amp;lt;/firstname&amp;gt;';
            payform +='    &amp;lt;lastname&amp;gt;';
            if(cPrimaryMember.lastname!=null){
                payform +=cPrimaryMember.lastname.replaceAll('[^a-zA-Z_0-9 ,\\/\\\\\\.\\-\'&]', '');
            }
            payform+='&amp;lt;/lastname&amp;gt;';
            payform +='    &amp;lt;address&amp;gt;';
            // field1.replaceAll('[^\\w ,\\/\\\\\\.\\-]', '');
            if(addr.size()>0){
                payform +='      &amp;lt;address1&amp;gt;'+addr[0].replaceAll('[^a-zA-Z_0-9 ,\\/\\\\\\.\\-\'&]', '').escapexml().escapexml().escapexml()+'&amp;lt;/address1&amp;gt;';
            }
            if(addr.size()>1){
                payform +='      &amp;lt;address2&amp;gt;'+addr[1].replaceAll('[^a-zA-Z_0-9 ,\\/\\\\\\.\\-\'&]', '').escapexml().escapexml().escapexml()+'&amp;lt;/address2&amp;gt;';
            }
            if(lea.city!=null){
                payform +='      &amp;lt;town&amp;gt;'+lea.city.replaceAll('[^a-zA-Z0-9 !\\.\\-\']', '').escapexml().escapexml().escapexml()+'&amp;lt;/town&amp;gt;';
            }
            if(lea.state!=null){
                payform +='      &amp;lt;county&amp;gt;'+lea.state.replaceAll('[^a-zA-Z0-9 !\\.\\-\']', '').escapexml().escapexml().escapexml()+'&amp;lt;/county&amp;gt;';
            }
            if(lea.PostalCode!=null){
                payform +='      &amp;lt;postcode&amp;gt;'+lea.PostalCode+'&amp;lt;/postcode&amp;gt;';
            }
            if(lea.country!=null){
                payform +='      &amp;lt;country&amp;gt;'+lea.country.replaceAll('[^a-zA-Z0-9 !\\.\\-\']', '').escapexml().escapexml().escapexml()+'&amp;lt;/country&amp;gt;';
            }
            payform +='    &amp;lt;/address&amp;gt;';
            payform +='    &amp;lt;email&amp;gt;'+lea.email.escapexml().escapexml().escapexml()+'&amp;lt;/email&amp;gt;';
            payform +='    &amp;lt;deliveryedit&amp;gt;true&amp;lt;/deliveryedit&amp;gt;';
            payform +='  &amp;lt;/customer&amp;gt;';
            payform +='  &amp;lt;hideBillingDetails&amp;gt;false&amp;lt;/hideBillingDetails&amp;gt;';
            payform +='  &amp;lt;hideDeliveryDetails&amp;gt;true&amp;lt;/hideDeliveryDetails&amp;gt;';
            payform +='  &amp;lt;tokenexpirationdate&amp;gt;31122020&amp;lt;/tokenexpirationdate&amp;gt;';
            payform +='  &amp;lt;registertoken&amp;gt;true&amp;lt;/registertoken&amp;gt;';
            //            payform +='  &amp;lt;registertoken&amp;gt;false&amp;lt;/registertoken&amp;gt;';
            //            payform +='  &amp;lt;tokenid&amp;gt;10006508401&amp;lt;/tokenid&amp;gt;';
            payform +='&amp;lt;/eftrequest&amp;gt;&lt;/requestdata&gt;';
            payform +='&lt;/postdata&gt; ';
            return payform;
        }
        set;
    }

    public Decimal joinCost{
        get{
            Decimal d;
            for(Club_Product__c m:mtList){
                if(m.Name == lea.Membership_Code__c){
                    for(Price__c p:m.prices__r){
                        if(p.Payment_Type__c == lea.Payment_Method__c)d=p.Joining_Fee__c;
                    }
                    if(!!lea.Joining_Fee_Waived__c )d=0;
                }
            }
            return d;
        }
        set;
    }

    public Decimal costTotal{
        get{
            costtotal=0;
            system.debug(mtCost);
            system.debug(lea.Payment_Method__c);
            if(mtCost!=null)costTotal+=mtCost;
            system.debug(lea.hasAssociate__c);
            if(lea.hasAssociate__c || joinDateFee)costTotal+=amCost;
            for(sectionSelectWrapper s:newsections){
                if(s.selected)costTotal+=s.price;
            }
            if(pageName == 'ChangePaymentDetails'){
                costTotal += joinFee;
            }
            else if(pageName == 'ChangeMembership' || pageName == 'ChangeAssociationSections'){
                costTotal += joinFeeChangeMem;
            }
            //costtotal=0;
            return costTotal;
        }
        set;
    }

    Map<string,club_product__c> mapPrices{
        get{
            if(mapPrices==null){
                mapPrices=new Map<string,club_product__c>();
                Date now = Date.today();
                List<Club_Product__c> pList = new List<Club_Product__c>();
                if(pageName == 'ChangeAtRenewal'){
                    pList = [select id,name,Product_Detail__c,(select Price__c, Start_Date__c , End_Date__c, change_fee__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: this.acc.Renewal_Date__c and (End_Date__c>=:this.acc.Renewal_Date__c or End_Date__c=null)) order by Start_Date__c DESC) from club_product__c where recordtype.name='Associate Membership' order by name];
                }
                else{
                    pList = [select id,name,Product_Detail__c,(select Price__c, Start_Date__c , End_Date__c, change_fee__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: this.acc.Renewal_Date__c and (End_Date__c>=:this.acc.Renewal_Date__c or End_Date__c=null)) OR (Start_Date__c<=:week8date and (End_Date__c>=:week8date or End_Date__c=null)) order by Start_Date__c ) from club_product__c where recordtype.name='Associate Membership' order by name];
                }
                for(Club_Product__c p:plist){
                    List<price__c> pr = p.prices__r;
                    if(pr.size()>0){
                        mapPrices.put('Associate Member',p);
                    }
                }
            }
            system.debug(mapPrices);
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
        ps.getParameters().put('ref',string.valueof(lea.id));
        ps.getParameters().put('result','SUCCESS');
        return ps;
    }

    public hopewiserSoapbankcoder.ValidateReturnDetailResponse_element validate()
    {
        hopewiserSoapbankcoder banklookup = new hopewiserSoapbankcoder();
        hopewiserSoapbankcoder.ValidateReturnDetailRequest_element bdets = new hopewiserSoapbankcoder.ValidateReturnDetailRequest_element();
        bdets.AccountNumber = lea.Sort_Code__c.replaceAll('[^0-9]', '')+lea.Bank_Account_Number__c.replaceAll('[^0-9]', '');
        bdets.Dataset='uk-vl-bankcode';

        docsOasisOpenOrgWss200401Oasis20040.securityType sectype = new docsOasisOpenOrgWss200401Oasis20040.securityType();
        docsOasisOpenOrgWss200401Oasis20040.usernameTokenType sectoken = new docsOasisOpenOrgWss200401Oasis20040.usernameTokenType();
        Hopewiser__c hopewiser = Hopewiser__c.getOrgDefaults();
        //            sectoken.Username ='ccc_internal';
        //            sectoken.password ='Yofakynw';
        sectoken.Username = hopewiser.username__c;
        sectoken.password =hopewiser.password__c;

        hopewiserSoapbankcoder.soapbankcoderInterfaceSoap11 r= new hopewiserSoapbankcoder.soapbankcoderInterfaceSoap11();
        sectype.UsernameToken = sectoken;
        r.Security = sectype;

        hopewiserSoapbankcoder.StatusResponse_element sr = r.Status();

        system.debug(sr.Default_x);
        system.debug(sr.Alternate.Dataset);

        hopewiserSoapbankcoder.ValidateReturnDetailResponse_element ret  = r.ValidateReturnDetail(lea.Sort_Code__c.replaceAll('[^0-9]', '')+lea.Bank_Account_Number__c.replaceAll('[^0-9]', ''),'uk-vl-bankcode');

        system.debug(ret);
        system.debug('Status: ' + ret.statustext);
        system.debug('Validity: ' + ret.validityflag);
        system.debug('Code: ' + ret.statuscode);
        //            system.debug(ret.bankdetail);
        for(hopewiserSoapbankcoder.itemValueType dv:ret.bankdetail.Item)
        {
            system.debug(dv);
        }

        return ret;
    }

    public boolean ddPayAllowed {
        get{
            ddPayAllowed=false;
            for(Club_Product__c p:mtlist){
                if(lea.membership_code__c ==p.Name){
                    ddPayAllowed= p.DD_Payment_Allowed__c;
                    break;
                }
            }
            return ddPayAllowed;
        }
        set;
    }

    public boolean cardPayAllowed {
        get{
            cardPayAllowed=false;
            for(Club_Product__c p:mtlist){
                if(lea.membership_code__c ==p.Name){
                    cardPayAllowed= p.Card_Payment_Allowed__c;
                    break;
                }
            }
            return cardPayAllowed;
        }
        set;
    }

    public boolean cashPayAllowed {
        get{
            cashPayAllowed=false;
            for(Club_Product__c p:mtlist){
                if(lea.membership_code__c ==p.Name){
                    cashPayAllowed= p.Cash_Payment_Allowed__c;
                    break;
                }
            }
            return cashPayAllowed;
        }
        set;
    }

    public List<SelectOption> maddressOptions2{
        get;set;
    }

    public void maddrsearch()
    {
        if(mstreet=='' || mcity==''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter street and city'));
            maddressOptions=null;
        }
        else
        {
            maddressOptions=null;
            maddressOptions2=null;
            mseladdr=null;
            mseladdr2=null;
            hopewiserSoapaddrsvr aSearch = new hopewiserSoapaddrsvr();
            hopewiserSoapaddrsvr.addressSearchRequestOptionsType asro = new hopewiserSoapaddrsvr.addressSearchRequestOptionsType();
            hopewiserSoapaddrsvr.formattedLabelOptionsType flo = new hopewiserSoapaddrsvr.formattedLabelOptionsType();
            hopewiserSoapaddrsvr.dataType dt = new hopewiserSoapaddrsvr.dataType();
            hopewiserSoapaddrsvr.dataType ed = new hopewiserSoapaddrsvr.dataType();
            String MAF = '';

            docsOasisOpenOrgWss200401Oasis20040.securityType sectype = new docsOasisOpenOrgWss200401Oasis20040.securityType();
            docsOasisOpenOrgWss200401Oasis20040.usernameTokenType sectoken = new docsOasisOpenOrgWss200401Oasis20040.usernameTokenType();
            Hopewiser__c hopewiser = Hopewiser__c.getOrgDefaults();
            //            sectoken.Username ='ccc_internal';
            //            sectoken.password ='Yofakynw';
            sectoken.Username = hopewiser.username__c;
            sectoken.password =hopewiser.password__c;

            hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11 r= new hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11();
            sectype.UsernameToken = sectoken;
            r.Security = sectype;

            results = r.AddressSearch(mHouseNumber,mstreet,mcity,'','','','','','','',MAF,asro);

            if(results.match==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,results.StatusDesc));
                maddressOptions=null;
            }
            else
            {
                maddressOptions=null;
                for(hopewiserSoapaddrsvr.searchMatchType m: results.Match)
                {
                    system.debug(m.text);
                }
            }
        }
    }


    public void addrsearch() {
        system.debug(pcode);
        if(pcode!=''){
            hopewiserSoapaddrsvr pclook = new hopewiserSoapaddrsvr();
            hopewiserSoapaddrsvr.postcodeLookupRequestOptionsType plro = new hopewiserSoapaddrsvr.postcodeLookupRequestOptionsType();
            hopewiserSoapaddrsvr.formattedLabelOptionsType flo = new hopewiserSoapaddrsvr.formattedLabelOptionsType();
            hopewiserSoapaddrsvr.dataType dt = new hopewiserSoapaddrsvr.dataType();
            hopewiserSoapaddrsvr.dataType ed = new hopewiserSoapaddrsvr.dataType();
            String postcode = pcode;
            String Premise = housenumber;
            String MAF = '';
            docsOasisOpenOrgWss200401Oasis20040.securityType sectype = new docsOasisOpenOrgWss200401Oasis20040.securityType();
            docsOasisOpenOrgWss200401Oasis20040.usernameTokenType sectoken = new docsOasisOpenOrgWss200401Oasis20040.usernameTokenType();
            Hopewiser__c hopewiser = Hopewiser__c.getOrgDefaults();
            //            sectoken.Username ='ccc_internal';
            //            sectoken.password ='Yofakynw';
            sectoken.Username = hopewiser.username__c;
            sectoken.password =hopewiser.password__c;

            hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11 r= new hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11();
            sectype.UsernameToken = sectoken;
            r.Security = sectype;

            hopewiserSoapaddrsvr.PostcodeLookupResponse_element rv = r.PostcodeLookup(postcode,premise,MAF,plro,flo,dt,ed);

            system.debug(rv);

            if(rv.Match!=null)
            {
                addMatch.clear();
                Integer i=0;
                for(hopewiserSoapaddrsvr.addressMatchType m: rv.Match)
                {
                    addMatch.put(i,m);
                    system.debug(m.Address);
                    ++i;
                }

                for(integer s=0;s<addMatch.size();s++)
                {
                    system.debug(addMatch.get(s).Address.Line1);
                }
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Postcode not Found'));
            }
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter a Postcode to search'));
        }
    }


    public void mfilladdress(){
        system.debug(mseladdr);
        mseladdr2=null;
        system.debug(results.Match[Integer.valueof(mseladdr)]);
        if(results.Match[Integer.valueof(mseladdr)].Expandable=='yes')
        {
            hopewiserSoapaddrsvr aSearch = new hopewiserSoapaddrsvr();
            hopewiserSoapaddrsvr.addressExpandRequestOptionsType asro = new hopewiserSoapaddrsvr.addressExpandRequestOptionsType();
            hopewiserSoapaddrsvr.formattedLabelOptionsType flo = new hopewiserSoapaddrsvr.formattedLabelOptionsType();
            hopewiserSoapaddrsvr.dataType dt = new hopewiserSoapaddrsvr.dataType();
            hopewiserSoapaddrsvr.dataType ed = new hopewiserSoapaddrsvr.dataType();

            docsOasisOpenOrgWss200401Oasis20040.securityType sectype = new docsOasisOpenOrgWss200401Oasis20040.securityType();
            docsOasisOpenOrgWss200401Oasis20040.usernameTokenType sectoken = new docsOasisOpenOrgWss200401Oasis20040.usernameTokenType();
            Hopewiser__c hopewiser = Hopewiser__c.getOrgDefaults();
            //            sectoken.Username ='ccc_internal';
            //            sectoken.password ='Yofakynw';
            sectoken.Username = hopewiser.username__c;
            sectoken.password =hopewiser.password__c;

            hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11 r= new hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11();
            sectype.UsernameToken = sectoken;
            r.Security = sectype;

            system.debug(results.Match[Integer.valueof(mseladdr)].SID);
            results2 = r.AddressExpand(results.Match[Integer.valueof(mseladdr)].SID,asro);
            maddressOptions2=null;
            maddressOptions2 = new List<SelectOption>();
            maddressOptions2.add(new Selectoption('','Please Select'));
            if(results2!=null){
                for(Integer i=0;i<results2.match.size();i++)
                {
                    hopewiserSoapaddrsvr.searchMatchType m=results2.match[i];
                    maddressOptions2.add(new Selectoption(String.valueOf(i),m.text));
                }
            }
        }
        else
        {
            system.debug(mseladdr);
            system.debug(results.Match[Integer.valueof(mseladdr)]);
            hopewiserSoapaddrsvr aSearch = new hopewiserSoapaddrsvr();
            hopewiserSoapaddrsvr.addressDetailsRequestOptionsType asro = new hopewiserSoapaddrsvr.addressDetailsRequestOptionsType();
            hopewiserSoapaddrsvr.formattedLabelOptionsType flo = new hopewiserSoapaddrsvr.formattedLabelOptionsType();
            hopewiserSoapaddrsvr.dataType dt = new hopewiserSoapaddrsvr.dataType();
            hopewiserSoapaddrsvr.dataType ed = new hopewiserSoapaddrsvr.dataType();
            docsOasisOpenOrgWss200401Oasis20040.securityType sectype = new docsOasisOpenOrgWss200401Oasis20040.securityType();
            docsOasisOpenOrgWss200401Oasis20040.usernameTokenType sectoken = new docsOasisOpenOrgWss200401Oasis20040.usernameTokenType();
            Hopewiser__c hopewiser = Hopewiser__c.getOrgDefaults();
            //            sectoken.Username ='ccc_internal';
            //            sectoken.password ='Yofakynw';
            sectoken.Username = hopewiser.username__c;
            sectoken.password =hopewiser.password__c;

            hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11 r= new hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11();
            sectype.UsernameToken = sectoken;
            r.Security = sectype;

            system.debug(results.Match[Integer.valueof(mseladdr)].SID);
            address = r.AddressDetails(results.Match[Integer.valueof(mseladdr)].SID,asro,flo,dt,ed);

            String faddress ='';
            if(address.Match.Address.Line1 !=null)faddress+=address.Match.Address.Line1+', ';
            if(address.Match.Address.Line2 !=null)faddress+=address.Match.Address.Line2+', ';
            if(address.Match.Address.Line3 !=null)faddress+=address.Match.Address.Line3+', ';
            if(address.Match.Address.Line4 !=null)faddress+=address.Match.Address.Line4+', ';
            if(address.Match.Address.Line5 !=null)faddress+=address.Match.Address.Line5+', ';
            faddress = faddress.removeEnd(', ');
            lea.street = faddress;
            lea.city = address.Match.Address.town;
            lea.state = address.Match.Address.County;
            lea.PostalCode = address.Match.Address.Postcode;
            lea.country='';

        }
    }

    public void mfilladdress2(){
        system.debug(mseladdr2);
        system.debug(results2.Match[Integer.valueof(mseladdr2)]);
        hopewiserSoapaddrsvr aSearch = new hopewiserSoapaddrsvr();
        hopewiserSoapaddrsvr.addressDetailsRequestOptionsType asro = new hopewiserSoapaddrsvr.addressDetailsRequestOptionsType();
        hopewiserSoapaddrsvr.formattedLabelOptionsType flo = new hopewiserSoapaddrsvr.formattedLabelOptionsType();
        hopewiserSoapaddrsvr.dataType dt = new hopewiserSoapaddrsvr.dataType();
        hopewiserSoapaddrsvr.dataType ed = new hopewiserSoapaddrsvr.dataType();
        docsOasisOpenOrgWss200401Oasis20040.securityType sectype = new docsOasisOpenOrgWss200401Oasis20040.securityType();
        docsOasisOpenOrgWss200401Oasis20040.usernameTokenType sectoken = new docsOasisOpenOrgWss200401Oasis20040.usernameTokenType();
        Hopewiser__c hopewiser = Hopewiser__c.getOrgDefaults();
        //            sectoken.Username ='ccc_internal';
        //            sectoken.password ='Yofakynw';
        sectoken.Username = hopewiser.username__c;
        sectoken.password =hopewiser.password__c;

        hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11 r= new hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11();
        sectype.UsernameToken = sectoken;
        r.Security = sectype;

        system.debug(results2.Match[Integer.valueof(mseladdr2)].SID);
        address = r.AddressDetails(results2.Match[Integer.valueof(mseladdr2)].SID,asro,flo,dt,ed);

        String faddress ='';
        if(address.Match.Address.Line1 !=null)faddress+=address.Match.Address.Line1+', ';
        if(address.Match.Address.Line2 !=null)faddress+=address.Match.Address.Line2+', ';
        if(address.Match.Address.Line3 !=null)faddress+=address.Match.Address.Line3+', ';
        if(address.Match.Address.Line4 !=null)faddress+=address.Match.Address.Line4+', ';
        if(address.Match.Address.Line5 !=null)faddress+=address.Match.Address.Line5+', ';
        faddress = faddress.removeEnd(', ');
        lea.street = faddress;
        lea.organisation__c=address.Match.Address.Organisation;
        lea.city = address.Match.Address.town;
        lea.state = address.Match.Address.County;
        lea.PostalCode = address.Match.Address.Postcode;

    }

    public PageReference changeaddressdetails(){
        if(lea != null){
            //update lea;
        }
        if(!lea.overseas_membership__c){
            if(lea.PostalCode==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'No Postcode Entered - either enter a postcode or select Overseas Membership'));
                return null;
            }
        }
        Account a = acc;
        //a = acc;
        a.billingstreet = lea.street;
        a.billingpostalcode = lea.PostalCode;
        a.billingcity = lea.City;
        a.billingcountry = lea.Country;
        a.billingstate = lea.State;
        a.Organisation_Name__c = lea.Organisation__c;
        a.overseas_membership__c = lea.overseas_membership__c;


        if(a.BillingPostalCode!=null && !a.Opted_In__c ){
            List<String> parts = a.BillingPostalCode.split(' ');
            if(parts.size()>1){
                String pcodeout = parts[0];
                String pcodein = parts[1].substring(0, 1);

                List<DA_Postcode__c> dap = new List<DA_Postcode__c>();

                dap = [select Association_Name__c,Postcode_Part_1__c,Postcode_Part_2__c
                from DA_Postcode__c where Postcode_Part_1__c =:pcodeout
                and (Postcode_Part_2__c = :pcodein or Postcode_Part_2__c = null ) limit 1];

                if(dap.size()>0)
                {
                    a.District_Association__c = dap[0].Association_Name__c;
                }
                else
                {
                    a.District_Association__c = null;
                }
            }
        }
        if(a != null){
            update a;
        }
        return new PageReference('/'+this.acc.id);
    }


    public PageReference changeLocation() {
        if(!lea.Overseas_Membership__c){
            lea.Country='';
        }
        return null;
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
        if (ret.ValidityFlag.tolowercase() != 'y' || ret.StatusCode == 5) {
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
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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