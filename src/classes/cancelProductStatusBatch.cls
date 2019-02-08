global class cancelProductStatusBatch implements Database.batchable<Account_Product__c>, Database.Stateful, Database.AllowsCallouts {
	
	// email body. 'global' and 'Database.Stateful' will make sure its value don't reset at each batch 
	global String email_message = '';
	// The number display in email title
	global integer counter = 0;
	
	global Iterable<Account_Product__c> start(Database.batchableContext info) {
		
		this.email_message+='*****************************************************************************************\r\n';
		this.email_message+='*****  T O D A Y S   P R O D U C T    C A N C E L S \r\n';
		this.email_message+='*****************************************************************************************\r\n';
		this.email_message+='\r\n';
		this.email_message+='\r\n';
				
		return new cancelProductStatus();	
	}
	
	global void execute(Database.batchableContext info, List<Account_Product__c> scope){
		List<Task> allTasks = new List<Task>();
		List<Account_Product__c> allProducts = new List<Account_Product__c>();

		counter += scope.size();
		
		for(Account_Product__c product : scope){
			String oldStatus = product.Product_Status__c;
			String newStatus = 'Cancelled';
			
			//update status
			ID accountid = product.Account__c;
			Boolean hasError = false;
			Account acc;
			Contact con;
			try {
				acc = [Select Id, Name From Account Where Id=:accountid];
				System.debug('acc:'+acc);
			}catch(Exception e) {
				hasError = true;
				this.email_message+='------------------------------------------------------------------\r\n';
				this.email_message+='Error fetching account record from product\r\n';
				this.email_message+='Account ID:'+product.Account__c+'\r\n';
				this.email_message+='Product Name:'+product.Name+'. URL:https://ap1.salesforce.com/'+product.Id+'\r\n';
				this.email_message+='Exception: '+e.getMessage()+'\r\n';
				this.email_message+='------------------------------------------------------------------\r\n';
			}
			if(hasError==false) {
				try {
					con = [Select Id, Name, firstName, lastName, Email From Contact Where AccountId =:accountid And Title = 'Billing'][0];
					System.debug('con:'+con);
				}catch(Exception e) {
					hasError = true;
					this.email_message+='------------------------------------------------------------------\r\n';
					this.email_message+='Error fetching contact record from account\r\n';
					this.email_message+='Account ID:'+product.Account__c+'\r\n';
					this.email_message+='Account Name:'+acc.Name+'\r\n';
					this.email_message+='Product Name:'+product.Name+'. URL:https://ap1.salesforce.com/'+product.Id+'\r\n';
					this.email_message+='Exception: '+e.getMessage()+'\r\n';
					this.email_message+='------------------------------------------------------------------\r\n';
				}
			}
			if(hasError==false) {			
				//send email
				this.email_message+='------------------------------------------------------------------\r\n';
				this.email_message+='Product Change Status Required To Check\r\n';
				this.email_message+='Account ID:'+product.Account__c+'\r\n';
				this.email_message+='Account Name:'+acc.Name+'\r\n';
				this.email_message+='Product Name:'+product.Name+'. URL:https://ap1.salesforce.com/'+product.Id+'\r\n';
				this.email_message+='Product Number:'+product.Product_Number__c+'\r\n';
				this.email_message+='Changed '+product.Name+' from ['+oldStatus+'] to ['+newStatus+']\r\n';
				this.email_message+='------------------------------------------------------------------\r\n';
				this.email_message+='\r\n';
				
				//update account activity
				Task task 			= new Task();
				task.WhoId 			= con.Id;
				task.WhatID 		= accountid;
				task.Subject 		= 'Changed '+product.Name+' from ['+oldStatus+'] to ['+newStatus+']';
				task.Description 	= 'Changed '+product.Name+' from ['+oldStatus+'] to ['+newStatus+']';
				task.Type 			= 'Status';
				task.ActivityDate 	= Date.Today();
				task.Status 		= 'Completed';
				System.debug('task:'+task);
				allTasks.add(task);
				
				//update product status
				product.Product_Status__c = 'Cancelled';
				product.pauseat__c = null;

				// for social engage product, need to clear workflow control flag
				if(product.Name.containsIgnoreCase('Social Engage')){
					product.Last_Paid_Date__c = null;
					// make a synchronous call to TigerPistol
					system.debug('product.TP_Record_Id__c = ' + product.id);
					TigerPistolConnector.deleteCustomerSynch(product.id);
				}


				//update product status :  to make sure there’s only one notification in the outbound message when the product is updated
				//allProducts.add(product);
				try {
					update product;				

				} catch(Exception e) {
					this.email_message+='Error update product failed ' + product.id + ' : Name = ' + product.Name + '\r\n';
					this.email_message+='Exception: '+e.getMessage()+'\r\n';
				}

			}
		}
		
		try {
			//update allProducts;
			try {
				insert allTasks;
			} catch(Exception e) {
				this.email_message+='Error inserting all the task activities into Accounts\r\n';
				this.email_message+='Exception: '+e.getMessage()+'\r\n';
			}
		} catch(Exception e) {
			this.email_message+='Error updating new Account product statuses\r\n';
			this.email_message+='Exception: '+e.getMessage()+'\r\n';
		}
	}
	
	global void finish(Database.batchableContext info){
		this.email_message+='\r\n';
		this.email_message+='\r\n';
		this.email_message+='**************************************************************\r\n';
		this.email_message+='**************************************************************\r\n';
		this.email_message+='\r\n';
		this.email_message+='\r\n'; 
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses  = new String[] { 'accounts@sponsoredlinx.com', 'kate.lewis@sponsoredlinx.com', 'erin.birkett@sponsoredlinx.com' };
		String[] bccAddresses  = new String[] { 'alister.dunlop@sponsoredlinx.com', 'william.zhang@sponsoredlinx.com', 'hanh.luu@sponsoredlinx.com' };
		
		mail.setToAddresses(toAddresses); 
		mail.setBccAddresses(bccAddresses);
		mail.setReplyTo('accounts@sponsoredlinx.com.au');
		mail.setSenderDisplayName('Salesforce Alert');
		string title = counter + ' Products Cancel Today.';
		mail.setSubject(title);
		mail.setSaveAsActivity(true);
		mail.setUseSignature(false);
		mail.setPlainTextBody(this.email_message);
		Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail } );
   	}
   	
   	public static testMethod void testcancelProductStatusBatch() {
		Test.startTest();
	 	
	 	Account_Product__c ap1 = new Account_Product__c();
	 	ap1.Product_Status__c = 'Active';
	 	ap1.cancelat__c = Date.today()+1;
	 	ap1.Product_Price__c = 55.0;
	 	insert ap1;
	 	
	 	cancelProductStatusBatch scriptBatch1 = new cancelProductStatusBatch();
		Database.executeBatch(scriptBatch1);
	 	
	 	Account account = new Account();
		account.Name = 'Test Account';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test@test.com';
		account.password__c = 'test';
		insert account;
		
		cancelProductStatusBatch scriptBatch2 = new cancelProductStatusBatch();
		Database.executeBatch(scriptBatch2);
		
		Contact contact = new Contact();
		contact.AccountId = account.Id;
		contact.title = 'Billing';
		contact.FirstName = 'bob';
		contact.LastName = 'down';
		contact.Email = 'down@bob.com';
		contact.MailingStreet='sdfasfsf\r\nsdfsdfdsf\r\nsdfsdfsf\r\ndsdfsdf';
		contact.MailingCity='brisbane';
		contact.MailingPostalCode='4500';
		contact.MailingState='Queensland';
		contact.MailingCountry='Australia';
		insert contact;
		
	 	Account_Product__c ap = new Account_Product__c();
	 	ap.Product_Status__c = 'Active';
	 	ap.Account__c = account.Id;
	 	ap.cancelat__c = Date.today();
	 	ap.Product_Price__c = 55.0;
	 	insert ap;
	 	
		cancelProductStatusBatch scriptBatch3 = new cancelProductStatusBatch();
		Database.executeBatch(scriptBatch3);
		
		Test.stopTest();
	} 
}