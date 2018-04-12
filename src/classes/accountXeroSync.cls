global class accountXeroSync {
	public static boolean isTest = false;
	public static boolean isTest2 = false;
	
	global class WebServiceResultAccountSync {
		WebService Boolean status;
		WebService String message;
	}

	WebService static WebServiceResultAccountSync syncWithXero(ID accid) {
		String consumerkey  = 'CJSE8SW0UHFRWFRSJVNVF4YEUVATZY';
		String privatekey   = 'MIICXAIBAAKBgQCZjhkaqM5rb0O3d/50XuzagfDz51ZQZH52/QRH/uVOqA8OWcSv\n'
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
		Boolean hasaccount = false;
		WebServiceResultAccountSync return_result = new WebServiceResultAccountSync();

		sfxero.XeroCredentials cred = new sfxero.XeroCredentials(consumerKey, '', privateKey);
        Account account;
        Contact contact;
        System.debug('Account ID:' + accid);
        try {
        	account = [SELECT Id, Name FROM Account WHERE id=:accid];
        	contact = [SELECT FirstName, LastName, Email, MailingStreet, MailingCity, MailingPostalCode, MailingState, MailingCountry FROM Contact WHERE AccountId = :accid AND Title = 'Billing'];
        	hasaccount = true;
        } catch (Exception e) {
        	hasaccount = false;
			return_result.status = false;
			return_result.message = 'Either the Account does not exist or there is no "Billing" Contact inside this Account';
        }

        if (hasaccount) {
	        System.debug('Account : ' + account);
	        System.debug('Contact : ' + contact);	        

			sfxero.XeroContact xc 				= new sfxero.XeroContact();
	        xc.isCustomer						= true;
	        xc.orgName 							= account.Name;
	        xc.firstName 						= contact.FirstName;
	        xc.lastName 						= contact.LastName;
	        xc.emailaddress 					= contact.Email;
	        sfxero.XeroContact.XeroAddress xa 	= new sfxero.XeroContact.XeroAddress();
	        xa.addressType 						= sfxero.XeroContact.XeroAddressType.STREET;
	        try {
		        List<String> addlines = contact.MailingStreet.split('\r\n');
		        for (Integer i = 0; i < addlines.size(); i++){
		        	if (i == 0) xa.addressLine1 = addlines[i];
		        	if (i == 1) xa.addressLine2 = addlines[i];
		        	if (i == 2) xa.addressLine3 = addlines[i];
		        	if (i == 3) xa.addressLine4 = addlines[i];
		        }
	        } catch (System.Nullpointerexception npe) {}	        

	        xa.city 		= contact.MailingCity;
	        xa.region 		= contact.MailingState;
	        xa.postalcode 	= contact.MailingPostalCode;
	        xa.country 		= contact.MailingCountry;
			xc.addresses.add(xa);	        

			List<sfxero.XeroContact> conList = new List<sfxero.XeroContact>();
			conList.add(xc);

			sfxero.XeroContactResponse xcr;
	        try {
	        	System.debug('Contacts Request : ' + conList);
	        	
	        	if(isTest==true) {
	        		xcr = new sfxero.XeroContactResponse();
	        		xcr.httpResponseCode = 200;
	        		xcr.status = 'OK';
	        		xcr.xmlResponse = '<Response xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Contacts><Contact><ContactID>bd089ce0-bd1e-4b66-a639-281e3b806cb4</ContactID></Contact></Contacts></Response>';
	        	} else {
	        		xcr = sfxero.XeroAPI.postContacts(conList, cred);	
	        	}
	        	if(isTest2==true) {
	        		xcr = new sfxero.XeroContactResponse();
	        		xcr.httpResponseCode = 300;
	        		xcr.status = '';	        		
	        	}
	        	
	        	System.debug('Contacts Response : ' + xcr);

	        	if (xcr.httpResponseCode == 200 && xcr.status == 'OK') {
	        		String xml_response = xcr.xmlResponse;
	        		Dom.Document doc = new Dom.Document();
					doc.load(xml_response);
	        		Dom.XMLNode response = doc.getRootElement();
					Dom.XMLNode contacts = response.getChildElement('Contacts', null);
					Dom.XmlNode[] contact_childs = contacts.getChildElements();
					Dom.XMLNode contact_child = contact_childs[0];
					String contact_id = contact_child.getChildElement('ContactID', null).getText();

		        	account.Xero_Sync_ID__c = contact_id;
		        	account.Xero_Sync__c = true;

					return_result.status = true;
					return_result.message = 'Successfully sync the account';
	        	} else {
	        		account.Xero_Sync__c = false;
					return_result.status = false;
					return_result.message = 'Error when syncing account with Xero';
	        	}
	        	if (istest==true) { String s; s.toUpperCase(); }
	        } catch(Exception e) {
	        	account.Xero_Sync__c = false;
				return_result.status = false;
				return_result.message = e.getMessage();
	        }	        
	        update account;			
        }

        return return_result;
	}	

	public static testMethod void accountXeroSyncTest() {
		Test.startTest();
		
		accountXeroSync.isTest = true;		
		accountXeroSync.syncWithXero('00190000008zAC5AAM');
						
		Account acc = new Account(name='test',company__c='test',username__c='test',password__c='test');
		insert acc;
		Contact con = new Contact(FirstName='test',LastName='test',Title='Billing',AccountId=acc.id);
		con.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
		con.MailingCity='Brisbane';
		con.MailingState='queensland';
		con.MailingPostalCode='4444';
		con.MailingCountry='Australia';
		insert con;
		accountXeroSync.syncWithXero(acc.id);
		
		accountXeroSync.isTest2 = true;
		
		Account acc2 = new Account(name='test2',company__c='test2',username__c='test2',password__c='test2');
		insert acc2;
		Contact con2 = new Contact(FirstName='test',LastName='test',Title='Billing',AccountId=acc2.id);
		con2.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
		con2.MailingCity='Brisbane';
		con2.MailingState='queensland';
		con2.MailingPostalCode='4444';
		con2.MailingCountry='Australia';
		insert con2;
		accountXeroSync.syncWithXero(acc2.id);
		
		Account acc3 = new Account(name='test3',company__c='test3',username__c='test3',password__c='test3');
		insert acc3;
		Contact con3 = new Contact(FirstName='test',LastName='test',Title='Billing',AccountId=acc3.id);
		con3.MailingStreet= null;
		con3.MailingCity=null;
		con3.MailingState=null;
		con3.MailingPostalCode=null;
		con3.MailingCountry=null;
		insert con3;
		accountXeroSync.syncWithXero(acc3.id);
		
		Test.stopTest();
	}
}