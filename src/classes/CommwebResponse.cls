public with sharing class CommwebResponse {

	public String vpc_AuthorizeId		{set;get;}
	public String vpc_Message   		{set;get;}
	public String vpc_ReceiptNo		    {set;get;}
	public String vpc_TransactionNo		{set;get;}
	public String vpc_TxnResponseCode	{set;get;}
	public String vpc_MerchTxnRef		{set;get;}
	public String vpc_AcqResponseCode   {set;get;}
	public String vpc_Amount   		    {set;get;}
	public String vpc_Erroe    		    {set;get;}
	private String body;
	private String error;
	private Map<String, String> params = new Map<String, String>();
	
	public CommwebResponse(){
		this.body = '';
	}	
	
	public void loadResponse(String body){
		this.body = body;
		this.createMapFromResponse();
		this.vpc_Message 		 = null2unknown('vpc_Message', this.params);
		this.vpc_AuthorizeId 	 = null2unknown('vpc_AuthorizeId', this.params);
		this.vpc_ReceiptNo 		 = null2unknown('vpc_ReceiptNo', this.params);
		this.vpc_TransactionNo   = null2unknown('vpc_TransactionNo', this.params);
		this.vpc_TxnResponseCode = null2unknown('vpc_TxnResponseCode', this.params);
		this.vpc_AcqResponseCode = null2unknown('vpc_AcqResponseCode', this.params);
		this.vpc_MerchTxnRef 	 = null2unknown('vpc_MerchTxnRef', this.params);
		this.vpc_Amount 		 = null2unknown('vpc_Amount', this.params);
		this.vpc_Erroe 			 = null2unknown('vpc_Erroe', this.params);
	}
	
	private String getVpcMessage(){
		return this.vpc_Message;
	}
	
	public void setCommWebErrors(String error) {
		this.error += error + '-';
		//this.ewayTrxnStatus = 'False';
	}

	public Boolean isSuccessful() {
		if ( this.vpc_TxnResponseCode == '0' ){
			return true;
		} else {
			return false;
		}
	}

	public String getTrxnError() {
		return EncodingUtil.urlDecode(this.vpc_AcqResponseCode + this.vpc_Message,'UTF-8');
	}
	
	private void createMapFromResponse() {
		String[] pairArray = this.body.split('&', 0);
		system.debug(pairArray);
		for(String pair: pairArray){
			String[] param = pair.split('=', 0);
			system.debug(param);
			String key     = EncodingUtil.urlDecode(param[0],'UTF-8');
			String value   = EncodingUtil.urlDecode(param[1],'UTF-8');
			this.params.put(key, value);
		}
		system.debug(params);
	}
	
	/*
    * This method takes a data String and returns a predefined value if empty
    * If data Sting is null, returns string "No Value Returned", else returns input
    *
    * @param key String containing the data String
    * @return String containing the output String
    */
    private static String null2unknown(String key, Map<String, String> responseFields) {
      if (key == null || key.length() == 0 || (String)responseFields.get(key) == null) {
            return 'No Value Returned';
        } else {
            return (String)responseFields.get(key);
        }
    } // null2unknown()	
	
	
}