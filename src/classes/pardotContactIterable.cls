global class pardotContactIterable implements Iterator<Account>{
	List<Account> accounts = new List<Account>();
	Integer i {get;set;}
	
	public pardotContactIterable(){
		this.i = 0;
		try{
		
			this.accounts = [select Id, Name, Owner.Name, Payment_Option__c, Website, infusionsoft_Id__c, Active__c, Psycho__c FROM Account where Type != 'Employee'];
			
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