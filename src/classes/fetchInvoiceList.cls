public with sharing class fetchInvoiceList {
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
                                
    
    public List<sfxero.XeroInvoice> invoice;
    public String compname = '';
    public Datetime systemnow;
    
    public void init() {
    	/**
    	try {
    		this.systemnow = System.Now();
	    	if (ApexPages.CurrentPage().getParameters().get('id') != null) { 
	    		this.compname += 'Contact.ContactID.ToString()=="'+ApexPages.CurrentPage().getParameters().get('id')+'"&&';	
	    	} 
	    	if (ApexPages.CurrentPage().getParameters().get('name') != null) { 
	    		this.compname += 'Contact.Name=="'+ApexPages.CurrentPage().getParameters().get('name')+'"&&';
	    	}
	    	if (ApexPages.CurrentPage().getParameters().get('invstatus') != null) { 
	    		this.compname += 'Status=="'+ApexPages.CurrentPage().getParameters().get('invstatus')+'"&&'; 
	    	}
	    	if (ApexPages.CurrentPage().getParameters().get('invtype') != null) { 
	    		this.compname += 'Type=="'+ApexPages.CurrentPage().getParameters().get('invtype')+'"&&'; 
	    	}
	    	this.compname = this.compname.substring(0,this.compname.length()-2);  
    	}  catch(Exception e) {}    
    	**/
    }
        
    public List<sfxero.XeroInvoice> getInvList() {
    	/**
        // Xero Credential
        sfxero.XeroCredentials cred = new sfxero.XeroCredentials();
        cred.consumerKey = fetchInvoiceList.consumerkey;
        cred.privateKey =  fetchInvoiceList.privatekey;
        
        this.compname = 'Type=="ACCREC"&&Status=="AUTHORISED"';
        sfxero.XeroInvoiceResponse invResponse1 = sfxero.XeroAPI.getInvoicesAll(cred,null,this.compname,''); 
        this.invoice = invResponse1.invoices;
        //List<sfxero.XeroInvoice> returnValue = new List<sfxero.XeroInvoice>();
        for (sfxero.XeroInvoice inv : this.invoice) {
        	try {
        		System.debug('*****************************');
        		System.debug(inv);
        		sfxero.XeroInvoiceResponse invResponse2 = sfxero.XeroAPI.getInvoiceByNumber(cred,'INV14526177');
        		sfxero.XeroInvoice invdetails = invResponse2.invoices[0];
        		System.debug(invdetails);
        		System.debug(invdetails.lineItems);
        		//for (sfxero.XeroLineItem line : inv.lineItems) {
        		//	System.debug(line);
        		//	System.debug(line.description);
        		//	System.debug(line.lineAmount);
        		//}
        		System.debug('*****************************');
        		//get line item
        	} catch(Exception e){ }
        	
        }
        
        
        
        
        
        
        return this.invoice;
        **/
        return null;
        /*
        List<sfxero.XeroInvoice> returnValue = new List<sfxero.XeroInvoice>();
        for (sfxero.XeroInvoice inv : this.invoice){
        	if (inv.invoiceId != null && inv.invoiceId != '' && Limits.getCallouts() < Limits.getLimitCallouts()){
        		
        		List<sfxero.XeroInvoice> details = sfxero.XeroAPI.getInvoices(cred,null,'','',inv.invoiceId);
        		returnValue.addAll(details);
        		//sfxero.XeroInvoice invdetails = sfxero.XeroAPI.getInvoiceByInvoiceNumber(cred,inv.invoiceNumber);
        		//returnValue.addAll(invdetails);
        		
        	}
        	
        }
        this.invoice = returnValue;
        return returnValue;
        */
       
    }
    public String getcompname() {
    	return this.compname;
    }
    public Datetime getsystemnow() {
    	return this.systemnow;
    } 

	public static testMethod void fetchInvoiceListTest() {
		ApexPages.CurrentPage().getParameters().put('name', 'Optus');
	    fetchInvoiceList fList = new fetchInvoiceList();
	    fList.init();
	    fList.getcompname();
	    fList.getsystemnow();
	    List<sfxero.XeroInvoice> invList = fList.getInvList();
    }
	public static testMethod void fetchInvoiceListInitTest1() {
		ApexPages.CurrentPage().getParameters().put('id', '1');
	    fetchInvoiceList fList = new fetchInvoiceList();
	    fList.init();
	}
	public static testMethod void fetchInvoiceListInitTest2() {
		ApexPages.CurrentPage().getParameters().put('invstatus', '1');
	    fetchInvoiceList fList = new fetchInvoiceList();
	    fList.init();
	}
	public static testMethod void fetchInvoiceListInitTest3() {
		ApexPages.CurrentPage().getParameters().put('invtype', '1');
	    fetchInvoiceList fList = new fetchInvoiceList();
	    fList.init();
	}

}