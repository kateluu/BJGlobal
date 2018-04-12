public class AccountHelper {

  @InvocableMethod(label='getBillingContact' description='get billing contact on related Account if it is available in the account')
  public static List<Contact> getBillingContact(List<Id> casesIds) {
  	try{
  		List<Cases__c> cases = [SELECT id, account__c, contact__c FROM Cases__c WHERE Id in :casesIds];
		List<Id> accounts = new List<Id>();
		Map<Id, Cases__c> newValues = new Map<Id, Cases__c>();
		if (cases.size() > 0){

			for(Cases__c item : cases){
				accounts.add( item.account__c);
				newValues.put(item.account__c, item);
			}
		    //List<Contact> billingContact = [SELECT id, Title, AccountId FROM Contact WHERE Title = 'Billing' AND AccountId = :cases[0].Account__c ];
		    List<Contact> billingContact = [SELECT id, Title, AccountId FROM Contact WHERE Title = 'Billing' AND AccountId in :accounts];
		    if (billingContact.size()>0){
				for(Contact con : billingContact){
                    Cases__c myCase =(Cases__c)newValues.get(con.AccountId);
                    myCase.Contact__c= con.id;
				}
				if(newValues.values().size()>0){
					update newValues.values();
				}
		    }
 		}	
  	}catch (Exception e){
		system.debug('AccountHelper : retry, exception : ' + e.getMessage());
		system.debug('Exception type caught: ' + e.getTypeName());
		system.debug('Message: ' + e.getMessage());
		system.debug('Cause: ' + e.getCause());    // returns null
		system.debug('Line number: ' + e.getLineNumber());
		system.debug('Stack trace: ' + e.getStackTraceString());
  	}    
    return  null;
  }
 
}