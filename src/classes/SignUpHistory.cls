public with sharing class SignUpHistory {
	public List<history> histories {get; set;}	
	
	public SignUpHistory () {
		List<sign_up__c> sus = [select 
									name, 
									id, 
									Account__c, 
									Account__r.name, 
									Assigned_To__c, 
									(Select 
										OldValue, 
										NewValue, 
										Field, 
										CreatedDate, 
										CreatedBy.name 
									From 
										Histories
									Where
										Field = 'Salesperson__c' 
									or 
										Field = 'Promocode__c')
								from 
									Sign_up__c 
								where 
									createdDate = last_week
								and
									id in (
										select 
											ParentId
										from
											Sign_Up__History 
										where 
											ParentId != null)
								];
		
		histories = new List<history>();
		Pattern p = Pattern.compile('[a-zA-Z0-9]{15,18}'); //check if newValue and oldValue is ID
										
		for (sign_up__c su : sus) {
			List<Sign_Up__History> suhs = (List<Sign_Up__History>) su.histories;
			
		    for (Sign_Up__History suh : suhs) {
		    	if(suh.NewValue == null) {
		    		continue;
		    	}
		    	Matcher m = p.matcher(String.valueof(suh.NewValue));
		    	if (!m.matches()) {
			    	history h = new history();
			    	h.name = su.name;
			    	h.id = su.id;
			    	h.accountName = su.Account__r.name;
			    	h.account = su.account__c;
			    	h.assignedTo = su.Assigned_To__c;
			    	h.timestamp = suh.CreatedDate.format();
			    	h.owner = suh.CreatedBy.name;
			    	
			        if (suh.Field == 'Salesperson__c') {
			        	h.oldSalesperson = String.valueof(suh.OldValue);
			        	h.newSalesperson = String.valueof(suh.NewValue);
			        } else if (suh.Field == 'Promocode__c') {
			        	h.oldPromocode = String.valueof(suh.OldValue);
			        	h.newPromocode = String.valueof(suh.NewValue);
			        }
			        histories.add(h);
		    	}
		    }
		}
	}
	
	public class history {
		public String name {get; set;}
		public id id {get; set;}
		public String accountName {get; set;}
		public id account {get; set;}
		public String assignedTo {get; set;}
		public String oldPromocode {get; set;}
		public String newPromocode {get; set;}
		public String oldSalesperson {get; set;}
		public String newSalesperson {get; set;}
		public String timestamp {get; set;}
		public String owner {get; set;}
	}
	
	@isTest(SeeAllData=true)
	static void test1 () {
		Test.startTest();
		SignUpHistory suh = new SignUpHistory();
		Test.stopTest();
	}
	
}