public class CustomLeadSynchToStdLead {	
	public List<Lead__c> myCustomLeads{get;set;}
	public Map<Id, Lead__c> newleads{get;set;}

	public CustomLeadSynchToStdLead(Map<Id, Lead__c> customLeads){
		newleads = customLeads;
	}

	public boolean synchToStdLeads(){
		Map<String, Lead__C> mapLeads = new Map<String,Lead__c>();
		
		try{		
			//build custom map
			myCustomLeads = [SELECT Id, Email__c, Assigned_To__c,Assigned_To_Id__c, Lead_Status__c FROM Lead__C WHERE Id IN :newleads.keySet()];
			for(Lead__c item : myCustomLeads){				
				mapLeads.put(item.email__c, item);
			}
			
			
			//build standard map
			List<Lead> leads = [SELECT id, Email, Assigned_To__c,status FROM Lead WHERE Email in :mapLeads.keyset()];
			Map<String , Lead> mapStdLead = new Map<String, Lead>();
			for(Lead item:leads){
				mapStdLead.put(item.Email, item);
			}

			//synch value
			for(String leadEmail : mapStdLead.keySet()){

				if( mapLeads.get(leadEmail) != null){
					Lead__c myLead = (Lead__c)mapLeads.get(leadEmail);
					Lead currentLead = (Lead)mapStdLead.get(leadEmail);
					currentLead.Status = myLead.Lead_Status__c;
					currentLead.Assigned_To__c = myLead.Assigned_To_Id__c;
				}
			}
			update mapStdLead.values();

		}catch(Exception ex){
			System.debug(ex.getMessage());
			return false;
		}

		return true;
	}
}