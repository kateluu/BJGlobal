global with sharing class SendSignupToXero {

    public Static Decimal getPromoPriceForProduct(Decimal SLXProductPrice, ID PromoCodeID, String isRecurring) {
    	try {
    		Promotions__c promotion = [SELECT IsActive__c,Setup_Discount_Type__c,Setup_Discount__c,Management_Discount_Type__c,Management_Discount__c FROM Promotions__c WHERE Id IN (SELECT Promotions__c FROM Promocode__c WHERE Id=:PromoCodeId)];
    		if (promotion.IsActive__c) {
    			if (isRecurring == 'Yes') {
    				if (promotion.Management_Discount_Type__c == '%') {
    					return SLXProductPrice - (SLXProductPrice*(promotion.Management_Discount__c / 100));
    				} else {
    					return SLXProductPrice - promotion.Management_Discount__c;
    				}	
    			} else {
    				if (promotion.Setup_Discount_Type__c == '%') {
    					return SLXProductPrice - (SLXProductPrice*(promotion.Setup_Discount__c / 100));
    				} else {
    					return SLXProductPrice - promotion.Setup_Discount__c;
    				}
    			}    			
    		}		
    	} catch(Exception e) {
    		
    	}
    	return SLXProductPrice;	
    }
	/*
    @future (callout=true)
    public static void sendToXero(Id signupid, Boolean setupProducts, Boolean recurringProducts) {
		
		Audit_Log__c al = new Audit_Log__c(Name = 'SendSignupToXero',Details__c = 'Signup Id: ' + signupid + '\r\n');
		
		// Source Data
		Sign_Up__c signup = [Select Invoiceno__c,s.Status__c,s.Promocode__c,s.Product_Company__c,s.Product_Type__c, s.Product_Family__c, s.Product_Package__c, s.Opportunity__c, s.Name, s.Id, s.Account__c From Sign_Up__c s Where Id = :signupid];
		List<SLX_Product__c> SLXProducts = [Select Id,ProductCode__c,product_description__c,Name,Product_Recurring__c,Product_Price__c FROM SLX_Product__c WHERE company_name__c=:signup.Product_Company__c and Product_Family__c=:signup.Product_Family__c and Product_Package__c=:signup.Product_Package__c];
		Contact con; 
		Account acc; 
		Boolean hasError = false;
		String invoice_number = signup.Invoiceno__c;  	
    	try {	
    		acc = [Select a.Id, a.Unique_Id__c, a.Name, a.Company__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity From Account a Where a.Id = :signup.Account__c];
    		    	
    		con = [Select FirstName, LastName, Email, MailingStreet, MailingCity, MailingPostalCode, MailingState,MailingCountry from Contact Where AccountId = :acc.Id And Title = 'Billing'];
    	} catch (Exception e){
    		hasError = true;    		
    	}
    	if (hasError==false) {
	    	System.debug('Account Products Size: ' + SLXProducts.size());
	    	al.Details__c += 'Account Products Size: ' + SLXProducts.size() + '\r\n';
	    	// Xero Credential
	        String consumerKey = 'CJSE8SW0UHFRWFRSJVNVF4YEUVATZY';
	        String privateKey = 'MIICXAIBAAKBgQCZjhkaqM5rb0O3d/50XuzagfDz51ZQZH52/QRH/uVOqA8OWcSv\n'
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
			sfxero.XeroCredentials cred = new sfxero.XeroCredentials(consumerkey, '', privatekey);
	        
	        // Define a Xero Invoice
	        sfxero.XeroInvoice xisetup = new sfxero.XeroInvoice();
	        sfxero.XeroInvoice xirecur = new sfxero.XeroInvoice();
	        //xi.reference = 'ACC' + acc.
	        
	        // Define a Xero Contact
	        sfxero.XeroContact xc 				= new sfxero.XeroContact();
	        xc.isCustomer						= true;
	        xc.orgName 							= acc.Name;
	        xc.firstName 						= con.FirstName;
	        xc.lastName 						= con.LastName;
	        xc.emailaddress 					= con.Email;
	        sfxero.XeroContact.XeroAddress xa 	= new sfxero.XeroContact.XeroAddress();
	        xa.addressType 						= sfxero.XeroContact.XeroAddressType.STREET;
	        try {
		        List<String> addlines = con.MailingStreet.split('\r\n');
		        for (Integer i = 0; i < addlines.size(); i++){
		        	if (i == 0) xa.addressLine1 = addlines[i];
		        	if (i == 1) xa.addressLine2 = addlines[i];
		        	if (i == 2) xa.addressLine3 = addlines[i];
		        	if (i == 3) xa.addressLine4 = addlines[i];
		        }
	        } catch (System.Nullpointerexception npe) {}
	        
	        
	        try { xa.city = con.MailingCity; } catch (System.Nullpointerexception npe) {}
	        try { xa.region = con.MailingState; } catch (System.Nullpointerexception npe) {}
	        try { xa.postalcode = con.MailingPostalCode; } catch (System.Nullpointerexception npe) {}
	        try { xa.country = con.MailingCountry; } catch (System.Nullpointerexception npe) {}
			xc.addresses.add(xa);
	        
	        //Invoice for Setup Product
	        xisetup.contact = xc;
	        xisetup.invoiceType = sfxero.XeroInvoice.XeroInvoiceType.ACCREC;
	        xisetup.invoiceNumber = invoice_number;
	        xisetup.reference = acc.Unique_Id__c;
	        xisetup.status = sfxero.XeroInvoice.XeroInvoiceStatus.DRAFT;
	        //xi.lineAmountTypes = sfxero.XeroInvoice.XeroLineAmountType.INCLUSIVE;
	        
	        //Invoice for Recurring Products
	        xirecur.contact = xc;
	        xirecur.invoiceType = sfxero.XeroInvoice.XeroInvoiceType.ACCREC;
	        xirecur.reference = acc.Unique_Id__c;
	        xirecur.status = sfxero.XeroInvoice.XeroInvoiceStatus.DRAFT;
	        
	        System.debug('Invoice Setup:'+xisetup);	        
	        System.debug('Invoice Recurring:'+xirecur);
	        System.debug('Signup:'+signup);
	        System.debug('Signup Products:'+SLXProducts);
	        
	        Decimal invtotal = 0;
	        
	        for (SLX_Product__c slxp : SLXProducts){
	        	System.debug('Account_Product__c:'+slxp);
	        	
	        	Decimal promoPrice = SendSignupToXero.getPromoPriceForProduct((Decimal)slxp.Product_Price__c,(Id)signup.Promocode__c,(String)slxp.product_recurring__c);
	        	
		        sfXero.XeroLineItem description = new sfxero.XeroLineItem();
		        description.accountCode = '200';
		        description.lineAmount = promoPrice;
		        description.quantity = 1;
		        description.unitAmount = promoPrice;
		        description.description = slxp.ProductCode__c + ' - ' + slxp.Name;
		        al.Details__c += '200' + ' ' + description.lineAmount + ' ' + description.unitAmount + ' '	 + description.description + '\r\n';
		        
		        //add setup line item
		        if(slxp.product_recurring__c == 'No') {
		        	xisetup.addLineItem(description);
		        	System.debug('Adding LineItem Setup:'+description);	
		        	al.Details__c += 'PRODUCT ADDED\r\n';
		        }
		        //add recurring line item 
		        if(slxp.product_recurring__c == 'Yes') {
		        	xirecur.addLineItem(description);
		        	System.debug('Adding LineItem Recurring:'+description);	
		        	al.Details__c += 'PRODUCT ADDED\r\n';
		        }
		        invtotal = invtotal + promoPrice;
	        }
	        System.debug('Invoice:' + xisetup);
	        List<sfxero.XeroInvoice> xil = new List<sfxero.XeroInvoice>();
	        xil.add(xisetup);
	        xil.add(xirecur);
	        sfxero.XeroInvoiceResponse xir;
	        	        
	        System.debug('Invoice List:' + xil);
	        //System.debug('Invoice Raw Response:' + xi.rawResponse);
	        boolean savesignup = false;
	        try {
	        	//disable creating invoices for the time being
	        	System.debug('RESPONSE: '+sfxero.XeroAPI.postInvoices(xil,  cred));
	        	System.debug('Post Invoice Response 1:' + xir); 
	        	savesignup = true;       	
	        } catch(Exception e) {
	        	savesignup = false;
	        	System.debug('Exception:'+e.getMessage());
	        	xir = new sfxero.XeroInvoiceResponse();
	        }
	        System.debug('Post Invoice Response 2:' + xir);
	        
	        al.Details__c += 'PRODUCT ADDED\r\n';
	        
	        System.debug('Syncing SF Account to Xero Contact');
	        //sync salesforce account with xero contacts
	        List<sfxero.XeroContact> conList = new List<sfxero.XeroContact>();
			conList.add(xc);
			
			//if(savesignup==true) {
			//	//get invoice number from Xero invoice response
			//	System.debug('Update Signup record start');
		    //    sfxero.XeroInvoice invDetails = xir.invoices[0];
		    //    invoice_number = invDetails.InvoiceNumber;
		    //    signup.Invoiceno__c = invoice_number;
		    //    System.debug('Signup record : '+signup);
		    //    update signup;
		    //    System.debug('Update Signup record finish');
			//}
			
			sfxero.XeroContactResponse xcr;
	        try {
	        	System.debug('Signup Contacts Request : '+conList);
	        	xcr = sfxero.XeroAPI.postContacts(conList, cred);
	        	System.debug('Signup Contacts Response : '+xcr);
	        	
	        	if (xcr.httpResponseCode == 200 && xcr.status == 'OK') {
		        	acc.Xero_Sync_ID__c = xcr.contacts[0].contactID;
		        	acc.Xero_Sync__c	= true;
	        	} else {
	        		acc.Xero_Sync_ID__c = xcr.status;
	        		acc.Xero_Sync__c	= false;
	        	}
	        } catch(Exception e) {
	        	acc.Xero_Sync_ID__c = e.getMessage();
	        	System.debug('Exception:'+e.getMessage());
	        	acc.Xero_Sync__c	= false;
	        }	        
	        update acc;
	        System.debug('Contact Xero Sync Result is:'+acc.Xero_Sync__c);
	        //end sync
	        
	        for (SLX_Product__c slxp : SLXProducts){        	
	        	Decimal promoPrice = SendSignupToXero.getPromoPriceForProduct((Decimal)slxp.Product_Price__c,(Id)signup.Promocode__c,(String)slxp.product_recurring__c);
	        
		        Account_Product__c accp = new Account_Product__c();
		        accp.Sign_Up_del__c = signupid;
		        accp.Account__c = signup.Account__c;
		        accp.SLX_Product__c = slxp.Id;
		        accp.Name = slxp.Name;
		        accp.Product_Price__c = promoPrice;
		        if(slxp.Product_Recurring__c == 'Yes') {
		        	accp.Recurring_Frequency__c = 1;	
		        }
		        try {
		        	insert accp;
		        	System.debug('Inserting Product to Account_Product:'+accp);
		        } catch(Exception e){
		        	System.debug('Failed to insert to Account_Product:'+accp);
		        }	        
	        }
	        
			try {
	        	insert al;
	        } catch (Exception e){
	        	insert new Audit_Log__c(Name = 'SendSignuptoXero', Details__c = 'Error inserting detailed Audit Log');
	        } 
    	}   	
    } 
    
    public static void getContacts(){
    	// Xero Credential
        String consumerKey = 'CJSE8SW0UHFRWFRSJVNVF4YEUVATZY';
        String privateKey = 'MIICXAIBAAKBgQCZjhkaqM5rb0O3d/50XuzagfDz51ZQZH52/QRH/uVOqA8OWcSv\n'
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
		sfxero.XeroCredentials cred = new sfxero.XeroCredentials(consumerkey, '', privatekey);
        
        //sfxero.XeroContactResponse contacts = sfxero.XeroAPI.getContactsWithResponse(cred,System.Now(),'','');
        sfxero.XeroContactResponse contacts = sfxero.XeroAPI.getContactsAll(cred,System.Now(),'','');
        System.debug('Contacts RESPONSE: ' + contacts.contacts.size());
        
    }
    */
}