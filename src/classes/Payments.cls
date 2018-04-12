public with sharing class Payments {
	
	TRANSIENT List<Payment__c> payments;
	public String description {get; set;}
	public String min {get; set;}
	public String max {get; set;}
	public String[] options {get; set;}
	public Payment__c payment1 = new Payment__c();
	public Payment__c payment2 = new Payment__c();
	public String soql = '';
	
	public ApexPages.StandardSetController con{get; set;}
	
	
	public Payments(){
	}
	
	public List<Payment__c> getPayments(){
		if(con != null) return (List<Payment__c>)con.getRecords(); 
		else return null;
	}
	
		
	public Payment__c getPayment1(){
		return this.payment1;
	}
	
	public Payment__c getPayment2(){
		return this.payment2;
	}
	
	
	
	 //Boolean to check if there are more records after the present displaying records  
    public Boolean hasNext  
    {  
        get  
        {  
            return con.getHasNext();  
        }  
        set;  
    }  
   
    //Boolean to check if there are more records before the present displaying records  
    public Boolean hasPrevious  
    {  
        get  
        {  
            return con.getHasPrevious();  
        }  
        set;  
    }  
   
    //Page number of the current displaying records  
    public Integer pageNumber  
    {  
        get  
        {  
            return con.getPageNumber();  
        }  
        set;  
    }  
  
    //Returns the previous page of records  
    public void previous()  
    {  
        con.previous();  
    }  
   
    //Returns the next page of records  
    public void next()  
    {  
        con.next();  
    }  
    
	
	public List<SelectOption> getPaymentTypes() {
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('Eway','Eway'));
    	options.add(new SelectOption('Eway Failure','Eway Failure'));
    	options.add(new SelectOption('Bill Buddy','Bill Buddy'));
    	options.add(new SelectOption('Cheque','Cheque'));
    	options.add(new SelectOption('EFT','EFT'));
    	options.add(new SelectOption('Direct Debit','Direct Debit'));
    	options.add(new SelectOption('Other','Other'));
    	options.add(new SelectOption('Commweb','Commweb'));
    	
    	return options;
	}
	
	public PageReference getResults(){
		if(this.description == '' && this.options.size() == 0 && this.min=='' && this.max == '' && this.payment1.Payment_Date__c == null && this.payment2.Payment_Date__c == null){
			return null;
		}
		Boolean hasNext = false;
		this.soql = 'select Id, Account__r.Name, Name, Invoice__r.Name, Payment_Type__c, Payment_Amount__c, Payment_Option__c, Payment_Date__c, Invoice_Number__c '+ 
					'from Payment__c where CreatedDate > 2012-07-01T00:00:00Z and ';
		if(this.description != ''){
			soql += ' Account__r.Name = \'' +this.description+ '\'';
			hasNext = true;
		}			
		if(this.options.size()!=0) {
			System.debug(options);
			String selectedOpts = '';
			for(Integer i = 0; i < this.options.size(); i++){
				if(i==0) selectedOpts = ' (Payment_Option__c = \'' +this.options[i]+ '\'';
				else selectedOpts +=' or Payment_Option__c = \'' +this.options[i]+ '\'';
			}
			selectedOpts+=')';
			if(hasNext)	soql += ' and'+selectedOpts+'';
			else soql += selectedOpts;
			hasNext = true;
		}
		if(this.min != '' && this.max != ''){
			if(hasNext) soql += ' and Payment_Amount__c >= ' +this.min+ ' and Payment_Amount__c <= ' +this.max+ '';
			else soql += ' Payment_Amount__c >= ' +this.min+ ' and Payment_Amount__c <= ' +this.max+ '';
			hasNext = true;
		}
		if(this.min != '' && this.max == ''){
			if(hasNext) soql += ' and Payment_Amount__c >= ' +this.min+ '';
			else soql += ' Payment_Amount__c >= ' +this.min+ '';
			hasNext = true;
		}
		if(this.min == '' && this.max != ''){
			if(hasNext) soql += ' and Payment_Amount__c <= ' +this.max+ '';
			else soql +=' Payment_Amount__c <= ' +this.max+ '';
			hasNext = true;		
		}
		if(this.payment1.Payment_Date__c != null && this.payment2.Payment_Date__c != null){
			String month1 = '';
			String month2 = '';
			String day1   = '';
			String day2   = '';
			if(payment1.Payment_Date__c.month() >= 10) month1 = payment1.Payment_Date__c.month()+'';
			else month1 = '0'+ payment1.Payment_Date__c.month();
			if(payment1.Payment_Date__c.day() >=  10) day1 = payment1.Payment_Date__c.day()+'';
			else day1 = '0'+ payment1.Payment_Date__c.day();
			if(payment2.Payment_Date__c.month() >= 10) month2 = payment2.Payment_Date__c.month()+'';
			else month2 = '0'+ payment2.Payment_Date__c.month();
			if(payment2.Payment_Date__c.day() >= 10) day2 = payment2.Payment_Date__c.day()+'';
			else day2 = '0'+ payment2.Payment_Date__c.day();
			String startDate = payment1.Payment_Date__c.year()+ '-' + month1+ '-' +day1;
			String endDate   = payment2.Payment_Date__c.year()+ '-' + month2+ '-' +day2;
			System.debug(startDate);
			System.debug(endDate);
			if(hasNext) soql += ' and Payment_Date__c >= ' + startDate + ' and Payment_Date__c <= ' + endDate + '';
			else soql += ' Payment_Date__c >= ' + startDate + ' and Payment_Date__c <= ' + endDate + '';
		}
		if(this.payment1.Payment_Date__c != null && this.payment2.Payment_Date__c == null){
			String month1 = '';
			String day1   = '';
			
			if(payment1.Payment_Date__c.month() >= 10) month1 = payment1.Payment_Date__c.month()+'';
			else month1 = '0'+ payment1.Payment_Date__c.month();
			if(payment1.Payment_Date__c.day() >=  10) day1 = payment1.Payment_Date__c.day()+'';
			else day1 = '0'+ payment1.Payment_Date__c.day();
	
			String startDate = payment1.Payment_Date__c.year()+ '-' + month1+ '-' +day1;
			System.debug(startDate);
			if(hasNext) soql += ' and Payment_Date__c >= ' + startDate + '';
			else soql += ' Payment_Date__c >= ' + startDate + '';
		}
		if(this.payment1.Payment_Date__c == null && this.payment2.Payment_Date__c != null){
			String month2 = '';
			String day2   = '';
			if(payment2.Payment_Date__c.month() >= 10) month2 = payment2.Payment_Date__c.month()+'';
			else month2 = '0'+ payment2.Payment_Date__c.month();
			if(payment2.Payment_Date__c.day() >= 10) day2 = payment2.Payment_Date__c.day()+'';
			else day2 = '0'+ payment2.Payment_Date__c.day();
	
			String endDate   = payment2.Payment_Date__c.year()+ '-' + month2+ '-' +day2;
			System.debug(endDate);
			if(hasNext) soql += ' and Payment_Date__c <= ' + endDate + '';
			else soql += ' Payment_Date__c <= ' + endDate + '';
		}
		System.debug(soql);
		
		try{
			con = new ApexPages.StandardSetController(Database.query(soql));
			
			con.setPageSize(100); 
		}catch(Exception e){
			System.debug(e.getMessage());
		}
		return null;	
	}
	
	public PageReference reset() {
		PageReference newpage = null;
		try{
	    	newpage = new PageReference(System.currentPageReference().getURL()); 
	    	newpage.getParameters().clear();
	    	newpage.setRedirect(true);   
		}catch(Exception e){
			System.debug(e.getMessage());
		}
		
	    return newpage;
 	}
 	
 	
 	public PageReference export(){
 		PageReference paymentExport = new PageReference('/apex/PaymentExport');
 		paymentExport.getParameters().put('soql',this.soql);
        paymentExport.setRedirect(false);
        return paymentExport;    
	}
	
	
	
	public static testMethod void testPayment(){
		Payments payments = new Payments();
		
		payments.getPayment1();
		payments.getPayment2();
		payments.getPaymentTypes();
		//payments.getResults();
		payments.export();
	}
	
	
	public static testMethod void testPayment1(){
		Account acc = new Account(Name='TestAccount', username__c = 'test', password__c = 'test');
		insert acc;
		Payment__c testpayment1 = new Payment__c( Account__c = acc.Id, Payment_Option__c = 'Eway', Payment_Date__c = Date.today(), Payment_Amount__c = 2.0);
		insert testpayment1;
		
		Payment__c testpayment2 = new Payment__c( Account__c = acc.Id, Payment_Option__c = 'Eway', Payment_Date__c = Date.today().addDays(100), Payment_Amount__c = 2.0);
		insert testpayment2;
		
		Payments payments = new Payments();
		payments.getPayments();
		payments.payment1 = testpayment1;
		payments.payment2 = testpayment2;
		
		payments.options = new List<String>();
		payments.options.add('Eway');
		payments.getPayment1();
		payments.getPayment2();
		payments.description = 'Test';
		payments.max = '1';
		payments.min = '2';
		payments.getPaymentTypes();
		payments.getResults();
		payments.export();
		//payments.reset();
	}
	public static testMethod void testPayment2(){
		Account acc = new Account(Name='TestAccount', username__c = 'test', password__c = 'test');
		insert acc;
		Payment__c testpayment1 = new Payment__c( Account__c = acc.Id, Payment_Option__c = 'Eway', Payment_Date__c = Date.today(), Payment_Amount__c = 2.0);
		insert testpayment1;
		
		
		Payments payments = new Payments();
		
		payments.getPayments();
		
		payments.payment1 = testpayment1;
		
		payments.options = new List<String>();
		payments.options.add('Eway');
		payments.getPayment1();
		payments.getPayment2();
		payments.description = 'Test';
		payments.max = '';
		payments.min = '1';
		payments.getPaymentTypes();
		payments.getResults();
		payments.export();
		//payments.reset();
	}
	
	public static testMethod void testPayment3(){
		Account acc = new Account(Name='TestAccount', username__c = 'test', password__c = 'test');
		insert acc;
		Payment__c testpayment2 = new Payment__c( Account__c = acc.Id, Payment_Option__c = 'Eway', Payment_Date__c = Date.today().addDays(-15), Payment_Amount__c = 2.0);
		insert testpayment2;
		
		Payments payments = new Payments();
		payments.getPayments();
		payments.payment2 = testpayment2;
		
		payments.options = new List<String>();
		payments.options.add('Eway');
		payments.getPayment1();
		payments.getPayment2();
		payments.description = 'Test';
		payments.min = '';
		payments.max = '2';
		payments.getPaymentTypes();
		payments.getResults();
		payments.export();
		//payments.reset();
	}
	
	
	public static testMethod void testPayment4(){
		Account acc = new Account(Name='TestAccount', username__c = 'test', password__c = 'test');
		insert acc;
		Payment__c testpayment2 = new Payment__c( Account__c = acc.Id, Payment_Option__c = 'Eway', Payment_Date__c = Date.today().addDays(1), Payment_Amount__c = 2.0);
		insert testpayment2;
		
		Payments payments = new Payments();
		payments.getPayments();
		payments.payment2 = testpayment2;
		payments.options = new List<String>();
		PageReference pageRef = new PageReference('/apex/Payments');
		payments.reset();
		payments.options.add('Eway');
		payments.getPayment1();
		payments.getPayment2();
		payments.min = '1';
		payments.getPaymentTypes();
		payments.getResults();
		
		//payments.reset();
	}
	
	
	
	

	
	
	
	

}