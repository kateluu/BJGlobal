public with sharing class Commweb2Response {

	private String error;
	public String responseBody;
	public Map<String, String> params = new Map<String, String>();
	
	public Commweb2Response(){
	}
	
	public void loadResponse(String body){
		this.responseBody = body;
		this.params = Utility.createMapFromQueryString(this.responseBody);
	}

	public void setErrors(String error) {
		this.error += error + '-';
	}

	public Boolean isSuccessful() {
		if ( this.params.get('result') == 'SUCCESS' ){
			return true;
		} else {
			return false;
		}
	}

	public String getErrorCode() {
		String errorCode;

		if (this.params.get('error.cause') != null) {
			// Post-request gateway errors, eg invalid request
			errorCode = this.params.get('error.cause');
		} else if (this.params.get('response.acquirerCode') != null) {
			// Post-request acquirer errors, eg do not honour
			errorCode = this.params.get('response.acquirerCode');
		}
		return errorCode;
	}

	public String getErrorMessage() {
		String errorMessage;

		if (this.params.isEmpty()){
			// Pre-request validation errors
			errorMessage = this.error;
		} else if (this.params.get('error.explanation') != null) {
			// Post-request gateway errors, eg invalid request
			errorMessage = this.params.get('error.explanation');
		} else if (this.params.get('response.acquirerMessage') != null) {
			// Post-request acquirer errors, eg do not honour
			errorMessage = this.params.get('response.acquirerMessage');
		} else if (this.params.get('response.gatewayCode') != null) {
			// Post-request gateway error, eg TIMED_OUT
			errorMessage = this.params.get('response.gatewayCode');
		}


		return errorMessage;
	}

	public String getTrxnNumber() {
		return this.params.get('transaction.receipt');
	}
	
}