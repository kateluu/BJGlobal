public class createProductList {
	public String product{get; set;}
	public SLX_Product__c prodobject = new SLX_Product__c();
	public Account account;
	public Sign_Up__c signup;
	public Boolean buttonIsDisabled;

	public void init() {
		this.buttonIsDisabled = true;
		Account[] accounts = [select Id, name from Account where id =:ApexPages.currentPage().getParameters().get('accid')];
		if(accounts.size() > 0) {
			this.account = accounts[0];
		}
		Sign_Up__c[] signups = [select Id FROM Sign_Up__c where Account__c =:ApexPages.currentPage().getParameters().get('accid')];
		if(signups.size() > 0) {
			this.signup	= signups[0];
		}
	}

	public List<SelectOption> getproductnames()	{
		List<SelectOption> options = new List<SelectOption>();
		List<SLX_Product__c> productlist = new List<SLX_Product__c>();
		productlist = [Select Id, Name FROM SLX_Product__c ];
		options.add(new SelectOption('--None--','--None--'));
		for (Integer j=0;j<productlist.size();j++) {
		    options.add(new SelectOption(productlist[j].Id,productlist[j].Name));
		}
		return options;
	}
	
	public void populate() {
		this.buttonIsDisabled = true;
		if (this.product != '--None--') {
			this.buttonIsDisabled = false;
			SLX_Product__c[] prodObj = [SELECT Id,Name,IsActive__c,Company_Name__c,ProductCode__c,product_description__c,Product_Family__c,product_max_usage__c,Product_Package__c,product_price__c,product_recurring__c,recurring_period__c FROM SLX_Product__c WHERE Id =:this.product];
			if(prodObj.size() > 0) {
				setprodobject(prodObj[0]);
			}
		}	
	}
	
	public Boolean getbuttonIsDisabled() {
		return this.buttonIsDisabled;
	}
	
	public Account getAccount() {
        return this.account;
    }
	
	public SLX_Product__c getprodobject() {
		return this.prodobject;	
	}	
	
	public void setprodobject(SLX_Product__c pObj) {
		this.prodobject = pObj;
	}
	
	public void addproduct() {
		this.buttonIsDisabled = true;
		try {
			Account_Product__c accprod = new Account_Product__c();
			accprod.Name 				= this.prodobject.Name;
			accprod.Account__c 			= this.account.Id;
			accprod.Sign_Up_del__c 		= this.signup.Id;
			accprod.SLX_Product__c 		= this.prodobject.Id;
			accprod.Product_Price__c 	= this.prodobject.product_price__c;	
			insert accprod;
		}
		catch (NullPointerException e) {}
		catch (Exception e) {}		
	}

    public static testMethod void createAnotherProductListTest() {
		createProductList testList = new createProductList();
		List<SelectOption> options = new List<SelectOption>();

		testList.init();
		options = testList.getproductnames();
		testList.product = 'a1B90000000PD4o';
		testList.getbuttonIsDisabled();
		testList.getAccount(); 
		testList.getprodobject();

		testList.populate(); 
		testList.addproduct();
    }
}