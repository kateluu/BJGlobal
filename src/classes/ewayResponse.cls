public with sharing class ewayResponse {
	
	private String ewayTrxnError		= '';
	private String ewayTrxnStatus		= '';
	private String ewayTrxnNumber		= '';
	private String ewayTrxnOption1		= '';
	private String ewayTrxnOption2		= '';
	private String ewayTrxnOption3		= '';
	private String ewayReturnAmount		= '';
	private String ewayAuthCode			= '';
	private String ewayTrxnReference	= '';
	private String xmlString			= '';
	private String ewayErrors			= '';
	
	public ewayResponse() {
		this.ewayTrxnStatus = 'True';
	}

	public void loadResponse(Dom.Document doc) {
		this.xmlString			= doc.toXmlString();
		Dom.XMLNode ewayXml 	= doc.getRootElement();
		system.debug(this.xmlString);
		this.ewayTrxnError 		= ewayXml.getChildElement('ewayTrxnError', 		null).getText();
		this.ewayTrxnStatus 	= ewayXml.getChildElement('ewayTrxnStatus', 	null).getText();
		this.ewayTrxnNumber 	= ewayXml.getChildElement('ewayTrxnNumber', 	null).getText();
		this.ewayTrxnOption1 	= ewayXml.getChildElement('ewayTrxnOption1', 	null).getText();
		this.ewayTrxnOption2 	= ewayXml.getChildElement('ewayTrxnOption2', 	null).getText();
		this.ewayTrxnOption3 	= ewayXml.getChildElement('ewayTrxnOption3', 	null).getText();
		this.ewayReturnAmount 	= ewayXml.getChildElement('ewayReturnAmount', 	null).getText();
		this.ewayAuthCode 		= ewayXml.getChildElement('ewayAuthCode', 		null).getText();
		//this.ewayTrxnReference 	= ewayXml.getChildElement('ewayTrxnReference', 	null).getText();
	}
	
	public void setewayTrxnReference(String reference) {
		this.ewayTrxnReference = reference;
	}
	public void setewayErrors(String error) {
		this.ewayErrors += error + '-';
		this.ewayTrxnStatus = 'False';
	}
	public String getewayErrors() {
		return this.ewayErrors;
	}
	public Boolean isSuccessful() {
		if (this.getewayTrxnStatus() == 'false'){
			return false;
		} else {
			return true;
		}
	}
	public String getewayTrxnError() {
		return EncodingUtil.urlDecode(this.ewayErrors+this.ewayTrxnError,'UTF-8');	
	}
	public String getewayTrxnStatus() {
		return EncodingUtil.urlDecode(this.ewayTrxnStatus,'UTF-8');
	}
	public String getewayTrxnNumber() {
		return EncodingUtil.urlDecode(this.ewayTrxnNumber,'UTF-8');
	}
	public String getewayTrxnOption1() {
		return EncodingUtil.urlDecode(this.ewayTrxnOption1,'UTF-8');
	}
	public String getewayTrxnOption2() {
		return EncodingUtil.urlDecode(this.ewayTrxnOption2,'UTF-8');
	}
	public String getewayTrxnOption3() {
		return EncodingUtil.urlDecode(this.ewayTrxnOption3,'UTF-8');
	}
	public String getewayReturnAmount() {
		return EncodingUtil.urlDecode(this.ewayReturnAmount,'UTF-8');
	}
	public String getewayAuthCode() {
		return EncodingUtil.urlDecode(this.ewayAuthCode,'UTF-8');
	}
	public String getewayTrxnReference() {
		return EncodingUtil.urlDecode(this.ewayTrxnReference,'UTF-8');
	}
	public String getxmlString() {
		String xml = '';
		xml += '<ewayResponse>\r\n';
		xml += '  <ewayTrxnError>'+		this.getewayTrxnError()		+'</ewayTrxnError>\r\n';
		xml += '  <ewayTrxnStatus>'+	this.getewayTrxnStatus()	+'</ewayTrxnStatus>\r\n';
		xml += '  <ewayTrxnNumber>'+	this.getewayTrxnNumber()	+'</ewayTrxnNumber>\r\n';
		xml += '  <ewayTrxnOption1>'+	this.getewayTrxnOption1()	+'</ewayTrxnOption1>\r\n';
		xml += '  <ewayTrxnOption2>'+	this.getewayTrxnOption2()	+'</ewayTrxnOption2>\r\n';
		xml += '  <ewayTrxnOption3>'+	this.getewayTrxnOption3()	+'</ewayTrxnOption3>\r\n';
		xml += '  <ewayReturnAmount>'+	this.getewayReturnAmount()	+'</ewayReturnAmount>\r\n';
		xml += '  <ewayAuthCode>'+		this.getewayAuthCode()		+'</ewayAuthCode>\r\n';
		xml += '  <ewayTrxnReference>'+	this.getewayTrxnReference()	+'</ewayTrxnReference>\r\n';
		xml += '</ewayResponse>\r\n';
		return xml;
	}
	public void setewayTrxnStatus(String status) {
		this.ewayTrxnStatus = status;
	}
	public void setewayTrxnError(String error) {
		this.ewayTrxnError = error;
	}
	public void setewayAuthCode(String code) {
		this.ewayAuthCode = code;
	}
	public static testMethod void ewayResponseTest() {
		String xml = '';
		xml += '<ewayResponse>';
		xml += '  <ewayTrxnError></ewayTrxnError>';
		xml += '  <ewayTrxnStatus> True </ewayTrxnStatus>';
		xml += '  <ewayTrxnNumber> 10002 </ewayTrxnNumber>';
		xml += '  <ewayTrxnOption1></ewayTrxnOption1>';
		xml += '  <ewayTrxnOption2></ewayTrxnOption2>';
		xml += '  <ewayTrxnOption3></ewayTrxnOption3>';
		xml += '  <ewayReturnAmount> 10 </ewayReturnAmount>';
		xml += '  <ewayAuthCode> 123456 </ewayAuthCode>';
		xml += '  <ewayTrxnReference> 987654321 </ewayTrxnReference>';
		xml += '</ewayResponse>';
		
		Dom.Document domDoc = new Dom.Document();
		domDoc.load(xml);
		
		ewayResponse eway 		= new ewayResponse();
		eway.loadResponse(domDoc);
		eway.getewayTrxnError();
		eway.getewayTrxnStatus();
		eway.getewayTrxnNumber();
		eway.getewayTrxnOption1();
		eway.getewayTrxnOption2();
		eway.getewayTrxnOption3();
		eway.getewayReturnAmount();
		eway.getewayAuthCode();
		eway.getewayTrxnReference();
		eway.getxmlString();
		eway.setewayTrxnReference('dsfgdfgdsfgdfgfdg');
		eway.setewayErrors('sdfsfsadfsdf');
		eway.getewayErrors();
		eway.setewayTrxnStatus('True');
		eway.setewayTrxnError('sdfsafsadf');
		eway.setewayAuthCode('345345');
	}
}