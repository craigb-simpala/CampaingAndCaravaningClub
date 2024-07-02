public with sharing class ChangeRenewalController {
    public apexpages.standardController controller {get; set;}

    public Integer wizardStep {get;set;}
    public Lead lea {get;set;}
    public Account acc {get;set;}
    public Opportunity  opp {get;set;}
    public constants sc = new constants();
    
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
                    cPrimaryMember = [select title,firstname,lastname,birthdate,email from Contact where accountid=:acc.id and recordtypeid=:sc.leadContactRecordTypeId limit 1];
                }
                catch (Exception e){
                    cPrimaryMember=new Contact();
                }
            }
            return cPrimaryMember;
        }
        set;
    }

    public Contact cSecondaryMember {
        get{
            if(cSecondaryMember==null){
                try{
                    cSecondaryMember = [select title,firstname,lastname,birthdate,email from Contact where accountid=:acc.id and recordtypeid=:sc.secondaryContactRecordTypeId limit 1];
                }
                catch (Exception e){
                    cSecondaryMember=new Contact();
                }
            }
            return cSecondaryMember;
        }
        set;
    }

    public List<Club_Opportunity_Product__c> cop {
        get{
            if(cop==null){
                cop = [select id,product__r.Product_Detail__c,product__r.name from Club_Opportunity_Product__c 
                        where account__c = :this.acc.id
                        and Opportunity__c = :this.opp.id 
                        and Status__c='Pending'
                        and recordtypeid = :sc.sectionRecordTypeId];
            }
            return cop;
        }
        set;
    }

    public List<Club_Opportunity_Product__c> oppli {
        get{
            if(oppli==null){
                oppli = [select id,product__r.Product_Detail__c,product__r.name,price__c,RecordTypeId from Club_Opportunity_Product__c 
                        where account__c = :this.acc.id
                        and Opportunity__c = :this.opp.id 
                        and Status__c='Pending'];
            }
            return oppli;
        }
        set;
    }

    public List<SelectOption> membershipTypeOptions{
        get{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--None--'));
            for(Club_Product__c p :mtList){
                List<price__c> pr = p.prices__r;
                if(pr.size()>0){
                    //sections.add(new sectionSelectWrapper(s,s.prices__r[0].price__c));
                    options.add(new SelectOption((String)p.get('Name'), (String)p.get('Product_Detail__c')+' £'+String.valueof(pr[0].get('price__c'))));
                }
            }        
            return options;
        }
        set;
    }
    
    public Decimal mtCost{
        get{
            system.debug('mtCost Calculation');
            system.debug('lea.MembershipCode: ' + lea.Membership_Code__c);
            system.debug('acc.Payment_Method2__c: ' + acc.Payment_Method2__c);
            Decimal d=0;
            for(Club_Product__c m:mtList){
            	system.debug(m);
            	system.debug(m.Prices__r);
                if(m.Name == lea.Membership_Code__c){
                	for(Price__c p : m.Prices__r){
                		system.debug(p.Payment_Type__c);
                		system.debug(lea.Payment_Method__c);
                        system.debug('p.Price__c: ' + p.Price__c);
                		if((p.Payment_type__c == acc.Payment_Method2__c) && p.start_Date__c <= opp.Renewal_Date__c && (p.End_Date__c >= opp.Renewal_Date__c || p.End_date__c == null)){
                			d+=p.Price__c;
                            System.debug('Final Value of d = ' + d);
                			break;
                		}
                	}
                }
            }
            return d;
        }
        set;
    }    
    
    public List<Club_Product__c> mtList{
        get{
            if(mtList==null){
            	Date now = Date.today();
            	mtList = [select id,name, Associate_Allowed__c, SectionsAreFree__c, Product_Detail__c, Allowed_Payment_Types__c, (select Price__c, payment_type__c, Start_Date__c, End_date__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: this.opp.Renewal_Date__c and (End_Date__c>=:this.opp.Renewal_Date__c or End_Date__c=null)) order by Start_Date__c DESC) from club_product__c where recordtype.name='Membership Code' and Show_in_New_Membership_Picklist__c=true order by name];
            	
            	/*List<Club_Product_Change__c> cpcl = [select id,from__c,to__c from Club_Product_Change__c where from__c = :acc.Membership_Code__c];
                Set<id> prodids = new Set<id>();
                for(Club_Product_Change__c cpc:cpcl){
                    prodids.add(cpc.to__c);
                }
                mtList = [select id,name, Associate_Allowed__c, SectionsAreFree__c, Product_Detail__c, Allowed_Payment_Types__c, (select Price__c, payment_type__c, Start_Date__c, End_date__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: this.opp.Renewal_Date__c and (End_Date__c>=:this.opp.Renewal_Date__c or End_Date__c=null)) order by Start_Date__c DESC) from club_product__c where recordtype.name='Membership Code' and id in :prodids order by name];
                */
                system.debug(mtList);
                                
                //mtList = [select Name,Product_Detail__c from Club_Product__c where Active__c=true and Show_in_Picklist__c=true order by name];
            }
            return mtList;                
        }
        set;
    }

    public List<Club_Product__c> pList{
        get{
            if(pList==null){
                Date now = Date.today();
                pList = [select id,name,Product_Detail__c,(select Price__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: this.opp.Renewal_Date__c and (End_Date__c>=:this.opp.Renewal_Date__c or End_Date__c=null)) order by Start_Date__c DESC) from club_product__c where recordtype.name='Associate Membership' order by name];
				system.debug(pList);                
                //mtList = [select Name,Product_Detail__c from Club_Product__c where Active__c=true and Show_in_Picklist__c=true order by name];
            }
            return pList;                
        }
        set;
    }


    public String MemberABday{get{if(MemberABday==null)MemberABday='';return MemberABday;}set;}   

    public ChangeRenewalController(apexpages.standardController controller) {
        wizardStep = 1; 
        this.controller = controller;
        this.lea = new Lead();
        
        List<String> accfields = new list<String>();

        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
        for(String s : objectFields.keySet()) {
            accfields.add(s);
            //system.debug(s);
        }
        accfields.add('account.Membership_Code__r.name');
        if(!test.isRunningTest()) 
            controller.addFields(accfields);

        this.opp = (Opportunity) controller.getRecord();
        
        if(this.opp.isclosed || this.opp.recordtypeid!=sc.OppRenewalRecordTypeId){
            wizardstep=0;
        }

        objectFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        String query = 'SELECT';
        for(String s : objectFields.keySet()) {
            query += ' ' + s + ',';
        }
        query += ' Membership_Code__r.name ';
        query += ' FROM Account where id=\''+this.opp.accountid+'\'';

        system.debug(query);

        acc = database.query(query);


        lea.LastName = this.acc.id;
        lea.Status = 'Open';
        lea.Company = this.acc.id;
        lea.Email = cPrimaryMember.Email;
        lea.Membership_Code__c = this.acc.Membership_Code__r.name;
        if(lea.Associate_Member_Date_of_Birth__c!=null)MemberABday = lea.Associate_Member_Date_of_Birth__c.format();
        List<String> omsections = new List<String>();
        for (Club_Opportunity_Product__c s:cop){
            omsections.add(s.product__r.name);
        }
        lea.sections__c= string.join(omsections,':');
        if(lea.sections__c!=null ){
            List<String> msections = lea.sections__c.split(':',-2);
            Set<String> ssections = new Set<String>();
            ssections.addall(msections);
    		
            for (sectionSelectWrapper s:sections){
                if(ssections.contains(s.s.name))s.selected=true;
            }
            system.debug(sections);
        }
    }

    public PageReference step1 () {
        wizardStep = 1;
        return null;
    }
    
    public PageReference step2 () {
        if(lea.Membership_Code__c==null){
            lea.Membership_Code__c.addError('Please Select a Membership type'); 
        }
        else{
        	if(associateAllowed){
            	wizardStep = 2;
        	}
        	else{
        		wizardStep = 3;
        	}
        }
        return null;
    }

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
            wizardStep = 3;
        }
        system.debug(lea);
        return null;
    }

    public PageReference step4 () {
        wizardStep = 4;
        system.debug ('CostTotal' + costTotal);
        return null;
    }

    public Decimal amCost{
        get{
            Decimal d;
            for(Club_Opportunity_Product__c c:oppli){
                if(c.recordtypeid == sc.amRecordTypeId)
                    d=c.price__c;
            }
            if(cAssocMember.id!=null){
                if(lea.hasPartner__c)
                    d=null;
            }
            else{
                if(lea.hasAssociate__c && d==null)d=mapPrices.get('Associate Member').prices__r[0].Price__c;
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
                for(club_product__c s:[select id,name,Product_Detail__c,(select Price__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: this.opp.Renewal_Date__c and (End_Date__c>=:this.opp.Renewal_Date__c or End_Date__c=null)) order by Start_Date__c DESC) from club_product__c where recordtype.name='Section' order by name]){
                    List<price__c> pr = s.prices__r;                    
                    if(pr.size()>0){
                        Decimal sprice = s.prices__r[0].price__c;
                        for(Club_Product__c mt: mtList){                        
                            if((acc.FreeSections__c == true || mt.SectionsAreFree__c == true) && lea.Membership_Code__c == mt.Name){
                                sprice = 0.00;
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

    private void upslead(){
        //if(lea.Associate_Member_First_Name__c!=null)lea.Associate_Member_First_Name__c=Utils.toProperCase(lea.Associate_Member_First_Name__c);
        //if(lea.Associate_Member_Surname__c!=null)lea.Associate_Member_Surname__c=Utils.toProperCase(lea.Associate_Member_Surname__c);
        if(MemberABday!='')lea.Associate_Member_Date_of_Birth__c = Date.parse(MemberABday);
        List<String> msections = new List<String>();
        for (sectionSelectWrapper s:sections){
            if(s.selected)msections.add(s.s.name);
        }
        lea.sections__c= string.join(msections,':');
        lea.leadstep__c = wizardStep;
        system.debug(lea);
        upsert lea;
    }
    
    public Decimal costTotal{
        get{
            costtotal=0;
            if(mtCost!=null)costTotal+=mtCost;
            if(amCost!=null)costTotal+=amCost;
            for(sectionSelectWrapper s:sections){
                if(s.selected)costTotal+=s.price;
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
                List<Club_Product__c> pList = [select id,name,Product_Detail__c,(select Price__c,change_fee__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: this.opp.Renewal_Date__c and (End_Date__c>=:this.opp.Renewal_Date__c or End_Date__c=null)) order by Start_Date__c DESC) from club_product__c where recordtype.name='Associate Membership' order by name];
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
        if(MemberABday!='')lea.Associate_Member_Date_of_Birth__c = Date.parse(MemberABday);    
        system.debug(lea);
        system.debug(costTotal);
        system.debug(mtCost);
        opp.Amount = costTotal;
        update opp;
        List<Club_Opportunity_Product__c> coptoadd = new List<Club_Opportunity_Product__c>();
        List<Club_Opportunity_Product__c> coptoupd = new List<Club_Opportunity_Product__c>();
        List<Club_Opportunity_Product__c> coptodel = new List<Club_Opportunity_Product__c>();
        List<Member_Section__c> ms = new List<Member_Section__c>();

        if(lea.hasPartner__c && cAssocMember.id!=null){
            cAssocMember.Date_Ended__c = opp.CloseDate;
            update cAssocMember;
            for(Club_Opportunity_Product__c c: oppli){
                if(c.recordtypeid == sc.amRecordTypeId){
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
                                    Birthdate = lea.Associate_Member_Date_of_Birth__c);
            insert assocContact;
        }
        else if(lea.hasAssociate__c && cAssocMember.id==null){
            Contact assocContact = new Contact(recordtypeid=sc.associateContactRecordTypeId,
                                    Accountid = acc.Id,
                                    Date_Joined__c = opp.CloseDate,
                                    firstname=lea.Associate_Member_First_Name__c,
                                    lastname=lea.Associate_Member_Surname__c,
                                    Salutation = lea.Associate_Member_Title__c,
                                    Birthdate = lea.Associate_Member_Date_of_Birth__c);
            insert assocContact;
            coptoadd.add(new Club_Opportunity_Product__c(Product__c = plist[0].id,recordtypeid = sc.amRecordTypeId,  opportunity__c = opp.id, price__c = amcost, account__c = acc.id,status__c = 'Pending' ));
        }

        for(sectionSelectWrapper s : sections){
            if(s.selected){
                Boolean found = false;
                for(Club_Opportunity_Product__c c : oppli){
                    if(s.s.Id == c.Product__c){
                    	found=true;
	                    if(s.price != c.Price__c){
	                    	c.price__c = s.price;
	                    	coptoupd.add(c);
	                    }
                    }
                }
                if(!found){
                    coptoadd.add(new Club_Opportunity_Product__c(recordtypeid = sc.sectionRecordTypeId, product__c = s.s.id, opportunity__c = opp.id, price__c = s.price, account__c = acc.id,status__c = 'Pending' ));
                }
            }
            else{
                for(Club_Opportunity_Product__c c : oppli){
                    if(s.s.Id == c.Product__c){
                        coptodel.add(c);
                        break;
                    }
                }
            }
        }
		system.debug(mtList);
        //if(lea.Membership_Code__c != acc.Membership_Type_Name__c){
            for(Club_Opportunity_Product__c c: oppli){
                if(c.recordtypeid == sc.mtRecordTypeId){
                    for(Club_Product__c m:mtList){
                    	system.debug(m.name);
                    	system.debug(lea.Membership_Code__c);
                        if(m.Name == lea.Membership_Code__c){
                            Club_Opportunity_Product__c ctu = c;
                            ctu.Product__c = m.id;                           
                            ctu.Price__c = pickCorrectPrice(m.prices__r, opp.Renewal_Date__c, opp.Renewal_Date__c);
                            //acc.Membership_Code__c = m.id;
                            coptoupd.add(ctu);
                            break;
                        }
                    }
                }
            }
        //} 
        system.debug(coptoupd);      
        if(coptoupd.size()>0){
            update coptoupd;
            //update acc;
        }
 		system.debug(coptoadd);
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
        return new PageReference('/'+this.opp.id);
    }
    
	private decimal pickCorrectPrice(List<Price__c> prices, Date startDate, Date endDate){
		for(Price__c p:prices){
			if(p.start_Date__c <= startDate && (p.End_Date__c >= endDate || p.End_date__c == null)){
				return p.price__c;
			}
		}
		return 0;	
	}

}