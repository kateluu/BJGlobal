global class sendXeroPaymentsIterable implements Iterator<Invoice_Payments__c> {

	List<Invoice_Payments__c> invpayments {get;set;}
	Integer i {get;set;}

	private String period = 'Today';
	private String batch_name = '';
	private Date batch_date = Date.today();

	public sendXeroPaymentsIterable(String period) {
		this.period = period;
		System.debug('Period: ' + period);

		this.batch_name = DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + this.period + ' Invoice Batch';
		System.debug('Batch Name: ' + this.batch_name);

		List<Invoice_Batch__c> todaysBatches = [
			SELECT
				Id,
				Name,
				Batch_Date__c,
				Batch_Number__c,
				Batch_Processed__c,
				status__c,
				Batch_Type__c
			FROM
				Invoice_Batch__c
			WHERE
				Batch_Type__c = 'Invoices'
				AND
				status__c = 'Batch Approved'
				AND
				Batch_Processed__c = 'No'
				AND
				Batch_Date__c =: this.batch_date
				AND
				Name =: this.batch_name
		];
		Invoice_Batch__c todaysBatch;

		if(todaysBatches.size() > 0) {
			todaysBatch = todaysBatches[0];
			this.invpayments = [
				SELECT
					Id,
					Name,
					Invoice_Batch__c,
					Payment_Amount__c,
					Payment_Date__c,
					Xero_Account_Code__c,
					Xero_Account_Id__c,
					Xero_Invoice_Id__c,
					Xero_Invoice_Number__c
				FROM
					Invoice_Payments__c
				WHERE
					Invoice_Batch__c =: todaysBatch.Id
			];
		}
		this.i = 0;
	}

	global boolean hasNext() {
		if(this.i >= this.invpayments.size())
			return false;
		else
			return true;
	}

	global Invoice_Payments__c next() {
		return this.invpayments[this.i++];
	}
}