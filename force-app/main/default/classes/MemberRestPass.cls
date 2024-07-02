@RestResource(urlMapping='/MembershipWithPassword/*')
global class  MemberRestPass {

        global class Error{
            global integer id;
            global String Message;
        }

        global class Result{
            global String status;
            global List<Error> Errors;
            global Membership membership;
        }
        
        global class VoluntaryOffice{
            global String voType;
            global String unitCode;
            global String officeName;
        }

        global virtual class Address{
            global String Organisation;
            global String Line1;
            global String Line2;
            global String Line3;
            global String Line4;
            global String Line5;
            global String PostTown;
            global String County;
            global String Country;
            global String PostCodeOut;
            global String PostCodeIn;
        }
        
        global virtual class Member{ 
            global String Id;
            global String Title;
            global String FirstName;
            global String LastName;
            global Date BirthDate;
        }
        
        global virtual class SecondaryMember extends Member {
            global String mobileNumber;
            global String Email;
            global Decimal Tenure;
            global boolean onlineAccount;
            global String WebsitePassword;
            global Integer WebsitePasswordStatus;
            global Boolean ageConcession;
            global List<VoluntaryOffice> VoluntaryOffice;
        }

        global class PrimaryMember extends SecondaryMember {
            global String phoneNumber;
            global List<MemberSection> memberSections;

        }
            
        global class CampingUnit{
            global String   UnitType;
            global Decimal  UnitLength;     
            global Decimal  UnitWidth;      
            global Decimal  UnitHeight;     
        }
    
    	global class MemberSection{
            global String productName;
            global Decimal price;
            global String status;
            global String AS400ID;
            global String membershipNumber;
            global String membershipSectionId;
            global string ClubOpportunityProduct;
            
            
    	}
            
        global class Membership {
            String MembershipName;
            String MembershipType;
            String MembershipStatus;
            String DA;
            Decimal tenure;
            Decimal BasicFee;
            String EmailStop;
            String PromMailStop;
            String OverseasMembership;
            Date renewalDate;
            String renewalId;
            Address MemberAddress;
            PrimaryMember PrimaryMember;
            SecondaryMember SecondaryMember;
            Member associateMember;
            CampingUnit CampingUnit;
            List<Member> ChildMember;
            List<Section> Section;
        }
        
        global class Section {
            String code;
            Decimal price;
        }

    
    @HttpGet
    global static Result getMemberDetails(){
        System.debug('here');
        Constants sc = new Constants();

        RestRequest req = RestContext.request;
//      String memberId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        system.debug(RestContext.request.params);
        String email = RestContext.request.params.get('email');
        system.debug(email);
        String memberid = RestContext.request.params.get('MembershipNumber');
        system.debug(memberid);
        Account a;
        List<Error> errors = new List<Error>();
        Result res = new Result();
        if(memberid!='' && memberid!=null){ 
            
        }
        else{
            res.status = '00100';
            Error e = new Error();
            e.id=1;
            e.Message='No Membership Number provided';
            Errors.add(e);
        }   

        if(memberId !=null){
            try{
                a = [SELECT id,
                            name,
                            Organisation_Name__c,
                            Membership_Code__r.name,
                            Membership_Status__c,
                            billingstreet,
                            BillingState,
                            BillingPostalCode,
                            BillingCountry,
                            BillingCity,
                            renewal_date__c,
                            Promotional_Mailstop__c,
                            Email_Stop__c,
                            Overseas_Membership__c,
                            Camping_Unit__c,
                            Camping_Unit_Height__c,
                            Camping_Unit_Length__c,
                            Camping_Unit_Width__c,
                       		//Added the following 2 lines to pass the DA and Tenure
                            District_Association__r.Name,
                            Tenure2__c,
                            (select id,
                                    salutation,
                                    Firstname,
                                    lastname,
                                    Birthdate,
                                    email,
                                    phone,
                                    Tenure2__c,
                                    MobilePhone,
                                    Website_Password__c,
                                    Website_Password_Status__c,
                                    online_account_created__c,
                                    recordtype.name,
                                    Age_Concession__c
                                    from Contacts
                                    where Date_Ended__c=null),
                            (select Name,
                                    Product_Name__c,
                                    Product__r.name,
                                    Price__c,
                                    recordtype.name
                                    from Club_Opportunity_Products__r
                                    where status__c='Active')   
                            FROM Account WHERE Hybrid_Membership_Number__c =:memberId LIMIT 1];
            }
            catch(Exception ex)
            {
                //Throw new MemberException(MEMBER_NOT_FOUND);
                res.status = '00100';
                Error e = new Error();
                e.id=1;
                e.Message='Member not Found';
                Errors.add(e);
            }
        }
        if(a!=Null){
            Opportunity opp = new Opportunity();
            try{
                opp = [select id,name,closedate,(select id,price__c,product__c,product__r.name,recordtypeid from Line_Items__r) from Opportunity where accountid =:a.id and recordtypeid= :sc.OppRenewalRecordTypeId and isclosed=false and iswon=false];
            }
            catch(Exception ex)
            {}
            
            res.status='00000';
            Membership m = new Membership();
            Address addr = new Address();
            CampingUnit cu = new CampingUnit();
            PrimaryMember pm = new PrimaryMember();
            SecondaryMember sm;
            Member am;
            List<Member> children = new List<Member>();
            List<Section> sections = new List<Section>();

            m.renewalId = opp.id;
            m.renewalDate = a.renewal_date__c;
            m.PromMailStop = (a.Promotional_Mailstop__c?'Y':'N');
            m.EmailStop = (a.Email_Stop__c?'Y':'N');
            m.OverseasMembership = (a.Overseas_Membership__c?'Y':'N');
            m.MembershipName = a.name;
            m.MembershipType = a.Membership_Code__r.name;
            m.MembershipStatus = a.Membership_Status__c;
            //Added the following 2 lines to pass the DA and Tenure
            m.DA = a.District_Association__r.Name;
            m.tenure = a.Tenure2__c;
            
            cu.UnitType = a.Camping_Unit__c;
            cu.UnitLength = a.Camping_Unit_Length__c;
            cu.UnitWidth = a.Camping_Unit_Width__c;
            cu.UnitHeight = a.Camping_Unit_Height__c;

            Set<id> conids = new Set<Id>();
            for(Contact c:a.contacts){
                conids.add(c.id);
            }

            List<Voluntary_Office__c> voList = [select id,Member__c,Voluntary_Office_Title__c,Association__r.Name,Association__r.Association_Code__c from Voluntary_Office__c where Member__c in :conids];
            system.debug(conids);
            system.debug('volunterary offices' +voList);
            Map<id,List<Voluntary_Office__c>> convoMap = new Map<id,List<Voluntary_Office__c>>();

            for(Voluntary_Office__c vo:voList){
                if(convoMap.containskey(vo.member__c)){
                    convoMap.get(vo.member__c).add(vo); 
                }
                else{
                    List<Voluntary_Office__c> vol = new List<Voluntary_Office__c>();
                    vol.add(vo);
                    convoMap.put(vo.member__c,vol);
                }
                
            }
			system.debug(convoMap);
            List<Member_Section__c> memberSections = [select id,Status__c,Member__c, AS400_ID__c ,Club_Opportunity_Product__c , Name ,Membership_Number__c, Price__c ,Product_Name__c  from Member_Section__c where Member__c in :conids];
            system.debug(memberSections);
            Map<id,List<Member_Section__c>> memSecMap  = new  Map<id,List<Member_Section__c>>();
            for(Member_Section__c memSec : memberSections ){
                if(memSec.Status__c == 'Active'){
                    if(memSecMap.containskey(memSec.member__c)){
                    	memSecMap.get(memSec.member__c).add(memSec); 
                	}
                	else{
                    	List<Member_Section__c> memSecs = new List<Member_Section__c>();
                    	memSecs.add(memSec);
                    	memSecMap.put(memSec.member__c,memSecs);
                	}
                }
                
            }
			system.debug(memSecMap);

                        
            for(Contact c:a.contacts){
                System.debug('contact: ' + c);
                System.debug('Website_Password_Status: ' + c.Website_Password_Status__c);
                System.debug('Website_Password__c: ' + c.Website_Password__c);
                if(c.recordtype.name == 'Lead'){
                    System.debug('***MARTIN - MemberRestPass class and getMemberDetails - contact Account is: '+ c.FirstName + ' ' + c.LastName);
                    pm.Id = c.id;
                    pm.Email = c.Email;
                    pm.mobileNumber = c.MobilePhone;
                    pm.phoneNumber = c.phone;
                    pm.Title = c.salutation;
                    pm.FirstName = c.FirstName;
                    pm.LastName = c.LastName;
                    pm.BirthDate = c.Birthdate;
                    pm.ageConcession = c.Age_Concession__c;
                    pm.WebsitePasswordStatus = Integer.valueof(c.Website_Password_Status__c);
                    pm.WebsitePassword = c.Website_Password__c;
                    pm.onlineAccount = true;
                    if(convoMap.containsKey(c.id)){
                        List<VoluntaryOffice> tvoList = new List<VoluntaryOffice>();
                        for(Voluntary_Office__c vo:convoMap.get(c.id)){
                            VoluntaryOffice v =new VoluntaryOffice();
                            v.voType = vo.Voluntary_Office_Title__c;
                            v.officeName = vo.Association__r.Name;
                            v.unitCode = vo.Association__r.Association_Code__c;
                            tvoList.add(v);
                        }                       
                        pm.VoluntaryOffice = tvoList;                       
                    }
                    if(memSecMap.containsKey(c.id)){
                        List<MemberSection> memberSectionsList = new List<MemberSection>();
                        for(Member_Section__c memberSection : memSecMap.get(c.Id)){
                           
                            MemberSection memberSec = new MemberSection();
                            memberSec.productName = memberSection.Product_Name__c;
            				memberSec.price = memberSection.Price__c;
            				memberSec.status = memberSection.Status__c;
            			    memberSec.AS400ID = memberSection.AS400_ID__c;
            				memberSec.membershipNumber = memberSection.Membership_Number__c;
            				memberSec.membershipSectionId = memberSection.Name;
            				memberSec.ClubOpportunityProduct = memberSection.Club_Opportunity_Product__c;
                            memberSectionsList.add(memberSec);
                        }
						pm.memberSections = memberSectionsList;

                    }
                }
                if(c.recordtype.name == 'Secondary'){
                    sm = new SecondaryMember();
                    sm.Id = c.id;
                    sm.Email = c.Email;
                    sm.tenure = c.Tenure2__c;
                    sm.mobileNumber = c.MobilePhone;
                    sm.Title = c.salutation;
                    sm.FirstName = c.FirstName;
                    sm.LastName = c.LastName;
                    sm.BirthDate = c.Birthdate;
                    sm.onlineAccount = true;
                    sm.WebsitePasswordStatus = integer.valueof(c.Website_Password_Status__c);
                    sm.WebsitePassword = c.Website_Password__c;
                    sm.ageConcession = c.Age_Concession__c;
                    if(convoMap.containsKey(c.id)){
                        List<VoluntaryOffice> tvoList = new List<VoluntaryOffice>();                        
                        for(Voluntary_Office__c vo:convoMap.get(c.id)){
                            VoluntaryOffice v =new VoluntaryOffice();
                            v.voType = vo.Voluntary_Office_Title__c;
                            v.officeName = vo.Association__r.Name;
                            v.unitCode = vo.Association__r.Association_Code__c;
                            tvoList.add(v);
                        }
                        sm.VoluntaryOffice = tvoList;                       
                    }
                }
                if(c.recordtype.name == 'Associate'){
                    am = new Member();
                    am.Id = c.id;
                    am.Title = c.salutation;
                    am.FirstName = c.FirstName;
                    am.LastName = c.LastName;
                    am.BirthDate = c.Birthdate;
                }
                if(c.recordtype.name == 'Child'){
                    Member cm = new Member();
                    cm.Id = c.id;
                    cm.Title = c.salutation;
                    cm.FirstName = c.FirstName;
                    cm.LastName = c.LastName;
                    cm.BirthDate = c.Birthdate;
                    children.add(cm);
                }
            }
            for(Club_Opportunity_Product__c c:a.Club_Opportunity_Products__r){
                if(c.recordtype.name == 'Membership Code'){
                    m.BasicFee = c.Price__c;
                }
                else{
                    Section s = new Section();
                    s.code=c.Product__r.name;
                    s.price = c.Price__c;
                    sections.add(s);            
                }
            }
            
            List<String> streetA;

            if(a.BillingStreet!=null){
    
                streetA = a.BillingStreet.split('[\n\r]');
    
                for (Integer i = 0; i < streetA.size(); i++) {
                    if (streetA.get(i).equals('')) {
                        streetA.remove(i);
                        i--; //Decrement counter since we removed an empty item from the list
                    }
                }
                if (streetA.size() > 0)addr.line1 = streetA[0];
                if (streetA.size() > 1)addr.line2 = streetA[1];
                if (streetA.size() > 2)addr.line3 = streetA[2];
                if (streetA.size() > 3)addr.line4 = streetA[3];
                if (streetA.size() > 4)addr.line5 = streetA[4];
            }
                


            addr.Organisation = a.Organisation_Name__c;
            addr.County = a.BillingState;
            addr.Country = a.BillingCountry;
            addr.PostTown = a.BillingCity;
            if(a.BillingPostalCode!=null){
                if(a.BillingPostalCode.contains(' ')){
                    addr.PostCodeOut = a.BillingPostalCode.substringbefore(' '); 
                    addr.PostCodeIn = a.BillingPostalCode.substringafter(' ');
                }
                else{
                    addr.PostCodeOut=a.BillingPostalCode;
                } 
            }
            m.memberaddress = addr;
            System.debug('pm: ' + pm.onlineAccount);
            m.PrimaryMember = pm;
            if(sm!=null)m.SecondaryMember = sm;
            if(am!=null)m.associateMember = am;
            if(children.size()>0)m.ChildMember = children;
            if(sections.size()>0)m.Section = sections;
            m.CampingUnit=cu; 
            res.membership= m;
            System.debug('res.membership.PrimaryMember.onlineAccount: ' + res.membership.PrimaryMember.onlineAccount);
            res.membership.PrimaryMember.onlineAccount = true;
        }
        res.Errors = Errors;

        System.debug('res: ' + res);
        return res;     
    }
}