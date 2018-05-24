public with sharing class SendInvoice {
	public Invoice__c inv {set; get;}
	public Account    acc     {set; get;}
	public String email  {set; get;}	
	public String ccEmail  {set; get;}
	public String subject {set; get;}
	public String body {set; get;}
	public Company__c company {set;get;}
	
	public SendInvoice(ApexPages.StandardController controller){
		Invoice__c invoice = (Invoice__c)controller.getRecord();
		
		this.inv   = [select 
							Id, 
							Account__c, 
							Invoice_Number__c, 
							Issue_Date__c, 
							Amount_Due__c,
							Due_Date__c, 
							Account_Product__r.SLX_Product__r.company_name__c 
						from 
							Invoice__c 
						where 
							Id=:invoice.Id];
		
		this.company = [select
                            Id,
                            Name,
                            Address__c,
                            Business_Name__c,
                            Email__c,
                            Logo_Code__c,
                            Phone__c,
                            ABN__c,
                            term_page__c,
                            OrgWideEmail__c
                        FROM 
                        	Company__c
                        WHERE 
                        	Name =: this.inv.Account_Product__r.SLX_Product__r.company_name__c
						];
	
		this.acc   = [select Id, Name, Unique_Id__c, (select Email, Name from Contacts where Title = 'Billing') from Account where Id=:this.inv.Account__c];
		
		this.email = this.acc.Contacts[0].Email;

		this.ccEmail = UserInfo.getUserEmail();
		
		this.subject = company.Business_Name__c + ' Invoice - ' + this.inv.Invoice_Number__c;
		
		String issue_date = formatDate(String.valueOf(this.inv.Issue_Date__c));
		String due_date   = formatDate(String.valueOf(this.inv.Due_Date__c));
		
		this.body = 'To '+acc.Contacts[0].Name+ ',\n\n'+
				  	'Please find attached a new invoice (No: '+this.inv.Invoice_Number__c+') issued on '+issue_date+'.\n';
		this.body += this.inv.Amount_Due__c > 0? 'for the amount of $'+this.inv.Amount_Due__c+' due on '+due_Date+'\n\n' : 'Your invoice has been fully paid.\n\n';
		this.body += 'Please call us at ' + company.Phone__c + ' or reply to this email if you have any questions.\n\n'+
					 'Best Regards,\n\n'+
					 company.Business_Name__c+'\n'+
					 company.Address__c;
	}
	
	
	public PageReference sendEmail(){
		send();
        PageReference AccountPage = new ApexPages.StandardController(this.inv).view();
        AccountPage.setRedirect(true);
        return AccountPage;
	}
	
	public void send() {
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 

        // Reference the attachment page and pass in the account ID
        PageReference invoicePDF =  new PageReference('/apex/printInvoice');
        invoicePDF.getParameters().put('id',(String)this.inv.id); 
        invoicePDF.setRedirect(true);

        // Take the PDF content
        try{
        	Blob b = invoicePDF.getContent();
        
	        // Create the email attachment
	        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
	        String filename = company.Business_Name__c + '-Invoice-'+this.inv.Invoice_Number__c+'.pdf';
	        efa.setFileName(filename);
	        efa.setBody(b);
	        String[] toAddresses =  new String[] {this.acc.Contacts[0].Email};

	        // get cc address
	        String currentUserEmail = UserInfo.getUserEmail();
			String[] ccAddresses = new String[] {currentUserEmail};

	        //email.setSenderDisplayName(company.Business_Name__c);
	        
	        email.setSubject( this.subject);
	        email.setToAddresses(toAddresses);
	        email.setccAddresses(ccAddresses);
	        email.setPlainTextBody(this.body );
	        email.setReplyTo(company.Email__c);
	        email.setUseSignature(false);
	        email.setOrgWideEmailAddressId(company.OrgWideEmail__c);
	
	        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa}); // Sends the email 
	    
	        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
        }catch(Exception e){
        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses   = new String[] {'bill.zhang@sponsoredlinx.com', 'william.zhang@sponsoredlinx.com'};
			mail.setToAddresses(toAddresses);
			mail.setSenderDisplayName('Send Invoice');
			mail.setSubject('Invoice Sending Failure');
			mail.setBccSender(false);
			mail.setUseSignature(false);
			mail.setHtmlBody(e.getMessage());
	   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
	}
	
	private String formatDate(String usDate){
		String[] temp = usDate.split('-');
		String year   = temp.get(0);
		String month  = temp.get(1);
		String day    = temp.get(2);
		String ozDate = day + '/' + month + '/' + year;
		return ozDate;	
	}
	
	
	public static testMethod void testSendInvoice(){
		Test.startTest();
		Account acc = new Account(name='test',company__c='test',username__c='test',password__c='test');
		insert acc;
		
		Contact con = new Contact(FirstName='test',LastName='test',Title='Billing',AccountId=acc.id);
		con.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
		con.MailingCity='Brisbane';
		con.MailingState='queensland';
		con.MailingPostalCode='4444';
		con.MailingCountry='Australia';
		insert con;
		
		Company__c com = new Company__c();
		com.name = 'test company';
		insert com;
		
		SLX_Product__c product = new SLX_Product__c();
		product.company_name__c = com.name;
		product.product_price__c = 10;
		insert product;
		
		Account_Product__c ap1 = new Account_Product__c(name = 'test', product_price__c=50, Account__c = acc.Id,recurring_period__c='Weekly', SLX_Product__c=product.id);
		insert ap1;
		
		Invoice__c invoice1 = new Invoice__c( Account__c = acc.Id, Issue_Date__c = Date.today(), Due_Date__c = Date.today(), Invoice_Total__c = 10, account_product__c=ap1.id);
		insert invoice1;
		
		ApexPages.standardController controller = new ApexPages.standardController(invoice1);
		SendInvoice printInv =  new SendInvoice(controller);
		printInv.Send();			
		Test.stopTest();
	}
	
	
	
	
	
	
	
	
	
	
	

}