global class XeroWebService {
	public class InvalidParamsException extends Exception {}
	public static String consumerkey  = 'CJSE8SW0UHFRWFRSJVNVF4YEUVATZY';
	public static String privatekey   = 'MIICXAIBAAKBgQCZjhkaqM5rb0O3d/50XuzagfDz51ZQZH52/QRH/uVOqA8OWcSv\n'
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

	global class WebServiceResultListInvoices {
		WebService Boolean status;
		WebService String invoices;
		WebService String message;
	}

	global class WebServiceResultInvoice {
		WebService Boolean status;
//		WebService sfxero.XeroInvoice invoice;
		WebService String invoice;
		WebService String message;
	}

	global class WebServiceResultAddInvoices {
		WebService Boolean status;
		WebService sfXero.XeroInvoice invoice;
		WebService String message;
	}

	WebService static WebServiceResultAddInvoices addInvoices(Id salesforceId) {
		WebServiceResultAddInvoices return_result = new WebServiceResultAddInvoices();

		// set xero credential
		sfxero.XeroCredentials credentials = new sfxero.XeroCredentials(XeroWebService.consumerkey, '', XeroWebService.privatekey);
//		credentials.consumerKey = XeroWebService.consumerkey;
//		credentials.privateKey =  XeroWebService.privatekey;

		// get the account unique id
		Account[] accounts = [SELECT Id, Xero_Sync_Id__c, Name, Unique_Id__c FROM Account WHERE Id =:salesforceId];
		if(accounts.size() > 0) {
			// get the account
			Account account = accounts[0];
			System.debug('account :' + account);

			// define xero contact(s) and prepare the xero response
			List<sfxero.XeroContact> contacts;
			sfxero.XeroContact contact = new sfxero.XeroContact();
			String contact_id = account.Xero_Sync_Id__c;
			sfxero.XeroContactResponse connection_response;
			sfxero.XeroTaxRateResponse taxrate_response;

			// fetch the xero contact
			try {
				connection_response = sfxero.XeroAPI.getContactById(credentials, contact_id);
				contacts = connection_response.contacts;
				contact = contacts[0];
			}
			catch (Exception e) {}

			// fetch the list of account products using this account id
			List<Account_Product__c> account_products = [Select Product_Number__c, Product_Status__c, Product_Price__c, Name, Id, Account__c, Cancellation_Date__c, Last_Invoice_Date__c, Start_Date__c, End_Date__c, Recurring_Frequency__c, Recurring_Period__c, Company__c From Account_Product__c WHERE Account__c=:salesforceId And Product_Status__c = 'Active' And Recurring_Frequency__c != 0];
			System.debug('account products :' + account_products);
			if(account_products.size() > 0) {
				// we now loop the account products and find out if the product
				// is recurring or not, then we check if the last invoiced date
				// is less than the recurring time (measured with current time).
				// if the product matches, then we need to generate the invoice
				// into xero
				for(Account_Product__c account_product : account_products) {
					// create a list of invoices
					List<sfxero.XeroInvoice> invoices = new List<sfxero.XeroInvoice>();

					// create a new invoice for this account product
					sfXero.XeroInvoice invoice = new sfXero.XeroInvoice();

					System.debug('invoice contact :' + contact);
					// append the same xero contact into xero invoice
					invoice.contact = contact;

					// we check if this account product is active and recurring
					if(account_product.Product_Status__c == 'Active' && account_product.Recurring_Frequency__c > 0) {
						// early on we set the branding theme id for current product
						String brandingid = '';
						List<Company__c> companies = [SELECT Id, Name, Business_Name__c, Address__c, Email__c, Logo_Code__c, Phone__c, Branding_Theme_Id__c FROM Company__c WHERE Id =: account_product.Company__c];
						Company__c company = null;

						if (companies.size() > 0) {
							company = companies[0];
							brandingid = company.Branding_Theme_Id__c;
						}
						// default, set to sponsoredlinx
						else {
							brandingid = 'f1e5ca3f-3648-4e8e-b34c-db2f22d48dd7';
						}
						invoice.brandingThemeID = brandingid;

						// get the last invoice date and recurring period, also
						// calculate the days and months between the dates
						String recurring_period = account_product.Recurring_Period__c;
						System.debug('Recurring period: ' + recurring_period);

						date start_date = account_product.Start_Date__c;
						System.debug('Start date: ' + start_date);

						date end_date = account_product.End_Date__c;
						System.debug('End date: ' + end_date);

						date last_invoice_date = account_product.Last_Invoice_Date__c;
						System.debug('Last invoice date: ' + last_invoice_date);

						date today_date = date.today();
						System.debug('Today date: ' + today_date);

						Integer subscription_days = 0;
						Integer subscription_months = 0;
						if(start_date != null) {
							subscription_days = start_date.daysBetween(today_date);
							System.debug('Subscription days: ' + subscription_days);

							subscription_months = start_date.monthsBetween(today_date);
							System.debug('Subscription months: ' + subscription_months);
						}


						// it turns out that this product is recurring and has
						// an upcoming invoice generator, we should save an
						// invoice into xero


						// let's create a line item for this product
						System.debug('Creating a new line item');
						sfxero.XeroLineItem line_item = new sfxero.XeroLineItem();
//						line_item.accountCode = '200'; // what ??????
						line_item.description = account_product.Product_Number__c + ' - ' + account_product.Name;
						line_item.unitAmount = account_product.Product_Price__c;
						line_item.quantity = 1;
						line_item.lineAmount = account_product.Product_Price__c;
						System.debug('Creating a new line item: ' + line_item);

						// add this line item into invoice
						invoice.addLineItem(line_item);
						System.debug('Adding line item to this invoice:' + line_item);

						// since we will have one product per invoice, we also
						// save the price into the invoice totals
//						invoice.subTotal = account_product.Product_Price__c;
						invoice.total = account_product.Product_Price__c;


						// issued date should be exactly the end of current recurring period
						System.debug('Adding issued and due date of invoice');
						if(recurring_period == 'Weekly') {
							// for weekly add the total days, either from last invoice or start date
							Integer total_days = (account_product.Recurring_Frequency__c).intValue() * 7;
							if(last_invoice_date != null) {
								invoice.issuedDate = last_invoice_date.addDays(total_days);
							}
							else {
								invoice.issuedDate = start_date.addDays(total_days);
							}
						}
						else if(recurring_period == 'Monthly') {
							// for monthly add 1 month, either from last invoice or start date
							Integer total_months = (account_product.Recurring_Frequency__c).intValue();
							if(last_invoice_date != null) {
								invoice.issuedDate = last_invoice_date.addMonths(total_months);
							}
							else {
								invoice.issuedDate = start_date.addMonths(total_months);
							}
						}
						else if(recurring_period == 'Yearly') {
							// for yearly add 1 year, either from last invoice or start date
							Integer total_years = (account_product.Recurring_Frequency__c).intValue();
							if(last_invoice_date != null) {
								invoice.issuedDate = last_invoice_date.addYears(total_years);
							}
							else {
								invoice.issuedDate = start_date.addYears(total_years);
							}
						}

						// due date should be 7 days after the due date
						invoice.dueDate = (invoice.issuedDate).addDays(7);

						System.debug('ACCOUNT UNIQUE ID: ' + account.Unique_Id__c);
						invoice.reference = String.valueOf(account.Unique_Id__c);
						invoice.invoiceType = sfxero.XeroInvoice.XeroInvoiceType.ACCREC;
						invoice.status = sfxero.XeroInvoice.XeroInvoiceStatus.DRAFT;
//						invoice.lineAmountTypes = sfxero.XeroInvoice.XeroLineAmountType.INCLUSIVE;

						// append the invoice into the list of invoices
						System.debug('Adding invoice into the list: ' + invoice);
						invoices.add(invoice);
						System.debug('All Invoices list: ' + invoices);

						sfxero.XeroInvoiceResponse invoice_response;
						try {
							invoice_response = sfxero.XeroAPI.postInvoices(invoices, credentials);
							System.debug('Post Invoice Response:' + invoice_response);
						} catch (Exception e) {
							return_result.status = false;
							return_result.message = '[ERROR] Failed adding new invoice(s) for this account: ' + e.getMessage();
				        	System.debug('Exception:' + e);
							return return_result;
						}
					}
				}
			}
		} else {
			return_result.status = false;
			return_result.message = '[ERROR] There is no account using this Id: ' + salesforceId;
			System.debug('return_result 1:' + return_result);
			return return_result;
		}

		return_result.status = true;
		return_result.message = '[Success] Adding new invoices successful. Done.';
		System.debug('return_result 2:' + return_result);
		return return_result;
	}

	WebService static WebServiceResultListInvoices getAccountInvoices(Id salesforceId) {
		WebServiceResultListInvoices return_result = new WebServiceResultListInvoices();
		List<sfxero.XeroInvoice> invoices;
		String params = '';

		try {
			// set xero credential
			sfxero.XeroCredentials credentials = new sfxero.XeroCredentials(XeroWebService.consumerkey, '', XeroWebService.privatekey);
//			credentials.consumerKey = XeroWebService.consumerkey;
//			credentials.privateKey =  XeroWebService.privatekey;
			// get the account unique id
			Account[] accounts = [SELECT Id, Xero_Sync_Id__c, Name FROM Account WHERE Id =:salesforceId];
			if(accounts.size() > 0) {
				Account account = accounts[0];
				try {
					// build the xero params and pass unique id as reference
//					params = 'Contact.ContactID.ToString()="' + account.Xero_Sync_Id__c + '"&&Type="ACCREC"&&Status<>"VOIDED"&&Status<>"DELETED"';
					params = 'Contact.ContactID.ToString()="' + account.Xero_Sync_Id__c + '"&&Type="ACCREC"';
					sfxero.XeroInvoiceResponse invResponse;
					invResponse = sfxero.XeroAPI.getInvoicesAll(credentials, null, params, '');
					invoices = invResponse.invoices;
					if(invoices.size() > 0) {
						System.debug('invResponse.invoices :'+invResponse.invoices);
						return_result.invoices += '[';
						for(sfxero.XeroInvoice invoice : invoices) {
							return_result.invoices += ('["' + invoice.invoiceId + '","' + invoice.invoiceNumber + '","' + invoice.status + '","' + invoice.issuedDate + '","' + invoice.dueDate + '","' + invoice.amountCredited + '","' + invoice.amountPaid + '","' + invoice.amountDue + '","' + invoice.subTotal + '","' + invoice.total + '","' + invoice.totalTax + '"],');
						}
						return_result.invoices += ']';
						return_result.status = true;
						return_result.message = 'Successfully fetch list of invoice';
						System.debug('Return Result 1:' + return_result);
						return return_result;
					}
					else {
						return_result.invoices = null;
						return_result.status = false;
						return_result.message = 'Can not find any invoice for this account';
						System.debug('Return Result 2:' + return_result);
						return return_result;
					}
				}
				catch (Exception e) {
					return_result.invoices = null;
					return_result.status = false;
					return_result.message = 'There is a problem fetching the invoices from Xero';
					System.debug('Return Result 3:' + return_result + ' ' + e);
					return return_result;
				}
			} else {
				return_result.invoices = null;
				return_result.status = false;
				return_result.message = 'There is no account using that Id';
				System.debug('Return Result 4:' + return_result);
				return return_result;
			}
		} catch (Exception e) {
			return_result.invoices = null;
			return_result.status = false;
			return_result.message = 'Failed to fetch invoice for this account';
			System.debug('Return Result 5:' + return_result);
			return return_result;
		}
		return return_result;
	}

/*
	WebService static WebServiceResultInvoice getInvoiceById(Id salesforceId, String invoiceId) {
		WebServiceResultInvoice return_result = new WebServiceResultInvoice();
		sfxero.XeroInvoice invoice;
		String params = '';

		try {
			// set xero credential
			sfxero.XeroCredentials credentials = new sfxero.XeroCredentials(XeroWebService.consumerkey, '', XeroWebService.privatekey);
//			credentials.consumerKey = XeroWebService.consumerkey;
//			credentials.privateKey =  XeroWebService.privatekey;
			sfxero.XeroInvoiceResponse invResponse = sfxero.XeroAPI.getInvoiceById(credentials, invoiceId);
			if(invResponse.invoices.size() > 0) {
				invoice = invResponse.invoices[0];
				System.debug('Invoice :' + invoice);
				//return_result.invoice += ('["' + invoice.invoiceId + '","' + invoice.invoiceNumber + '","' + invoice.issuedDate + '","' + invoice.status + '","' + invoice.amountCredited + '","' + invoice.amountPaid + '","' + invoice.amountDue + '","' + invoice.dueDate + '"]');

				return_result.invoice = '{"invoiceId": "' 
					+ invoice.invoiceId 
					+ '","invoiceNumber": "' 
					+ invoice.invoiceNumber 
					+ '","brandingThemeID": "' 
					+ invoice.brandingThemeID 
					+ '","issuedDate": "' 
					+ invoice.issuedDate 
					+ '","dueDate": "' 
					+ invoice.dueDate 
					+ '","reference": "' 
					+ invoice.reference 
					+ '","status": "' 
					+ invoice.status 
					+ '","subTotal": "' 
					+ invoice.subTotal 
					+ '","total": "' 
					+ invoice.total 
					+ '","totalTax": "' 
					+ invoice.totalTax 
					+ '","status": "' 
					+ invoice.status 
					+ '","amountCredited": "' 
					+ invoice.amountCredited 
					+ '","amountPaid": "' 
					+ invoice.amountPaid 
					+ '","amountDue": "' 
					+ invoice.amountDue 
					+ '","lineItems": [';

				Integer lineItemSize = invoice.lineItems.size();
				Integer counter = 1;
				for(sfxero.XeroLineItem lineItem : invoice.lineItems) {
					return_result.invoice += '{"description": "' 
					+ lineItem.description 
					+ '","lineAmount": "' 
					+ lineItem.lineAmount 
					+ '","quantity": "' 
					+ lineItem.quantity 
					+ '","taxAmount": "' 
					+ lineItem.taxAmount 
					+ '","taxType": "' 
					+ lineItem.taxType 
					+ '","unitAmount": "' 
					+ lineItem.unitAmount 
					+ '"}';

					// adding a comma if there is still line item
					if(counter < lineItemSize) {
						return_result.invoice += ','; 
					}
					counter++;
				}

				return_result.invoice += ']}';

//				return_result.invoice = invoice;
				return_result.status = true;
				return_result.message = 'Successfully fetch the invoice';
			}
			else {
				return_result.invoice = null;
				return_result.status = false;
				return_result.message = 'Unable to find the invoice';
			}
		} catch (Exception e) {
			return_result.invoice = null;
			return_result.status = false;
			return_result.message = 'Failed to fetch the invoice';
		}
		return return_result;
	}
*/

	static testMethod void addInvoicesNoAccountTest() {
		Test.startTest();
		XeroWebService.addInvoices('00190000005fake');
		Test.stopTest();
	}

	static testMethod void addInvoicesWeeklyTest() {
		Test.startTest();

		Account account						= new Account();
		account.Name						= 'Test Account';
		account.Company__c					= 'SponsoredLinX';
		account.username__c					= 'test@test.com';
		account.password__c					= 'test';
		insert account;

		Contact contact						= new Contact();
		contact.AccountId					= account.Id;
		contact.title						= 'Billing';
		contact.FirstName					= 'bob';
		contact.LastName					= 'down';
		contact.Email						= 'down@bob.com';
		contact.MailingStreet				= 'sdfasfsf\r\nsdfsdfdsf\r\nsdfsdfsf\r\ndsdfsdf';
		contact.MailingCity					= 'brisbane';
		contact.MailingPostalCode			= '4500';
		contact.MailingState				= 'Queensland';
		contact.MailingCountry				= 'Australia';
		insert contact;

		Account_Product__c account_product		= new Account_Product__c();
		account_product.Account__c				= account.id;
		account_product.Company__c				= 'a0C90000002PU4f'; // linked to sponsoredlinx
		account_product.Name					= 'Test Product';
		account_product.Product_Price__c		= 10.00;
		account_product.Product_Status__c		= 'Active';
		account_product.Recurring_Frequency__c	= 1;
		account_product.Start_Date__c			= date.newinstance(2010, 12, 1); 
		account_product.Last_Invoice_Date__c	= date.newinstance(2010, 12, 1);
		account_product.Recurring_Period__c		= 'Weekly'; 
		insert account_product;

		XeroWebService.addInvoices(account.Id);
		Test.stopTest();
	}
	static testMethod void addInvoicesMonthlyTest() {
		Test.startTest();

		Account account						= new Account();
		account.Name						= 'Test Account';
		account.Company__c					= 'SponsoredLinX';
		account.username__c					= 'test@test.com';
		account.password__c					= 'test';
		insert account;

		Contact contact						= new Contact();
		contact.AccountId					= account.Id;
		contact.title						= 'Billing';
		contact.FirstName					= 'bob';
		contact.LastName					= 'down';
		contact.Email						= 'down@bob.com';
		contact.MailingStreet				= 'sdfasfsf\r\nsdfsdfdsf\r\nsdfsdfsf\r\ndsdfsdf';
		contact.MailingCity					= 'brisbane';
		contact.MailingPostalCode			= '4500';
		contact.MailingState				= 'Queensland';
		contact.MailingCountry				= 'Australia';
		insert contact;

		Account_Product__c account_product		= new Account_Product__c();
		account_product.Account__c				= account.id;
		account_product.Company__c				= 'a0C90000002PU4f'; // linked to sponsoredlinx
		account_product.Name					= 'Test Product';
		account_product.Product_Price__c		= 10.00;
		account_product.Product_Status__c		= 'Active';
		account_product.Recurring_Frequency__c	= 1;
		account_product.Start_Date__c			= date.newinstance(2010, 12, 1); 
		account_product.Last_Invoice_Date__c	= date.newinstance(2010, 12, 1);
		account_product.Recurring_Period__c		= 'Monthly'; 
		insert account_product;

		XeroWebService.addInvoices(account.Id);
		Test.stopTest();
	}
	static testMethod void addInvoicesYearlyTest() {
		Test.startTest();

		Account account						= new Account();
		account.Name						= 'Test Account';
		account.Company__c					= 'SponsoredLinX';
		account.username__c					= 'test@test.com';
		account.password__c					= 'test';
		insert account;

		Contact contact						= new Contact();
		contact.AccountId					= account.Id;
		contact.title						= 'Billing';
		contact.FirstName					= 'bob';
		contact.LastName					= 'down';
		contact.Email						= 'down@bob.com';
		contact.MailingStreet				= 'sdfasfsf\r\nsdfsdfdsf\r\nsdfsdfsf\r\ndsdfsdf';
		contact.MailingCity					= 'brisbane';
		contact.MailingPostalCode			= '4500';
		contact.MailingState				= 'Queensland';
		contact.MailingCountry				= 'Australia';
		insert contact;

		Account_Product__c account_product		= new Account_Product__c();
		account_product.Account__c				= account.id;
		account_product.Company__c				= 'a0C90000002PU4f'; // linked to sponsoredlinx
		account_product.Name					= 'Test Product';
		account_product.Product_Price__c		= 10.00;
		account_product.Product_Status__c		= 'Active';
		account_product.Recurring_Frequency__c	= 1;
		account_product.Start_Date__c			= date.newinstance(2010, 12, 1); 
		account_product.Last_Invoice_Date__c	= date.newinstance(2010, 12, 1);
		account_product.Recurring_Period__c		= 'Yearly'; 
		insert account_product;

		XeroWebService.addInvoices(account.Id);
		Test.stopTest();
	}
	// correct account no
	static testMethod void getAccountInvoicesTest1() {
		Test.startTest();

		Account account						= new Account();
		account.Name						= 'Test Account';
		account.Company__c					= 'SponsoredLinX';
		account.username__c					= 'test@test.com';
		account.password__c					= 'test';
		insert account;

		XeroWebService.getAccountInvoices(account.Id);
		Test.stopTest();
	}
	static testMethod void getAccountInvoicesTest2() {
		Test.startTest();

		Account account						= new Account();
		account.Name						= 'Test Account';
		account.Company__c					= 'SponsoredLinX';
		account.username__c					= 'test@test.com';
		account.password__c					= 'test';
		insert account;

		XeroWebService.getAccountInvoices(account.Id);
		Test.stopTest();
	}
/*
	static testMethod void getInvoiceByNumberTest1() {
		Test.startTest();

		Account account						= new Account();
		account.Name						= 'Test Account';
		account.Company__c					= 'SponsoredLinX';
		account.username__c					= 'test@test.com';
		account.password__c					= 'test';
		insert account;
		String invoiceId					= 'e71580da-41fa-4df2-a631-8570aed32c7e';

		XeroWebService.getInvoiceById(account.Id, invoiceId);
		Test.stopTest();
	}
	// correct account no, wrong invoice no
	static testMethod void getInvoiceByNumberTest2() {
		Test.startTest();

		Account account						= new Account();
		account.Name						= 'Test Account';
		account.Company__c					= 'SponsoredLinX';
		account.username__c					= 'test@test.com';
		account.password__c					= 'test';
		insert account;
		String invoiceId					= 'asasas';

		XeroWebService.getInvoiceById(account.Id, invoiceId);
		Test.stopTest();
	}
*/
}