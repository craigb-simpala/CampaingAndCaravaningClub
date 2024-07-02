public with sharing class PaymentSuccessController {

    public Lead lea {get;set;}
    public String ref {get;set;}
    public String tokenid {get;set;}
    public String acode {get;set;}
    public String result {get;set;}
    public Boolean skipDDpay {get;set;}
    public Account globalAcc;
    static Long days7Milliseconds = 604800000;  
	private Date week8date;
    public constants sc = new constants();

    public  PaymentSuccessController(){
        skipDDpay=false;
        if(ApexPages.currentPage()!=null){
            system.debug(ApexPages.currentPage().getParameters());
            system.debug(ApexPages.currentPage().getParameters().get('ref'));
            system.debug(ApexPages.currentPage().getParameters().get('result'));
            ref = ApexPages.currentPage().getParameters().get('ref');
            tokenid = ApexPages.currentPage().getParameters().get('tokenid');
            acode = ApexPages.currentPage().getParameters().get('acode');
            result = ApexPages.currentPage().getParameters().get('result');
        }
    }

    public pagereference ConvertLead(){
        System.debug('converting');
        System.debug('converting ' + tokenid);
        Opportunity newOpp;
        String basequery = 'SELECT';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap();
        for(String s : objectFields.keySet()) {
            basequery += ' ' + s + ',';
        }
        basequery = basequery.subString(0,basequery.Length()-1);
        basequery += ' from lead where id = :ref';
        lea = database.query(basequery);
        system.debug(lea);

        Account a;
        try{
            a = [select id,Membership_Status__c,Payment_Method2__c from Account where id=:lea.Company];
        }
        catch(exception e){
            a=new Account();
        }
        
        Opportunity o;
        try{
            o = [select id,name,closedate,accountid,(select id,price__c,product__c,recordtypeid from Line_Items__r) from Opportunity where id=:lea.Company and recordtypeid= :sc.OppRenewalRecordTypeId and isclosed=false and iswon=false];
        }
        catch(exception e){
            o=new Opportunity();
        }

        system.debug(a);
        system.debug(o);        
        if(result=='CANCELLED')
        {
            if(a.id!=null){
                if(a.Membership_Status__c=='Cancelled'){
                    return new PageReference('/apex/ReinstateMembership?id='+a.id);
                }
                else{
                    return new PageReference('/apex/ChangeMembership?id='+a.id);
                }
            }
            if(o.id!=null){
                return new PageReference('/apex/RenewMembership?id='+o.accountid);
            }
            return new PageReference('/'+ref+'/e');
        }
        if(result=='FAILED')
        {
            if(a.id!=null){
                if(a.Membership_Status__c=='Cancelled'){
                    return new PageReference('/apex/ReinstateMembership?id='+a.id);
                }
                else{
                    return new PageReference('/apex/ChangeMembership?id='+a.id);
                }
            }
            if(o.id!=null){
                return new PageReference('/apex/RenewMembership?id='+o.accountid);
            }
            return new PageReference('/'+ref+'/e');
        }
        
        if(a.id!=null)
        {
            objectFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
            String query = 'SELECT';
            for(String s : objectFields.keySet()) {
                query += ' ' + s + ',';
            }
            query += ' Membership_Code__r.name ';
            query += ' FROM Account where id=\''+a.id+'\'';
    
            Account acc = database.query(query);
            globalAcc = acc;
            if(acc.Membership_Status__c=='Cancelled' || a.Membership_Status__c=='Ex-Member'){
                system.debug('cancellation');
                acc.Membership_Status__c = 'Paid';

                List<Club_Opportunity_Product__c> coptoadd = new List<Club_Opportunity_Product__c>();
                List<Club_Opportunity_Product__c> rencoptoadd = new List<Club_Opportunity_Product__c>();
                Decimal costTotal=0;
                Decimal rencostTotal=0;

                List<Club_Opportunity_Product__c> cop = [select id,account__c,price__c,product__c,product__r.Product_Detail__c,product__r.name,(select id,name,Member__c from Members_Sections__r) from Club_Opportunity_Product__c 
                                                        where account__c = :acc.id
                                                        and Status__c='Cancelled'
                                                        and recordtypeid=:sc.mtRecordTypeId]; // previous line added to restrict reinstatements to membership only
                system.debug(cop);
                List<Cancellation__c> cancs = [select id,cancellation_date__c from Cancellation__c where Membership__c = :acc.id order by createddate desc limit 1];

                Integer costMultiplier=0;
                //Date sd = acc.date_joined__c;
                Date sd = acc.renewal_date__c;

/* remowved to use calc for each years payment
                while(sd<cancs[0].cancellation_date__c){
                    sd=sd.addmonths(12);
                } 
                
                system.debug(sd);
                
                while(sd<date.today()){
                    sd=sd.addmonths(12);
                    system.debug(sd);
                    costMultiplier++;
                }
*/
                Decimal amcost=0;
                Decimal seccost=0;
                Decimal mtcost=0;

                List<Club_Product__c> mtList = [select id,name,Product_Detail__c,(select Price__c,start_date__c,end_date__c,payment_type__c from Prices__r order by Start_Date__c) from club_product__c where recordtype.name='Membership Code'  order by name];

                List<String> omsections = new List<String>();
                List<Club_Opportunity_Product__c> seccop=[select id,product__c,account__c,product__r.Product_Detail__c,product__r.name,(select id,name,Member__c from Members_Sections__r) from Club_Opportunity_Product__c 
                                where account__c = :acc.id
                                and Status__c='Cancelled'
                                and recordtypeid = :sc.sectionRecordTypeId];
                for (Club_Opportunity_Product__c s:seccop){
                    omsections.add(s.product__r.name);
                    system.debug('omsection: ' + omsections);
                }

                List<sectionSelectWrapper> sections = new List<sectionSelectWrapper>();
                Date now = Date.today();
    
                for(club_product__c s:[select id,name,Product_Detail__c,(select Price__c,start_date__c,end_date__c from Prices__r  order by Start_Date__c) from club_product__c where recordtype.name='Section' order by name]){
                    List<price__c> pr = s.prices__r;
                    Decimal scost=0;
                    sd = acc.renewal_date__c;
                    while(sd<=date.today()){
                        system.debug(sd);
                        for(Price__c p:s.prices__r){
                            system.debug(s.prices__r);
                            if(p.Start_Date__c <=sd && (p.end_date__c >=sd || p.end_date__c==null)){
                                scost+=p.price__c;
                                system.debug(p);
                            }
                        }
                        sd=sd.addmonths(12);
                    }
                    sections.add(new sectionSelectWrapper(s,scost));
                    system.debug('sections: ' + sections);                    
                }
                Set<String> ssections = new Set<String>();
                ssections.addall(omsections);
                
                for (sectionSelectWrapper s:sections){
                    if(ssections.contains(s.s.name)){
                        s.selected=true;
                    }
                }

                for(Club_Opportunity_Product__c c:seccop){
                    for(sectionSelectWrapper s:sections){
                        if(s.s.name==c.product__r.name){
                            seccost+=s.price;       
                        }
                    }
                }

                List<Club_Opportunity_Product__c> amcop = [select id,account__c,product__c,product__r.Product_Detail__c,product__r.name,(select id,name,Member__c from Members_Sections__r) from Club_Opportunity_Product__c 
                        where account__c = :acc.id
                        and Status__c='Cancelled'
                        and recordtypeid = :sc.amsectRecordTypeId];
                List<Club_Product__c> cplist = [select id,name,Product_Detail__c,(select Price__c,start_date__c,end_date__c from Prices__r  order by Start_Date__c) from club_product__c where recordtype.name='Associate Membership' order by name];
                sd = acc.renewal_date__c;
                while(sd<=date.today()){
                    system.debug(sd);
                    for(Club_Opportunity_Product__c c:amcop){
                        for(Club_Product__c cp:cplist){
                            for(Price__c p:cp.prices__r){
                                if(p.Start_Date__c <=sd && (p.end_date__c >=sd || p.end_date__c==null)){
                                    amcost+=p.price__c;
                                }
                            }
                        }
                    }
                    sd=sd.addmonths(12);
                }

                
                sd = acc.renewal_date__c;
                system.debug(sd);
                while(sd<=date.today()){
                    system.debug(sd);
                    for(Club_Product__c m:mtList){
                        if(m.Name == lea.Membership_Code__c){
                            boolean found=false;
                            for(Price__c p:m.prices__r){
                                if(p.Start_Date__c <=sd && (p.end_date__c >=sd || p.end_date__c==null) && p.payment_type__c == lea.payment_method__c){
                                    mtcost+=p.price__c;
                                    found=true;
                                    break;
                                }
                            }
                            system.debug(mtcost+'    '+found);
                            if(!found){
                                for(Price__c p:m.prices__r){
                                    if(p.Start_Date__c <=sd && (p.end_date__c >=sd || p.end_date__c==null)){
                                        mtcost+=p.price__c;
                                        found=true;
                                        break;
                                    }
                                }
                            }
                            system.debug(mtcost+'    '+found);
                        }
                    }
                    sd=sd.addmonths(12);
                }

                if(sd==date.today())sd=sd.addmonths(12);
                acc.renewal_date__c = sd;
                acc.Payment_Method2__c = lea.payment_method__c;
                update acc;
                
                if(acc.renewal_date__c  < date.today().addmonths(2).tostartofmonth()){

                    Map<Id,Club_Product__c> prodMap = new Map<Id,Club_Product__c>([select id,name,Product_Detail__c,(select Price__c,start_date__c,end_date__c,payment_type__c from Prices__r order by Start_Date__c) from club_product__c   order by recordtype.name,name]);

                    Decimal rmtcost=0;
                    Decimal rseccost=0;
                    Decimal ramcost=0;

                    
                    for(Club_Opportunity_Product__c c:cop){
                        boolean foundmem = false;
                        for(Price__c p: prodMap.get(c.product__c).Prices__r){
                            if(p.Start_Date__c <=acc.renewal_date__c && (p.end_date__c >=acc.renewal_date__c || p.end_date__c==null) && p.payment_type__c == lea.payment_method__c){
                                rmtcost+=p.price__c;
                                foundmem=true;
                            }
                        }
                        if(foundmem==false){
                            for(Price__c p: prodMap.get(c.product__c).Prices__r){
                                if(p.Start_Date__c <=acc.renewal_date__c && (p.end_date__c >=acc.renewal_date__c || p.end_date__c==null)){
                                    rmtcost+=p.price__c;
                                    break;
                                }
                            }
                        }
                    }

                    for(Club_Opportunity_Product__c c:seccop){
                        for(Price__c p: prodMap.get(c.product__c).Prices__r){
                            if(p.Start_Date__c <=acc.renewal_date__c && (p.end_date__c >=acc.renewal_date__c || p.end_date__c==null)){
                                rseccost+=p.price__c;
                            }
                        }
                    }

                    for(Club_Opportunity_Product__c c:amcop){
                        for(Price__c p: prodMap.get(c.product__c).Prices__r){
                            if(p.Start_Date__c <=acc.renewal_date__c && (p.end_date__c >=acc.renewal_date__c || p.end_date__c==null)){
                                ramcost+=p.price__c;
                            }
                        }
                    }

                    rencostTotal=rmtcost+rseccost+ramcost;
                
                    Opportunity renOpp =new Opportunity(recordtypeid=sc.OppRenewalRecordTypeId,name='Renewal',closedate=acc.renewal_date__c,accountid=acc.id,Amount = rencostTotal,stagename='Due');
                    insert renOpp;
                    
                    for(Club_Opportunity_Product__c c:cop){
                        Club_Opportunity_Product__c cta = c.clone(false,true,false,false);
                        cta.Opportunity__c = renOpp.Id;
                        cta.Status__c = 'Pending';
                        cta.price__c = rmtcost;
                        rencoptoadd.add(cta);
                    }

                    for(Club_Opportunity_Product__c c:seccop){
                        system.debug(c);
                        Club_Opportunity_Product__c cta = c.clone(false,true,false,false);
                        cta.Opportunity__c = renOpp.Id;
                        cta.Status__c = 'Pending';
                        for(Price__c p: prodMap.get(c.product__c).Prices__r){
                            system.debug(p);
                            if(p.Start_Date__c <=acc.renewal_date__c && (p.end_date__c >=acc.renewal_date__c || p.end_date__c==null)){
                                system.debug('found it');
                                cta.price__c=p.price__c;
                            }
                        }
                        rencoptoadd.add(cta);
                    }

                    for(Club_Opportunity_Product__c c:amcop){
                        Club_Opportunity_Product__c cta = c.clone(false,true,false,false);
                        cta.Opportunity__c = renOpp.Id;
                        cta.Status__c = 'Pending';
                        cta.price__c = ramcost;
                        rencoptoadd.add(cta);
                    }
                    system.debug(rencoptoadd);
                    insert rencoptoadd;
    
                    List<Member_Section__c> renms = new List<Member_Section__c>();
                    
                    for(Club_Opportunity_Product__c c: cop){
                        for(Club_Opportunity_Product__c newprods: coptoadd){
                            if(newprods.account__c == c.account__c && c.product__c == newprods.product__c){
                                for(Member_Section__c m : c.Members_Sections__r){
                                    Member_Section__c nms = new Member_Section__c(Club_Opportunity_Product__c = newprods.id, Member__c= m.member__c);
                                    renms.add(nms);
                                }
                                
                            }
                        }
                    }

                    for(Club_Opportunity_Product__c c: seccop){
                        for(Club_Opportunity_Product__c newprods: coptoadd){
                            if(newprods.account__c == c.account__c && c.product__c == newprods.product__c){
                                for(Member_Section__c m : c.Members_Sections__r){
                                    Member_Section__c nms = new Member_Section__c(Club_Opportunity_Product__c = newprods.id, Member__c= m.member__c);
                                    renms.add(nms);
                                }
                                
                            }
                        }
                    }
                    for(Club_Opportunity_Product__c c: amcop){
                        for(Club_Opportunity_Product__c newprods: coptoadd){
                            if(newprods.account__c == c.account__c && c.product__c == newprods.product__c){
                                for(Member_Section__c m : c.Members_Sections__r){
                                    Member_Section__c nms = new Member_Section__c(Club_Opportunity_Product__c = newprods.id, Member__c= m.member__c);
                                    renms.add(nms);
                                }
                                
                            }
                        }
                    }

                    
                    insert renms;

                }
                
                costTotal = mtcost+amcost+seccost;

                Opportunity rstOpp =new Opportunity(recordtypeid=sc.OppReinRecordTypeId,name='Reinstatement',closedate=Date.today(),accountid=acc.id,Amount = costTotal,stagename=sc.complete);
                system.debug('Reinstatement Opps: ' + rstOpp);
                insert rstOpp;
                
                newOpp = rstOpp;
                                                        
                for(Club_Opportunity_Product__c c:cop){
                    Club_Opportunity_Product__c cta = c.clone(false,true,false,false);
                    cta.Opportunity__c = rstOpp.Id;
                    cta.Status__c = sc.active;
                    cta.price__c=mtcost;
                    coptoadd.add(cta);
                }

                for(Club_Opportunity_Product__c c:amcop){
                    Club_Opportunity_Product__c cta = c.clone(false,true,false,false);
                    cta.Opportunity__c = rstOpp.Id;
                    cta.Status__c = sc.active;
                    cta.price__c=amcost;
                    coptoadd.add(cta);
                }
                for(Club_Opportunity_Product__c c:seccop){
                    Club_Opportunity_Product__c cta = c.clone(false,true,false,false);
                    cta.Opportunity__c = rstOpp.Id;
                    cta.Status__c = sc.active;
                    for(sectionSelectWrapper s:sections){
                        if(s.s.name==c.product__r.name){
                            cta.price__c=s.price;       
                        }
                    }
                    coptoadd.add(cta);
                }
                system.debug('Club Opp Products: ' + coptoadd);
                insert coptoadd;

                List<Member_Section__c> ms = new List<Member_Section__c>();
                
                for(Club_Opportunity_Product__c c: cop){
                    for(Club_Opportunity_Product__c newprods: coptoadd){
                        if(newprods.account__c == c.account__c && c.product__c == newprods.product__c){
                            for(Member_Section__c m : c.Members_Sections__r){
                                Member_Section__c nms = new Member_Section__c(Club_Opportunity_Product__c = newprods.id, Member__c= m.member__c);
                                ms.add(nms);
                            }
                            
                        }
                    }
                }
                for(Club_Opportunity_Product__c c: seccop){
                    for(Club_Opportunity_Product__c newprods: coptoadd){
                        if(newprods.account__c == c.account__c && c.product__c == newprods.product__c){
                            for(Member_Section__c m : c.Members_Sections__r){
                                Member_Section__c nms = new Member_Section__c(Club_Opportunity_Product__c = newprods.id, Member__c= m.member__c);
                                ms.add(nms);
                            }
                            
                        }
                    }
                }
                for(Club_Opportunity_Product__c c: amcop){
                    for(Club_Opportunity_Product__c newprods: coptoadd){
                        if(newprods.account__c == c.account__c && c.product__c == newprods.product__c){
                            for(Member_Section__c m : c.Members_Sections__r){
                                Member_Section__c nms = new Member_Section__c(Club_Opportunity_Product__c = newprods.id, Member__c= m.member__c);
                                ms.add(nms);
                            }
                            
                        }
                    }
                }
                system.debug('Reinstatement Member Sections: ' + ms);
                insert ms;

                for(Club_Opportunity_Product__c c: amcop){
                    c.Status__c='Cancelled-Superseded'; 
                }                
                
                for(Club_Opportunity_Product__c c: cop){
                    c.Status__c='Cancelled-Superseded'; 
                }                
                
                for(Club_Opportunity_Product__c c: seccop){
                    c.Status__c='Cancelled-Superseded'; 
                }
                
                update seccop;
                update cop;
                update amcop;                
                

                                                        
                
            }
            else{  // change membership
                if(lea.id!=null && lea.sections__c!=null ){
                    List<String> msections = lea.sections__c.split(':',-2);
                    Set<String> ssections = new Set<String>();
                    ssections.addall(msections);
            
                    for (sectionSelectWrapper s:sections){
                        if(ssections.contains(s.s.name))s.selected=true;
                    }
                }
        		Opportunity wonRenOpp;
        		try{
        			wonRenOpp = [select id,name,closedate,accountid,(select id,price__c,product__c,recordtypeid from Line_Items__r) from Opportunity where accountid=:acc.id and recordtypeid= :sc.OppRenewalRecordTypeId and isclosed=true and iswon=true ORDER BY CloseDate DESC LIMIT 1];
        		}catch(exception e){
        			wonRenOpp = new Opportunity();
        		}
                Opportunity renopp;
                try{
                    renopp = [select id,name,closedate,accountid,(select id,price__c,product__c,recordtypeid from Line_Items__r) from Opportunity where accountid=:acc.id and recordtypeid= :sc.OppRenewalRecordTypeId and isclosed=false and iswon=false];
                }
                catch(exception e){
                    renopp=new Opportunity();
                }
                system.debug(acc.id);
                system.debug(renopp);
    
                List<Club_Opportunity_Product__c> cop = [select id,recordtypeid,product__r.Product_Detail__c,product__r.name,price__c, product__c, (select id,name,Member__c  from Members_Sections__r) from Club_Opportunity_Product__c 
                            where account__c = :acc.id 
                            and Status__c=:sc.active];
    
                Contact cAssocMember; 
                Contact cPrimaryMember; 
                Contact cSecondaryMember; 
                try{
                    cAssocMember = [select title,firstname,lastname,birthdate from Contact where date_ended__c = null and accountid=:acc.id and recordtypeid=:sc.associateContactRecordTypeId limit 1];
                }
                catch (Exception e){
                    cAssocMember=new Contact();
                }
                try{
                    cPrimaryMember = [select title,firstname,lastname,birthdate,email from Contact where accountid=:acc.id and recordtypeid=:sc.leadContactRecordTypeId limit 1];
                }
                catch (Exception e){
                    cPrimaryMember=new Contact();
                }
                try{
                    cSecondaryMember = [select title,firstname,lastname,birthdate,email from Contact where accountid=:acc.id and recordtypeid=:sc.secondaryContactRecordTypeId limit 1];
                }
                catch (Exception e){
                    cSecondaryMember=new Contact();
                }
                Date now = Date.today();
                boolean within8weeks = false;
				week8date = null;
				if(wonRenOpp.closeDate != null){                  
			        if((wonRenOpp.closeDate.addDays(56)) > now){
			            within8weeks = true; 
			            week8date = wonRenOpp.closeDate;           
			        }			        
				}
				else if(acc.Date_Joined__c.addDays(56) > now){
			        	within8weeks = true; 
			            week8date = acc.Date_Joined__c;
			    }
			    else{
			    	week8date = now;
			    }
                List<Club_Product__c> mtList = new List<Club_Product__c>();
                List<Club_Product__c> pList = new List<Club_Product__c>();
                
                mtList = [select id,name,Product_Detail__c,Membership_Length__c,renewable__c,SectionsAreFree__c,(select Start_Date__c, End_Date__c, Price__c,Payment_Type__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: acc.Renewal_Date__c and (End_Date__c>=:acc.Renewal_Date__c or End_Date__c=null)) OR (Start_Date__c<=:week8date and (End_Date__c>=:week8date or End_Date__c=null)) order by Start_Date__c DESC) from club_product__c where recordtype.name='Membership Code' order by name];
                pList  = [select id,name,Product_Detail__c,(select Start_Date__c, End_Date__c, Price__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: acc.Renewal_Date__c and (End_Date__c>=:acc.Renewal_Date__c or End_Date__c=null)) OR (Start_Date__c<=:week8date and (End_Date__c>=:week8date or End_Date__c=null)) order by Start_Date__c DESC) from club_product__c where recordtype.name='Associate Membership' order by name];                    
				
    			system.debug(within8weeks);
                List<sectionSelectWrapper> newsections = new List<sectionSelectWrapper>();
                for(sectionSelectWrapper s:sections){
                    if(s.selected){
                        boolean found=false;
                        for(Club_Opportunity_Product__c c:cop){
                            if(c.product__c == s.s.id){
                                found=true;
                                break;
                            }
                        }
                    if(!found){
                        //Decimal sprice = pickCorrectPrice(s.Prices, acc.Renewal_Date__c, acc.Renewal_Date__c);
                        //change membership changed price to use current price
                        Decimal sprice;
                       	sprice = pickCorrectPrice(s.Prices, now, now);
                        for(Club_Product__c mt: mtList){                        
                            if((acc.FreeSections__c == true || mt.SectionsAreFree__c == true) && lea.Membership_Code__c == mt.Name){
                                sprice = 0;
                            }                           
                        }
                        newsections.add(new sectionSelectWrapper(s.s,sprice, true));
                        //newsections.add(new sectionSelectWrapper(s.s,s.price,true));
                        }
                    }
                }
    
    
                Decimal costtotal=0;
                for(Club_Product__c m:mtList){
                    if(m.Name == lea.Membership_Code__c && (m.id!=acc.Membership_Code__c || lea.Join_Fee_8_Weeks__c) ){
                        //change membership changed price to use current price
                        for(Price__c p:m.prices__r){
                            if(p.Payment_Type__c == lea.Payment_Method__c){
                            	if(within8Weeks){
	                                if(p.Start_Date__c <= week8date && (p.End_Date__c >= week8date || p.End_Date__c == null)){
	                                    costTotal+=p.Price__c;
	                                }
                            	}
                            	else{
                            		if(p.Start_Date__c <= now && (p.End_Date__c >= now || p.End_Date__c == null)){
	                                    costTotal+=p.Price__c;
	                                }
                            	}
                            }
                        }
                        /*
                        for(Price__c p:m.prices__r){
                            if(p.Start_Date__c <= acc.Renewal_Date__c && (p.End_Date__c >= acc.Renewal_Date__c || p.End_Date__c == null)){
                                if(p.Payment_Type__c == lea.Payment_Method__c){
                                    costtotal+=p.Price__c;
                                }

                            //costtotal+=m.prices__r[0].Price__c;
//                            if(m.id == acc.Membership_Code__c)
//                        costtotal-=m.prices__r[0].Price__c;
                            }
                        }
*/
                    }
                }
                for(Club_Opportunity_Product__c op :cop){
                    if(op.RecordTypeId == sc.mtsectRecordTypeId && !lea.Join_Fee_8_Weeks__c){
                        system.debug('oldprice');
                        costTotal -= op.Price__c;
                    }
                }
                if(lea.Join_Fee_8_Weeks__c)costtotal+=lea.Join_Fee__c;
                if(costtotal<0)costtotal=0;
    
                if(lea.hasAssociate__c){
                    if(cAssocMember.birthdate!=null){
                    	
                        for(Price__c p : mapPrices.get('Associate Member').prices__r){
                            if(p.Start_Date__c <= acc.Renewal_Date__c && (p.End_Date__c >= acc.Renewal_Date__c || p.End_Date__c == null)){
                                if(lea.Join_Fee_8_Weeks__c){
                                	costtotal+=p.Price__c;
                                	break;
                                }
                                else{
                                	costtotal+=p.Change_Fee__c;
                                }
                            }
                        }
                        
                    }
                    else{                       
                        //change membership changed price to use current price
                        //costtotal+=pickCorrectPrice(mapPrices.get('Associate Member').prices__r, acc.Renewal_Date__c, acc.Renewal_Date__c);
            			costtotal+=pickCorrectPrice(mapPrices.get('Associate Member').prices__r, now, now);
                    }
                }
    
				if(lea.Join_Fee_8_Weeks__c){
	                for(sectionSelectWrapper s:sections){
	                	system.debug(s.selected);
	                    if(s.selected)costTotal+=pickCorrectPrice(s.Prices, now, now);
	                }
				}
				else{
	                for(sectionSelectWrapper s:newsections){
	                	system.debug(s.selected);
	                    if(s.selected)costTotal+=s.price;
	                }
				}
                
                Opportunity chgOpp =new Opportunity(recordtypeid=sc.OppChangeRecordTypeId,name='Change',closedate=now,accountid=acc.id,Amount = costTotal,stagename=sc.complete);
                
                insert chgOpp;
                newOpp = chgOpp;
                system.debug(newopp);
    
                List<Club_Opportunity_Product__c> coptoadd = new List<Club_Opportunity_Product__c>();
                List<Club_Opportunity_Product__c> coptoupd = new List<Club_Opportunity_Product__c>();
                List<Club_Opportunity_Product__c> coptodel = new List<Club_Opportunity_Product__c>();
                List<Member_Section__c> ms = new List<Member_Section__c>();
    
                List<Club_Opportunity_Product__c> cprods = [select id, recordtype.name,
                                                            product__c,Member_Section__c,status__c,
                                                            Opportunity__r.accountid 
                                                            from Club_Opportunity_Product__c 
                                                            where Opportunity__r.accountid = :acc.id
                                                            and status__c = :sc.active];
    
    
                Decimal amcost = 0;
                if(lea.hasAssociate__c){
                    if(cAssocMember.birthdate!=null){
                        for(Price__c p : mapPrices.get('Associate Member').prices__r){
                            if(p.Start_Date__c <= acc.Renewal_Date__c && (p.End_Date__c >= acc.Renewal_Date__c || p.End_Date__c == null)){
                                system.debug(p);
                                amcost+=p.Change_Fee__c;
                            }
                        }                       
                    }
                    else{
						 amcost+=pickCorrectPrice(mapPrices.get('Associate Member').prices__r, now, now);
                    }
                }
                if(lea.hasPartner__c && cAssocMember.id!=null){
                    cAssocMember.Date_Ended__c = date.today();
                    update cAssocMember;
                    for(Club_Opportunity_Product__c c: cprods){
                        if(c.recordtypeid == sc.amRecordTypeId){
                            Club_Opportunity_Product__c nc =c;
                            nc.status__c=sc.superseded;
                            coptoupd.add(nc);
                        }
                    }
                    for(Club_Opportunity_Product__c c: renopp.line_items__r){
                        if(c.recordtypeid == sc.amRecordTypeId){
                            coptodel.add(c);
                        }
                    }
                }
                else if(lea.hasAssociate__c && cAssocMember.id!=null){
                    cAssocMember.Date_Ended__c = date.today();
                    update cAssocMember;
                    for(Club_Opportunity_Product__c c: cprods){
                        if(c.recordtypeid == sc.amRecordTypeId){
                            Club_Opportunity_Product__c nc =c;
                            nc.status__c=sc.superseded;
                            coptoupd.add(nc);
                        }
                    }
                    Contact assocContact = new Contact(recordtypeid=sc.associateContactRecordTypeId,
                                            Accountid = acc.Id,
                                            Date_Joined__c = date.today(),
                                            firstname=lea.Associate_Member_First_Name__c,
                                            lastname=lea.Associate_Member_Surname__c,
                                            Salutation = lea.Associate_Member_Title__c,
                                            Birthdate = lea.Associate_Member_Date_of_Birth__c);
                    insert assocContact;
                    coptoadd.add(new Club_Opportunity_Product__c(Product__c = plist[0].id,recordtypeid = sc.amRecordTypeId,  opportunity__c = chgopp.id, price__c = amcost, account__c = acc.id,status__c = sc.active ));
                    if(renopp.id!=null)
                        coptoadd.add(new Club_Opportunity_Product__c(Product__c = plist[0].id,recordtypeid = sc.amRecordTypeId,  opportunity__c = renopp.id, price__c = amcost, account__c = acc.id,status__c = 'Pending' ));
                }
                else if(lea.hasAssociate__c && cAssocMember.id==null){
                    Contact assocContact = new Contact(recordtypeid=sc.associateContactRecordTypeId,
                                            Accountid = acc.Id,
                                            Date_Joined__c = date.today(),
                                            firstname=lea.Associate_Member_First_Name__c,
                                            lastname=lea.Associate_Member_Surname__c,
                                            Salutation = lea.Associate_Member_Title__c,
                                            Birthdate = lea.Associate_Member_Date_of_Birth__c);
                    insert assocContact;
                    coptoadd.add(new Club_Opportunity_Product__c(Product__c = plist[0].id,recordtypeid = sc.amRecordTypeId,  opportunity__c = chgopp.id, price__c = amcost, account__c = acc.id,status__c = sc.active ));
                    if(renopp.id!=null)
                        coptoadd.add(new Club_Opportunity_Product__c(Product__c = plist[0].id,recordtypeid = sc.amRecordTypeId,  opportunity__c = renopp.id, price__c = amcost, account__c = acc.id,status__c = 'Pending' ));
                }
        
                for(sectionSelectWrapper s : sections){
                    if(s.selected){
                        Boolean found = false;
                        Decimal sprice = pickCorrectPrice(s.Prices, Date.today(), date.today());
                            for(Club_Product__c mt: mtList){                        
                                if((acc.FreeSections__c == true || mt.SectionsAreFree__c == true) && lea.Membership_Code__c == mt.Name){
                                    sprice = 0;
                                }                           
                            }
                        for(Club_Opportunity_Product__c c : cop){
                            if(s.s.Id == c.Product__c)found=true;
                        }
                        if(!found){
                            
                            system.debug('Payment Success section price:' + sprice);
                            coptoadd.add(new Club_Opportunity_Product__c(recordtypeid = sc.sectionRecordTypeId, product__c = s.s.id, opportunity__c = chgopp.id, price__c = sprice, account__c = acc.id,status__c = sc.active ));
                        }
                        found = false;
                        sprice = pickCorrectPrice(s.Prices, acc.Renewal_Date__c, acc.Renewal_Date__c);
                        if(renopp.id!=null){
                            for(Club_Opportunity_Product__c c : renopp.line_items__r){
                                if(s.s.Id == c.Product__c){
                                    coptodel.add(c);
                                    break;
                                }
                            }
                            if(!found){
                                coptoadd.add(new Club_Opportunity_Product__c(recordtypeid = sc.sectionRecordTypeId, product__c = s.s.id, opportunity__c = renopp.id, price__c = sprice, account__c = acc.id,status__c = 'Pending' ));
                            }
                        }
                    }
                    else{
                        for(Club_Opportunity_Product__c c : cop){
                            if(s.s.Id == c.Product__c){
                                Club_Opportunity_Product__c nc =c;
                                nc.status__c=sc.superseded;
                                nc.Section_Leave_Date__c=Date.today();
                                coptoupd.add(nc);
                                break;
                            }
                        }
                        if(renopp.id!=null){
                            for(Club_Opportunity_Product__c c : renopp.line_items__r){
                                if(s.s.Id == c.Product__c){
                                    coptodel.add(c);
                                    break;
                                }
                            }
                        }
                    }
                }
    			system.debug(within8weeks);
    			system.debug(week8date);
                if(lea.Membership_Code__c != acc.Membership_Type_Name__c || lea.Join_Fee_8_Weeks__c){
                    for(Club_Opportunity_Product__c c: renopp.line_items__r){
                        if(c.recordtypeid == sc.mtRecordTypeId){
                            for(Club_Product__c m:mtList){                                                                                              
                                for(Price__c p: m.Prices__r){                                                            	                                  
                                    if(p.Start_Date__c <= acc.Renewal_Date__c && (p.End_Date__c >= acc.Renewal_Date__c || p.End_Date__c == null) && p.Payment_Type__c == lea.Payment_Method__c){
                                        if(m.Name == lea.Membership_Code__c){
                                            system.debug('price found');
                                        	system.debug(p);
                                            Club_Opportunity_Product__c ctu = c;
                                            ctu.Product__c = m.id;
                                            ctu.Price__c = p.price__c;
                                            coptoupd.add(ctu);
                                            system.debug(p);
                                            system.debug(coptoupd);
                                        }
                                	}
                                }
                            }
                        }                        
                    }
                    for(Club_Opportunity_Product__c c: cop){
                        boolean found = false;
                        if(c.recordtypeid == sc.mtRecordTypeId){
                            for(Club_Product__c m:mtList){
                                if(m.Name == lea.Membership_Code__c){
                                    for(Price__c p: m.Prices__r){
                                        if(p.Payment_Type__c == lea.Payment_Method__c){
                                        	if(within8Weeks){
			                            		if(p.Start_Date__c <= week8date && (p.End_Date__c >= week8date || p.End_Date__c == null) && p.Payment_Type__c == lea.Payment_Method__c){
			                                        if(m.Name == lea.Membership_Code__c){
			                                            system.debug('price found');
	                                        			system.debug(p);
			                                            Club_Opportunity_Product__c ctu = c;
			                                            ctu.Product__c = m.id;
			                                            ctu.Price__c = p.price__c;
			                                            coptoupd.add(ctu);
			                                            acc.Membership_Code__c = m.id;
			                                            system.debug(p);
			                                            system.debug(coptoupd);
			                                        }
			                                    }
			                            	}
			                            	else{
	                                            if(p.Start_Date__c <= now && (p.End_Date__c >= now || p.End_Date__c == null) && p.Payment_Type__c == lea.Payment_Method__c){
	                                                system.debug('price found');
	                                        		system.debug(p);
	                                                Club_Opportunity_Product__c ctu = c;
	                                                Club_Opportunity_Product__c cta = c.clone(false,true,false,false);
	                                                ctu.status__c=sc.superseded;
	                                                coptoupd.add(ctu);
	                                                cta.Product__c = m.id;
	                                                
	                                                cta.Price__c = p.price__c;
	                                                cta.opportunity__c = chgopp.id;
	                                                cta.account__c = acc.id;
	                                                cta.status__c = sc.active;
	                                                acc.Membership_Code__c = m.id;
	                                                coptoadd.add(cta);
	                                                break;
	                                            }
			                            	}
                                        }
                                    }                                       
                                }
                                if(found)break;
                            }
                        }
                    }
                Update acc;
                }       
                system.debug(coptoupd);
                system.debug(coptoadd);
                if(coptoupd.size()>0){
                    update coptoupd;
                }
                if(coptoadd.size()>0){
                    insert coptoadd;
                }
    
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

                Decimal currprice=0;
                Decimal newprice=0;
                List<Club_Opportunity_Product__c> olilist = [select Price__c,Status__c from Club_Opportunity_Product__c where account__c = :a.id];
                for(Club_Opportunity_Product__c c:olilist){
                    if(c.Status__c=='Active')currprice+=c.Price__c;
                    if(c.Status__c=='Pending')newprice+=c.Price__c;
                }
                
                if(renOpp.id!=null && newprice!=0){
                    system.debug(newprice);
                    renOpp.Amount = newprice;
                    update renOpp;
                }
                     
            }       
            delete [select id from lead where name=:a.id];
            system.debug('here');
            
            Decimal currprice=0;
            Decimal newprice=0;
            
            List<Club_Opportunity_Product__c> olilist = [select Price__c,Status__c from Club_Opportunity_Product__c where account__c = :a.id];
            for(Club_Opportunity_Product__c c:olilist){
                if(c.Status__c=='Active')currprice+=c.Price__c;
                if(c.Status__c=='Pending')newprice+=c.Price__c;
            }
            
            // if(acc.Payment_Method2__c=='Direct Debit'){
            if((acc.Payment_Method2__c=='Direct Debit' && lea.Payment_Method__c == 'Direct Debit') || 
                ((acc.Payment_Method2__c=='Direct Debit' && lea.Payment_Method__c != 'Direct Debit') && (acc.Membership_Type_Name__c == lea.Membership_Code__c)) ){
                //this is where it dies
                try{
                    Payment_Method__c pm = [select id,Mandate_Amount__c from Payment_Method__c where status__c='Active' and Membership__c = :acc.id and recordtypeid=:sc.ddebitRecordTypeId limit 1];                           
                    if(newprice!=0){
                        pm.Mandate_Amount__c = newprice;
                    }
                    else{
                        pm.Mandate_Amount__c = currprice;
                    }
                    update pm;
                }
                catch(Exception ex){}
            }
            Payment_Method__c pm = new Payment_Method__c();
            pm.Membership__c = a.id;
            Payment_Method__c currentDD;
            try{
                currentDD = [select id,Bank_Account_Name__c,Bank_Account_Number__c,Bank_Name__c,Sort_Code__c,
                                (select id,status__c,amount__c from Transactions__r where Transaction_Type__c='01' or Transaction_Type__c='0N')
                             from payment_method__c 
                             where recordtypeid=:sc.ddebitRecordTypeId
                             and status__c='Active' 
                             and Membership__c = :a.id
                             order by createddate desc
                             limit 1];

                System.debug('currentDD 11 = ' + JSON.serialize(currentDD));
            }
            catch(exception ex)
            {
                currentDD=new Payment_Method__c();
            }
            pm.Status__c = 'Active';
            pm.start_date__c = Date.today();
            if(lea.Payment_Method__c=='Debit/Credit Card'){
                System.debug('tokenid = ' + tokenid);
                pm.CC_Token__c = tokenid;
                pm.recordtypeid = sc.CcardRecordTypeId;
                pm.Authorization_code__c = acode;
                if(tokenid!=null){
                    a.Membership_Status__c='Paid';
                }
                else
                {
                    a.Membership_Status__c='Unpaid';
                }
            }
            else if(lea.Payment_Method__c=='Direct Debit'){
                if(currentDD.id==null || (currentDD.Bank_Account_Number__c!=lea.Bank_Account_Number__c
                                    || (String.isNotEmpty(lea.Sort_Code__c) && currentDD.Sort_Code__c!=lea.Sort_Code__c.replaceAll('[^0-9]', ''))) ){
                    pm.recordtypeid = sc.ddebitRecordTypeId;
                    pm.Bank_Account_Name__c = lea.Bank_Account_Name__c;
                    pm.Bank_Account_Number__c = lea.Bank_Account_Number__c;
                    pm.Bank_Name__c = lea.Bank_Name__c;
                    pm.Sort_Code__c = String.isNotEmpty(lea.Sort_Code__c) ? lea.Sort_Code__c.replaceAll('[^0-9]', '') : '';
                    pm.Mandate_Amount__c = newOpp.Amount; 
                    a.Membership_Status__c='DD Pending';
                }
                else{
                    pm=currentDD;
                }
            }
            else if (lea.Payment_Method__c=='Cash/Cheque'){
                pm.recordtypeid = sc.cashRecordTypeId;
                a.Membership_Status__c='Paid';
            }
            
            if (acc.Membership_Type_Name__c == lea.Membership_Code__c && lea.Payment_Method__c != 'Direct Debit' && !lea.Join_Fee_8_Weeks__c){
                pm.One_off_payment_date__c = date.today();
            }
            if(lea.Join_Fee_8_Weeks__c){
            	a.Payment_Method2__c = lea.payment_method__c;
            	update a;
            }

            System.debug('pm 11 = ' + JSON.serialize(pm));

            upsert pm;

            system.debug('pm '+pm);
            system.debug('newOpp '+newopp);
            newOpp.Payment_Method__c = pm.id;
            update newOpp;

            BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
            
            system.debug(pm);
            system.debug(currentdd);
    
            Transaction__c tr;
            Decimal costTotal = newOpp.Amount;
            system.debug(costTotal);
            if(lea.Payment_Method__c=='Direct Debit'){
                if(pm.id!=currentDD.id){ // new DD
/*
                    if(costTotal!=0){
                        tr = new Transaction__c(Amount__c=costTotal);
                        tr.Payment_Method__c = pm.id;
                        tr.Transaction_type__c = '01';
                        tr.status__c='Pending';
                        tr.recordtypeid = sc.trddebitRecordTypeId;
                        tr.Transaction_Date__c = BusinessHours.add(bh.id, system.now(), days7Milliseconds).date();
                    }
                    else{
                        tr = new Transaction__c(Amount__c=costTotal);
                        tr.Payment_Method__c = pm.id;
                        tr.Transaction_type__c = '01';
                        tr.status__c='Pending'; // set to dummy
                        tr.recordtypeid = sc.trddebitRecordTypeId;
                        tr.Transaction_Date__c = date.today();
                    }
*/
                }
                else{ // existing DD
                    if(costTotal!=0){
                        tr = new Transaction__c(Amount__c=costTotal);
                        tr.Payment_Method__c = pm.id;
                        tr.Transaction_type__c = '17';
                        tr.status__c='Pending';
                        tr.recordtypeid = sc.trddebitRecordTypeId;
                        tr.Transaction_Date__c = date.today();
                        for(Transaction__c t: currentDD.transactions__r){
                    system.debug(t);
                            if(t.status__c=='Pending'){
                                system.debug('Existing DD and Pending');
                                tr = t;
                                tr.amount__c+=costTotal;
                            }
                        }
                    }
                }
                    system.debug(tr);
            }
            else if(lea.Payment_Method__c=='Debit/Credit Card'){
                tr = new Transaction__c(Amount__c=costTotal);
                tr.Payment_Method__c = pm.id;
                tr.Authorization_code__c = acode;
                tr.recordtypeid = sc.trCcardRecordTypeId;
                if(tokenid!=null){
                    tr.Transaction_Date__c = date.today();
                }
            }
            else if (lea.Payment_Method__c=='Cash/Cheque'){
                tr = new Transaction__c(Amount__c=costTotal);
                tr.Payment_Method__c = pm.id;
                tr.recordtypeid = sc.trcashRecordTypeId;
            }
            
            if(tr!=null)upsert tr;

                        
            return  new PageReference('/'+a.id);
        }
        else if(o.id!=null)
        {
            objectFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
            String query = 'SELECT';
            for(String s : objectFields.keySet()) {
                query += ' ' + s + ',';
            }
            query += ' Membership_Code__r.name ';
            query += ' FROM Account where id=\''+o.accountid+'\'';
    
            Account acc = database.query(query);
            globalAcc = acc;
            
            if(lea.id!=null && lea.sections__c!=null ){
                List<String> msections = lea.sections__c.split(':',-2);
                Set<String> ssections = new Set<String>();
                ssections.addall(msections);
        
                for (sectionSelectWrapper s:sections){
                    if(ssections.contains(s.s.name))s.selected=true;
                }
            }
            
            
            Contact cAssocMember; 
            Contact cPrimaryMember; 
            Contact cSecondaryMember; 
            try{
                cAssocMember = [select title,firstname,lastname,birthdate from Contact where date_ended__c = null and accountid=:acc.id and recordtypeid=:sc.associateContactRecordTypeId limit 1];
            }
            catch (Exception e){
                cAssocMember=new Contact();
            }
            try{
                cPrimaryMember = [select title,firstname,lastname,birthdate,email from Contact where accountid=:acc.id and recordtypeid=:sc.leadContactRecordTypeId limit 1];
            }
            catch (Exception e){
                cPrimaryMember=new Contact();
            }
            try{
                cSecondaryMember = [select title,firstname,lastname,birthdate,email from Contact where accountid=:acc.id and recordtypeid=:sc.secondaryContactRecordTypeId limit 1];
            }
            catch (Exception e){
                cSecondaryMember=new Contact();
            }

//added to make 006 renewals from web just update renewal, and not process cost        

            if(skipDDpay){
                List<Club_Opportunity_Product__c> coptoadd = new List<Club_Opportunity_Product__c>();
                List<Club_Opportunity_Product__c> coptoupd = new List<Club_Opportunity_Product__c>();
                List<Club_Opportunity_Product__c> coptodel = new List<Club_Opportunity_Product__c>();
                List<Member_Section__c> ms = new List<Member_Section__c>();
                Date now = o.closedate;
                List<Club_Opportunity_Product__c> oppli = [select id,product__r.Product_Detail__c,product__r.name,price__c,RecordTypeId from Club_Opportunity_Product__c 
                        where account__c = :acc.id
                        and Opportunity__c = :o.id 
                        and Status__c='Pending'];

                List<Club_Product__c> pList = new List<Club_Product__c>();
                List<Club_Product__c> mtList = new List<Club_Product__c>();
                pList = [select id,name,Product_Detail__c,(select Start_Date__c, End_Date__c, Price__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: acc.Renewal_Date__c and (End_Date__c>=:acc.Renewal_Date__c or End_Date__c=null)) order by Start_Date__c DESC) from club_product__c where recordtype.name='Associate Membership' order by name];
                mtList = [select id,name,Product_Detail__c,SectionsAreFree__c,(select Payment_Type__c, Start_Date__c, End_Date__c, Price__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: acc.Renewal_Date__c and (End_Date__c>=:acc.Renewal_Date__c or End_Date__c=null)) order by Start_Date__c DESC) from club_product__c where recordtype.name='Membership Code'  order by name];

                Decimal amcost=0;
                for(Club_Opportunity_Product__c c:oppli){
                    if(c.recordtypeid == sc.amRecordTypeId)
                        amcost=c.price__c;
                }
                if(cAssocMember.id!=null){
                    if(lea.hasPartner__c)
                        amcost=0;
                }
                else{                   
                    if(lea.hasAssociate__c && amcost==0)amcost=pickCorrectPrice(mapPrices.get('Associate Member').prices__r, acc.Renewal_Date__c, acc.Renewal_Date__c);
                }                

                Decimal mtcost=0;
                for(Club_Product__c m:mtList){
                    if(m.Name == lea.Membership_Code__c)
                    for(Price__c p : m.prices__r){
                        if(p.Start_Date__c <= acc.Renewal_date__c && (p.End_Date__c >= acc.Renewal_Date__c || p.End_date__c == null) && p.Payment_Type__c == lea.Payment_Method__c){
                            mtcost+=p.Price__c;
                        }
                    }
                }
                
                if(lea.hasPartner__c && cAssocMember.id!=null){
                    cAssocMember.Date_Ended__c = o.CloseDate;
                    update cAssocMember;
                    for(Club_Opportunity_Product__c c: oppli){
                        if(c.recordtypeid == sc.amRecordTypeId){
                            coptodel.add(c);
                        }
                    }
                }
                else if(lea.hasAssociate__c && cAssocMember.id!=null){
                    cAssocMember.Date_Ended__c = o.CloseDate;
                    update cAssocMember;
                    Contact assocContact = new Contact(recordtypeid=sc.associateContactRecordTypeId,
                                            Accountid = acc.Id,
                                            Date_Joined__c = o.CloseDate,
                                            firstname=lea.Associate_Member_First_Name__c,
                                            lastname=lea.Associate_Member_Surname__c,
                                            Salutation = lea.Associate_Member_Title__c,
                                            Birthdate = lea.Associate_Member_Date_of_Birth__c);
                    insert assocContact;
                }
                else if(lea.hasAssociate__c && cAssocMember.id==null){
                    Contact assocContact = new Contact(recordtypeid=sc.associateContactRecordTypeId,
                                            Accountid = acc.Id,
                                            Date_Joined__c = o.CloseDate,
                                            firstname=lea.Associate_Member_First_Name__c,
                                            lastname=lea.Associate_Member_Surname__c,
                                            Salutation = lea.Associate_Member_Title__c,
                                            Birthdate = lea.Associate_Member_Date_of_Birth__c);
                    insert assocContact;
                    coptoadd.add(new Club_Opportunity_Product__c(Product__c = plist[0].id,recordtypeid = sc.amRecordTypeId,  opportunity__c = o.id, price__c = amcost, account__c = acc.id,status__c = 'Pending' ));
                }
        
                Decimal costtotal=0;
                system.debug(mtCost);
                costTotal+=mtCost;
                system.debug(amCost);
                costTotal+=amCost;
                for(sectionSelectWrapper s:sections){
                    if(s.selected){
                        Decimal sprice = pickCorrectPrice(s.prices, acc.Renewal_Date__c, acc.Renewal_date__c);
                            for(Club_Product__c mt: mtList){                        
                                if((acc.FreeSections__c == true || mt.SectionsAreFree__c == true) && lea.Membership_Code__c == mt.Name){
                                    sprice = 0;
                                }                           
                            }
                        costTotal+=sprice;
                        system.debug(costTotal);
                    }
                }
                
                o.Amount = costTotal;
                update o;
                
                for(sectionSelectWrapper s : sections){
                    if(s.selected){
                        Boolean found = false;
                        for(Club_Opportunity_Product__c c : oppli){
                            if(s.s.Id == c.Product__c)found=true;                       
                        }
                        if(!found){
                            Decimal sprice = pickCorrectPrice(s.prices, acc.Renewal_Date__c, acc.Renewal_date__c);
                            for(Club_Product__c mt: mtList){                        
                                if((acc.FreeSections__c == true || mt.SectionsAreFree__c == true) && lea.Membership_Code__c == mt.Name){
                                    sprice = 0;
                                }                           
                            }
                            coptoadd.add(new Club_Opportunity_Product__c(recordtypeid = sc.sectionRecordTypeId, product__c = s.s.id, opportunity__c = o.id, price__c = sprice, account__c = acc.id,status__c = 'Pending' ));
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
                system.debug(oppli);
                system.debug(mtList);
                system.debug(lea.Membership_Code__c);
                system.debug(acc.Membership_Type_Name__c);
                if(lea.Membership_Code__c != acc.Membership_Type_Name__c){
                    for(Club_Opportunity_Product__c c: oppli){
                        system.debug(c.recordtypeid);
                        if(c.recordtypeid == sc.mtRecordTypeId){
                            system.debug('rec type ok');
                            for(Club_Product__c m:mtList){
                                system.debug(m);
                                if(m.Name == lea.Membership_Code__c){
                                    for(Price__c p : m.Prices__r){
                                        if(p.Start_Date__c <= acc.Renewal_Date__c && (p.End_Date__c >= acc.Renewal_Date__c || p.End_Date__c == null) && p.Payment_Type__c == lea.Payment_Method__c){
                                            Club_Opportunity_Product__c ctu = c;
                                            ctu.Product__c = m.id;
                                            ctu.Price__c = p.Price__c;
                                            //acc.Membership_Code__c = m.id;
                                            coptoupd.add(ctu);
                                            system.debug(coptoupd);
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }       
                if(coptoupd.size()>0){
                    update coptoupd;
                    update acc;
                }
         
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
                
                payment_method__c currentDD;
                try{
                    currentDD = [select id,Bank_Account_Name__c,Bank_Account_Number__c,Bank_Name__c,Sort_Code__c,Re_issue_Payment__c
                                 from payment_method__c 
                                 where recordtypeid=:sc.ddebitRecordTypeId
                                 and status__c='Active' 
                                 and Membership__c = :acc.id
                                 order by createddate desc
                                 limit 1];
                }
                catch(exception ex)
                {
                    currentDD=new Payment_Method__c();
                }

                if(currentDD.id==null || (currentDD.Bank_Account_Number__c!=lea.Bank_Account_Number__c
                                      || (String.isNotEmpty(lea.Sort_Code__c) && currentDD.Sort_Code__c!=lea.Sort_Code__c.replaceAll('[^0-9]', ''))) ){

                    Payment_Method__c pm = new Payment_Method__c();
                    pm.Membership__c = acc.id;
                    pm.recordtypeid = sc.ddebitRecordTypeId;
                    pm.Bank_Account_Name__c = lea.Bank_Account_Name__c;
                    pm.Bank_Account_Number__c = lea.Bank_Account_Number__c;
                    pm.Bank_Name__c = lea.Bank_Name__c;
                    pm.Sort_Code__c = String.isNotEmpty(lea.Sort_Code__c) ? lea.Sort_Code__c.replaceAll('[^0-9]', '') : '';
                    if(Date.today()>o.closedate){
                        pm.Mandate_Amount__c = costTotal;
                    }
                    else{
                        pm.Mandate_Amount__c = 0;
                    }
                    pm.Status__c = 'Active';
                    acc.Membership_Status__c = 'Paid';
                    pm.start_date__c = Date.today();
                    acc.Payment_Method2__c = lea.Payment_Method__c;
                    insert pm;
                    
                    update acc;
                                        
                }
                
                delete [select id from lead where name=:o.id];
                            
            } // end of skip DD section -- just update the opp
            else{    
                //Date now = Date.today();
                Date now = o.closedate;
                List<Club_Opportunity_Product__c> cop = [select id,recordtypeid,product__r.Product_Detail__c,product__r.name,price__c, product__c, (select id,name,Member__c  from Members_Sections__r) from Club_Opportunity_Product__c 
                                where account__c = :o.accountid
                                and Status__c=:sc.active];
                List<Club_Product__c> mtList = new List<Club_Product__c>();
                List<Club_Product__c> pList = new List<Club_Product__c>();
                mtList = [select id,name, SectionsAreFree__c, Product_Detail__c,Membership_Length__c,(select Start_Date__c, End_Date__c, Price__c,payment_type__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: acc.Renewal_Date__c and (End_Date__c>=:acc.Renewal_Date__c or End_Date__c=null)) order by Start_Date__c DESC) from club_product__c where recordtype.name='Membership Code'  order by name];                
                pList = [select id,name,Product_Detail__c,(select Start_Date__c, End_Date__c, Price__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: acc.Renewal_Date__c and (End_Date__c>=:acc.Renewal_Date__c or End_Date__c=null)) order by Start_Date__c DESC) from club_product__c where recordtype.name='Associate Membership' order by name];
                system.debug(mtlist);
                Decimal costTotal=0;
                for(Club_Product__c m:mtList){
                    if(m.Name == lea.Membership_Code__c){
                        for(Price__c p:m.prices__r){
                            if(p.Payment_Type__c == lea.Payment_Method__c){
                                if(p.Start_Date__c <= acc.Renewal_Date__c && (p.End_Date__c >= acc.Renewal_date__c || p.End_Date__c == null)){
                                    costTotal+=p.Price__c;
                                }
                                //costTotal+=m.prices__r[0].Price__c;
                            }
                        }
                    }
                }
    /*
                for(Club_Opportunity_Product__c op :cop){
                    if(op.RecordTypeId == sc.mtsectRecordTypeId){
                        costTotal -= op.Price__c;
                    }
                }
    */
                Decimal amCost=0;
                for(Club_Opportunity_Product__c c:o.line_items__r){
                    if(c.recordtypeid == sc.amRecordTypeId)
                        amCost+=c.price__c;
                }
                if(cAssocMember.id!=null){
                    if(lea.hasPartner__c)
                        amCost=0;
                }
                else{
                    if(lea.hasAssociate__c && amCost==0)amCost=pickCorrectPrice(mapPrices.get('Associate Member').prices__r, acc.Renewal_date__c, acc.Renewal_Date__c);
                }
                
                costTotal+=amCost;
                system.debug(sections);
                for(sectionSelectWrapper s:sections){
                    if(s.selected){
                        system.debug(s.prices);
                        system.debug(acc.Renewal_Date__c);
                    Decimal sprice = pickCorrectPrice(s.prices, acc.Renewal_Date__c, acc.Renewal_Date__c);
                        for(Club_Product__c mt: mtList){                        
                            if((acc.FreeSections__c == true || mt.SectionsAreFree__c == true) && lea.Membership_Code__c == mt.Name){
                                sprice = 0;
                            }                           
                        }
                    costTotal+=sprice; 
                    }
                }
                
                o.Amount = costTotal;
                o.StageName = sc.complete;
                update o;
        
                List<Club_Opportunity_Product__c> cprods = [select id, recordtype.name,
                                                            product__c,Member_Section__c,status__c,
                                                            Opportunity__r.accountid 
                                                            from Club_Opportunity_Product__c 
                                                            where Opportunity__r.accountid = :acc.id
                                                            and status__c = :sc.active];
            
                for(Club_Opportunity_Product__c c:cprods){
                    c.status__c = sc.superseded;
                }
                
                update cprods;
        
                for(Club_Opportunity_Product__c c: o.line_items__r){
                    c.Status__c = 'Active';
                }
        
                update o.line_items__r;
                
        
                List<Club_Opportunity_Product__c> coptoadd = new List<Club_Opportunity_Product__c>();
                List<Club_Opportunity_Product__c> coptoupd = new List<Club_Opportunity_Product__c>();
                List<Club_Opportunity_Product__c> coptodel = new List<Club_Opportunity_Product__c>();
                List<Member_Section__c> ms = new List<Member_Section__c>();
        
                if(lea.hasPartner__c && cAssocMember.id!=null){
                    cAssocMember.Date_Ended__c = o.CloseDate;
                    update cAssocMember;
                    for(Club_Opportunity_Product__c c: o.line_items__r){
                        if(c.recordtypeid == sc.amRecordTypeId){
                            coptodel.add(c);
                        }
                    }
                }
                else if(lea.hasAssociate__c && cAssocMember.id!=null){
                    cAssocMember.Date_Ended__c = o.CloseDate;
                    update cAssocMember;
                    Contact assocContact = new Contact(recordtypeid=sc.associateContactRecordTypeId,
                                            Accountid = acc.Id,
                                            Date_Joined__c = o.CloseDate,
                                            firstname=lea.Associate_Member_First_Name__c,
                                            lastname=lea.Associate_Member_Surname__c,
                                            Salutation = lea.Associate_Member_Title__c,
                                            Birthdate = lea.Associate_Member_Date_of_Birth__c);
                    insert assocContact;
                }
                else if(lea.hasAssociate__c && cAssocMember.id==null){
                    Contact assocContact = new Contact(recordtypeid=sc.associateContactRecordTypeId,
                                            Accountid = acc.Id,
                                            Date_Joined__c = o.CloseDate,
                                            firstname=lea.Associate_Member_First_Name__c,
                                            lastname=lea.Associate_Member_Surname__c,
                                            Salutation = lea.Associate_Member_Title__c,
                                            Birthdate = lea.Associate_Member_Date_of_Birth__c);
                    insert assocContact;
                    coptoadd.add(new Club_Opportunity_Product__c(Product__c = plist[0].id,recordtypeid = sc.amRecordTypeId,  opportunity__c = o.id, price__c = amcost, account__c = acc.id,status__c = sc.active ));
                }
                system.debug(sections);
                for(sectionSelectWrapper s : sections){
                    if(s.selected){
                        Boolean found = false;
                        for(Club_Opportunity_Product__c c : o.line_items__r){
                            if(s.s.Id == c.Product__c)found=true;
                        }
                        if(!found){
                            Decimal sprice = pickCorrectPrice(s.prices, acc.Renewal_Date__c, acc.Renewal_Date__c);
                            for(Club_Product__c mt: mtList){                        
                                if((acc.FreeSections__c == true || mt.SectionsAreFree__c == true) && lea.Membership_Code__c == mt.Name){
                                    sprice = 0;
                                }                           
                            }
                            coptoadd.add(new Club_Opportunity_Product__c(recordtypeid = sc.sectionRecordTypeId, product__c = s.s.id, opportunity__c = o.id, price__c = sprice, account__c = acc.id,status__c = sc.active ));
                        }
                    }
                    else{
                        for(Club_Opportunity_Product__c c : o.line_items__r){
                            if(s.s.Id == c.Product__c){
                                coptodel.add(c);
                                break;
                            }
                        }
                    }
                }
        
    //            if(lea.Membership_Code__c != acc.Membership_Type_Name__c){
                    for(Club_Opportunity_Product__c c: o.line_items__r){
                        system.debug(c);
                        system.debug(c.recordtypeid);
                        system.debug(sc.mtRecordTypeId);
                        if(c.recordtypeid == sc.mtRecordTypeId){
                            system.debug(mtList);
                            for(Club_Product__c m:mtList){
                                system.debug(m.Name);
                                system.debug(lea.Membership_Code__c);
                                if(m.Name == lea.Membership_Code__c){
                                    for(Price__c p : m.Prices__r){
                                        system.debug(p.Payment_Type__c);
                                        system.debug(acc.Payment_Method2__c);
                                        system.debug(p.start_Date__c);
                                        system.debug(acc.Renewal_date__c);
                                        if(p.Start_Date__c <= acc.Renewal_Date__c && (p.End_Date__c >= acc.Renewal_Date__c || p.End_Date__c == null) && p.Payment_Type__c == lea.Payment_Method__c){
                                            system.debug('Line Item Renewal Date Loop');
                                            system.debug(acc.Renewal_Date__c);
                                            Club_Opportunity_Product__c ctu = c;
                                            ctu.Product__c = m.id;
                                            ctu.Price__c = p.price__c;
                                            acc.Membership_Code__c = m.id;
                                            acc.Renewal_Date__c = acc.Renewal_Date__c.addmonths(Integer.valueof(m.Membership_Length__c));
                                            coptoupd.add(ctu);
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
    //            }       
                if(coptoupd.size()>0){
                    update coptoupd;
                }
        
                acc.Membership_Status__c='Paid';
                //acc.Renewal_Date__c = acc.Renewal_Date__c.addmonths(12);
                
         
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
                
                delete [select id from lead where name=:o.id];
                system.debug('here');
    
                Decimal currprice=0;
                Decimal newprice=0;
                
                List<Club_Opportunity_Product__c> olilist = [select Price__c,Status__c from Club_Opportunity_Product__c where account__c = :acc.id];
                for(Club_Opportunity_Product__c c:olilist){
                    if(c.Status__c=='Active')currprice+=c.Price__c;
                    if(c.Status__c=='Pending')newprice+=c.Price__c;
                }
    
                Payment_Method__c pm = new Payment_Method__c();
                pm.Membership__c = acc.id;
                Payment_Method__c currentDD;
                try{
                    currentDD = [select id,Bank_Account_Name__c,Bank_Account_Number__c,Bank_Name__c,Sort_Code__c
                                 from payment_method__c 
                                 where recordtypeid=:sc.ddebitRecordTypeId
                                 and status__c='Active' 
                                 and Membership__c = :acc.id
                                 order by createddate desc
                                 limit 1];
                }
                catch(exception ex)
                {
                    currentDD=new Payment_Method__c();
                }
                if(lea.Payment_Method__c=='Debit/Credit Card'){
                    System.debug('tokenid = ' + tokenid);

                    pm.CC_Token__c = tokenid;
                    pm.recordtypeid = sc.CcardRecordTypeId;
                    pm.Authorization_code__c = acode;
                    acc.Payment_Method2__c = 'Debit/Credit Card';
                    if(tokenid!=null){
                        acc.Membership_Status__c='Paid';
                    }
                    else
                    {
                        acc.Membership_Status__c='Unpaid';
                    }
                }
                else if(lea.Payment_Method__c=='Direct Debit'){
                    if(currentDD.id==null || (currentDD.Bank_Account_Number__c!=lea.Bank_Account_Number__c
                                        || (String.isNotEmpty(lea.Sort_Code__c) && currentDD.Sort_Code__c!=lea.Sort_Code__c.replaceAll('[^0-9]', ''))) ){
                        pm.recordtypeid = sc.ddebitRecordTypeId;
                        pm.Bank_Account_Name__c = lea.Bank_Account_Name__c;
                        pm.Bank_Account_Number__c = lea.Bank_Account_Number__c;
                        pm.Bank_Name__c = lea.Bank_Name__c;
                        pm.Sort_Code__c = String.isNotEmpty(lea.Sort_Code__c) ? lea.Sort_Code__c.replaceAll('[^0-9]', '') : '';
                        acc.Membership_Status__c='DD Pending';
                        acc.Payment_Method2__c = 'Direct Debit';
                    }
                    else{
                        pm=currentDD;
                    }
                    if(newprice!=0){
                        pm.Mandate_Amount__c = newprice;
                    }
                    else{
                        pm.Mandate_Amount__c = currprice;
                    }
                }
                else if (lea.Payment_Method__c=='Cash/Cheque'){
                    pm.recordtypeid = sc.cashRecordTypeId;
                    acc.Membership_Status__c='Paid';
                    acc.Payment_Method2__c = 'Cash/Cheque';
                }
                pm.Status__c = 'Active';
                pm.start_date__c = Date.today();
                upsert pm;
    
                o.Payment_Method__c = pm.id;
                update o;
        
                Transaction__c tr;
                if(lea.Payment_Method__c=='Debit/Credit Card'){
                    tr = new Transaction__c(Amount__c=costTotal);
                    tr.Payment_Method__c = pm.id;
                    tr.Authorization_code__c = acode;
                    tr.recordtypeid = sc.trCcardRecordTypeId;
                    if(tokenid!=null){
                        tr.Transaction_Date__c = date.today();
                    }
                }
                else if (lea.Payment_Method__c=='Cash/Cheque'){
                    tr = new Transaction__c(Amount__c=costTotal);
                    tr.Payment_Method__c = pm.id;
                    tr.recordtypeid = sc.trcashRecordTypeId;
                }
                
                if(tr!=null)insert tr;
                update acc;
            }    
            return  new PageReference('/'+acc.id);      
        }
        else
        {
            CreateMember cm = new CreateMember();
                
            Database.LeadConvertResult lcr = cm.createMembershipfromLead(lea,tokenid,acode);
            
            return new PageReference('/'+lcr.accountId);
        }
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
            system.debug(sections);
            if(sections==null){
                sections = new List<sectionSelectWrapper>();
                Date now = Date.today();
                List<Club_Product__c> sprods = new List<Club_Product__c>();
                system.debug(globalAcc);
                sprods = [select id,recordtypeid,name,Product_Detail__c,(select Start_Date__c, End_Date__c, Price__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: globalAcc.Renewal_Date__c and (End_Date__c>=:globalAcc.Renewal_Date__c or End_Date__c=null)) order by Start_Date__c DESC) from club_product__c where recordtype.name='Section' order by name];                
                system.debug(sprods);
                for(club_product__c s:sprods){
                    List<price__c> pr = s.prices__r;
                    system.debug(pr);
                    if(pr.size()>0){
                        sections.add(new sectionSelectWrapper(s,s.prices__r));
                    }
                }
            }
            return sections;
        } 
        set;
    }

    Map<string,club_product__c> mapPrices{
        get{
            if(mapPrices==null){
                mapPrices=new Map<string,club_product__c>();
                Date now = Date.today();
                List<Club_Product__c> pList = new List<Club_Product__c>();
                pList = [select id,name,Product_Detail__c,(select Start_Date__c, End_Date__c, Price__c,change_fee__c from Prices__r where (Start_Date__c<=:now and (End_Date__c>=:now or End_Date__c=null)) OR (Start_Date__c <=: globalAcc.Renewal_Date__c and (End_Date__c>=:globalAcc.Renewal_Date__c or End_Date__c=null)) OR (Start_Date__c<=:week8date and (End_Date__c>=:week8date or End_Date__c=null)) order by Start_Date__c DESC) from club_product__c where recordtype.name='Associate Membership' order by name];                   
                system.debug(pList);
               for(Club_Product__c p:plist){
                    List<price__c> pr = p.prices__r;
                    system.debug(pr);
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
}