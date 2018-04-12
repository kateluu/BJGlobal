public with sharing class GenerateWeeklyOpportunity {
	public GenerateWeeklyOpportunity() {	
		Account[] accs = [select 
								id,
								website,
								name,
								(select id from Opportunities__r where createdDate = LAST_N_DAYS:180),
								(select Name, Phone, Email from Contacts where Title = 'Marketing' limit 1),
								(select Daily_Budget__c from Sign_Ups__r where Product_Type__c = 'AdWords Management' and Daily_Budget__c >= 10 order by CreatedDate desc limit 1)
							from 
								Account
							where
								HasSEOProject__c = false
							and
								Active_Days__c > 90
							and
								Active__c = true
							and
								Outstanding_Amount__c < 100
							]; 
		List<Account> accounts = new List<Account>();					
		for(Account acc : accs) {
			if(acc.Opportunities__r.isEmpty()) {
				accounts.add(acc);
			}
		}
		
		List<SLXOpportunity__c> opps = new List<SLXOpportunity__c>();
		
		List<User> team = [
		SELECT Id, name, email 
		FROM user 
		WHERE isActive = true AND (UserRole.name = 'Digital Strategy Sales' OR UserRole.name = 'Sales Manager Assistant Digital Strategy' OR UserRole.name = 'Digital Strategy Manager')
		];

		for(User u : team) {
			integer counter = 0;
			while(counter < 10 && !accounts.isEmpty()) {
				SLXOpportunity__c opp = new SLXOpportunity__c();
				integer index = getRandomIndex(accounts.size());
				Account acc = accounts.remove(index);
				opp.Account__c = acc.Id;
				opp.name = acc.name;
				opp.Product_Type__c = 'SEO Management';
				opp.OwnerId = u.Id;
				opp.Send_to_Salesperson__c = u.Name;
				opp.website__c = acc.website == null ? 'Cannot find in Account. Please update manually' : acc.website;
				opp.status__c = 'New';
				opp.importance__c = 'Medium';
				opp.Contact_Name__c = acc.Contacts.isEmpty() ? '' : acc.Contacts.get(0).Name;
				opp.Contact_Email__c = acc.Contacts.isEmpty() ? '' : acc.Contacts.get(0).Email;
				opp.Contact_Phone_Number__c = acc.Contacts.isEmpty() ? '' : acc.Contacts.get(0).Phone;
				opp.Adwords_Daily_budget__c = !acc.Sign_Ups__r.isEmpty() && acc.Sign_Ups__r.get(0).Daily_Budget__c >= 10 ? acc.Sign_Ups__r.get(0).Daily_Budget__c : 20;
				opp.Reason_For_Opportunity__c = 'System generated weekly opportunities';
				opps.add(opp);
				counter++;
			}
		}
		
		insert(opps);
	}
	
	public Integer getRandomIndex(Integer arraySize){
        return (integer) Math.floor(Math.random() * arraySize);
    }
	
}