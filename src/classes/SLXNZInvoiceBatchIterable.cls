global class  SLXNZInvoiceBatchIterable implements Iterator<Invoice__c>{
	
	List<Invoice__c> Invoices {get; set;}
	private String period = 'Today';
	private String batch_name = '';
	private Date batch_date = Date.today();
	Integer i {get;set;}
	public SLXNZInvoiceBatchIterable(String period) {
		this.period = period;
		System.debug('Period: ' + period);

		DateTime target_date	= datetime.now();
		
		if(period == 'Today') {
			target_date = datetime.now();
		}
		else if(period == '3 Day') {
			target_date = target_date.addDays(-3);
		} 
		else if(period == '5 Day') {
			target_date = target_date.addDays(-5);
		}
		else if(period == '9 Day') {
			target_date = target_date.addDays(-9);
		}
		else if(period == '13 Day') {
			target_date = target_date.addDays(-13);
		}
		String target_date_string  = String.valueOf(target_date.format('yyyy-MM-dd'));
		System.debug('Target Date String: ' + target_date_string);

		this.Invoices = [Select 
							t.Reference__c, 
							t.Processed__c, 
							t.Process_Message__c, 
							t.Payment_Response__c, 
							t.Payment_Option__c, 
							t.Payment_Message__c, 
							t.Name, 
							t.LastModifiedDate, 
							t.Issue_Date__c, 
							t.IsDeleted, 
							t.Invoice_Number__c, 
							t.Invoice_Batch__c, 
							t.Id, 
							t.Exclude_Reminder__c, 
							t.Exclude_Invoice__c, 
							t.Email_Processed__c, 
							t.Due_Date__c, 
							t.Amount_Paid__c, 
							t.Amount_Due__c, 
							t.Amount_Credited__c, 
							t.Invoice_Total__c, 
							t.Account__c, 
							t.Account_Product__c, 
							t.Status__c 
						From 
							Invoice__c t 
						where 
							t.IsDeleted = false 
						and 
							(t.Status__c = 'AUTHORISED' 
							or 
								t.Status__c = 'PARTIALLY PAID' 
							or 
								t.Status__c = 'PARTIALLY CREDITED') 
						and 
							t.Due_Date__c=: target_date.date()
						and
							t.Account_Product__r.SLX_Product__r.company_name__c = 'SponsoredLinX New Zealand'];
		
		this.i = 0;
		this.batch_name = 'NZ ' + DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + this.period + ' Invoice Batch';
		System.debug('Batch Name: ' + this.batch_name);
		
		try {
			List<Invoice_Batch__c> todaysbatch = [SELECT Id FROM Invoice_Batch__c WHERE name =: this.batch_name AND Batch_Date__c =: this.batch_date];
			Invoice_Batch__c batch;
			System.debug('Todays Batch:' + todaysbatch);
			if (todaysbatch.size() > 0) {
				System.debug('Updating New Invoice Batch with salesforce invoices');
				batch = todaysbatch[0];
				if(this.Invoices.size() > 0) {
					batch.status__c = 'New Batch';
				} else {
					System.debug('salesforce returned no invoices');
					batch.status__c = 'Empty Batch';
				}
				batch.Batch_Records__c = this.Invoices.size();
				System.debug('Invoice Batch: ' + batch);
				update batch;
			}
		} catch(Exception e) {
			System.debug('Failed updating details in new invoice batch: ' + e);
		}
	}

	global boolean hasNext() {
		if(this.i >= this.Invoices.size()) 
        	return false; 
		else 
        	return true;	
	}

	global Invoice__c next() {
   		return this.Invoices[this.i++];	
	}
		
		
		
		
		
		
	}