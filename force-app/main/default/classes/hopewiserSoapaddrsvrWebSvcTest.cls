@isTest
private class hopewiserSoapaddrsvrWebSvcTest {
	
	@isTest static void coverGeneratedCodeTypes() {
		Test.setMock(WebServiceMock.class, new hopewiserSoapaddrsvrMockImpl());
		hopewiserSoapaddrsvr parentObject = new hopewiserSoapaddrsvr();
		new docsOasisOpenOrgWss200401Oasis20040.securityType();
		new docsOasisOpenOrgWss200401Oasis20040.usernameTokenType();
		new hopewiserSoapaddrsvr.AddressDetailsRequest_element();
		new hopewiserSoapaddrsvr.addressDetailsRequestOptionsType();
		new hopewiserSoapaddrsvr.AddressDetailsResponse_element();
		new hopewiserSoapaddrsvr.AddressExpandRequest_element();
		new hopewiserSoapaddrsvr.addressExpandRequestOptionsType();
		new hopewiserSoapaddrsvr.AddressExpandResponse_element();
		new hopewiserSoapaddrsvr.addressMatchType();
		new hopewiserSoapaddrsvr.AddressSearchRequest_element();
		new hopewiserSoapaddrsvr.addressSearchRequestOptionsType();
		new hopewiserSoapaddrsvr.AddressSearchResponse_element();
		new hopewiserSoapaddrsvr.addressType();
		new hopewiserSoapaddrsvr.alternateType();
		new hopewiserSoapaddrsvr.dataType();
		new hopewiserSoapaddrsvr.dataValueType();
		new hopewiserSoapaddrsvr.defaultType();
		new hopewiserSoapaddrsvr.extraDataRecordType();
		new hopewiserSoapaddrsvr.ExtraDataRequest_element();
		new hopewiserSoapaddrsvr.ExtraDataResponse_element();
		new hopewiserSoapaddrsvr.formattedLabelOptionsType();
		new hopewiserSoapaddrsvr.formattedLabelType();
		new hopewiserSoapaddrsvr.itemValueType();
		new hopewiserSoapaddrsvr.mafType();
		new hopewiserSoapaddrsvr.PostcodeLookupRequest_element();
		new hopewiserSoapaddrsvr.postcodeLookupRequestOptionsType();
		new hopewiserSoapaddrsvr.PostcodeLookupResponse_element();
		new hopewiserSoapaddrsvr.searchMatchType();
		new hopewiserSoapaddrsvr.StatusRequest_element();
		new hopewiserSoapaddrsvr.StatusResponse_element();
		new hopewiserSoapaddrsvr.VersionRequest_element();
		new hopewiserSoapaddrsvr.VersionResponse_element();
	}
	@isTest static void coverCodeForAddressDetails(){
		Test.setMock(WebServiceMock.class, new hopewiserSoapaddrsvrMockImpl());
		hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11 testObject = new hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11();
        hopewiserSoapaddrsvr.AddressDetailsResponse_element a = testObject.AddressDetails(null, null, null, null, null);
		//System.assertEquals(null, testObject.AddressDetails(null, null, null, null, null));
	}
	@isTest static void coverCodeForAddressExpand(){
		Test.setMock(WebServiceMock.class, new hopewiserSoapaddrsvrMockImpl());
		hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11 testObject = new hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11();
        hopewiserSoapaddrsvr.AddressExpandResponse_element a = testObject.AddressExpand(null, null);
		//System.assertEquals(null, testObject.AddressExpand(null, null));
	}
	@isTest static void coverCodeForAddressSearch(){
		Test.setMock(WebServiceMock.class, new hopewiserSoapaddrsvrMockImpl());
		hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11 testObject = new hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11();
        hopewiserSoapaddrsvr.AddressSearchResponse_element a = testObject.AddressSearch(null, null, null, null, null, null, null, null, null, null, null, null);
		//System.assertEquals(null, testObject.AddressSearch(null, null, null, null, null, null, null, null, null, null, null, null));
	}
	@isTest static void coverCodeForExtraData(){
		Test.setMock(WebServiceMock.class, new hopewiserSoapaddrsvrMockImpl());
		hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11 testObject = new hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11();
        hopewiserSoapaddrsvr.ExtraDataResponse_element a = testObject.ExtraData(null);
		//System.assertEquals(null, testObject.ExtraData(null));
	}
	@isTest static void coverCodeForPostcodeLookup(){
		Test.setMock(WebServiceMock.class, new hopewiserSoapaddrsvrMockImpl());
		hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11 testObject = new hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11();
        hopewiserSoapaddrsvr.PostcodeLookupResponse_element a = testObject.PostcodeLookup(null, null, null, null, null, null, null);
		//System.assertEquals(null, testObject.PostcodeLookup(null, null, null, null, null, null, null));
	}
	@isTest static void coverCodeForStatus(){
		Test.setMock(WebServiceMock.class, new hopewiserSoapaddrsvrMockImpl());
		hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11 testObject = new hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11();
        hopewiserSoapaddrsvr.StatusResponse_element a = testObject.Status();
		//System.assertEquals(null, testObject.Status());
	}
	@isTest static void coverCodeForVersion(){
		Test.setMock(WebServiceMock.class, new hopewiserSoapaddrsvrMockImpl());
		hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11 testObject = new hopewiserSoapaddrsvr.soapaddrsvrInterfaceSoap11();
        hopewiserSoapaddrsvr.VersionResponse_element a = testObject.Version();
		//System.assertEquals(null, testObject.Version());
	}
}