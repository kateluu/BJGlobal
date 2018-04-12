global class batchXeroInvoiceCreateIterable implements Iterator<sfxero.XeroInvoice> {
	public static boolean isTest = false;

	private static string consumerkey  = 'CJSE8SW0UHFRWFRSJVNVF4YEUVATZY';
    private static string privatekey   = 'MIICXAIBAAKBgQCZjhkaqM5rb0O3d/50XuzagfDz51ZQZH52/QRH/uVOqA8OWcSv\n'
								+ 'RB2LtaiVosnxlB6Bji69sx3pM8AEaNrCWjetjktgdF/611Aqy83IABFLT926KWxt\n'
								+ 'nmE2EfdeC3PE/gTf1ASgQ+seD6LyxWpy62G75dtz56bxoERkN6LYLfF5IQIDAQAB\n'
								+ 'AoGAUR0B39ZJ6/CDadgl/tzh6u73FDAgpSjgsQQojct0397gzSjYP+kQXmugWSL7\n'
								+ '3/PpRXCQ+j4yz6w5g1rMLBwyClds5nn0Tsi2TZbxx/uGdcb8/ulYfEySw7CJspDk\n'
								+ 'Bw7m37IHDJn/bLHHZdxKQMed4/8Z8HBzGbaRz8kMhU8f+x0CQQDMnVIChO9BVYb1\n'
								+ 'd1PL+eVQWzY2bOxs+yfFrw6RYCvIpEsVGpvuFLYD4NKCD/3YDwNzFVCsIyiFKCxX\n'
								+ 'vn2aGhjbAkEAwB4pfRFW9fKqiuDr+Xohn2L/5eYiwtqDrFKzCS7zwDFRCjPKP7oY\n'
								+ 'FaqoW+c3bRdBJ99otB6lWsSd9elSCgXIswJBAJv2ZmZpMX1ZVc+QrxzRVAtWGxKN\n'
								+ 'IAFJx10VPENvTLBZGqnxaF2nB74ZBhwBWHnxp61219D904r7viD7n/1wWvUCQBdu\n'
								+ 'Vk8Lo1iBzSz8+6rEq38d+unWJJ0xO2fz+iP/lvj0ytZ8tIkLME7MLpZu38KtWGP9\n'
								+ 'im6VYkNswXsxhrD0PaMCQGMmLGr8gsq9GeRkBetGTH4QiLFEpLanNXoCnStmuAF8\n'
								+ '6Wikk/7w1vjZNzJUX43BWBkYKT2O9waibBowkVP4EBQ=\n';
	List<sfxero.XeroInvoice> xeroInvoices {get; set;} 
	Integer i {get;set;}

	private String period = 'Today';
	private String batch_name = '';
	private Date batch_date = Date.today();

	public batchXeroInvoiceCreateIterable(String period) {
		/*
		this.period = period;
		System.debug('Period: ' + period);

		System.debug('batchXeroInvoiceCreateIterable: Starts');
		sfxero.XeroCredentials cred = new sfxero.XeroCredentials(batchXeroInvoiceCreateIterable.consumerkey, '', batchXeroInvoiceCreateIterable.privatekey);

		DateTime target_date	= datetime.now();
		date days90back			= date.today().addDays(-90);

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
		sfxero.XeroInvoiceResponse invoice = sfxero.XeroAPI.getInvoicesAll(cred, days90back, 'Type=="ACCREC"&&Status=="AUTHORISED"&&Date==DateTime.Parse("' + target_date_string  + '")','');
		System.debug('Invoice list: ' + invoice);

		this.xeroInvoices = invoice.invoices;
		this.i = 0;


		// now we need to update the invoice batch details with the result from
		// xero api above.
		this.batch_name = DateTime.now().format('EEEE yyyy-MM-dd') + ' ' + this.period + ' Invoice Batch';
		System.debug('Batch Name: ' + this.batch_name);

		try {
			List<Invoice_Batch__c> todaysbatch = [SELECT Id FROM Invoice_Batch__c WHERE name =: this.batch_name AND Batch_Date__c =: this.batch_date];
			Invoice_Batch__c batch;
			System.debug('Todays Batch:' + todaysbatch);
			if (todaysbatch.size() > 0) {
				System.debug('Updating New Invoice Batch with Xero result');
				batch = todaysbatch[0];
				if(this.xeroInvoices.size() > 0) {
					batch.status__c = 'New Batch';
				} else {
					System.debug('Xero API returned no invoices');
					batch.status__c = 'Empty Batch';
				}
				batch.Batch_Records__c = this.xeroInvoices.size();
				System.debug('Invoice Batch: ' + batch);
				update batch;
			}
		} catch(Exception e) {
			System.debug('Failed updating details in new invoice batch: ' + e);
		}
		*/
	}

	global boolean hasNext() {
		if(this.i >= this.xeroInvoices.size()) 
        	return false; 
		else 
        	return true;	
	}

	global sfxero.XeroInvoice next() {
   		return this.xeroInvoices[this.i++];	
	}
}