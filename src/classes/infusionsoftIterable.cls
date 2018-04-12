global class infusionsoftIterable implements Iterator<Account> {
	
	List<Account> accounts = new List<Account>();
	Integer i {get;set;}
	
	public infusionsoftIterable(){
		Date today = System.today();
		Date startOfWeek = today.toStartOfWeek();
		Integer dayOfWeek = today.day()-startOfWeek.day();
		
		this.i = 0;
		
		try{
			if(dayOfWeek == 6 ){
				this.accounts = [select Id, Name, Owner.Name, Payment_Option__c, Website, infusionsoft_Id__c, Active__c, Psycho__c FROM Account where Type != 'Employee'];
			}else{
				this.accounts = [select Id, Name, Website, Payment_Option__c, infusionsoft_Id__c, Active__c, Psycho__c FROM Account where Type != 'Employee'];
			}
			}catch(Exception e){
				System.debug(e.getMessage());
			}
	}
	
	global boolean hasNext() {
	    if(this.i >= this.accounts.size()) 
	        return false; 
	    else 
	        return true;  
    }
    
	global Account next() {
		return this.accounts[this.i++];  
	}
	
	public static testMethod void testinfusionsoftIterable() {
        Test.startTest();
        Account account = new Account();
		account.Name = 'Test Account';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test@test.com';
		account.password__c = 'test';
		insert account;
        
        infusionsoftIterable infusionsoftIterable = new infusionsoftIterable();
        if(infusionsoftIterable.hasNext()){
        	Account account1 = infusionsoftIterable.next();
        }
        Test.stopTest();
    }
}