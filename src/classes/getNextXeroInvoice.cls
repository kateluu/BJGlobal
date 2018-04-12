global class getNextXeroInvoice implements Iterator<sfxero.XeroInvoice> {
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
	Integer Counter {get; set;}
	public getNextXeroInvoice() {
		sfxero.XeroCredentials cred = new sfxero.XeroCredentials();
        cred.consumerKey = getNextXeroInvoice.consumerkey;
        cred.privateKey =  getNextXeroInvoice.privatekey;
        this.xeroInvoices = new List<sfxero.XeroInvoice>();
        if(isTest==true) {
			sfxero.XeroInvoice inv = new sfxero.XeroInvoice();
			inv.InvoiceID = 'fdfdsfdsfdsfdsa'; 	
			inv.Contact.OrgName = 'test1';
			inv.InvoiceNumber = 'test1';        	
			inv.Reference = 'test1';
			inv.AmountCredited = 0;
			inv.AmountDue = 50;
			inv.AmountPaid = 0;
			inv.Total = 50;
			this.xeroInvoices.add(inv); 
			inv.Contact.OrgName = 'test2';
			inv.InvoiceNumber = 'test2';        	
			inv.Reference = 'test2';
			this.xeroInvoices.add(inv); 
		} else {
			DateTime d = datetime.now();
			String todaysdate = String.valueOf(d.format('yyyy-MM-dd'));
			sfxero.XeroInvoiceResponse invoice = sfxero.XeroAPI.getInvoicesAll(cred,null,'Type=="ACCREC"&&Status=="AUTHORISED"&&Date<=DateTime.Parse("'+todaysdate+'")','');
			
			this.xeroInvoices = invoice.invoices;
		}
		this.Counter = this.xeroInvoices.size()-1;
	}
	global Integer records() {
		return this.xeroInvoices.size();
	}
	global boolean hasNext() {
		return this.xeroInvoices != null && !this.xeroInvoices.isEmpty() && this.Counter > 0;
	}
	global sfxero.XeroInvoice next() {
		return this.xeroInvoices[this.Counter--];
	}
	global List<sfxero.XeroInvoice> getAll(){
		return this.xeroInvoices;
	}	
	public static testMethod void testBatch() {
		Test.startTest();
	 	getNextXeroInvoice.isTest = true;
		getNextXeroInvoice scriptBatch = new getNextXeroInvoice();
		scriptBatch.records();
		scriptBatch.hasNext();
		scriptBatch.next();
		scriptBatch.getAll();
		Test.stopTest();
	}
}