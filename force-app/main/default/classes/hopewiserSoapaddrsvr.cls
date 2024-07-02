//Methods Included: AddressDetails, AddressExpand, AddressSearch, Version, Status, ExtraData, PostcodeLookup
// Primary Port Class Name: soapaddrsvrInterfaceSoap11	
public class hopewiserSoapaddrsvr {
	public class AddressDetailsRequest_element {
		public String SID;
		public hopewiserSoapaddrsvr.addressDetailsRequestOptionsType RequestOptions;
		public hopewiserSoapaddrsvr.formattedLabelOptionsType FormattedLabelOptions;
		public hopewiserSoapaddrsvr.dataType Data;
		public hopewiserSoapaddrsvr.dataType ExtraData;
		private String[] SID_type_info = new String[]{'SID','http://hopewiser/soapaddrsvr','string','1','1','false'};
		private String[] RequestOptions_type_info = new String[]{'RequestOptions','http://hopewiser/soapaddrsvr','addressDetailsRequestOptionsType','0','1','false'};
		private String[] FormattedLabelOptions_type_info = new String[]{'FormattedLabelOptions','http://hopewiser/soapaddrsvr','formattedLabelOptionsType','0','1','false'};
		private String[] Data_type_info = new String[]{'Data','http://hopewiser/soapaddrsvr','dataType','0','1','false'};
		private String[] ExtraData_type_info = new String[]{'ExtraData','http://hopewiser/soapaddrsvr','dataType','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'SID','RequestOptions','FormattedLabelOptions','Data','ExtraData'};
	}
	public class addressDetailsRequestOptionsType {
		public Integer Timeout;
		public String AddressType;
		private String[] Timeout_type_info = new String[]{'Timeout','http://hopewiser/soapaddrsvr','positiveInteger','0','1','false'};
		private String[] AddressType_type_info = new String[]{'AddressType','http://hopewiser/soapaddrsvr','addressTypeString','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'Timeout','AddressType'};
	}
	public class AddressDetailsResponse_element {
		public Integer StatusCode;
		public String StatusDesc;
		public hopewiserSoapaddrsvr.addressMatchType Match;
		private String[] StatusCode_type_info = new String[]{'StatusCode','http://hopewiser/soapaddrsvr','integer','1','1','false'};
		private String[] StatusDesc_type_info = new String[]{'StatusDesc','http://hopewiser/soapaddrsvr','string','1','1','false'};
		private String[] Match_type_info = new String[]{'Match','http://hopewiser/soapaddrsvr','addressMatchType','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'StatusCode','StatusDesc','Match'};
	}
	public class AddressExpandRequest_element {
		public String SID;
		public hopewiserSoapaddrsvr.addressExpandRequestOptionsType RequestOptions;
		private String[] SID_type_info = new String[]{'SID','http://hopewiser/soapaddrsvr','string','1','1','false'};
		private String[] RequestOptions_type_info = new String[]{'RequestOptions','http://hopewiser/soapaddrsvr','addressExpandRequestOptionsType','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'SID','RequestOptions'};
	}
	public class addressExpandRequestOptionsType {
		public Integer Timeout;
		private String[] Timeout_type_info = new String[]{'Timeout','http://hopewiser/soapaddrsvr','positiveInteger','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'Timeout'};
	}
	public class AddressExpandResponse_element {
		public Integer StatusCode;
		public String StatusDesc;
		public hopewiserSoapaddrsvr.searchMatchType[] Match;
		private String[] StatusCode_type_info = new String[]{'StatusCode','http://hopewiser/soapaddrsvr','integer','1','1','false'};
		private String[] StatusDesc_type_info = new String[]{'StatusDesc','http://hopewiser/soapaddrsvr','string','1','1','false'};
		private String[] Match_type_info = new String[]{'Match','http://hopewiser/soapaddrsvr','searchMatchType','0','-1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'StatusCode','StatusDesc','Match'};
	}
	public class addressMatchType {
		public hopewiserSoapaddrsvr.addressType Address;
		public hopewiserSoapaddrsvr.formattedLabelType FormattedLabel;
		public hopewiserSoapaddrsvr.dataValueType Data;
		public hopewiserSoapaddrsvr.extraDataRecordType[] ExtraDataRecord;
		private String[] Address_type_info = new String[]{'Address','http://hopewiser/soapaddrsvr','addressType','0','1','false'};
		private String[] FormattedLabel_type_info = new String[]{'FormattedLabel','http://hopewiser/soapaddrsvr','formattedLabelType','0','1','false'};
		private String[] Data_type_info = new String[]{'Data','http://hopewiser/soapaddrsvr','dataValueType','0','1','false'};
		private String[] ExtraDataRecord_type_info = new String[]{'ExtraDataRecord','http://hopewiser/soapaddrsvr','extraDataRecordType','0','-1','false'};
		public Integer number_x;
		public String[] number_x_att_info = new String[]{'number'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'Address','FormattedLabel','Data','ExtraDataRecord'};
	}
	public class AddressSearchRequest_element {
		public String Input1;
		public String Input2;
		public String Input3;
		public String Input4;
		public String Input5;
		public String Input6;
		public String Input7;
		public String Input8;
		public String Input9;
		public String Input10;
		public String MAF;
		public hopewiserSoapaddrsvr.addressSearchRequestOptionsType RequestOptions;
		private String[] Input1_type_info = new String[]{'Input1','http://hopewiser/soapaddrsvr','string','1','1','false'};
		private String[] Input2_type_info = new String[]{'Input2','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Input3_type_info = new String[]{'Input3','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Input4_type_info = new String[]{'Input4','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Input5_type_info = new String[]{'Input5','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Input6_type_info = new String[]{'Input6','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Input7_type_info = new String[]{'Input7','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Input8_type_info = new String[]{'Input8','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Input9_type_info = new String[]{'Input9','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Input10_type_info = new String[]{'Input10','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] MAF_type_info = new String[]{'MAF','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] RequestOptions_type_info = new String[]{'RequestOptions','http://hopewiser/soapaddrsvr','addressSearchRequestOptionsType','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'Input1','Input2','Input3','Input4','Input5','Input6','Input7','Input8','Input9','Input10','MAF','RequestOptions'};
	}
	public class addressSearchRequestOptionsType {
		public Integer MaxMatches;
		public Integer Timeout;
		public String SearchMethod;
		public String IncludeWelsh;
		public String IncludePersonNames;
		private String[] MaxMatches_type_info = new String[]{'MaxMatches','http://hopewiser/soapaddrsvr','positiveInteger','0','1','false'};
		private String[] Timeout_type_info = new String[]{'Timeout','http://hopewiser/soapaddrsvr','positiveInteger','0','1','false'};
		private String[] SearchMethod_type_info = new String[]{'SearchMethod','http://hopewiser/soapaddrsvr','searchMethodString','0','1','false'};
		private String[] IncludeWelsh_type_info = new String[]{'IncludeWelsh','http://hopewiser/soapaddrsvr','yesNoString','0','1','false'};
		private String[] IncludePersonNames_type_info = new String[]{'IncludePersonNames','http://hopewiser/soapaddrsvr','yesNoString','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'MaxMatches','Timeout','SearchMethod','IncludeWelsh','IncludePersonNames'};
	}
	public class AddressSearchResponse_element {
		public Integer StatusCode;
		public String StatusDesc;
		public hopewiserSoapaddrsvr.searchMatchType[] Match;
		private String[] StatusCode_type_info = new String[]{'StatusCode','http://hopewiser/soapaddrsvr','integer','1','1','false'};
		private String[] StatusDesc_type_info = new String[]{'StatusDesc','http://hopewiser/soapaddrsvr','string','1','1','false'};
		private String[] Match_type_info = new String[]{'Match','http://hopewiser/soapaddrsvr','searchMatchType','0','-1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'StatusCode','StatusDesc','Match'};
	}
	public class addressType {
		public String Organisation;
		public String Department;
		public String Line1;
		public String Line2;
		public String Line3;
		public String Line4;
		public String Line5;
		public String Town;
		public String County;
		public String Postcode;
		public String DP;
		private String[] Organisation_type_info = new String[]{'Organisation','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Department_type_info = new String[]{'Department','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Line1_type_info = new String[]{'Line1','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Line2_type_info = new String[]{'Line2','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Line3_type_info = new String[]{'Line3','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Line4_type_info = new String[]{'Line4','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Line5_type_info = new String[]{'Line5','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Town_type_info = new String[]{'Town','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] County_type_info = new String[]{'County','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Postcode_type_info = new String[]{'Postcode','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] DP_type_info = new String[]{'DP','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'Organisation','Department','Line1','Line2','Line3','Line4','Line5','Town','County','Postcode','DP'};
	}
	public class alternateType {
		public hopewiserSoapaddrsvr.mafType[] MAF;
		private String[] MAF_type_info = new String[]{'MAF','http://hopewiser/soapaddrsvr','mafType','1','-1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'MAF'};
	}
	public class dataType {
		public String[] Item;
		private String[] Item_type_info = new String[]{'Item','http://hopewiser/soapaddrsvr','string','1','-1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'Item'};
	}
	public class dataValueType {
		public hopewiserSoapaddrsvr.itemValueType[] Item;
		private String[] Item_type_info = new String[]{'Item','http://hopewiser/soapaddrsvr','itemValueType','1','-1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'Item'};
	}
	public class defaultType {
		public hopewiserSoapaddrsvr.mafType MAF;
		private String[] MAF_type_info = new String[]{'MAF','http://hopewiser/soapaddrsvr','mafType','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'MAF'};
	}
	public class extraDataRecordType {
		public hopewiserSoapaddrsvr.itemValueType[] Item;
		private String[] Item_type_info = new String[]{'Item','http://hopewiser/soapaddrsvr','itemValueType','1','-1','false'};
		public Integer number_x;
		public String[] number_x_att_info = new String[]{'number'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'Item'};
	}
	public class ExtraDataRequest_element {
		public String MAF;
		private String[] MAF_type_info = new String[]{'MAF','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'MAF'};
	}
	public class ExtraDataResponse_element {
		public Integer StatusCode;
		public String StatusDesc;
		public hopewiserSoapaddrsvr.dataType ExtraData;
		private String[] StatusCode_type_info = new String[]{'StatusCode','http://hopewiser/soapaddrsvr','integer','1','1','false'};
		private String[] StatusDesc_type_info = new String[]{'StatusDesc','http://hopewiser/soapaddrsvr','string','1','1','false'};
		private String[] ExtraData_type_info = new String[]{'ExtraData','http://hopewiser/soapaddrsvr','dataType','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'StatusCode','StatusDesc','ExtraData'};
	}
	public class formattedLabelOptionsType {
		public String OrganisationFormat;
		public String LabelFormat;
		public String IncludeCounty;
		public String DropCountyToFit;
		public String CaseFormat;
		public Integer NumLines;
		public Integer LineWidth;
		private String[] OrganisationFormat_type_info = new String[]{'OrganisationFormat','http://hopewiser/soapaddrsvr','organisationFormatString','0','1','false'};
		private String[] LabelFormat_type_info = new String[]{'LabelFormat','http://hopewiser/soapaddrsvr','labelFormatString','0','1','false'};
		private String[] IncludeCounty_type_info = new String[]{'IncludeCounty','http://hopewiser/soapaddrsvr','includeCountyString','0','1','false'};
		private String[] DropCountyToFit_type_info = new String[]{'DropCountyToFit','http://hopewiser/soapaddrsvr','yesNoString','0','1','false'};
		private String[] CaseFormat_type_info = new String[]{'CaseFormat','http://hopewiser/soapaddrsvr','caseFormatString','0','1','false'};
		private String[] NumLines_type_info = new String[]{'NumLines','http://hopewiser/soapaddrsvr','numLinesInteger','0','1','false'};
		private String[] LineWidth_type_info = new String[]{'LineWidth','http://hopewiser/soapaddrsvr','lineWidthInteger','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'OrganisationFormat','LabelFormat','IncludeCounty','DropCountyToFit','CaseFormat','NumLines','LineWidth'};
	}
	public class formattedLabelType {
		public String Line1;
		public String Line2;
		public String Line3;
		public String Line4;
		public String Line5;
		public String Line6;
		public String Line7;
		public String Line8;
		public String Line9;
		private String[] Line1_type_info = new String[]{'Line1','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Line2_type_info = new String[]{'Line2','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Line3_type_info = new String[]{'Line3','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Line4_type_info = new String[]{'Line4','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Line5_type_info = new String[]{'Line5','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Line6_type_info = new String[]{'Line6','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Line7_type_info = new String[]{'Line7','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Line8_type_info = new String[]{'Line8','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Line9_type_info = new String[]{'Line9','http://hopewiser/soapaddrsvr','string','0','1','false'};
		public String status;
		public String[] status_att_info = new String[]{'status'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'Line1','Line2','Line3','Line4','Line5','Line6','Line7','Line8','Line9'};
	}
	
	//Warning: Simple Content Types with Attributes are not supported by WebServiceCallout.invoke
	public class itemValueType {
		public String input;
		private String[] input_type_info = new String[]{'input','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		public String name;
		public String[] name_att_info = new String[]{'name'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{};
	}
	
	//Warning: Simple Content Types with Attributes are not supported by WebServiceCallout.invoke
	public class mafType {
		public String input;
		private String[] input_type_info = new String[]{'input','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		public String version;
		public String[] version_att_info = new String[]{'version'};
		public String blockedReason;
		public String[] blockedReason_att_info = new String[]{'blockedReason'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{};
	}
	public class PostcodeLookupRequest_element {
		public String Postcode;
		public String Premise;
		public String MAF;
		public hopewiserSoapaddrsvr.postcodeLookupRequestOptionsType RequestOptions;
		public hopewiserSoapaddrsvr.formattedLabelOptionsType FormattedLabelOptions;
		public hopewiserSoapaddrsvr.dataType Data;
		public hopewiserSoapaddrsvr.dataType ExtraData;
		private String[] Postcode_type_info = new String[]{'Postcode','http://hopewiser/soapaddrsvr','string','1','1','false'};
		private String[] Premise_type_info = new String[]{'Premise','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] MAF_type_info = new String[]{'MAF','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] RequestOptions_type_info = new String[]{'RequestOptions','http://hopewiser/soapaddrsvr','postcodeLookupRequestOptionsType','0','1','false'};
		private String[] FormattedLabelOptions_type_info = new String[]{'FormattedLabelOptions','http://hopewiser/soapaddrsvr','formattedLabelOptionsType','0','1','false'};
		private String[] Data_type_info = new String[]{'Data','http://hopewiser/soapaddrsvr','dataType','0','1','false'};
		private String[] ExtraData_type_info = new String[]{'ExtraData','http://hopewiser/soapaddrsvr','dataType','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'Postcode','Premise','MAF','RequestOptions','FormattedLabelOptions','Data','ExtraData'};
	}
	public class postcodeLookupRequestOptionsType {
		public Integer MaxMatches;
		public Integer Timeout;
		public String AddressType;
		public String IncludeWelsh;
		private String[] MaxMatches_type_info = new String[]{'MaxMatches','http://hopewiser/soapaddrsvr','positiveInteger','0','1','false'};
		private String[] Timeout_type_info = new String[]{'Timeout','http://hopewiser/soapaddrsvr','positiveInteger','0','1','false'};
		private String[] AddressType_type_info = new String[]{'AddressType','http://hopewiser/soapaddrsvr','addressTypeString','0','1','false'};
		private String[] IncludeWelsh_type_info = new String[]{'IncludeWelsh','http://hopewiser/soapaddrsvr','yesNoString','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'MaxMatches','Timeout','AddressType','IncludeWelsh'};
	}
	public class PostcodeLookupResponse_element {
		public Integer StatusCode;
		public String StatusDesc;
		public hopewiserSoapaddrsvr.addressMatchType[] Match;
		private String[] StatusCode_type_info = new String[]{'StatusCode','http://hopewiser/soapaddrsvr','integer','1','1','false'};
		private String[] StatusDesc_type_info = new String[]{'StatusDesc','http://hopewiser/soapaddrsvr','string','1','1','false'};
		private String[] Match_type_info = new String[]{'Match','http://hopewiser/soapaddrsvr','addressMatchType','0','-1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'StatusCode','StatusDesc','Match'};
	}
	public class searchMatchType {
		public String SID;
		public String Text;
		public String Expandable;
		private String[] SID_type_info = new String[]{'SID','http://hopewiser/soapaddrsvr','string','1','1','false'};
		private String[] Text_type_info = new String[]{'Text','http://hopewiser/soapaddrsvr','string','1','1','false'};
		private String[] Expandable_type_info = new String[]{'Expandable','http://hopewiser/soapaddrsvr','yesNoString','1','1','false'};
		public Integer number_x;
		public String[] number_x_att_info = new String[]{'number'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'SID','Text','Expandable'};
	}
	public class soapaddrsvrInterfaceSoap11 {
		public String endpoint_x = 'https://cloud.hopewiser.com:443/soapaddrsvr/';
		public Map<String,String> inputHttpHeaders_x;
		public Map<String,String> outputHttpHeaders_x;
		public String clientCertName_x;
		public String clientCert_x;
		public String clientCertPasswd_x;
		public Integer timeout_x;
		public docsOasisOpenOrgWss200401Oasis20040.securityType Security;
		private String Security_hns = 'Security=http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
		private String[] ns_map_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','docsOasisOpenOrgWss200401Oasis20040'};

		public hopewiserSoapaddrsvr.AddressDetailsResponse_element AddressDetails(String SID,hopewiserSoapaddrsvr.addressDetailsRequestOptionsType RequestOptions,hopewiserSoapaddrsvr.formattedLabelOptionsType FormattedLabelOptions,hopewiserSoapaddrsvr.dataType Data,hopewiserSoapaddrsvr.dataType ExtraData) {
			hopewiserSoapaddrsvr.AddressDetailsRequest_element request_x = new hopewiserSoapaddrsvr.AddressDetailsRequest_element();
			hopewiserSoapaddrsvr.AddressDetailsResponse_element response_x;
			request_x.SID = SID;
			request_x.RequestOptions = RequestOptions;
			request_x.FormattedLabelOptions = FormattedLabelOptions;
			request_x.Data = Data;
			request_x.ExtraData = ExtraData;
			Map<String, hopewiserSoapaddrsvr.AddressDetailsResponse_element> response_map_x = new Map<String, hopewiserSoapaddrsvr.AddressDetailsResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'',
				'http://hopewiser/soapaddrsvr',
				'AddressDetailsRequest',
				'http://hopewiser/soapaddrsvr',
				'AddressDetailsResponse',
				'hopewiserSoapaddrsvr.AddressDetailsResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x;
		}

		public hopewiserSoapaddrsvr.AddressExpandResponse_element AddressExpand(String SID,hopewiserSoapaddrsvr.addressExpandRequestOptionsType RequestOptions) {
			hopewiserSoapaddrsvr.AddressExpandRequest_element request_x = new hopewiserSoapaddrsvr.AddressExpandRequest_element();
			hopewiserSoapaddrsvr.AddressExpandResponse_element response_x;
			request_x.SID = SID;
			request_x.RequestOptions = RequestOptions;
			Map<String, hopewiserSoapaddrsvr.AddressExpandResponse_element> response_map_x = new Map<String, hopewiserSoapaddrsvr.AddressExpandResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'',
				'http://hopewiser/soapaddrsvr',
				'AddressExpandRequest',
				'http://hopewiser/soapaddrsvr',
				'AddressExpandResponse',
				'hopewiserSoapaddrsvr.AddressExpandResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x;
		}

		public hopewiserSoapaddrsvr.AddressSearchResponse_element AddressSearch(String Input1,String Input2,String Input3,String Input4,String Input5,String Input6,String Input7,String Input8,String Input9,String Input10,String MAF,hopewiserSoapaddrsvr.addressSearchRequestOptionsType RequestOptions) {
			hopewiserSoapaddrsvr.AddressSearchRequest_element request_x = new hopewiserSoapaddrsvr.AddressSearchRequest_element();
			hopewiserSoapaddrsvr.AddressSearchResponse_element response_x;
			request_x.Input1 = Input1;
			request_x.Input2 = Input2;
			request_x.Input3 = Input3;
			request_x.Input4 = Input4;
			request_x.Input5 = Input5;
			request_x.Input6 = Input6;
			request_x.Input7 = Input7;
			request_x.Input8 = Input8;
			request_x.Input9 = Input9;
			request_x.Input10 = Input10;
			request_x.MAF = MAF;
			request_x.RequestOptions = RequestOptions;
			Map<String, hopewiserSoapaddrsvr.AddressSearchResponse_element> response_map_x = new Map<String, hopewiserSoapaddrsvr.AddressSearchResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'',
				'http://hopewiser/soapaddrsvr',
				'AddressSearchRequest',
				'http://hopewiser/soapaddrsvr',
				'AddressSearchResponse',
				'hopewiserSoapaddrsvr.AddressSearchResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x;
		}

		public hopewiserSoapaddrsvr.ExtraDataResponse_element ExtraData(String MAF) {
			hopewiserSoapaddrsvr.ExtraDataRequest_element request_x = new hopewiserSoapaddrsvr.ExtraDataRequest_element();
			hopewiserSoapaddrsvr.ExtraDataResponse_element response_x;
			request_x.MAF = MAF;
			Map<String, hopewiserSoapaddrsvr.ExtraDataResponse_element> response_map_x = new Map<String, hopewiserSoapaddrsvr.ExtraDataResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'',
				'http://hopewiser/soapaddrsvr',
				'ExtraDataRequest',
				'http://hopewiser/soapaddrsvr',
				'ExtraDataResponse',
				'hopewiserSoapaddrsvr.ExtraDataResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x;
		}

		public hopewiserSoapaddrsvr.PostcodeLookupResponse_element PostcodeLookup(String Postcode,String Premise,String MAF,hopewiserSoapaddrsvr.postcodeLookupRequestOptionsType RequestOptions,hopewiserSoapaddrsvr.formattedLabelOptionsType FormattedLabelOptions,hopewiserSoapaddrsvr.dataType Data,hopewiserSoapaddrsvr.dataType ExtraData) {
			hopewiserSoapaddrsvr.PostcodeLookupRequest_element request_x = new hopewiserSoapaddrsvr.PostcodeLookupRequest_element();
			hopewiserSoapaddrsvr.PostcodeLookupResponse_element response_x;
			request_x.Postcode = Postcode;
			request_x.Premise = Premise;
			request_x.MAF = MAF;
			request_x.RequestOptions = RequestOptions;
			request_x.FormattedLabelOptions = FormattedLabelOptions;
			request_x.Data = Data;
			request_x.ExtraData = ExtraData;
			Map<String, hopewiserSoapaddrsvr.PostcodeLookupResponse_element> response_map_x = new Map<String, hopewiserSoapaddrsvr.PostcodeLookupResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'',
				'http://hopewiser/soapaddrsvr',
				'PostcodeLookupRequest',
				'http://hopewiser/soapaddrsvr',
				'PostcodeLookupResponse',
				'hopewiserSoapaddrsvr.PostcodeLookupResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x;
		}

		public hopewiserSoapaddrsvr.StatusResponse_element Status() {
			hopewiserSoapaddrsvr.StatusRequest_element request_x = new hopewiserSoapaddrsvr.StatusRequest_element();
			hopewiserSoapaddrsvr.StatusResponse_element response_x;
			Map<String, hopewiserSoapaddrsvr.StatusResponse_element> response_map_x = new Map<String, hopewiserSoapaddrsvr.StatusResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'',
				'http://hopewiser/soapaddrsvr',
				'StatusRequest',
				'http://hopewiser/soapaddrsvr',
				'StatusResponse',
				'hopewiserSoapaddrsvr.StatusResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x;
		}

		public hopewiserSoapaddrsvr.VersionResponse_element Version() {
			hopewiserSoapaddrsvr.VersionRequest_element request_x = new hopewiserSoapaddrsvr.VersionRequest_element();
			hopewiserSoapaddrsvr.VersionResponse_element response_x;
			Map<String, hopewiserSoapaddrsvr.VersionResponse_element> response_map_x = new Map<String, hopewiserSoapaddrsvr.VersionResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
				'',
				'http://hopewiser/soapaddrsvr',
				'VersionRequest',
				'http://hopewiser/soapaddrsvr',
				'VersionResponse',
				'hopewiserSoapaddrsvr.VersionResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x;
		}
	}
	public class StatusRequest_element {
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{};
	}
	public class StatusResponse_element {
		public Integer StatusCode;
		public String StatusDesc;
		public hopewiserSoapaddrsvr.defaultType Default_x;
		public hopewiserSoapaddrsvr.alternateType Alternate;
		private String[] StatusCode_type_info = new String[]{'StatusCode','http://hopewiser/soapaddrsvr','integer','1','1','false'};
		private String[] StatusDesc_type_info = new String[]{'StatusDesc','http://hopewiser/soapaddrsvr','string','1','1','false'};
		private String[] Default_x_type_info = new String[]{'Default','http://hopewiser/soapaddrsvr','defaultType','0','1','false'};
		private String[] Alternate_type_info = new String[]{'Alternate','http://hopewiser/soapaddrsvr','alternateType','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'StatusCode','StatusDesc','Default_x','Alternate'};
	}
	public class VersionRequest_element {
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{};
	}
	public class VersionResponse_element {
		public Integer StatusCode;
		public String StatusDesc;
		public String SoapAddrSvr;
		public String Atlas;
		private String[] StatusCode_type_info = new String[]{'StatusCode','http://hopewiser/soapaddrsvr','integer','1','1','false'};
		private String[] StatusDesc_type_info = new String[]{'StatusDesc','http://hopewiser/soapaddrsvr','string','1','1','false'};
		private String[] SoapAddrSvr_type_info = new String[]{'SoapAddrSvr','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] Atlas_type_info = new String[]{'Atlas','http://hopewiser/soapaddrsvr','string','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://hopewiser/soapaddrsvr','true','false'};
		private String[] field_order_type_info = new String[]{'StatusCode','StatusDesc','SoapAddrSvr','Atlas'};
	}
}