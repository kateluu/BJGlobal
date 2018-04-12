public class BJBOpportunityHelper {

	list<SLXOpportunity__c> objects{get;set;}
	SLXOpportunity__c myOpp{get;set;}
	
	//constructor
	public void BJBOpportunityHelper(){

	}

	public String getValidAdwordID( SLXOpportunity__c opp){		
		
		//get required fields from opp
		//this.myOpp = [SELECT id,Account__c,Adwords_Keyword__c FROM SLXOpportunity__c WHERE id = :opp.Id];

		// get all active product with type is Adword Management and recursive is not null
		List<Account_Product__c> products = [ 	SELECT Id, Adwords_ID__c, Product_Status__c, Recurring_Period__c, Product_Type__c
												FROM Account_Product__c
												WHERE Product_Type__c = 'AdWords Management'  
														AND Product_Status__c = 'Active' 
														AND Account__c= :opp.Account__c];
		if((products!= null) && (products.size()>0)){
			for(Account_Product__c item:products){
				if ((item.Recurring_Period__c != null) && (item.Recurring_Period__c != 'N/A')  && (item.Adwords_ID__c != null)){
					return item.Adwords_ID__c;
				}
			}
		}

		return 'N/A';
	}

}