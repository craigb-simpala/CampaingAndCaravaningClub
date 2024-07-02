public with sharing class NewMembershipController  {
    
    public boolean btnDisabled{get;set;}    
    public apexpages.standardController controller {get; set;}
    
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
            if(lea.Salutation!=null){
                payform +=lea.Salutation.replaceAll('[^a-zA-Z_0-9 ,\\/\\\\\\.\\-\'&]', '')+' ';
            }
            if(lea.firstname!=null){
                payform +=lea.firstname.replaceAll('[^a-zA-Z_0-9 ,\\/\\\\\\.\\-\'&]', '');
            }
            payform +='&amp;lt;/firstname&amp;gt;';
            payform +='    &amp;lt;lastname&amp;gt;';
            if(lea.lastname!=null){
                payform +=lea.lastname.replaceAll('[^a-zA-Z_0-9 ,\\/\\\\\\.\\-\'&]', '');
            }
            payform+='&amp;lt;/lastname&amp;gt;';
            payform +='    &amp;lt;address&amp;gt;';
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
            payform +='    &amp;lt;email&amp;gt;';
            if(lea.email!=null){
                payform +=lea.email.escapexml().escapexml().escapexml();
            }
            payform += '&amp;lt;/email&amp;gt;';
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
    
    public Account acc;
    public Integer wizardStep {get;set;}
    public Lead lea {get;set;}
    public Lead l;
    public String minMembershipAge { get; set;}
    public String maxMembershipAge{ get; set;}
    public List<Lead> searchLeadResults {get; set;}
    public List<Account> searchAccResults {get; set;}
    public Date dob {get; set;}
    public String HouseNumber { get;set; }
    public String pcode { get;set; }
    public String mHouseNumber { get;set; }
    public String mstreet { get;set; }
    public String mcity { get;set; }

    public String joinday{get{if(joinday==null)joinday='';return joinday;}set;}   
    public String MemberBday{get{if(MemberBday==null)MemberBday='';return MemberBday;}set;}   
    public String Member2Bday{get{if(Member2Bday==null)Member2Bday='';return Member2Bday;}set;}   
    public String Child1Bday{get{if(Child1Bday==null)Child1Bday='';return Child1Bday;}set;}   
    public String Child2Bday{get{if(Child2Bday==null)Child2Bday='';return Child2Bday;}set;}   
    public String Child3Bday{get{if(Child3Bday==null)Child3Bday='';return Child3Bday;}set;}   
    public String Child4Bday{get{if(Child4Bday==null)Child4Bday='';return Child4Bday;}set;}   
    public String Child5Bday{get{if(Child5Bday==null)Child5Bday='';return Child5Bday;}set;}   
    public String Child6Bday{get{if(Child6Bday==null)Child6Bday='';return Child6Bday;}set;}   
    public String MemberABday{get{if(MemberABday==null)MemberABday='';return MemberABday;}set;}   
    
    public String searchPostcode { get;set; }
    public String searchSurname { get;set; }
    public String searchHouseNumber { get;set; }
    public Id dealerCodeId {get; set;}
    
    public boolean showmanual {get;set;}
    
    public boolean associateAllowed {
        get{
            associateAllowed=false;
            for(Club_Product__c p:mtlist){
                if(lea.membership_code__c ==p.Name){
                    associateAllowed= p.Associate_Allowed__c;
                    break;
                }
            }
            return associateAllowed;
        }
        set;
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
    
    public boolean partnerAllowed {
        get{
            partnerAllowed=false;
            for(Club_Product__c p:mtlist){
                if(lea.membership_code__c ==p.Name){
                    partnerAllowed= p.PartnerAllowed__c;
                    break;
                }
            }
            return partnerAllowed;
        }
        set;
    }
    
    public boolean childrenAllowed {
        get{
            childrenAllowed=false;
            for(Club_Product__c p:mtlist){
                if(lea.membership_code__c ==p.Name){
                    childrenAllowed= p.Children_Allowed__c;
                    break;
                }
            }
            return childrenAllowed;
        }
        set;
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
    
    public void calculateLMAge () {
        
        Integer days = this.dob.daysBetween(Date.Today());
        lea.Lead_Member_Age__c = Integer.valueOf(days/365);
        
    }
    
    public void calculateSMAge () {
        
        Integer days = this.dob.daysBetween(Date.Today());
        lea.Lead_Member_Age__c = Integer.valueOf(days/365);
        
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

    public NewMembershipController(ApexPages.StandardSetController controller){}    
    public NewMembershipController(apexpages.standardController controller) {
        wizardStep = 1;
        this.controller = controller;
        btnDisabled = false;
        List<String> leadfields = new list<String>();

        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap();
        for(String s : objectFields.keySet()) {
            leadfields.add(s);
        }
        if(!test.isRunningTest())controller.addFields(leadfields);

        this.lea = (Lead) controller.getRecord();
        system.debug(lea.leadstep__c);
        lea.joining_date__c=date.today();
        if(lea.Secondary_Member_Email__c==null)lea.Secondary_Member_Email__c='example@example.com';
        if(lea.Application_Source__c==null)lea.Application_Source__c='Telephone';
        if(lea.leadstep__c!=null)wizardStep = Integer.valueof(lea.leadstep__c);
        if(lea.max_leadstep__c==null)lea.max_leadstep__c=2;
        if(lea.Joining_Date__c!=null)joinday = lea.Joining_Date__c.format();
        if(lea.Lead_Member_Date_of_Birth__c!=null)MemberBday = lea.Lead_Member_Date_of_Birth__c.format();
        if(lea.Secondary_Member_Date_of_Birth__c!=null)Member2Bday = lea.Secondary_Member_Date_of_Birth__c.format();
        if(lea.Child_1_Date_of_Birth__c!=null)Child1Bday = lea.Child_1_Date_of_Birth__c.format();
        if(lea.Child_2_Date_of_Birth__c!=null)Child2Bday = lea.Child_2_Date_of_Birth__c.format();
        if(lea.Child_3_Date_of_Birth__c!=null)Child3Bday = lea.Child_3_Date_of_Birth__c.format();
        if(lea.Child_4_Date_of_Birth__c!=null)Child4Bday = lea.Child_4_Date_of_Birth__c.format();
        if(lea.Child_5_Date_of_Birth__c!=null)Child5Bday = lea.Child_5_Date_of_Birth__c.format();
        if(lea.Child_6_Date_of_Birth__c!=null)Child6Bday = lea.Child_6_Date_of_Birth__c.format();
        if(lea.Associate_Member_Date_of_Birth__c!=null)MemberABday = lea.Associate_Member_Date_of_Birth__c.format();
        searchLeadResults = new List<Lead>();
        searchAccResults = new List<Account>();
        if(lea.id!=null && lea.sections__c!=null ){
            List<String> msections = lea.sections__c.split(':',-2);
            Set<String> ssections = new Set<String>();
            ssections.addall(msections);
    
            for (sectionSelectWrapper s:sections){
                if(ssections.contains(s.s.name))s.selected=true;
            }
        }
        if(lea.id!=null && lea.Membership_Code__c != null){
            try{
                Club_Product__c cp = [SELECT id, Max_Age_for_Membership__c, Min_Age_for_Membership__c FROM Club_Product__c WHERE Name = :lea.Membership_Code__c];
                minMembershipAge = String.valueOf(cp.Min_Age_for_Membership__c);
                maxMembershipAge = String.valueOf(cp.Max_Age_for_Membership__c);
            } catch (Exception e){}
        }
    
        promoCodeValidated = false;
        if(lea.Id != null && lea.Voucher_Code__c != null){
            Set<String> selectedValues = new Set<string>();
            if(promoCode.Valid_for_Memberships__c != null ){
                selectedValues.addAll(promoCode.Valid_for_Memberships__c.split(';'));
            }
            if(promoCode.Id == null && (lea.Voucher_Code__c != '' || lea.Voucher_Code__c != null)){
                promoCodeValidated = false;
            }
            if(promoCode != null && lea.Voucher_Code__c != null){
                if(system.today() >= promoCode.Valid_From__c || promoCode.Valid_From__c == null){
                    system.debug(system.today() + ' ' + promoCode.Expiry_Date__c);
                    if(system.today() <= promoCode.Expiry_Date__c || promoCode.Expiry_Date__c == null){
                        if(promoCode.Number_of_Valid_Codes__c > 0){
                            if(selectedValues.contains(lea.Membership_Code__c)){
                                promoCodeValidated = true;
                            }
                        }
                    }
                }
            }
        }
        lea.Kit_Issued__c = 'No';
    }

    public PageReference changeLocation() {
        if(!lea.Overseas_Membership__c){
            lea.Country='';
        }
        return null;
    }

    public String selAddr {get;set;}
    public String mselAddr {get;set;}
    public String mselAddr2 {get;set;}

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


    public Map<Integer,hopewiserSoapaddrsvr.addressMatchType> addMatch {
        get{
            if(addMatch==null){
                addMatch = new Map<Integer,hopewiserSoapaddrsvr.addressMatchType>();
            }
            return addMatch;
        }
        set;
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
            system.debug(ret.statustext);
            system.debug(ret.validityflag);
            system.debug(ret.statuscode);
//            system.debug(ret.bankdetail);
            for(hopewiserSoapbankcoder.itemValueType dv:ret.bankdetail.Item)
            {
              system.debug(dv); 
            }
            
         return ret;
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
            Decimal d;
            for(Club_Product__c m:mtList){
                if(m.Name == lea.Membership_Code__c){
                    for(Price__c p:m.prices__r){
                        if(p.Payment_Type__c == lea.Payment_Method__c)d=p.Price__c;
                    }
                    if(d==null && lea.Payment_Method__c==null)d=m.Price_for_Initial_Picklist__c;
                }
            }
            return d;
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
                    if(!!lea.Joining_Fee_Waived__c || promoCodeValidated)d=0;
                }
            }
            return d;
        }
        set;
/*
        get{
            Decimal d=0;
            system.debug(lea.Payment_Method__c);
            system.debug(lea.Joining_Fee_Waived__c);
            if(lea.Payment_Method__c=='Direct Debit' || lea.Payment_Method__c==''|| lea.Payment_Method__c==null || wizardstep!=7){
                d=0;
            }else if(!lea.Joining_Fee_Waived__c){
                for(Club_Product__c m:mtList){
                    if(m.Name == lea.Membership_Code__c)d=m.prices__r[0].Joining_Fee__c;
                }
            }
            return d;
        }
        set;
*/
    } 
    
    public List<Club_Product__c> mtList{
        get{
            CustomPermissionsReader cpr = new CustomPermissionsReader();
            Boolean haspermission = cpr.hasPermission('CanEditMemebershipType');
            if(mtList==null){
                Date now = Date.today();
                if(haspermission){
                    mtList = [select id,name,Product_Detail__c,
                                Sections_Allowed__c,Associate_Allowed__c,
                                PartnerAllowed__c,children_allowed__c,
                                Card_Payment_Allowed__c,Cash_Payment_Allowed__c,DD_Payment_Allowed__c,Price_for_Initial_Picklist__c, 
                                (select Price__c, Joining_Fee__c, Payment_Type__c from Prices__r where Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null) order by Start_Date__c) 
                                from club_product__c 
                                where recordtype.name='Membership Code' 
                                and Show_in_New_Membership_Picklist__c=true 
                                order by name];
                    
                }
                else{
                      mtList = [select id,name,Product_Detail__c,
                                Sections_Allowed__c,Associate_Allowed__c,
                                PartnerAllowed__c,Children_allowed__c,
                                Card_Payment_Allowed__c,Cash_Payment_Allowed__c,DD_Payment_Allowed__c,Price_for_Initial_Picklist__c, 
                                (select Price__c, Joining_Fee__c, Payment_Type__c from Prices__r where Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null) order by Start_Date__c) 
                                from club_product__c 
                                where recordtype.name='Membership Code' 
                                and Show_in_New_Membership_Picklist__c=true 
                                AND Visible_to_Admin_Users_Only__c = false 
                                order by name];
                }
            }
            return mtList;                
        }
        set;
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

    public List<SelectOption> maddressOptions2{get;set;}

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

    public hopewiserSoapaddrsvr.AddressSearchResponse_element results{
        get{
            return results;
        }
        private set;
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
        
    public PageReference search() {

        if(searchLeadResults == null) {
            searchLeadResults = new List<Lead>();
        } else {
            searchLeadResults.Clear();
        }
        
        if(searchSurname=='' && searchPostcode=='' ){
            searchLeadResults = new List<Lead>();   
            searchAccResults = new List<Account>(); 
        }
        else
        {
            String startSurname;
            String startPostcode;
            if(searchSurname!=''){startsurname =searchSurname+'%';}
            if(searchPostcode!=''){startPostcode =searchPostcode+'%';}
            String LeadQuery = 'Select Name,street,city,postalcode,lastmodifieddate from Lead where isconverted=false';
            if(searchSurname!='')LeadQuery+='  and Lastname like :startsurname';
            if(searchPostcode!='')LeadQuery+='  AND postalcode LIKE :startPostcode';
            LeadQuery += ' ORDER BY CreatedDate DESC';
            
            searchLeadResults = database.query(LeadQuery);
            system.debug(searchLeadResults);
            String AccQuery = 'Select Name,membership_number__c,Membership_Status__c,billingstreet,billingcity,billingpostalcode from Account where id!=null ';
            if(searchSurname!='')AccQuery+='  and name like :startsurname';
            if(searchPostcode!='')AccQuery+='  AND BillingPostalCode LIKE :startPostcode';
            AccQuery += ' ORDER BY CreatedDate DESC';
            
            searchAccResults = database.query(AccQuery);
            system.debug(searchAccResults);
        }
        
        return null;
    }
    
    public PageReference step1 () {
        wizardStep = 1;
        return null;
    }
    
    public PageReference step2 () {
        if(lea.max_leadstep__c==null)lea.max_leadstep__c=2;
        if(wizardstep!=1){
            validateform();
            if(ApexPages.hasMessages())
            {
                return null;
            }
            wizardStep = 2;
            lea.leadstep__c = wizardStep;
            upslead();
        }
        else
        {
            lea.company = searchSurname;
        }
        wizardStep = 2;
        return null;
    }
    
    public PageReference step3 () {
        validateform();
        if(ApexPages.hasMessages())
        {
            return null;
        }
        wizardStep = 3;
        if(lea.lastname==null)lea.lastname=lea.company;
        if(lea.Child_1_Surname__c==null)lea.Child_1_Surname__c = lea.company; 
        if(lea.Child_2_Surname__c==null)lea.Child_2_Surname__c = lea.company; 
        if(lea.Child_3_Surname__c==null)lea.Child_3_Surname__c = lea.company; 
        if(lea.Child_4_Surname__c==null)lea.Child_4_Surname__c = lea.company; 
        if(lea.Child_5_Surname__c==null)lea.Child_5_Surname__c = lea.company; 
        if(lea.Child_6_Surname__c==null)lea.Child_6_Surname__c = lea.company;
        if(lea.Associate_Member_Surname__c==null)lea.Associate_Member_Surname__c =lea.company; 
        if(lea.secondary_Member_Surname__c==null)lea.secondary_Member_Surname__c =lea.company; 
        upslead();
        return null;
    }
    
    public PageReference step4 () {
        validateform();
        if(ApexPages.hasMessages())
        {
            return null;
        }
        wizardStep = 4;
        upslead();
        return null;
    }
    
    public PageReference step5 () { 
        validateform();
        if(ApexPages.hasMessages())
        {
            return null;
        }
        if(sectionsAllowed){
            wizardStep = 5;
        }
        else
        {
            wizardStep = 6;
        }
        upslead();
        return null;
    }
    
    public PageReference step6 () {
        validateform();
        if(ApexPages.hasMessages())
        {
            return null;
        }
        wizardStep = 6;
        upslead();
        return null;
    }
 
    public PageReference step7 () {
        validateform();
        if(ApexPages.hasMessages())
        {
            return null;
        }
        wizardStep = 7;
        upslead();
        return null;
    }
    
    public PageReference step8 () {
        validateform();
        if(ApexPages.hasMessages())
        {
            return null;
        }
        wizardStep = 8;
        upslead();
        return null;
    }
    
    public pagereference changepayment(){
        upslead();
        return null;
    } 

    public pagereference changeChildren(){
        return null;
    } 

    public pagereference changepartner(){
        return null;
    } 

    public pagereference changeassoc(){
        return null;
    } 

    public pagereference changems(){
        system.debug(showmanual);
        return null;
    } 

    public pagereference changemt(){
        for(Club_Product__c cp:mtList){
            lea.payment_method__c=null;
            if(cp.name==lea.Membership_Code__c){
                if(!cp.PartnerAllowed__c)lea.haspartner__c=false;
                if(!cp.Associate_Allowed__c)lea.hasAssociate__c=false;
                if(!cp.Sections_Allowed__c){
                    for (sectionSelectWrapper s:sections){
                        s.selected=false;
                    }
                    lea.sections__c='';
                }
                if(!cp.children_allowed__c)lea.Number_of_Children__c=null;
            }
        }
        return null;
    } 

    public PageReference confirm() {
        btnDisabled = true;
//      wizardStep = 8;
//      lea.leadstep__c = wizardStep;
//      upsert lea;
        boolean haserrors=false;
        if(lea.Payment_Method__c=='Direct Debit'){
            hopewiserSoapbankcoder.ValidateReturnDetailResponse_element ret;
            if(lea.Sort_Code__c==''||lea.Sort_Code__c==null){lea.Sort_Code__c.adderror('Please Enter Sort Code');haserrors=true;}
            if(lea.Bank_Account_Name__c==''||lea.Bank_Account_Name__c==null){lea.Bank_Account_Name__c.adderror('Please Enter Bank Account Name');haserrors=true;}
            if(lea.Bank_Account_Number__c==''||lea.Bank_Account_Number__c==null){lea.Bank_Account_Number__c.adderror('Please Enter Bank Account Number');haserrors=true;}
            if(lea.Bank_Name__c==''||lea.Bank_Name__c==null){lea.Bank_Name__c.adderror('Please Enter Bank Name');haserrors=true;}
            if(lea.Bank_Account_Number__c!=null && lea.Sort_Code__c!=null){
                ret = validate();
                if(ret.validityflag.tolowercase()!='y'){haserrors=true;ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, ret.StatusText));}
                //if(ret.statuscode!=2){haserrors=true;ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, ret.StatusText));}
            }
            if(haserrors)return null;
        }
        
        //if(Costtotal==0)lea.Payment_Method__c='Cash/Cheque';
        upslead();

        CreateMember cm = new CreateMember();
        
        Database.LeadConvertResult lcr = cm.createMembershipfromLead(lea,'xxxxxx',null);
        btnDisabled=false;
        return new PageReference('/'+lcr.accountId);
    }

    public voucher__c voucher{
        get{
            try{
                voucher = [select id,name,Applies_to_Membership__c,Applies_to_Sections__c,Available__c,Valid_From__c,Expiry_Date__c
                    from voucher__c
                    where name = :lea.voucher_code__c];
            }
            catch (exception ex){
                voucher = new Voucher__c();
            }
            return voucher;         
        }
        set;
    }
    
    public Dealer_Advert__c dealercode{
        get{                
                try{
                    dealercode = [select id,name,Active__c,Valid_Show__c,Show_Start_Date__c,Show_End_Date__c
                        from Dealer_Advert__c
                        where name = :lea.Dealer_Code__c];
                }
                catch (exception ex){
                    dealercode = new Dealer_Advert__c();
                }
            return dealercode;         
        }
        set;
    }
    
    private void validateform(){
        if(wizardstep==2){
            if(lea.Membership_Code__c ==null){
                lea.Membership_Code__c.addError('Please select membership type');
            }
            system.debug(dealerCodeId);
            system.debug(DealerCode);
            if(lea.Dealer_Code__c != null){
                if(dealercode!=null){
                    if(DealerCode.id!=null){
                        dealerCodeId = DealerCode.id;
                    }
                    else{
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Dealer Code '+lea.Dealer_Code__c+ ' not found'));
                    }
                }
                
            }
            if(lea.voucher_code__c!=null){
                if(promoCodeValidated == false && lea.Voucher_Code__c!=''){             
                    lea.voucher_code__c.adderror('Please validate the promo code');
                }
                /*if(voucher.id==null){
                    lea.voucher_code__c.adderror('Voucher does not exist');
                }
                else{
                    if(!voucher.available__c){
                        lea.voucher_code__c.adderror('Voucher has been used or is expired');
                    }*/
    //              else{
    //                  boolean hassections = false;
    //                  for (sectionSelectWrapper s:sections){
    //                      if(s.selected)hassections=true;
    //                  }
    //                  if(voucher.Applies_to_Sections__c && !voucher.Applies_to_Membership__c && !hassections){
    //                      lea.voucher_code__c.adderror('Voucher is a sections only voucher - no sections on this membership');
    //                  }
                  //}   
              //  }
            }
        }
        if(wizardstep==3){
            if(lea.email==null){
                lea.email.addError('Please Enter an Email address');
            }
            if(MemberBday==''){
                lea.addError('Please enter Lead members Birthdate');
            }
            if(lea.haspartner__c){
                if(lea.Secondary_Member_Email__c==null){
                    lea.Secondary_Member_Email__c.addError('Please enter Secondary members email address');
                }
	            if(Member2Bday==''){
	                lea.addError('Please enter Secondary members Birthdate');
	            }
            }
            if(lea.email!=null && lea.haspartner__c && lea.Secondary_Member_Email__c!=null){
                if(!lea.email.contains('@example.com') && !lea.Secondary_Member_Email__c.contains('@example.com') && lea.email==lea.Secondary_Member_Email__c){
                    lea.adderror('Lead and Secondary members emails cannot be the same');
                }
            }
            if(lea.hasAssociate__c){
                if(MemberABday=='')
                  lea.adderror('Please enter associate members Birthdate');   
                
            }
        }
    
    
        if(wizardstep==4){
            if(lea.camping_unit__c==null){
                lea.camping_unit__c.addError('Please Enter a Camping Unit');
            }
        } 
    
    
    
        if(wizardStep==6 && lea.Existing_Members_Number__c !=null){
            Account a;
            try{
                a = [select id from account where Hybrid_Membership_Number__c = :lea.Existing_Members_Number__c];
            }
            catch(Exception ex){
                lea.Existing_Members_Number__c.adderror('Membership number does not exist');
            }
        }
    }

    private void upslead(){
        system.debug(MemberBday);
        /*
        if(lea.FirstName!=null)lea.FirstName= Utils.toProperCase(lea.FirstName);
        if(lea.LastName!=null)lea.LastName=Utils.toProperCase(lea.LastName);
        if(lea.Company!=null)lea.Company=Utils.toProperCase(lea.Company);
        if(lea.Secondary_Member_First_Name__c!=null)lea.Secondary_Member_First_Name__c=Utils.toProperCase(lea.Secondary_Member_First_Name__c);
        if(lea.Secondary_Member_Surname__c!=null)lea.Secondary_Member_Surname__c=Utils.toProperCase(lea.Secondary_Member_Surname__c);
        if(lea.Child_1_First_Name__c!=null)lea.Child_1_First_Name__c=Utils.toProperCase(lea.Child_1_First_Name__c);
        if(lea.Child_1_Surname__c!=null)lea.Child_1_Surname__c=Utils.toProperCase(lea.Child_1_Surname__c);
        if(lea.Child_2_First_Name__c!=null)lea.Child_2_First_Name__c=Utils.toProperCase(lea.Child_2_First_Name__c);
        if(lea.Child_2_Surname__c!=null)lea.Child_2_Surname__c=Utils.toProperCase(lea.Child_2_Surname__c);
        if(lea.Child_3_First_Name__c!=null)lea.Child_3_First_Name__c=Utils.toProperCase(lea.Child_3_First_Name__c);
        if(lea.Child_3_Surname__c!=null)lea.Child_3_Surname__c=Utils.toProperCase(lea.Child_3_Surname__c);
        if(lea.Child_4_First_Name__c!=null)lea.Child_4_First_Name__c=Utils.toProperCase(lea.Child_4_First_Name__c);
        if(lea.Child_4_Surname__c!=null)lea.Child_4_Surname__c=Utils.toProperCase(lea.Child_4_Surname__c);
        if(lea.Child_5_First_Name__c!=null)lea.Child_5_First_Name__c=Utils.toProperCase(lea.Child_5_First_Name__c);
        if(lea.Child_5_Surname__c!=null)lea.Child_5_Surname__c=Utils.toProperCase(lea.Child_5_Surname__c);
        if(lea.Child_6_First_Name__c!=null)lea.Child_6_First_Name__c=Utils.toProperCase(lea.Child_6_First_Name__c);
        if(lea.Child_6_Surname__c!=null)lea.Child_6_Surname__c=Utils.toProperCase(lea.Child_6_Surname__c);
        if(lea.Associate_Member_First_Name__c!=null)lea.Associate_Member_First_Name__c=Utils.toProperCase(lea.Associate_Member_First_Name__c);
        if(lea.Associate_Member_Surname__c!=null)lea.Associate_Member_Surname__c=Utils.toProperCase(lea.Associate_Member_Surname__c);
        */
        if(lea.Dealer_Code__c==null){
            lea.Dealer_Ad_Code__c = null;
            dealerCodeId = null;
        }
        if(lea.Dealer_Code__c != null && dealerCodeId != null){
            lea.Dealer_Ad_Code__c = dealerCodeId;
            
        }
        
        if(joinday!='')lea.joining_date__c = Date.parse(joinday);
        if(MemberBday!='')lea.Lead_Member_Date_of_Birth__c = Date.parse(MemberBday);
        if(Member2Bday!='')lea.Secondary_Member_Date_of_Birth__c = Date.parse(Member2Bday);
        if(Child1Bday!='')lea.Child_1_Date_of_Birth__c = Date.parse(Child1Bday);
        if(Child2Bday!='')lea.Child_2_Date_of_Birth__c = Date.parse(Child2Bday);
        if(Child3Bday!='')lea.Child_3_Date_of_Birth__c = Date.parse(Child3Bday);
        if(Child4Bday!='')lea.Child_4_Date_of_Birth__c = Date.parse(Child4Bday);
        if(Child5Bday!='')lea.Child_5_Date_of_Birth__c = Date.parse(Child5Bday);
        if(Child6Bday!='')lea.Child_6_Date_of_Birth__c = Date.parse(Child6Bday);
        if(MemberABday!='')lea.Associate_Member_Date_of_Birth__c = Date.parse(MemberABday);
        List<String> msections = new List<String>();
        for (sectionSelectWrapper s:sections){
            if(s.selected)msections.add(s.s.name);
        }
        lea.sections__c= string.join(msections,':');
        system.debug(lea);
        system.debug(promoCodeValidated);
        system.debug(lea.LeadStep__c);
        system.debug(lea.Max_LeadStep__c);
        system.debug(lea.LeadStep__c>lea.Max_LeadStep__c);
        lea.leadstep__c = wizardStep;
        system.debug(lea.LeadStep__c);
        system.debug(lea.Max_LeadStep__c);
        system.debug(lea.LeadStep__c>lea.Max_LeadStep__c);
        if(lea.LeadStep__c>lea.Max_LeadStep__c){
            lea.Max_LeadStep__c=lea.LeadStep__c;
        }
        
        
        if(lea.Membership_Code__c != null){
            try{
                Club_Product__c cp = [SELECT id, Max_Age_for_Membership__c, Min_Age_for_Membership__c FROM Club_Product__c WHERE Name = :lea.Membership_Code__c];
                minMembershipAge = String.valueOf(cp.Min_Age_for_Membership__c);
                maxMembershipAge = String.valueOf(cp.Max_Age_for_Membership__c);
            } catch (Exception e){
                
            }
        }
        upsert lea;
        system.debug(lea);
    }

    Map<string,club_product__c> mapPrices{
        get{
            if(mapPrices==null){
                mapPrices=new Map<string,club_product__c>();
                Date now = Date.today();
                List<Club_Product__c> pList = [select id,name,Product_Detail__c,(select Price__c from Prices__r where Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null) order by Start_Date__c) from club_product__c where recordtype.name='Associate Membership' order by name];
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
    
    public Decimal costTotal{
        get{
            costtotal=0;
            if(mtCost!=null && !promoCodeValidated)costTotal+=mtCost;
            if(joinCost != null && lea.Joining_Fee_Waived__c == false)costTotal += joinCost;
            if(lea.hasAssociate__c)costTotal+=mapPrices.get('Associate Member').prices__r[0].Price__c;
            for(sectionSelectWrapper s:sections){
                if(s.selected && !(dealercode.valid_show__c && dealercode.Show_Start_Date__c <= date.today() && dealercode.Show_End_Date__c >= date.today()))costTotal+=s.price;
            }
            //if(mtCost==null)costTotal=null;
            return costTotal;
        }
        set;
    }

    public Decimal amCost{
        get{
            Decimal d;
            if(lea.hasAssociate__c){
                d=mapPrices.get('Associate Member').prices__r[0].Price__c;
            }
            return d;
        }
        set;
    }    
    

    public List<sectionSelectWrapper> sections {
        get{
            if(sections==null){
                sections = new List<sectionSelectWrapper>();
                Date now = Date.today();
                for(club_product__c s:[select id,name,Product_Detail__c,Product_Description__c,(select Price__c from Prices__r where Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null) order by Start_Date__c) from club_product__c where recordtype.name='Section' order by name]){
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

    public String searchTerm {get; set;}
    public String selectedMovie {get; set;}
    public boolean promoCodeValidated{get; set;}

    public Promotional_Code__c promoCode{
        get{
            try{
                promoCode = [SELECT id, name,Description__c,Expiry_Date__c, Number_Allowed__c, Number_of_Valid_Codes__c, Number_Used__c, Valid_From__c, 
                            Valid_for_Memberships__c FROM Promotional_Code__c
                            WHERE Name = :lea.Voucher_Code__c];
            }
            catch (Exception ex){
                promoCode = new Promotional_Code__c();
            }
            return promoCode;
        }
        set;
    }

    public void promoValidation(){
        promoCodeValidated = false;
        Set<String> selectedValues = new Set<string>();
        if(promoCode.Valid_for_Memberships__c != null ){
            selectedValues.addAll(promoCode.Valid_for_Memberships__c.split(';'));
        } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a valid Promo Code value'));          
        }
        system.debug(promoCode.Id+' promoCode');
        if(promoCode.Id == null && (lea.Voucher_Code__c != '' || lea.Voucher_Code__c != null)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Promo code does not exist'));      
        }
        if(lea.Voucher_Code__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a valid Promo Code'));    
        }
        if(promoCode != null && lea.Voucher_Code__c != null){
            if(system.today() >= promoCode.Valid_From__c || promoCode.Valid_From__c == null){
            system.debug(system.today() + ' ' + promoCode.Expiry_Date__c);
                if(system.today() <= promoCode.Expiry_Date__c || promoCode.Expiry_Date__c == null){
                    if(promoCode.Number_of_Valid_Codes__c > 0){
                        if(selectedValues.contains(lea.Membership_Code__c)){
                            promoCodeValidated = true;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Promo code validated successfully.'));
                        }
                        else{
                            promoCodeValidated = false;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,promoCode.Name+' Promo code is not vaild for '+lea.Membership_Code__c + ' type of membership'));
                        }
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Number of valid codes is 0.'));
                    }
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Expiry date on this Promo code is not valid'));
                }
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Promo code is only valid from ' + promoCode.Valid_From__c));
            }
        }
    }

    public void changePromoCode(){
        promoCodeValidated = false;
    }

@RemoteAction
    public static List<Account> searchMemberNumber(String searchTerm) {
        List<Account> accs = Database.query('Select Id, Name, Hybrid_Membership_Number__c, NumHybrid_Membership_Number__c from Account where  Hybrid_Membership_Number__c like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' and Membership_Status__c!=\'Cancelled\' and Membership_Status__c!=\'Ex-Member\' and Membership_Status__c!=\'Lapsed\' and Membership_Status__c!=\'Refer to Manager\' order by NumHybrid_Membership_Number__c ASC LIMIT 50');
        system.debug(accs);
        return accs;
    }
 
@RemoteAction
    public static List<Dealer_Advert__c> searchDealers(String searchTerm) {
        List<Dealer_Advert__c> accs = Database.query('Select Id, Name from Dealer_Advert__c where  ((active__c = TRUE AND Valid_show__c=false) OR (active__c = TRUE AND Valid_show__c=true and Show_Start_Date__c <=today and Show_End_Date__c >= today)) and Name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' order by Name LIMIT 50');
        system.debug(accs);
        return accs;
    }
 
}