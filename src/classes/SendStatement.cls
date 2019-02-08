public with sharing class SendStatement {
	public String subject{set;get;}
	public String body{set;get;}
	public String acc_name {get;set;}
	public String acc_id {get;set;}
	public String acc_number { get;set;}
	public String statement_from { get;set;}
	public String statement_to {get; set;}
	public Date to_date;
	public String email {get; set;}
	public Account account{set; get;}
	public String s_from {get; set;}
	public String s_to   {get; set;}
	public Company__c company {get;set;}
	
	
	public SendStatement(){
		this.acc_id         = ApexPages.currentPage().getParameters().get('acc_id');
		this.acc_name       = ApexPages.currentPage().getParameters().get('acc_name');
		this.acc_number     = ApexPages.currentPage().getParameters().get('acc_number');
		this.statement_from = ApexPages.currentPage().getParameters().get('statement_from');
		this.statement_to   = ApexPages.currentPage().getParameters().get('statement_to');
		
		account = [Select 
						Name,
						CreatedDate,
				  		(Select 
				  			Contact.Name, 
				  			Contact.Email 
				  		from 
				  			Account.Contacts 
				  		where 
				  			Title = 'Billing' 
				  		limit 1) 
				   From 
				   		Account 
				   where 
				   		Id =: this.acc_id ];
				   		
		if(this.statement_to == null) {
			s_to = Date.today().format();
		} else {
			s_to = formatDate(this.statement_to);
		}
		
		if(this.statement_from == null) {
			s_from = account.CreatedDate.date().format();
		} else {
			s_from = formatDate(this.statement_from);
		}
		
		if(this.acc_name.startsWith('GetMoreTraffic')) {
			this.company = [select
                            Id,
                            Name,
                            Address__c,
                            Business_Name__c,
                            Email__c,
                            Logo_Code__c,
                            Phone__c,
                            ABN__c,
                            term_page__c
                        FROM 
                        	Company__c
                        WHERE 
                        	Name = 'Get More Traffic'
						];
		} else {
			this.company = [select
                            Id,
                            Name,
                            Address__c,
                            Business_Name__c,
                            Email__c,
                            Logo_Code__c,
                            Phone__c,
                            ABN__c,
                            term_page__c
                        FROM 
                        	Company__c
                        WHERE 
                        	Name = 'SponsoredLinx'
						];
		}
		
		this.acc_name = this.acc_name.removeStart('GetMoreTraffic - ');		
		
		this.subject = 'Statement from ' + company.Business_Name__c;
		this.body    = 'To '+account.Contacts[0].Name+ ',\n\n'+
						'Please find attached your account statement from '+this.s_from+' to ' + this.s_to +'.\n'+
						'If you have any queries, please contact us on ' + company.Phone__c + ' or reply to\n'+
						'this email.\n\n'+
						'Thank you.\n\n'+
						'Best Regards,\n'+
						company.Business_Name__c + '\n'+
						'PO Box 3200\n'+
						'Yeronga QLD 4104\n';
	}
	
	public PageReference send(){
		
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 

        // Reference the attachment page and pass in the account ID
        PageReference statement = new PageReference('/apex/StatementPDF');
		statement.getParameters().put('acc_id',this.acc_id);	
 		statement.getParameters().put('acc_name',this.account.name);
 		statement.getParameters().put('acc_number',this.acc_number);
 		statement.getParameters().put('statement_from',this.statement_from);
 		statement.getParameters().put('statement_to',this.statement_to);
 		statement.setRedirect(true);

        // Take the PDF content
        try{
        	Blob b = statement.getContent();
        
	        // Create the email attachment
	        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
	        String filename = this.acc_name+' '+this.s_from + ' - '+this.s_to+'.pdf';
	        efa.setFileName(filename);
	        efa.setBody(b);
	        String[] toAddresses =  new String[] {this.account.Contacts[0].Email};
	        email.setSenderDisplayName(this.subject);
	        email.setSubject( this.subject);
	        email.setToAddresses(toAddresses);
	        email.setPlainTextBody(this.body );
	        email.setReplyTo(company.Email__c);
	        email.setUseSignature(false);
	
	        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa}); // Sends the email 
	    
	        Messaging.SendEmailResult [] r = 
	            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
        }catch(Exception e){
        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses   = new String[] {'william.zhang@sponsoredlinx.com','bill.zhang@sponsoredlinx.com'};
			mail.setToAddresses(toAddresses);
			mail.setSenderDisplayName('Account Statement');
			mail.setSubject('Account Statement Sending Failure');
			mail.setBccSender(false);
			mail.setUseSignature(false);
			mail.setHtmlBody(e.getMessage());
	   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        PageReference AccountPage = new ApexPages.StandardController(this.account).view();
        AccountPage.setRedirect(true);
        return AccountPage;
        
	}
	
	private String formatDate(String usDate){
		String[] temp = usDate.split('-');
		String year   = temp.get(0);
		String month  = temp.get(1);
		String day    = temp.get(2);
		String ozDate = day + '/' + month + '/' + year;
		return ozDate;	
	}
	
	public static testMethod void testSendStatment(){
		Test.startTest();
	    Account acc = new Account(Name ='TestAccount1', username__c='TestAccount1', password__c='TestAccount1', CurrencyIsoCode ='AUD', Phone='78456213',Active__c= true , card_number__c ='3413551010014590', Card_Number_Masked__c ='34XX-XXXX-XXXX-4590' );
	    insert acc;

	    List<Account_Product__c> testProducts = new List<Account_Product__c>();
	    for(Integer i=0;i<1;i++) {                              
	        Account_Product__c item = new Account_Product__c(Name ='Social Engage '+1, Product_Status__c ='Active', Product_Price__c=1000, CurrencyIsoCode ='AUD', Account__c = acc.id , 
	                      recordTypeId =Schema.SObjectType.Account_Product__c.getRecordTypeInfosByName().get('Traditional Products').getRecordTypeId());
	        testProducts.add(item);
	    }
	    insert testProducts; 

		Contact con = new Contact(FirstName='test',LastName='test',Title='Billing',AccountId=acc.id, Email='test@gmail.com');
		con.MailingStreet='sdfsadfsa\r\ndfsafa\r\nsfsdfsdfs\r\ndfsdfs\r\ndfsdf';
		con.MailingCity='Brisbane';
		con.MailingState='queensland';
		con.MailingPostalCode='4444';
		con.MailingCountry='Australia';
		insert con;
		
		Company__c com = new Company__c();
		com.name = 'SponsoredLinx';
		insert com;
		
		Invoice__c invoice1 = new Invoice__c( Account__c = acc.Id, Account_Product__c = testProducts.get(0).Id, Issue_Date__c = Date.today(), Invoice_Total__c = 10);
		insert invoice1;
		
		Invoice__c invoice2 = new Invoice__c( Account__c = acc.Id,  Account_Product__c = testProducts.get(0).Id, Issue_Date__c = Date.today(),Invoice_Total__c = 10);
		insert invoice2;
		
		Invoice__c invoice3 = new Invoice__c( Account__c = acc.Id,  Account_Product__c = testProducts.get(0).Id, Issue_Date__c = Date.today().addDays(-2),Invoice_Total__c = 10, Status__c = 'AUTHORISED');
		insert invoice3;
		
		
		Payment__c testpayment1 = new Payment__c( Account__c = acc.Id, Payment_Option__c = 'Eway', Payment_Date__c = Date.today(), Payment_Amount__c = 2.0);
		insert testpayment1;
		
		Payment__c testpayment2 = new Payment__c( Account__c = acc.Id, Payment_Option__c = 'Eway', Payment_Date__c = Date.today().addDays(100), Payment_Amount__c = 2.0);
		insert testpayment2;
		
		PageReference pageRef = ApexPages.currentPage();
		pageRef.getParameters().put('acc_id',acc.Id);
		pageRef.getParameters().put('acc_id',acc.Id);	
 		pageRef.getParameters().put('acc_name',acc.Name);
 		pageRef.getParameters().put('statement_from','2012-01-01 00:00:00');
 		pageRef.getParameters().put('statement_to','2012-09-01 00:00:00');	
		SendStatement sendstatment = new SendStatement();
		sendstatment.send();
		
		
		Test.stopTest();
			
	
	}
	
}