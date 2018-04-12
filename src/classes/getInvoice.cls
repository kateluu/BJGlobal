public with sharing class getInvoice {
    private sfxero.XeroInvoice invDetails;
    private sfxero.XeroLineItem invLineItems;
    
    public getInvoice() {}
    
    public getInvoice(String invnum) {
    	try {
	    	sfxero.XeroCredentials cred = new sfxero.XeroCredentials();
        	cred.consumerKey = 'CJSE8SW0UHFRWFRSJVNVF4YEUVATZY';
        	cred.privateKey = 'MIICXAIBAAKBgQCZjhkaqM5rb0O3d/50XuzagfDz51ZQZH52/QRH/uVOqA8OWcSv\n'
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
          	sfxero.XeroInvoiceResponse invResponse = sfxero.XeroAPI.getInvoiceByNumber(cred,invnum); 
          	invDetails = invResponse.invoices[0];          	
    	}  catch(Exception e) {}
    }
                                
    public void init() {
    	try {
    		String invNumber = '';
	    	if (ApexPages.CurrentPage().getParameters().get('invnum') != null) { 
	    		invNumber = ApexPages.CurrentPage().getParameters().get('invnum'); 
	    	}
	    	sfxero.XeroCredentials cred = new sfxero.XeroCredentials();
        	cred.consumerKey = 'CJSE8SW0UHFRWFRSJVNVF4YEUVATZY';
        	cred.privateKey = 'MIICXAIBAAKBgQCZjhkaqM5rb0O3d/50XuzagfDz51ZQZH52/QRH/uVOqA8OWcSv\n'
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
          	sfxero.XeroInvoiceResponse invResponse = sfxero.XeroAPI.getInvoiceByNumber(cred,invNumber); 
          	invDetails = invResponse.invoices[0];          	
    	}  catch(Exception e) {}    
    }
    
    public sfxero.XeroInvoice getinvDetails() {
    	System.debug(this.invDetails);
    	try {
    	this.invLineItems = this.invDetails.lineItems[0];
    	} catch(Exception e) {}
   		return this.invDetails;
    }
    
    public sfxero.XeroLineItem getinvLineItems() {
    	System.debug(this.invLineItems);
    	return this.invLineItems;
    }
    
    public static testMethod void getInvoiceTest() {
    	getInvoice inv1 = new getInvoice('INV - TEST1');
    	inv1.init();
    	inv1.getinvDetails();
    	inv1.getinvLineItems();
    	
    	getInvoice inv2 = new getInvoice();
    	ApexPages.CurrentPage().getParameters().put('invnum','INV14526177');
    	inv2.init();
    	inv2.getinvDetails();
    	inv2.getinvLineItems();
    }
}