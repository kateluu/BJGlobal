// No longer used. The general "make a payment" button now handles all payment methods.
public with sharing class MakeAPaymentCommweb {
public String TESTMESSAGE {get;set;}
  	public boolean isTest {get;set;}
  	public boolean generateErrors {get;set;}
  
  	public boolean PageRefresh {get;set;}
  
  	public List<Invoice__c> invoice = new List<Invoice__c>();
  	public Account acc {get;set;}
  	public List<Invoice__c> checkInvoice = new List<Invoice__c>(); 
  	public Decimal paymentAmount {get;set;}
  	public Boolean showPaymentButton {get;set;}
  	public Boolean commwebPayment {get;set;}
  	public Decimal invoiceTotal {get;set;}
  	public String invoiceNumber {get;set;}
  	public String PaymentType {get;set;}
  	public String PaymentReference {get;set;}
  	public Boolean complete {get;set;}
  	public Boolean incomplete {get;set;}
  	public Payment__c inputPayment = new Payment__c();
  	public String invChecked {get;set;}
  	public String invoiceId {get;set;}
  	public String cardName {get;set;}
  	public String cardNumber {get;set;}
  	public String cardMonthExpiry {get;set;}
  	public String cardYearExpiry {get;set;}
  	public String cardCVN {get;set;}
  	public String message {get;set;}
  	public String AccountProduct {get; set;}
  	public String CommwebCompany {get; set;}
  	public String CurrencyIsoCode {get; set;}
  	
  	public list<Payment__c> listOfPayments = new list<Payment__c>();
  
  	public List<Payment__c> getlistOfPayments() {
    	return listOfPayments;
  	}
  	public void setlistOfPayments(list<Payment__c> value) {
    	listOfPayments = value;
  	}
  	public List<Invoice__c> getcheckInvoice() {
    	return checkInvoice;
  	}
  	public void setcheckInvioce(List<Invoice__c> value) {
    	checkInvoice = value;
  	}
  	public List<Invoice__c> getinvoice() {
    	return invoice;
  	}
  	public void setinvioce(List<Invoice__c> value) {
    	invoice = value;
  	}	
  
  	public List<SelectOption> getinvoiceItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('','--none--')); 
        for(Invoice__c thisInvoice : this.invoice){
          options.add(new SelectOption(thisInvoice.Name,thisInvoice.Name));  
        }
        
        return options; 
	}
	
	public List<Invoice__c> getInvList() {
        return this.invoice;        
    }
    
    public void setInvList(List<Invoice__c> listofinv) {
        this.invoice = listofinv;        
    }
    
  	public Payment__c getinputPayment() {
    	return inputPayment;
  	}
  	
  	public void setinputPayment(Payment__c value) {
   		inputPayment = value;
  	}
  
  	public List<SelectOption> getInvoiceNumbers() {
      	List<SelectOption> options = new List<SelectOption>();
        for(Invoice__c thisInvoice : this.invoice){
          	options.add(new SelectOption(thisInvoice.Invoice_Number__c,thisInvoice.Invoice_Number__c));  
        }
      	return options;
  	}
  	
  	public List<SelectOption> getPaymentTypes() {
     	 List<SelectOption> options = new List<SelectOption>();
      	options.add(new SelectOption('','---None---'));
      	options.add(new SelectOption('Commweb','Commweb'));
        options.add(new SelectOption('Commweb Failure','Commweb Failure'));
      	options.add(new SelectOption('Cheque','Cheque'));
      	options.add(new SelectOption('EFT','EFT'));
     	options.add(new SelectOption('Other','Other'));
      
      	return options;
  	}
  
  	public void ChangeInvoiceNumber() {
	    this.commwebPayment = false;
	    this.PaymentType = '';
	    this.cardName = '';
	    this.cardNumber = '';
	    this.cardMonthExpiry = '';
	    this.cardYearExpiry = '';
	    this.cardCVN = '';
	    for(Invoice__c thisInvoice : this.invoice){
      		if (thisInvoice.Invoice_Number__c == this.invoiceNumber) {
        		this.invoiceNumber   	  	= thisInvoice.Invoice_Number__c;
          		this.invoiceTotal     		= thisInvoice.Amount_Due__c;
	          	this.paymentAmount     		= thisInvoice.Amount_Due__c;
          		this.PaymentReference   	= thisInvoice.Invoice_Number__c;
          		this.PaymentType     		= thisInvoice.Account_Product__r.Payment_Option__c;
	          	this.InvoiceId      		= thisInvoice.Id;
	          	this.AccountProduct     	= thisInvoice.Account_Product__c;
	          	this.CommwebCompany			= thisInvoice.Account_Product__r.SLX_Product__r.company_name__c;
	         	this.CurrencyIsoCode        = thisInvoice.CurrencyIsoCode;
          		if(thisInvoice.Account__r.Payment_Option__c == 'Commweb' || this.generateErrors == true) {
		            this.commwebPayment = true;
//		            this.cardName = thisInvoice.Account__r.Name_On_Card__c;
//		            this.cardNumber = thisInvoice.Account__r.Card_Number__c;
//		            this.cardMonthExpiry = thisInvoice.Account__r.Card_Month_Expiry__c;
//		            this.cardYearExpiry = thisInvoice.Account__r.Card_Year_Expiry__c;
//		            this.cardCVN = thisInvoice.Account__r.Card_CVN__c;
	          	}
      		}
    	}
    	ChangePaymentType();    
  	}
  
  	public MakeAPaymentCommweb(ApexPages.StandardController controller) {
  		
  		
  		String message = '' + ApexPages.CurrentPage().GetParameters().Get('response');
        String pageHeaderReferer = ApexPages.currentPage().getHeaders().get('Referer'); 
        system.debug(message);
        system.debug(pageHeaderReferer);
        // Use the referrer parameter to only show the message when coming from Make a Payment page
        if(pageHeaderReferer != null && pageHeaderReferer.containsIgnoreCase('makeapayment') && message != 'null'){
        	if(message == 'success'){
        		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.CONFIRM,'Transaction Completed');
        		ApexPages.addMessage(myMsg); 
         	}else{
        		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message); 
        		ApexPages.addMessage(myMsg); 
        	}
        }     
        
  		
		this.acc = (Account)controller.getRecord();
		String id = this.acc.Id;
		this.acc = [select Id, 
							Name, 
							Card_Number__c, 
							Name_On_Card__c, 
							Card_Month_Expiry__c, 
							Card_Year_Expiry__c, 
							Card_CVN__c,
							Unique_Id__c
					from Account 
					where ID =: id
					];
		system.debug(this.acc);
	    this.isTest = false;
	    this.generateErrors = false;
	    this.PageRefresh = false;
	    this.inputPayment.Payment_Date__c = date.today();
	    this.inputPayment.Payment_Type__c = 'Payment';
	    commwebPayment = false;
	    complete = false;
	    incomplete = true;
        
        this.listOfPayments = [
        	SELECT 
        		Id,
        		Name,
        		Payment_Type__c,
            Payment_Option__c,
        		Invoice_Number__c,
        		Payment_Amount__c,
        		Payment_Date__c,
        		CurrencyIsoCode,
        		Account__c 
        	FROM 
        		Payment__c 
        	WHERE 
        		Account__c =:this.acc.Id 
        	order by 
        		Name desc 
        	Limit 10
        ];
        this.showPaymentButton = true;
  	}
  
  	public PageReference PageLoad() {
        if(ApexPages.currentPage().getParameters().get('msg') != null) 
        	this.message = ApexPages.currentPage().getParameters().get('msg');
        	
        this.invoice = [
        	SELECT 
        		Id, 
        		Name,
        		Amount_Credited__c, 
        		Account__r.Payment_Option__c,
        		Account__r.Name_On_Card__c,
        		Account__r.Card_Number__c, 
        		Account__r.Card_CVN__c,
        		Account__r.Card_Month_Expiry__c,
        		Account__r.Card_Year_Expiry__c, 
        		Account_Product__c, 
        		Account_Product__r.Name,
        		Account_Product__r.OwnerId,
        		Account_Product__r.Payment_Option__c,
        		Account_Product__r.Name_On_Card__c,
        		Account_Product__r.Card_Number__c,
        		Account_Product__r.Card_Month_Expiry__c,
        		Account_Product__r.Card_Year_Expiry__c,
        		Account_Product__r.Card_CVN__c,
        		Account_Product__r.SLX_Product__r.company_name__c, 
        		Account__c, 
        		Checked__c, 
        		Invoice_Number__c, 
            	Payment_Option__c,
        		Invoice_Total__c, 
        		Amount_Paid__c, 
        		Amount_Due__c, 
        		Due_Date__c, 
        		Issue_Date__c, 
            	Payment_Response__c,
            	CurrencyIsoCode,
        		Status__c 
        	FROM 
        		Invoice__c 
        	WHERE 
        		Account__c=:acc.Id 
        	AND 
        		(Status__c = 'PARTIALLY PAID' or Status__c = 'AUTHORISED' or Status__c = 'PARTIALLY CREDITED') 
        	AND 
        		Amount_Due__c > 0
            // Commented out to support paying Commweb Failure
        	//AND 
        	//	Payment_Option__c = 'Commweb'
        	order by
        		Issue_Date__c desc
        	];
        	
    	try {
          	this.checkInvoice = this.invoice;
      		for(Invoice__c thisInvoice : this.Invoice){
	            this.invoiceNumber = thisInvoice.Invoice_Number__c;
	            list<Credit__c> RelatedCredits = new list<Credit__c>();
	            System.debug('Date.Today ='+date.today());
	            System.debug('thisInvoice.Account_Product__c = '+thisInvoice.Account_Product__c);
	            RelatedCredits = [SELECT Id, Name, Account__c, Account_Product__c, Credit_Used__c, Credit_Left__c, Amount__c, Valid_From__c FROM Credit__c WHERE Account_Product__c=:thisInvoice.Account_Product__c AND Valid_From__c <=:thisInvoice.Issue_Date__c AND Credit_Left__c > 0];
	            for(Credit__c thisRelatedCredit : RelatedCredits){
	              	Payment__c CreditPayment = new Payment__c();
	              	CreditPayment.Account__c = thisInvoice.Account__c;
	          		CreditPayment.Invoice_Reference__c = thisInvoice.Invoice_Number__c;
		          	CreditPayment.Payment_Reference__c = 'Credit from Credit ID - '+String.valueOf(thisRelatedCredit.Name);
		          	CreditPayment.Credit__c = thisRelatedCredit.Id;
		          	CreditPayment.Invoice_Number__c = thisInvoice.Invoice_Number__c;
		          	CreditPayment.Payment_Name__c = 'Credit Payment';
		          	CreditPayment.Payment_Date__c = Date.today();
		          	CreditPayment.Invoice__c = thisInvoice.Id;
		          	CreditPayment.Payment_Type__c = 'Credit';
		          	CreditPayment.CurrencyIsoCode = thisInvoice.CurrencyIsoCode;
		          	CreditPayment.Account_Product__c = thisInvoice.Account_Product__c;
		          	CreditPayment.Payment_Owner__c   = thisInvoice.Account_Product__r.OwnerId;
	        
		          	decimal CreditLeft = thisRelatedCredit.Credit_Left__c;
		          	decimal InvoiceAmountDue = thisInvoice.Amount_Due__c;
	          		decimal InvoiceAmountPaid = thisInvoice.Amount_Paid__c;
		          	decimal CreditUsed = thisRelatedCredit.Credit_used__c;
		          	decimal InvoiceAmountCredited = thisInvoice.Amount_Credited__c;
	        
	          		if(CreditLeft >= InvoiceAmountDue){
	            		CreditLeft = CreditLeft - InvoiceAmountDue;
			            CreditPayment.Payment_Amount__c = InvoiceAmountDue;
			            CreditUsed = CreditUsed + InvoiceAmountDue;
			            InvoiceAmountDue = 0;
			            InvoiceAmountPaid = InvoiceAmountPaid + CreditPayment.Payment_Amount__c;
			            InvoiceAmountCredited = InvoiceAmountCredited + CreditPayment.Payment_Amount__c;
			            thisInvoice.Status__c = 'CREDITED';
		          	} else {
	            		InvoiceAmountDue = InvoiceAmountDue - CreditLeft;
			            CreditPayment.Payment_Amount__c = CreditLeft;
			            CreditUsed = CreditUsed + CreditLeft;
			            CreditLeft = 0;
			            InvoiceAmountPaid = InvoiceAmountPaid + CreditPayment.Payment_Amount__c;
			            InvoiceAmountCredited = InvoiceAmountCredited + CreditPayment.Payment_Amount__c;
			            thisInvoice.Status__c = 'PARTIALLY CREDITED';
	          		}
	        
		          	thisInvoice.Amount_Due__c = InvoiceAmountDue;
	          		thisInvoice.Amount_Paid__c = InvoiceAmountPaid;
		          	thisInvoice.Amount_Credited__c = InvoiceAmountCredited;
	          
          		  	Credit__c updateCredit = new Credit__c();
          			updateCredit = [SELECT Id,Credit_Used__c FROM Credit__c WHERE Id=:thisRelatedCredit.Id][0];
	          		updateCredit.Credit_Used__c = CreditUsed;
	          		update updateCredit;
	          		if(CreditPayment.Payment_Amount__c > 0) {
	            		insert CreditPayment;
	            		this.PageRefresh = true;
	          		}
	          		System.debug('Before invoice update');
	          		update thisInvoice;
	          		System.debug('After invoice update'); 
	            }
      		}
          
          	System.debug('Invoice List:'+this.invoice);
		} catch (Exception e) { }
        
        
        if(this.PageRefresh){
          	PageReference MakeAPaymentPage = new PageReference('/apex/MakeAPaymentCommweb');
          	MakeAPaymentPage.getParameters().put('id',this.acc.id);
          	MakeAPaymentPage.setRedirect(true);
          	return MakeAPaymentPage;
        }
        
        ChangeInvoiceNumber();
        ChangePaymentType();
        
        
        return null;
  }

    public Decimal getallInvoiceTotal() {
      Decimal total = 0;
      if(this.invoice.size() > 0) {
        for(Invoice__c listinv : this.invoice) {
        if (listinv.Checked__c == true) {
          total = total + listinv.Amount_Due__c;  
        }    
      }
      }
      System.debug('total:'+total);
      return total;
    }
    
    
    public Decimal getUnpaidInvoiceTotal() {
      Decimal total = 0;
      if(this.invoice.size() > 0) {
        for(Invoice__c listinv : this.invoice) {
        total = total + listinv.Amount_Due__c;    
      }
      }
      System.debug('total:'+total);
      return total;
    }
    
    public PageReference updatePaymentDate() {
      system.debug('NEW PAYMENT DATE = ' + this.inputPayment.Payment_Date__c);
      return null;
    }
    
    public PageReference makeAPayment() {
    	PageReference MakeAPaymentPage = new PageReference('/apex/MakeAPaymentCommweb');
    	Decimal totalSelected   = this.getAllInvoiceTotal();
      Decimal totalUnPaid   = this.getUnpaidInvoiceTotal();
      Decimal payAmount     = this.paymentAmount;
      Boolean hasError    = false;
      Contact contact;
    
    	try{
      	contact = [SELECT Id,Name,FirstName, LastName, Email, MailingStreet, MailingCity, MailingPostalCode, MailingState,MailingCountry FROM Contact WHERE AccountId=:acc.Id and Title='Billing' limit 1];
    	} catch (Exception e) {
     		System.debug('Exception: '+e);
       	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Unable to load the Billing contact for this account');
         	ApexPages.addMessage(myMsg);
         	hasError = true;
    	}
          
    	if (this.invoiceTotal <= 0 || this.generateErrors == true) {
      	System.debug('Error: Please select atleast 1 unpaid invoice');                 
    	}
    	
    	if (payAmount <= 0) {
      	System.debug('Error: Please enter a positive number for payment');
       	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please enter a positive number for payment');
          ApexPages.addMessage(myMsg);
          hasError = true;    
    	}

    	if(commwebPayment &&  this.acc.Name_On_Card__c == null || this.generateErrors == true){
      	System.debug('Error: Please enter the name on the credit card');
       	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please enter the name on the credit card');
       	ApexPages.addMessage(myMsg);
       	hasError = true;
    	}
    	
    	if(commwebPayment && this.acc.Card_Number__c == null || this.generateErrors == true){
      	System.debug('Error: Please enter a card number');
       	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please enter a card number');
       	ApexPages.addMessage(myMsg);
       	hasError = true;
    	}
    	
    	if(commwebPayment && this.acc.Card_Month_Expiry__c == '' || this.generateErrors == true){
      	System.debug('Error: Please enter the card month expiry');
       	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please enter the card month expiry');
       	ApexPages.addMessage(myMsg);
       	hasError = true;
    	}
    	
    	if(commwebPayment && this.acc.Card_Year_Expiry__c == '' || this.generateErrors == true){
      	System.debug('Error: Please enter the card year expiry');
       	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please enter the card year expiry');
       	ApexPages.addMessage(myMsg);
       	hasError = true;
    	}

    	if(this.PaymentType == null || this.generateErrors == true) {
      	System.debug('Error: Please select a payment type');
       	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please select a payment type');
       	ApexPages.addMessage(myMsg);
       	hasError = true;
    	}
    	
    	CommwebResponse commwebResp = new CommwebResponse();
    	if (hasError==false || this.generateErrors == true) {
    		try{
      		//create commweb transaction payment
      		if(commwebPayment || this.generateErrors == true){
            commwebPayment commweb = new commwebPayment();

            String priceInCents = String.valueOf((payAmount.setScale(2) * 100).setScale(0));
            System.debug('Commweb Invoice Amount in cents: ' + priceInCents);
            commweb.setAmount(priceInCents);
            commweb.setCommwebMerchTxnRef(this.PaymentReference);
            commweb.setOrderInfo(acc.Unique_Id__c);
            commweb.setCardNum(this.acc.Card_Number__c);
            String month = '';
            if(this.acc.Card_Month_Expiry__c.length() == 1){
              month = '0' + this.acc.Card_Month_Expiry__c;
            }else {
              month = this.acc.Card_Month_Expiry__c;
            }
				
            commweb.setCardExp(this.acc.Card_Year_Expiry__c.substring(2,4) + month);

            //process commweb response
            System.debug('Commweb Payment: ' + commweb);
            if(payAmount > 0){
              commwebResp = commweb.makePayment();
            }

            System.debug('Commweb Response: ' + commwebResp);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses   = new String[] {'william.zhang@sponsoredlinx.com'};
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName(Date.today().format());
            mail.setSubject('Commweb Payment Response');
            mail.setBccSender(false);
            mail.setUseSignature(false);
	         	mail.setHtmlBody(commwebResp.vpc_AcqResponseCode + commwebResp.vpc_Message);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Commweb Response: '+ commwebResp.vpc_AcqResponseCode + commwebResp.vpc_Message);
            ApexPages.addMessage(myMsg);
            if (this.generateErrors == true) {
              String s; s.toUpperCase();
            }
        	}
        } catch (Exception e) {
          System.debug('Exception: '+e);

          System.debug('Error: Problem contacting Commweb to make payment');
          ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Commweb API Not Responding');
          ApexPages.addMessage(myMsg1);
          //MakeAPaymentPage.addMessage(myMsg1);
          ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
          ApexPages.addMessage(myMsg2);
          //MakeAPaymentPage.addMessage(myMsg2);
          hasError = true;
		   	}
      }

    	System.debug('hasError:'+hasError);
    	System.debug('CommwebRep.vpc_TxnResponseCode:'+commwebResp.vpc_TxnResponseCode);
    	Boolean Proceed = false;
    	if (commwebResp.vpc_TxnResponseCode == '0' || this.commwebPayment == false) Proceed = true;
    	if ((hasError==false && Proceed == true) || this.generateErrors == true) {
	      	List<Payment__c> thisPayments = new List<Payment__c>();
	      	Decimal totalPayAmount = payAmount;
	      	Decimal invPayment = 0;
	      	//Payment__c payment;
	      	List<Invoice__c> UpdatedInvoices = new List<Invoice__c>();
	      
	      	System.debug('this.invoice:'+this.invoice);
	      	System.debug('this.invoice.size():'+this.invoice.size());
	        if (this.invoice.size() > 0) {
	          	for(Invoice__c listinv : this.invoice) {
	            	Invoice__c inv  = new Invoice__c();
	            	inv = [SELECT Id, Name, Amount_Due__c, Amount_Paid__c FROM Invoice__c where id=:listinv.Id];
	            	Payment__c payment = new Payment__c();
	            	//System.debug('listinv.url:'+listinv.url);
		          	if (listinv.Id == this.invoiceId) {
		            	invPayment = 0; 
		            	System.debug('totalPayAmount:'+totalPayAmount);
		            	//System.debug('listinv.amountDue:'+listinv.amountDue);
			            if(totalPayAmount >= listinv.Amount_Due__c) {
			              	invPayment = listinv.Amount_Due__c;
			              	//payment.Payment_Amount__c        = totalPayAmount;
			              	totalPayAmount = totalPayAmount - listinv.Amount_Due__c;
			              
			              	inv.Amount_Due__c = 0;
			              	inv.Status__c = 'PAID';
			              	inv.Amount_Paid__c = listinv.Amount_Paid__c + invPayment;
                      		inv.Payment_Response__c = commwebResp.vpc_TransactionNo;
			              	payment.Payment_Amount__c        = invPayment;   
			            } else {
			              	if (totalPayAmount > 0 || this.generateErrors == true) {
				                invPayment = totalPayAmount;
				                inv.Amount_Due__c = listinv.Amount_Due__c - invPayment;
				                inv.Amount_Paid__c = listinv.Amount_Paid__c + invPayment;
				                inv.Status__c = 'Partially Paid';
                        		inv.Payment_Response__c = commwebResp.vpc_TransactionNo;
				                payment.Payment_Amount__c        = invPayment;
				                totalPayAmount = 0;  
			              	}
			            }
			            			
			            payment.Payment_Reference__c = this.PaymentReference;
			            payment.Account__c = this.acc.Id;
			            payment.Payment_Amount__c = invPayment;
			            payment.Account__c = this.acc.Id;
			            payment.Invoice__c = inv.Id;
			            payment.Invoice_Number__c = inv.Name;

			            inv.Invoice_Number__c    = listinv.Invoice_Number__c;
			            payment.Invoice_Reference__c        = inv.Id;
			            payment.Payment_Type__c = this.inputPayment.Payment_Type__c;
			            payment.Invoice_Number__c = listinv.Invoice_Number__c;
			            payment.Payment_Date__c   = this.inputPayment.Payment_Date__c;
			            payment.Payment_Option__c = this.PaymentType;
			            payment.CurrencyIsoCode = listinv.CurrencyIsoCode;
			            payment.Account_Product__c = listinv.Account_Product__c;
			            payment.Payment_Owner__c = listinv.Account_Product__r.OwnerId;
			            
			            datetime t = System.now();
			            System.debug('datetime: '+t);
			            System.debug('paymentDate: '+Date.newInstance(t.year(),t.month(),t.day()));  
			          
			            if(payment.Payment_Amount__c > 0) {
                    thisPayments.add(payment);
                  }

			            UpdatedInvoices.add(inv);
			        }    
	        	}
	        	
	        	if (this.commwebPayment == false || (this.commwebPayment && commwebResp.vpc_TxnResponseCode=='0')){
	          		insert thisPayments;
	          		
	          		if (payAmount > this.invoiceTotal) {
                Credit__c overpayCredit = new Credit__c();
                overpayCredit.Account__c = this.acc.id;
                overpayCredit.Credit_Used__c = 0;
                overpayCredit.Amount__c = payAmount - this.invoiceTotal;
                overpayCredit.Valid_From__c = date.today();
                overpayCredit.Account_Product__c = this.AccountProduct;
                insert overpayCredit; 
			      	}
	        	}
	        	
	        	update UpdatedInvoices;
	        	complete = true;
	        	incomplete = false;
	        }
    	}
    
      MakeAPaymentPage.getParameters().put('id',this.acc.id);
      if (hasError){
        	MakeAPaymentPage.getParameters().put('msg','Transaction Failed');
        	MakeAPaymentPage.setRedirect(true);
        	//return MakeAPaymentPage;
        	ApexPages.currentPage().getParameters().put('msg','');
        	this.message = null;
        	return null;
      } else {
        	if (this.commwebPayment == false || commwebResp.vpc_TxnResponseCode == '0'){
          	//MakeAPaymentPage.getParameters().put('msg','Transaction Completed');
          	MakeAPaymentPage.getParameters().put('response','success');
          	//ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.CONFIRM,'Transaction Completed');
       		//ApexPages.addMessage(myMsg);
        	} else {
              //MakeAPaymentPage.getParameters().put('msg','Transaction Unsuccessful | '+CommwebRep.getCommwebTrxnError());  
              MakeAPaymentPage.getParameters().put('response', commwebResp.vpc_AcqResponseCode + ' ' +commwebResp.vpc_Message);  
        	}
       
        	MakeAPaymentPage.setRedirect(true);
        	return MakeAPaymentPage;
      }
    }
    
    public PageReference returnToAccount() {
      	PageReference AccountPage = new ApexPages.StandardController(this.acc).view();
        AccountPage.setRedirect(true);
        return AccountPage;
    }
    
    public PageReference ChangePaymentType() {
      	if (this.PaymentType == 'Commweb') {
        	this.commwebPayment = true;
      	} else {
         	this.commwebPayment = false;
      	}
      	return null;
    }
 
  
}