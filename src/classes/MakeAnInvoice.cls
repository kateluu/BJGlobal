//Create an account product and an initial invoice for it

public with sharing class MakeAnInvoice {
    public Account acc {get;set;}
    public SLX_Product__c slxProduct {get; set;}
    public Account_Product__c accProduct {get; set;}
	public Invoice__c inv {get; set;}
	
    public List<SelectOption> items {get; set;}
    public string selectedSlxProduct {get; set;}
    	            
    public Boolean creating  {get;set;}
    public Boolean confirming {get;set;}    
        
    public MakeAnInvoice(ApexPages.StandardController controller) {
        ID accId = ((Account)controller.getRecord()).id;
        acc = [SELECT Id, Unique_Id__c, Name, Name_On_Card__c, Card_Number__c, Card_Month_Expiry__c,
        				Card_Year_Expiry__c, Card_CVN__c, OwnerId, Payment_Option__c, website, Amex__c, BJB_Company__r.Name FROM Account WHERE Id=:accId];
        
    	slxProduct = new SLX_Product__c();
        if (acc.BJB_Company__r.Name == null || acc.BJB_Company__r.Name == 'SponsoredLinX'){
            slxProduct.company_name__c = 'SponsoredLinx';
        } else {
            slxProduct.company_name__c = acc.BJB_Company__r.Name;
        }

    	setProductList();
    	
        creating = false;
        confirming = false;
    }
    
    public void setProductList () {
    	try{
            SLX_Product__c[] productList = [SELECT Id,Name,CurrencyIsoCode,product_price__c,product_description__c, product_recurring__c, recurring_period__c FROM SLX_Product__c WHERE IsActive__c = true AND company_name__c =:slxProduct.company_name__c order by Name asc];
            items = new List<SelectOption>();
	        items.add(new SelectOption('','---None---'));
	        for(SLX_Product__c pro : productList){
	        	String item = pro.Name;
	        	if(pro.product_description__c != null) {
	        		item += ' - ' + pro.product_description__c + ' - $';
	        	} else {
	        		item += ' - $';
	        	} 
	        	item += pro.product_price__c;
	        	if(pro.product_recurring__c == 'Hourly') { item += ' (Hourly)'; }
	            items.add(new SelectOption(pro.id, item));
	        }
	        system.debug(items);
        } catch (Exception e) {
            System.debug('Exception: '+e);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Unable to load products');
            ApexPages.addMessage(myMsg);
        }
    }    
    
    public PageReference createInvoiceDetails() {
    	slxProduct = [SELECT Id, Name, product_price__c, CurrencyIsoCode, Recurring_Period__c, company_name__c, product_description__c, product_recurring__c FROM SLX_Product__c WHERE id = :selectedSlxProduct LIMIT 1];
        
        accProduct = new Account_Product__c();
    	accProduct.account__c = acc.id;
    	accProduct.Send_Invoice__c = true;
        accProduct.Start_Date__c = date.today();
    	accProduct.Name_On_Card__c = acc.Name_On_Card__c;		
		accProduct.Card_Number__c = acc.Card_Number__c;
		accProduct.Card_Month_Expiry__c = acc.Card_Month_Expiry__c;				
		accProduct.Card_Year_Expiry__c = acc.Card_Year_Expiry__c;
		accProduct.Card_CVN__c = acc.Card_CVN__c;
		
		User checkUser = [SELECT Id, IsActive FROM User where Id =:acc.OwnerId][0];
        if(checkUser.IsActive == true) accProduct.OwnerId = acc.OwnerId;
        else accProduct.OwnerId = UserInfo.getUserId();
        
        accProduct.name = slxProduct.name;
        accProduct.SLX_Product__c = slxProduct.Id;
        accProduct.Product_Price__c = slxProduct.product_price__c;
        accProduct.Description__c = slxProduct.product_description__c;
        accProduct.Recurring_Period__c = slxProduct.recurring_period__c;
        accProduct.CurrencyIsoCode     = slxProduct.CurrencyIsoCode;
        if (slxProduct.product_recurring__c == 'Hourly') {
        	accProduct.Hours__c = 1;
        	accProduct.Hourly_Rate__c = slxProduct.product_price__c;
        }
        
        inv = new Invoice__c();
        inv.Name = acc.Name;
        inv.Account__c = acc.Id;
        inv.Invoice_Number__c = '0';
        inv.Issue_Date__c = Date.today();
        inv.Amount_Paid__c = 0;
        inv.Amount_Credited__c = 0;
		inv.Reference__c = acc.Unique_Id__c;
    	inv.Status__c = 'AUTHORISED';
    	
	    updateDueDate();
	    
	    creating = true;
        confirming = false;
	    
        return null;
    }
    
    public PageReference save() {	
    	try {
    		//the below statements' sequence is important. Change cautiously.
    		insert accProduct;
    		
    		inv.Invoice_Total__c = accProduct.Product_Price__c;
    		//check NewZealand Client
    		//if (acc.website != null && acc.website.endsWithIgnoreCase('.nz') == true) {
    		//	inv.Invoice_Total__c = accProduct.Product_Price__c / 1.1; //deduct GST
    		//	inv.Invoice_Total__c = inv.Invoice_Total__c.setScale(2); //keep only 2 decimal digit
    		//}
    		//check Amex user
    		if(acc.Amex__c == true){
                Date myDate = Date.newInstance(2018, 8, 1);
                if (inv.Issue_Date__c >= myDate){
                    // Amex charge change from 1st August 2018
                    inv.Invoice_Total__c      	= inv.Invoice_Total__c*(1+ Decimal.valueof(Pardot_Auto_Convert_Add__c.getValues('Amex Surcharge').value__c)); 
                }
                else{
                    inv.Invoice_Total__c          = inv.Invoice_Total__c*(1+ Decimal.valueof(Pardot_Auto_Convert_Add__c.getValues('Old Amex Surcharge').value__c)); 
                }
                  
  				inv.Invoice_Total__c		= inv.Invoice_Total__c.setScale(2);
  				inv.Amex__c					= true;
                
  			}
	        inv.Amount_Due__c = inv.Invoice_Total__c;
	        inv.Payment_Option__c = accProduct.Payment_Option__c;
	        inv.Account_Product__c = accProduct.Id;
	        inv.CurrencyIsoCode = accProduct.CurrencyIsoCode;
	        insert inv;
	        
	        inv = [SELECT Id, Salesforce_Invoice_Number__c, Issue_Date__c FROM Invoice__c WHERE Id=:inv.Id];
	        
	        accProduct.Last_Invoice_Date__c = inv.Issue_Date__c;
	        accProduct.Last_Invoice_Number__c = inv.Salesforce_Invoice_Number__c;
	        update accProduct;
	        
	        inv.Invoice_Number__c = inv.Salesforce_Invoice_Number__c;
	        update inv;
	        
	        return returnToAccount();
    	} catch (Exception e) {
            System.debug('Exception: '+e);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }     
    }
    
    public PageReference Next() {
    	if(accProduct.Payment_Option__c != null){
	        creating = false;
	        confirming = true;
    	}
    	else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a payment option.');
            ApexPages.addMessage(myMsg);
    	}
        return null;
    }
    
    public PageReference changePaymentMethod() {
    	updateDueDate();
    	return null;
    }
        
    public void updateDueDate(){
    	if(inv.Issue_Date__c < Date.today()){
    		inv.Issue_Date__c = Date.today();
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to backdate invoice.');
            ApexPages.addMessage(myMsg);
    	}
    	
    	//Update due date based on issue date and payment method
    	Date dueDate = inv.Issue_Date__c;
    	if(accProduct.Payment_Option__c == 'Cheque'){
    		dueDate = dueDate.addDays(7);	
    	}
    	
    	if(accProduct.Payment_Option__c ==  'Direct Deposit'){
    		dueDate = dueDate.addDays(3);
    	}
    	
    	if(accProduct.Payment_Option__c == 'Bill Buddy'){
    		dueDate = dueDate.addDays(3);
    	}
    	
    	if(accProduct.Payment_Option__c == 'Other'){
    		dueDate = dueDate.addDays(3);
    	}
    	inv.Due_Date__c = dueDate;	
    }
        
    public PageReference returnToAccount() {
    	PageReference AccountPage = new ApexPages.StandardController(this.acc).view();
        AccountPage.setRedirect(true);
        return AccountPage;
    }
        
    public void updateSetPrice() {
    	try{
	    	accProduct.Hours__c = accProduct.Product_Price__c / accProduct.Hourly_Rate__c;
    	}
    	catch(Exception e){
    		System.debug('Exception: '+e);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please check the price your enter.\n' + e.getMessage());
            ApexPages.addMessage(myMsg);
    	}
    }
    
    public void updateHours() {
    	try{
	    	accProduct.Product_Price__c = (accProduct.Hours__c * double.valueOf(accProduct.Hourly_Rate__c)).intValue();
    	}
    	catch(Exception e){
    		System.debug('Exception: '+e);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please check the hours your enter.\n' + e.getMessage());
            ApexPages.addMessage(myMsg);
    	}
    }
    
    public void ApplyPromo() {          
        if(inv.Promocode__c != null && accProduct.product_price__c == slxProduct.product_price__c){
            Promotions__c promotion = [SELECT IsActive__c,Setup_Discount_Type__c,Setup_Discount__c,Management_Discount_Type__c,Management_Discount__c FROM Promotions__c WHERE Id IN (SELECT Promotions__c FROM Promocode__c WHERE Id=:inv.Promocode__c)];
            if (promotion.IsActive__c) {
                if (slxProduct.product_recurring__c == 'Yes') {
                    if (promotion.Management_Discount_Type__c == '%') {
                        accProduct.Product_Price__c = accProduct.Product_Price__c - (accProduct.Product_Price__c*(promotion.Management_Discount__c / 100));
                    } else {
                        accProduct.Product_Price__c = accProduct.Product_Price__c - promotion.Management_Discount__c;
                    }   
                } else {
                    if (promotion.Setup_Discount_Type__c == '%') {
                        accProduct.Product_Price__c = accProduct.Product_Price__c - (accProduct.Product_Price__c*(promotion.Setup_Discount__c / 100));
                    } else {
                        accProduct.Product_Price__c = accProduct.Product_Price__c - promotion.Setup_Discount__c;
                    }
                }               
            }   
        }
    }
     
     public static testMethod void coverageTest() {
    	Test.startTest();
    	
    	Account testAcc = new Account();
    	testAcc.Name = 'Test';
    	testAcc.Payment_Option__c = 'Eway';
    	testAcc.Name_On_Card__c = 'test';
    	testAcc.Card_Number__c = '1234123412341234';
    	testAcc.Card_Month_Expiry__c = '5';
    	testAcc.Card_Year_Expiry__c = '1010';
    	testAcc.Card_CVN__c = '123';
    	testAcc.Website = 'www.test.com.nz';
    	insert testAcc;
    	    	
    	Promotions__c promo = new Promotions__c();
    	promo.IsActive__c = true;
    	promo.Promotion_Description__c='test';
    	promo.Management_Discount_Type__c = '$';
    	promo.Management_Discount__c = 10;
    	promo.Setup_Discount_Type__c = '%';
    	promo.Setup_Discount__c = 10;
    	insert promo;
    	
    	Promocode__c promocode = new Promocode__c();
    	promocode.name = 'pcode';
    	promocode.Promotions__c = promo.id;
    	promocode.isactive__c = true;
    	promocode.Promocode_Description__c = 'fjfjfj';
    	insert promocode;
    	
    	SLX_Product__c product = new SLX_Product__c();
    	product.Name = 'Adwords Standard Management';
    	product.product_price__c = 110;
    	product.company_name__c = 'SponsoredLinx';
    	product.recurring_period__c='Weekly';
    	product.product_recurring__c = 'Yes';
    	insert product;
    	
    	SLX_Product__c product1 = new SLX_Product__c();
    	product1.Name = 'Hourly WebSite';
    	product1.product_price__c = 20;
    	product1.company_name__c = 'SponsoredLinx';
    	product1.recurring_period__c='N/A';
    	product1.product_recurring__c = 'Hourly';
    	insert product1;		
    	
    	ApexPages.standardController controller = new ApexPages.standardController(testAcc);
    	MakeAnInvoice testClass = new MakeAnInvoice(controller);
		testClass.setProductList();
    	
    	testClass.selectedSlxProduct = product.id;
    	testClass.createInvoiceDetails();
    	testClass.accProduct.Payment_Option__c = 'Eway';
    	testClass.changePaymentMethod();
    	testClass.inv.Promocode__c = promocode.id;
    	testClass.ApplyPromo();
    	testClass.Next();
    	testClass.Save();
    	
    	testClass.selectedSlxProduct = product1.id;
    	testClass.createInvoiceDetails();
    	testClass.accProduct.Payment_Option__c = 'Eway';
    	testClass.changePaymentMethod();
    	testClass.accProduct.Hours__c = 10;
    	testClass.updateSetPrice();
    	testClass.accProduct.Product_Price__c = 1100;
    	testClass.updateHours();
    	testClass.Next();
    	testClass.Save();
    	
    	testClass.returnToAccount();
		Test.stopTest();
    }
}