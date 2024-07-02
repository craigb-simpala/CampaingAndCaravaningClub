public with sharing class ValidatePostcodeExtension {

    private final Account acct;
    ApexPages.StandardController sController;  
    
    public ValidatePostcodeExtension(ApexPages.StandardController stdController) {
        sController = stdController;  
        this.acct = (Account)stdController.getRecord();
        wizardStep = 1;
    }

    public Integer wizardStep {get;set;}
    public String selAddr {get;set;}

    public Map<Integer,hopewiserSoapaddrsvr.addressMatchType> addMatch {
        get{
            if(addMatch==null){
                addMatch = new Map<Integer,hopewiserSoapaddrsvr.addressMatchType>();
            }
            return addMatch;
        }
        set;
    }


    public PageReference validate()
    {
            hopewiserSoapaddrsvr pclook = new hopewiserSoapaddrsvr();
            hopewiserSoapaddrsvr.postcodeLookupRequestOptionsType plro = new hopewiserSoapaddrsvr.postcodeLookupRequestOptionsType();
            hopewiserSoapaddrsvr.formattedLabelOptionsType flo = new hopewiserSoapaddrsvr.formattedLabelOptionsType();
            hopewiserSoapaddrsvr.dataType dt = new hopewiserSoapaddrsvr.dataType();
            hopewiserSoapaddrsvr.dataType ed = new hopewiserSoapaddrsvr.dataType();
            String postcode = acct.BillingPostalCode;
            //postcode = 'L1 4GF';
            String Premise = '';
            String MAF = '';
            
            docsOasisOpenOrgWss200401Oasis20040.securityType sectype = new docsOasisOpenOrgWss200401Oasis20040.securityType();
            docsOasisOpenOrgWss200401Oasis20040.usernameTokenType sectoken = new docsOasisOpenOrgWss200401Oasis20040.usernameTokenType();
            sectoken.Username ='stuart.greig@sandyxsystems.co.uk';
            sectoken.password ='K4RfVEVL';
            
            hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11 r= new hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11();
            sectype.UsernameToken = sectoken;
            r.Security = sectype;
            if(!test.isRunningTest()){
            hopewiserSoapaddrsvr.PostcodeLookupResponse_element rv = r.PostcodeLookup(postcode,premise,MAF,plro,flo,dt,ed);
            
            system.debug(rv);
                        
            if(rv.Match!=null)
            {
                wizardstep=2;
                Integer i=0;
                for(hopewiserSoapaddrsvr.addressMatchType m: rv.Match)
                {
                    addMatch.put(i,m);
                    system.debug(m.Address);
                    ++i;
                }
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

        return null;
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
        if(addr.Line1 !=null)address+=addr.Line1+' ,';
        if(addr.Line2 !=null)address+=addr.Line2+' ,';
        if(addr.Line3 !=null)address+=addr.Line3+' ,';
        if(addr.Line4 !=null)address+=addr.Line4+' ,';
        if(addr.Line5 !=null)address+=addr.Line5+' ,';
        if(addr.TOWN !=null)address+=addr.TOWN+' ,';
        if(addr.County !=null)address+=addr.County+' ,';
        if(addr.Postcode !=null)address+=addr.Postcode+' ,';
        address = address.removeEnd(',');
        
        return address;
        
    }

    private String billAddress(hopewiserSoapaddrsvr.addressType addr){
        String address ='';
        if(addr.Line1 !=null)address+=addr.Line1+'\r\n';
        if(addr.Line2 !=null)address+=addr.Line2+'\r\n';
        if(addr.Line3 !=null)address+=addr.Line3+'\r\n';
        if(addr.Line4 !=null)address+=addr.Line4+'\r\n';
        if(addr.Line5 !=null)address+=addr.Line5+'';
        
        return Address;
    }

    public PageReference updateAddress(){
        if(seladdr==null)
        {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No Address Selected'));
                return null;
        }

        List<DA_Postcode__c> dap = new List<DA_Postcode__c>();
        
        acct.BillingStreet = billAddress(addMatch.get(integer.valueOf(seladdr)).Address);
        acct.BillingCity = addMatch.get(integer.valueOf(seladdr)).Address.Town;
        acct.BillingState = addMatch.get(integer.valueOf(seladdr)).Address.County;
        acct.BillingPostalCode = addMatch.get(integer.valueOf(seladdr)).Address.Postcode;

        List<String> parts = acct.BillingPostalCode.split(' ');
        String pcodeout = parts[0];
        String pcodein = parts[1].substring(0, 1); 
        
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

        
        PageReference pr = sController.save(); 
        
        return pr;
    }

}