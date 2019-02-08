public class TriggerUtilities {
    /*
 	public static Integer getNumberOfResolutionManager(){
         System.debug('TriggerUtilities::getNumberOfResolutionManager');
         List<User> managers = [SELECT id, username, profile.name, isActive 
                               FROM User 
                               WHERE isActive=true 
                               		 AND profile.name = 'Resolution Manager' ORDER BY username DESC];
         return managers.size();
    }

    public static User getAvailableResultionManager(Integer escalatedNo){
		System.debug('TriggerUtilities::getAvailableResultionManager');
        List<User> managers = [SELECT id, username, profile.name, isActive 
                               FROM User 
                               WHERE isActive=true 
                               		 AND profile.name = 'Resolution Manager' ORDER BY username DESC];
        if(managers.size() < escalatedNo){
            return managers.get(managers.size()-1);
        }else{
            return managers.get(escalatedNo-1);
        }
    }
    
	public static User getAvailableResultionManagerByNo(Integer escalatedNo){
		System.debug('TriggerUtilities::getAvailableResultionManagerByNo');
        List<User> managers = [SELECT id, username, profile.name, isActive 
                               FROM User 
                               WHERE isActive=true 
                               		 AND profile.name = 'Resolution Manager' ORDER BY username DESC];
        if(managers.size() < escalatedNo){
            return managers.get(managers.size()-1);
        }else{
            return managers.get(escalatedNo-1);
        }
    }
	*/
    public static User getAvailableResolutionManagerByCap(){
        try {
            System.debug('TriggerUtilities::getAvailableResultionManagerByCap');

            // exlcude a certain RM out of the auto assignment loop 
            // added on 8 NOv, 2018
            List<String> exclusiveRM = new List<String>();
            if (Default_Manager__c.getInstance('Exclusive Resolution Manager')!= null  &&  Default_Manager__c.getInstance('Exclusive Resolution Manager').value__c!= null){
                exclusiveRM =Default_Manager__c.getInstance('Exclusive Resolution Manager').value__c.split(',');
            }
            List<User> managers  = [
                    SELECT id, username, profile.name, isActive
                    FROM User
                    WHERE isActive = true
                    AND profile.name = 'Resolution Manager'
                    AND id NOT IN :exclusiveRM
                    ORDER BY username
            ];


            AggregateResult[] caseNums = [
                    SELECT Resolution_Manager__c, count(Id) sum
                    FROM Cases__c
                    WHERE Status__c = 'Escalated'
                    AND (Product_Type__c = 'Social Marketing' OR Product_Type__c = 'AdWords Management' OR Product_Type__c = 'Social')
                    AND CaseType__c = 'Cancellation'
                    AND Resolution_Manager__c IN :managers
                    GROUP BY Resolution_Manager__c
                    ORDER BY count(Id) ASC
            ];
            String userId = '' + caseNums[0].get('Resolution_Manager__c');
            User mag = [
                    SELECT id, username, isActive
                    FROM User
                    WHERE isActive = true
                    AND Id = :userId
            ];
            return mag;
        } catch (Exception ex ){
            // init time
            return [SELECT id, username,isActive FROM User WHERE isActive = true AND Profile.Name= 'Resolution Manager' LIMIT 1];
        }

    }
        
   
}