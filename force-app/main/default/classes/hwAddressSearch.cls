public with sharing class hwAddressSearch {

    public String Input1{get;set;}
    public String Input2{get;set;}
    public String Input3{get;set;}
    public String Input4{get;set;}
    public String Input5{get;set;}
    public String Input6{get;set;}
    public String Input7{get;set;}
    public String Input8{get;set;}
    public String Input9{get;set;}
    public String Input10{get;set;}

    public String aline1{get;set;}
    public String aline2{get;set;}
    public String aline3{get;set;}
    public String aline4{get;set;}
    public String aline5{get;set;}
    public String atown{get;set;}
    public String acounty{get;set;}
    public String apostcode{get;set;}
    
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
    
    public String addr1{get;set;}
    public String addr2{get;set;}
    
    public List<SelectOption> dispoptions{
    	get{
    		if(dispoptions==null)
    		{
    			dispoptions = new List<SelectOption>();
    			dispoptions.add(new Selectoption('','Please Select'));
    			if(results!=null){
					if(results.match!=null){
			    		for(Integer i=0;i<results.match.size();i++)
			            {
			            	hopewiserSoapaddrsvr.searchMatchType m=results.match[i];
			    			dispoptions.add(new Selectoption(String.valueOf(i),m.text));
			            }
					}
    			}
    		}
    		return dispoptions;
    	}
    	set;
    }

    public List<SelectOption> dispoptions2{
    	get;set;
    }

    public void filladdress(){
    	system.debug(addr1);
    	addr2=null;
    	system.debug(results.Match[Integer.valueof(addr1)]);
    	if(results.Match[Integer.valueof(addr1)].Expandable=='yes')
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
            
            system.debug(results.Match[Integer.valueof(addr1)].SID);
            results2 = r.AddressExpand(results.Match[Integer.valueof(addr1)].SID,asro);
    		dispoptions2=null;
			dispoptions2 = new List<SelectOption>();
			dispoptions2.add(new Selectoption('','Please Select'));
			if(results2!=null){
				for(Integer i=0;i<results2.match.size();i++)
	            {
	            	hopewiserSoapaddrsvr.searchMatchType m=results2.match[i];
	    			dispoptions2.add(new Selectoption(String.valueOf(i),m.text));
	            }
   			}
    	}
    	else
    	{
	    	system.debug(addr1);
	    	system.debug(results.Match[Integer.valueof(addr1)]);
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
	            
	        system.debug(results.Match[Integer.valueof(addr1)].SID);
	        address = r.AddressDetails(results.Match[Integer.valueof(addr1)].SID,asro,flo,dt,ed);
	        aline1=address.Match.Address.Line1;
	        aline2=address.Match.Address.Line2;
	        aline3=address.Match.Address.Line3;
	        aline4=address.Match.Address.Line4;
	        aline5=address.Match.Address.Line5;
	        atown=address.Match.Address.town;
	        acounty=address.Match.Address.county;
	        apostcode=address.Match.Address.Postcode;
    		
    	}
    }

    public void filladdress2(){
    	system.debug(addr2);
    	system.debug(results2.Match[Integer.valueof(addr2)]);
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
            
        system.debug(results2.Match[Integer.valueof(addr2)].SID);
        address = r.AddressDetails(results2.Match[Integer.valueof(addr2)].SID,asro,flo,dt,ed);
        aline1=address.Match.Address.Line1;
        aline2=address.Match.Address.Line2;
        aline3=address.Match.Address.Line3;
        aline4=address.Match.Address.Line4;
        aline5=address.Match.Address.Line5;
        atown=address.Match.Address.town;
        acounty=address.Match.Address.county;
        apostcode=address.Match.Address.Postcode;
    }

	
	public hwAddressSearch(){
	}

    public void validate()
    {
    		dispoptions=null;
    		dispoptions2=null;
    		addr1=null;
    		addr2=null;
            hopewiserSoapaddrsvr aSearch = new hopewiserSoapaddrsvr();
            hopewiserSoapaddrsvr.addressSearchRequestOptionsType asro = new hopewiserSoapaddrsvr.addressSearchRequestOptionsType();
            hopewiserSoapaddrsvr.formattedLabelOptionsType flo = new hopewiserSoapaddrsvr.formattedLabelOptionsType();
            hopewiserSoapaddrsvr.dataType dt = new hopewiserSoapaddrsvr.dataType();
            hopewiserSoapaddrsvr.dataType ed = new hopewiserSoapaddrsvr.dataType();
            String postcode = 'L1 4GF';
            String Premise = '';
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
            
            results = r.AddressSearch(Input1,Input2,Input3,Input4,Input5,Input6,Input7,Input8,Input9,Input10,MAF,asro);
            
			if(results.match==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,results.StatusDesc));
                dispoptions=null;
			}
			else
			{
                dispoptions=null;
	            for(hopewiserSoapaddrsvr.searchMatchType m: results.Match)
	            {
	                system.debug(m.text);
	            }
			}
            
    }

}