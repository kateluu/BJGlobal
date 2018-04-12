global class dailyBatchPaymentsIterable implements Iterator<Invoice__c> {

	List<Invoice__c> invoices {get;set;} 
	Integer i {get;set;}
	private String period = 'Today';
	private String batch_name = '';
	private Boolean batch_exist = false;
	private ID todays_batch_id;
	private Date batch_date = Date.today();

	public dailyBatchPaymentsIterable(String period) {
		this.period = period;
		System.debug('Period: ' + period);

		this.batch_name = 'SLX ' + DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + this.period + ' Payment Batch';
		System.debug('Batch Name: ' + this.batch_name);

		Invoice_Batch__c todaysBatch;
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
				Batch_Type__c = 'Payments'
				AND
				status__c = 'Payments In Progress'
				AND
				Batch_Processed__c = 'No'
				AND
				Batch_Date__c =: Date.today()
				AND
				Name =: this.batch_name
		];

		if(todaysBatches.size() > 0) {
			todaysBatch = todaysBatches[0];
			this.invoices = [
				SELECT
					Id,
					Name,
					Payment_Batch__c,
					Payment_Message__c,
					Payment_Response__c,
					Account__c,
					Account_Product__c,
					Account_Product__r.OwnerId,
					Amount_Credited__c,
					Amount_Due__c,
					Amount_Paid__c,
					Due_Date__c,
					Invoice_Batch__c,
					Invoice_Number__c,
					Invoice_Total__c,
					Issue_Date__c,
					Payment_Option__c,
					Processed__c,
					Process_Message__c,
					Reference__c,
					Xero_Contact_Id__c,
					Xero_Invoice_Id__c
				FROM
					Invoice__c
				WHERE
					Payment_Option__c = 'Eway'
					AND
					Processed__c = false
					AND
					Payment_Batch__c =: todaysBatch.Id
				ORDER BY
					Due_Date__c ASC
			];
		}
		this.i = 0;
	}

	global boolean hasNext() {
		if(this.invoices == null) return false;
		if(this.i >= this.invoices.size())
			return false;
		else
			return true;
	}

	global Invoice__c next() {
		return this.invoices[this.i++];
	}
}