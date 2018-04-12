global class TwilioIVR {
	
	public String callerName {get;set;}
	public User rep {get;set;}
	
	public TwilioIVR(){
		try{
			// Look up contact from incoming caller id
			String fromNumber = System.currentPageReference().getParameters().get('From');
			List<Contact> callers = (fromNumber == null) 
			    ? null 
			    : [SELECT Name, OwnerId 
			       FROM Contact 
			       WHERE Phone = :fromNumber OR MobilePhone = :fromNumber];
			Contact caller = (callers != null && callers.size() == 1) 
			    ? callers[0]
			    : null;
			callerName = caller.Name;
		    
		    // Look up rep from contact
			List<User> reps = (caller == null) 
			    ? null 
			    : [SELECT Name, Phone 
			      FROM User 
			       WHERE Id = :caller.OwnerId];
			           
			// If we don't have a unique rep, connect with switchboard
		    rep = (reps != null && reps.size() == 1) 
			    ? reps[0] 
			    : [SELECT Name, Phone 
			       FROM User 
			       WHERE LastName = 'Switchboard'];
		    }catch (Exception e){
				System.debug(e);
		}
	}

}