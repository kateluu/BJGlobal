global class pardotAccountIterable implements Iterator<Account>{
	List<Account> accounts = new List<Account>();
	Integer i {get;set;}
	
	public pardotAccountIterable(){
		this.i = 0;
		try{
		
			this.accounts = [select Id,
									Name, 
									Owner.Name,
									Payment_Option__c, 
									Website,
									Cancelled_Date__c, 
									Active__c,
									Psycho__c,
									Adwords_Product__c,
									Adwords_Active_Days__c,
									SEO_Product__c,
									SEO_Active_Days__c,
									Facebook_Product__c,
									Facebook_Active_Days__c,
									Converto_Product__c,
									Converto_Active_Days__c,
									Package_Name__c
								FROM Account 
								where Type != 'Employee'
								];
			
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
}