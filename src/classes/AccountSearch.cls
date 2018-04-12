public with sharing class AccountSearch {
  // the soql without the order and limit
  private String soql {get;set;}
  // the collection of contacts to display
  public List<Contact> contacts {get;set;}
 public String ContactTitle {get;set;}
 public boolean GenerateErrors = false;
 
 
 
 
 	public List<String> getContactTitles() {
    	//List<SelectOption> options = new List<SelectOption>();
        List<String> contactTitles = new List<String>();
        
        //options.add(new SelectOption('Billing','Billing'));	
        //options.add(new SelectOption('Reporting','Reporting'));
        //options.add(new SelectOption('Marketing','Marketing'));
        contactTitles.add('Billing');
        contactTitles.add('Reporting');
        contactTitles.add('Marketing');
        
    	return contactTitles;
	}
 
 
 
  // the current sort direction. defaults to asc
  public String sortDir {
    get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
    set;
  }
 
  // the current field to sort by. defaults to last name
  public String sortField {
    get  { if (sortField == null) {sortField = 'lastName'; } return sortField;  }
    set;
  }
 
  // format the soql for display on the visualforce page
  public String debugSoql {
    get { return soql + ' order by ' + sortField + ' ' + sortDir + ' limit 5'; }
    set;
  }
 
  // init the controller and display some sample data when the page loads
  public AccountSearch() {
    
  }
  public void Begin() {
  	soql = 'select firstname, lastname, account.name, phone, title, account.OwnerId, account.id, Sign_Up__c from contact where account.name != null';
    runQuery();
  	
  }
 
  // toggles the sorting of query from asc<-->desc
  public void toggleSort() {
    // simply toggle the direction
    sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
    // run the query again
    runQuery();
  }
 
  // runs the actual query
  public void runQuery() {
 
    try {
      contacts = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' limit 5');
      for(Contact thisContact : contacts){
      	Sign_Up__c SignUp = new Sign_Up__c();
      	try{
	      	SignUp = [SELECT Id from Sign_Up__c WHERE Account__c =:thisContact.account.Id][0];
	      	if(thisContact.Sign_Up__c != SignUp.Id){
	      		thisContact.Sign_Up__c = SignUp.Id;
	      		update thisContact;
	      	}
      	}
      	catch(Exception e){
      		
      	}
      	
      }
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
    }
 
  }
 
  // runs the search with parameters passed via Javascript
  public PageReference runSearch() {
 
    String firstName = Apexpages.currentPage().getParameters().get('firstname');
    String lastName = Apexpages.currentPage().getParameters().get('lastname');
    String accountName = Apexpages.currentPage().getParameters().get('accountName');
    
    //Sign_Up__c thisSignUp = new Sign_Up__c();
    //thisSignUp = [Select Id From Sign_Up__c where ];
    
    String contactTitle = Apexpages.currentPage().getParameters().get('ContactTitle');
    System.debug('contactTitle' + contactTitle);
    //String technology = Apexpages.currentPage().getParameters().get('technology');
  
 	if(GenerateErrors == true){
 		firstname = 'test';
 		lastname = 'test';
 		accountName = 'test';
 		contactTitle = 'Billing';
 	}
 	
    soql = 'select firstname, lastname, account.name, phone, title, account.OwnerId, account.Id, Sign_Up__c from contact where account.name != null';
    if (!firstName.equals(''))
      soql += ' and firstname LIKE \'%'+String.escapeSingleQuotes(firstName)+'%\'';
    if (!lastName.equals(''))
      soql += ' and lastname LIKE \'%'+String.escapeSingleQuotes(lastName)+'%\'';
    if (!accountName.equals(''))
      soql += ' and account.name LIKE \'%'+String.escapeSingleQuotes(accountName)+'%\'';
    if (!contactTitle.equals(''))
      soql += ' and title LIKE \'%'+String.escapeSingleQuotes(contactTitle)+'%\'';  
    //if (!technology.equals(''))
     // soql += ' and interested_technologies__c includes (\''+technology+'\')';
 
    // run the query again
    runQuery();
 
    return null;
  }
 
  // use apex describe to build the picklist values
  public List<String> technologies {
    get {
      if (technologies == null) {
 
        technologies = new List<String>();
    //    Schema.DescribeFieldResult field = Contact.interested_technologies__c.getDescribe();
 
    //    for (Schema.PicklistEntry f : field.getPicklistValues())
    //      technologies.add(f.getLabel());
 
      }
      return technologies;          
    }
    set;
  }
  
       public static testMethod void testMethod1() {
    	Test.startTest();
    	Account testAcc = new Account();
    	//Account testAc = [SELECT Unique_Id__c,Name_On_Card__c,Card_Number__c,Card_Month_Expiry__c,Card_Year_Expiry__c FROM Account WHERE Name='TestAccount'][0];
    	testAcc.Name = 'Test';
    	testAcc.Payment_Option__c = 'Eway';
    	testAcc.Name_On_Card__c = 'test';
    	testAcc.Card_Number__c = '1234123412341234';
    	testAcc.Card_Month_Expiry__c = '5';
    	testAcc.Card_Year_Expiry__c = '1010';
    	testAcc.Card_CVN__c = '123';
    	insert testAcc;
    	
    	Contact testContact = new Contact();
    	testContact.AccountId = testAcc.Id;
    	testContact.Title = 'Billing';
    	testContact.FirstName = 'test';
    	testContact.LastName = 'test';
    	
    	insert testContact; 
    	
    	Promotions__c promo = new Promotions__c();
    	promo.IsActive__c = true;
    	promo.Promotion_Description__c='test';
    	insert promo;
    	
    	
    	SLX_Product__c product = new SLX_Product__c();
    	product.Name = 'Adwords Standard Management';
    	product.product_price__c = 79;
    	product.recurring_period__c='N/A';
    	insert product;
    	
    	SLX_Product__c product1 = new SLX_Product__c();
    	product1.Name = 'Adwords Standard Management';
    	product1.product_price__c = 79;
    	product1.recurring_period__c='Weekly';
    	insert product1;	
    	
    	    	Account_Product__c testAccPr = new Account_Product__c();
    

    	List<SLX_Product__c> slx = [select Id from SLX_Product__c where product_price__c = 79 and recurring_period__c = 'Weekly'];	
    	
    	ApexPages.standardController controller = new ApexPages.standardController(testAcc);
    	AccountSearch testClass = new AccountSearch();
    	testClass.GenerateErrors = true;
    	testClass.getContactTitles();
    	//testClass.AccountSearch();
    	testClass.toggleSort();
    	testClass.runQuery();
    	testClass.runSearch();

    
		test.stopTest()    ;
    }
  
  
  
 
}