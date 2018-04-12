public with sharing class SendCredit {
	public Credit__c credit {set; get;}
	public Account acc {set; get;}
	public String email {set; get;}
	public String subject {set; get;}
	public String body {set; get;}
	
	public SendCredit(ApexPages.StandardController controller){
	Credit__c cr = (Credit__c)controller.getRecord();
	
	this.credit   = [select Id, Name, Account__c, Amount__c, Credit_Left__c, Credit_Used__c, Valid_From__c  from Credit__c where Id=:cr.Id];
	
	this.acc   = [select Id, Name, Unique_Id__c, (select Email, Name from Contacts where Title = 'Billing') from Account where Id=:this.credit.Account__c];
	
	this.email = this.acc.Contacts[0].Email;
	
	this.subject = 'SponsoredLinX Credit Note - ' + this.credit.Name;
	
	String validFromDate = formatDate(String.valueOf(this.credit.Valid_From__c));
	
	this.body    =  'To '+acc.Contacts[0].Name+ ',\n\n'+
					'Please find attached a new Credit Note (No: '+this.credit.Name+') valid from '+validFromDate+' for the amount of $'+this.credit.Credit_left__c+'\n\n'+
			        'Please call us at 1300 859 600 or reply to this email if you have any questions.\n\n'+
					'Best Regards,\n\n'+
					'SponsoredLinX\n'+
					'PO Box 3200\n'+
					'Yeronga QLD 4104\n'+
					'Phone: 1300 859 600';
	}


	public PageReference Send(){
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 

        // Reference the attachment page and pass in the account ID
        PageReference creditPDF =  new PageReference('/apex/generateCreditNotePDF');
        creditPDF.getParameters().put('id',(String)this.credit.id); 
        creditPDF.setRedirect(true);

        // Take the PDF content
        try{
        	//getContent method is not avaialbe in TestMethod, so below is just a workaround
        	Blob b;
        	if(!Test.isRunningTest()) {
	            b = creditPDF.getContent();
        	} else { 
        		b = Blob.valueOf('Unit Test Attachment Body');
		    }
	        // Create the email attachment
	        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
	        String filename = 'SponsoredLinX-Credit Note-'+this.credit.Name+'.pdf';
	        efa.setFileName(filename);
	        efa.setBody(b);
	        String[] toAddresses =  new String[] {this.acc.Contacts[0].Email};
	        //String[] toAddresses =  new String[] {'bill.zhang@sponsoredlinx.com'};
	        email.setSenderDisplayName(this.subject);
	        email.setSubject( this.subject);
	        email.setToAddresses(toAddresses);
	        email.setPlainTextBody(this.body );
	        email.setReplyTo('accounts@sponsoredlinx.com');
	        email.setUseSignature(false);
	
	        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa}); // Sends the email 
	    
	        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
        }catch(Exception e){
        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses   = new String[] {'bill.zhang@sponsoredlinx.com'};
			//String[] bccAddresses  = new String[] {'william.zhang@sponsoredlinx.com'};
			mail.setToAddresses(toAddresses);
			//mail.setBccAddresses(bccAddresses);
			mail.setSenderDisplayName('Send Credit Note');
			mail.setSubject('Credit Note Sending Failure');
			mail.setBccSender(false);
			mail.setUseSignature(false);
			mail.setHtmlBody(e.getMessage());
	   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        PageReference AccountPage = new ApexPages.StandardController(this.credit).view();
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
	
	public static testMethod void test(){
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
		Credit__c credit = new Credit__c(Account__c = acc.Id, valid_From__c = Date.today(), Amount__c = 100);
		insert credit;
		ApexPages.standardController controller = new ApexPages.standardController(credit);
		SendCredit creditController =  new SendCredit(controller);
		creditController.send();
		Test.stopTest();
	}
}