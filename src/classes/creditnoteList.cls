public with sharing class creditnoteList {
	
	public List<sfxero.XeroCreditNote> creditnote;
	
	public creditnoteList(ApexPages.StandardController controller) {
        Account acc = (Account)controller.getRecord();
        
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
            
            System.Debug('Account:'+acc); 
            System.Debug('XeroString:Contact.ContactID.ToString()="'+acc.Xero_Sync_ID__c+'"&&Type="ACCREC"&&Status<>"VOIDED"&&Status<>"DELETED"');
            sfxero.XeroCreditNoteResponse crdResponse = sfxero.XeroAPI.getCreditNotesAll(cred,null,'Contact.ContactID.ToString()="'+acc.Xero_Sync_ID__c+'"&&Type="ACCRECCREDIT"&&Status<>"VOIDED"&&Status<>"DELETED"','');    
        	this.creditnote = crdResponse.creditNotes;
        } catch(Exception e) { }
	}
	public List<sfxero.XeroCreditNote> getCrdList() {
        return this.creditnote;        
    }
    public Boolean getrenderCrdList() {
    	if (this.creditnote == null) {
    		return false;
    	}
    	return true;
    }
    public Boolean getrenderCrdMsg() {
    	if (this.creditnote == null) {
    		return true;
    	}
    	return false;
    }
	public static testMethod void accountExtTest() {
		ApexPages.standardController controller = new ApexPages.standardController(new Account(name='test'));
        creditnoteList ext = new creditnoteList(controller);
        ext.getCrdList();
        ext.getrenderCrdMsg();
        ext.getrenderCrdList();
        ext.getCrdList();
        ext.getCrdList();
    }
}