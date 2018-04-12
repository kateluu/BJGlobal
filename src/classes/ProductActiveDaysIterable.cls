global class  ProductActiveDaysIterable implements Iterator<Account>{
	Integer i {get;set;}
	List<Account> accounts {get;set;}
	
	public ProductActiveDaysIterable() {
		
		this.accounts = [Select 
							   Id,
							   Name,
							   Active_Days__c,
							   Phone,
							   (select Phone from Contacts where title = 'Marketing' limit 1)
						From 
							   Account
						WHERE
							   Active__c = true
						];
      								
		this.i = 0;
		
		
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