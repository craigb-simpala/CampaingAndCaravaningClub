@isTest
private class ValidatePostcodeExtensionTests {

    static testMethod void ValidatePostcodeExtensionTest() {
        // TO DO: implement unit test
        
       Account acc = new Account (Name = 'Patel', BillingPostalCode='M50 2ZY', BillingCity='Manchester', BillingState='United Kingdom');
       insert acc;
       
      Test.setCurrentPage(Page.ValidatePostcode);
      ValidatePostcodeExtension controller = new ValidatePostcodeExtension(new ApexPages.StandardController(acc));
      
      
       Map<Integer,hopewiserSoapaddrsvr.addressMatchType> hpamtMap = new Map<Integer,hopewiserSoapaddrsvr.addressMatchType>();
       hopewiserSoapaddrsvr.addressMatchType hpamt = new hopewiserSoapaddrsvr.addressMatchType();
       hopewiserSoapaddrsvr.addressType addr = new hopewiserSoapaddrsvr.addressType();
       addr.Line1 = '4';
       addr.Line2 = 'Carolina Way';
       addr.Line3 = 'Quays Reach';
       addr.Line4 = 'M50 2ZY';
       addr.Town = 'Manchester';
       hpamt.Address = addr;
       hpamtMap.put(5, hpamt);
       hopewiserSoapaddrsvr.addressMatchType hpamt2 = new hopewiserSoapaddrsvr.addressMatchType();
       hopewiserSoapaddrsvr.addressType addr2 = new hopewiserSoapaddrsvr.addressType();
       addr2.Line1 = '3';
       addr2.Line2 = 'Carolina Way';
       addr2.Line3 = 'Quays Reach';
       addr2.Postcode = 'M50 2ZY';
       addr2.Line5 = 'Manchester';
       addr2.Town = 'Greater Manchester';
       addr2.County = 'U.K';
       hpamt2.Address = addr2;
       hpamtMap.put(0, hpamt2);
       controller.seladdr = '0';
       controller.addMatch = hpamtMap;
       
      String selAddr = controller.selAddr;
      Map<Integer,hopewiserSoapaddrsvr.addressMatchType> addMatch = controller.addMatch;
      PageReference validate = controller.validate();
      PageReference updateAddress = controller.updateAddress();
      
      
      controller.addMatch = new Map<Integer,hopewiserSoapaddrsvr.addressMatchType>();
      List<SelectOption> addressOptions = controller.addressOptions;
    }
}