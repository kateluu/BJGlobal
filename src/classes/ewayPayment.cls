public with sharing class ewayPayment {
	//**********
	//Constants
	//**********
	private static String EWAY_MOCK_GATEWAY_URL = 'https://slxconsole-bw.sponsoredlinx.com/ewaymock.php';
	private static String EWAY_MOCK_CUSTOMER_ID = '87654321';
	private static String EWAY_TEST_GATEWAY_URL = 'https://www.eway.com.au/gateway/xmltest/testpage.asp';
	private static String EWAY_TEST_CUSTOMER_ID = '87654321';
	private static String EWAY_LIVE_GATEWAY_URL = 'https://www.eway.com.au/gateway/xmlpayment.asp';
	private static String EWAY_LIVE_CUSTOMER_ID = '10343624';
	private static String EWAY_LIVE_GMT_CUSTOMER_ID = '19520741';
		
	//**********
	//Properties
	//**********
	private ewayResponse response;
	private String ewayGatewayUrl 					= '';
	private String ewayCustomerId 					= '';
	private String ewayTotalAmount 					= '';
	private String ewayCustomerFirstName 			= ''; 
	private String ewayCustomerLastName 			= '';	 
	private String ewayCustomerEmail 				= ''; 
	private String ewayCustomerAddress 				= '';	 
	private String ewayCustomerPostcode 			= '';
	private String ewayCustomerInvoiceDescription 	= ''; 
	private String ewayCustomerInvoiceRef 			= '';
	private String ewayCardHoldersName 				= '';
	private String ewayCardNumber 					= '';
	private String ewayCardExpiryMonth 				= '';
	private String ewayCardExpiryYear 				= '';
	private String ewayCVN             				= '';
	private String ewayTrxnNumber 					= ''; 	
	private String ewayOption1 						= ''; 	
	private String ewayOption2 						= ''; 	
	private String ewayOption3 						= '';	
	private String xmldata 							= '';
		
	//***********
	//Constructor
	//***********
	public ewayPayment() {
		this.response = new ewayResponse();		
	}
		
	//*******
	//Methods
	//*******
	public void setewayTotalAmount(String ewayTotalAmount) { 
		// 	12 	Included
		this.ewayTotalAmount = this.checkValue('ewayTotalAmount',ewayTotalAmount,12,true);
	}
	public void setewayCustomerFirstName(String ewayCustomerFirstName) {
		// 	50 
		this.ewayCustomerFirstName = this.checkValue('ewayCustomerFirstName',ewayCustomerFirstName,50,false);
	}	 
	public void setewayCustomerLastName(String ewayCustomerLastName) { 
		//	50
		 this.ewayCustomerLastName = this.checkValue('ewayCustomerLastName',ewayCustomerLastName,50,false);
	} 	 
	public void setewayCustomerEmail(String ewayCustomerEmail) { 
		//	50
		 this.ewayCustomerEmail = this.checkValue('ewayCustomerEmail',ewayCustomerEmail,50,false);
	} 	 
	public void setewayCustomerAddress(String ewayCustomerAddress) { 	
		//255
		this.ewayCustomerAddress = this.checkValue('ewayCustomerAddress',ewayCustomerAddress,255,false);
	} 	 
	public void setewayCustomerPostcode(String ewayCustomerPostcode) { 
		//	6
		 this.ewayCustomerPostcode = this.checkValue('ewayCustomerPostcode',ewayCustomerPostcode,6,false);
	} 	 
	public void setewayCustomerInvoiceDescription(String ewayCustomerInvoiceDescription) {
		// 	255
		 this.ewayCustomerInvoiceDescription = this.checkValue('ewayCustomerInvoiceDescription',ewayCustomerInvoiceDescription,255,false);
	} 	 
	public void setewayCustomerInvoiceRef(String ewayCustomerInvoiceRef) {
		// 	50
		 this.ewayCustomerInvoiceRef = this.checkValue('ewayCustomerInvoiceRef',ewayCustomerInvoiceRef,50,false);
	} 	 
	public void setewayCardHoldersName(String ewayCardHoldersName) {
		// 	50 	Included		
		 this.ewayCardHoldersName = this.checkValue('ewayCardHoldersName',ewayCardHoldersName,50,true);
	}
	public void setewayCardNumber(String ewayCardNumber) { 
		//	20 	Included
		 this.ewayCardNumber = this.checkValue('ewayCardNumber',ewayCardNumber,20,true);
	}
	public void setewayCardExpiryMonth(String ewayCardExpiryMonth) {
		// 	2 	Included
		 this.ewayCardExpiryMonth = this.checkValue('ewayCardExpiryMonth',ewayCardExpiryMonth,2,true);
	}
	public void setewayCardExpiryYear(String ewayCardExpiryYear) { 
		//	2 	Included
		 this.ewayCardExpiryYear = this.checkValue('ewayCardExpiryYear',ewayCardExpiryYear,2,true);
	}
	
	public void setewayCVN(String ewayCVN) { 
		//	4 	Included
		 //this.ewayCVN = this.checkValue('ewayCVN',ewayCVN,4,true);
		 this.ewayCVN   = ewayCVN;
	}
	
	public void setewayTrxnNumber(String ewayTrxnNumber) { 
		//	16
		 this.ewayTrxnNumber = this.checkValue('ewayTrxnNumber',ewayTrxnNumber,16,false);
	} 	
	public void setewayOption1(String ewayOption1) {
		// 	255
		 this.ewayOption1 = this.checkValue('ewayOption1',ewayOption1,255,false);
	} 	
	public void setewayOption2(String ewayOption2) {
		// 	255
		 this.ewayOption2 = this.checkValue('ewayOption2',ewayOption2,255,false);
	} 	
	public void setewayOption3(String ewayOption3) { 
		//	255
		 this.ewayOption3 = this.checkValue('ewayOption3',ewayOption3,255,false);
	}
	
	public void setMode(String mode) {
		if (mode == 'test') {
			this.ewayCustomerId	= EWAY_TEST_CUSTOMER_ID;
			this.ewayGatewayUrl = EWAY_TEST_GATEWAY_URL;
		} else if (mode == 'mock') {
			this.ewayCustomerId	= EWAY_MOCK_CUSTOMER_ID;
			this.ewayGatewayUrl = EWAY_MOCK_GATEWAY_URL;
		} else if (mode == 'Get More Traffic') {
			this.ewayCustomerId	= EWAY_LIVE_GMT_CUSTOMER_ID;
			this.ewayGatewayUrl = EWAY_LIVE_GATEWAY_URL;
		} else {
			this.ewayCustomerId	= EWAY_LIVE_CUSTOMER_ID;
			this.ewayGatewayUrl = EWAY_LIVE_GATEWAY_URL;
		} 
	}
	
	private String checkValue(String field, String value, Integer length, Boolean required) {
		System.debug('***'+field+':'+value);
		try {
			value = value.trim();
			if (required == true) {
				if (value == null || value.length()==0) {
					if (field.length() > 0) {
						this.response.setewayErrors(field+' can not be empty');
					}
				}
			}
			if (value.length() > length) {
				if (field.length() > 0) {
					this.response.setewayErrors(field+' can not be longer than '+length);
				}
			}
		} catch (Exception e) {
			if (required == true) {
				if (field.length() > 0) {
					this.response.setewayErrors(field+' can not be empty');
				}
			}
		} 
		return value;	
	}
	
	private void checkRequired() {
		this.ewayCustomerId	 		= this.checkValue('',this.ewayCustomerId,8,true);
		this.ewayTotalAmount 		= this.checkValue('',this.ewayTotalAmount,12,true);
		this.ewayCardHoldersName 	= this.checkValue('',this.ewayCardHoldersName,50,true);
		this.ewayCardNumber 		= this.checkValue('',this.ewayCardNumber,20,true);
		this.ewayCardExpiryMonth 	= this.checkValue('',this.ewayCardExpiryMonth,2,true);
		this.ewayCardExpiryYear 	= this.checkValue('',this.ewayCardExpiryYear,2,true);
	}
	
	private void buildXML() {
		this.xmldata = '';
		this.xmldata += '<ewaygateway>';
		this.xmldata += '<ewayCustomerID>'+					EncodingUtil.urlEncode(this.ewayCustomerId,'UTF-8')						+'</ewayCustomerID>';
		this.xmldata += '<ewayTotalAmount>'+				EncodingUtil.urlEncode(this.ewayTotalAmount,'UTF-8')					+'</ewayTotalAmount>'; 
		this.xmldata += '<ewayCustomerFirstName>'+			EncodingUtil.urlEncode(this.ewayCustomerFirstName,'UTF-8')				+'</ewayCustomerFirstName>'; 
		this.xmldata += '<ewayCustomerLastName>'+			EncodingUtil.urlEncode(this.ewayCustomerLastName,'UTF-8')				+'</ewayCustomerLastName>'; 
		this.xmldata += '<ewayCustomerEmail>'+				EncodingUtil.urlEncode(this.ewayCustomerEmail,'UTF-8')					+'</ewayCustomerEmail>'; 
		this.xmldata += '<ewayCustomerAddress>'+			EncodingUtil.urlEncode(this.ewayCustomerAddress,'UTF-8')				+'</ewayCustomerAddress>'; 
		this.xmldata += '<ewayCustomerPostcode>'+			EncodingUtil.urlEncode(this.ewayCustomerPostcode,'UTF-8')				+'</ewayCustomerPostcode>'; 
		this.xmldata += '<ewayCustomerInvoiceDescription>'+	EncodingUtil.urlEncode(this.ewayCustomerInvoiceDescription,'UTF-8')		+'</ewayCustomerInvoiceDescription>'; 
		this.xmldata += '<ewayCustomerInvoiceRef>'+			EncodingUtil.urlEncode(this.ewayCustomerInvoiceRef,'UTF-8')				+'</ewayCustomerInvoiceRef>'; 
		this.xmldata += '<ewayCardHoldersName>'+			EncodingUtil.urlEncode(this.ewayCardHoldersName,'UTF-8')				+'</ewayCardHoldersName>'; 
		this.xmldata += '<ewayCardNumber>'+					EncodingUtil.urlEncode(this.ewayCardNumber,'UTF-8')						+'</ewayCardNumber>'; 
		this.xmldata += '<ewayCardExpiryMonth>'+			EncodingUtil.urlEncode(this.ewayCardExpiryMonth,'UTF-8')				+'</ewayCardExpiryMonth>'; 
		this.xmldata += '<ewayCardExpiryYear>'+				EncodingUtil.urlEncode(this.ewayCardExpiryYear,'UTF-8')					+'</ewayCardExpiryYear>'; 
		this.xmldata += '<ewayCVN>'+		         		EncodingUtil.urlEncode(this.ewayCVN,'UTF-8')			        		+'</ewayCVN>'; 
		this.xmldata += '<ewayTrxnNumber>'+					EncodingUtil.urlEncode(this.ewayTrxnNumber,'UTF-8')						+'</ewayTrxnNumber>'; 
		this.xmldata += '<ewayOption1>'+					EncodingUtil.urlEncode(this.ewayOption1,'UTF-8')						+'</ewayOption1>';
		this.xmldata += '<ewayOption2>'+					EncodingUtil.urlEncode(this.ewayOption2,'UTF-8')						+'</ewayOption2>';
		this.xmldata += '<ewayOption3>'+					EncodingUtil.urlEncode(this.ewayOption3,'UTF-8')						+'</ewayOption3>';  
		this.xmldata += '</ewaygateway>';
	}
	
	private void sendXml() {
		this.buildXML();

		if (this.response.getewayTrxnStatus() == 'True') {
			system.debug('ewayGatewayUrl ' + this.ewayGatewayUrl);

	        HttpRequest req = new HttpRequest();
	        Http h = new Http();
	        req.setEndpoint(this.ewayGatewayUrl);
	        req.setMethod('POST');
	        req.setBody(this.xmldata); 
	        req.setTimeout(20000);
	        system.debug(req);
	        this.response.loadResponse(h.send(req).getBodyDocument());
		} else {
			this.response.setewayTrxnReference(this.ewayTrxnNumber);
		}		
	}
	
	public String getxmldata() {
		this.buildXML();
		return this.xmldata;
	}
	
	public ewayResponse makePayment() {
		this.checkRequired();
		this.sendXml();
		
		return this.response;
	}	
	
	public String getEWAY_TEST_CUSTOMER_ID() {
		return EWAY_TEST_CUSTOMER_ID;
	}
	public String getEWAY_TEST_GATEWAY_URL() {
		return EWAY_TEST_GATEWAY_URL;
	}

	public static testMethod void ewayPaymentTest() {
		ewayPayment eway = new ewayPayment();
		eway.setMode('test');
		eway.setewayTotalAmount('');
		eway.setewayCustomerFirstName('');
		eway.setewayCustomerLastName(''); 
		eway.setewayCustomerEmail('');
		eway.setewayCustomerAddress('');
		eway.setewayCustomerPostcode('');
		eway.setewayCustomerInvoiceDescription('');
		eway.setewayCustomerInvoiceRef('');
		eway.setewayCardHoldersName('');
		eway.setewayCardNumber('');
		eway.setewayCardExpiryMonth('');
		eway.setewayCardExpiryYear('');
		eway.setewayTrxnNumber('');	
		eway.setewayCVN('');	
		eway.setewayOption1('');	
		eway.setewayOption2('');	
		eway.setewayOption3('');
		eway.makePayment();
	}
}