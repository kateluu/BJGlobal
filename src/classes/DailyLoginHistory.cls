public class DailyLoginHistory {
	

	public DailyLoginHistory(){
		Map<Id,LoginHistory> systemHistories = new Map<id,LoginHistory>([SELECT USerId, application FROM LoginHistory WHERE LoginTime = today ORDER BY LoginTime asc]);
		Set<Id> loginUserIds = new Set<Id>();

		for( LoginHistory item:systemHistories.values()){
			if(item.application.equalsIgnoreCase('Browser')){
				loginUserIds.add(item.UserId);
			}
		}

		List<USer> activeUsers = [SELECT id , Username , firstname, lastname, email ,LastLoginDate ,Alias, Profile.Name  FROM User WHERE isActive = true];
		Map<Id,User> nonLoginUsers = new Map<Id, User>();
		for(User item: activeUsers){
			if(!loginUserIds.contains(item.Id)){
				nonLoginUsers.put(item.Id, item);
			}
		}

		// copy all nonloginuser to snapshot object
		List<ss_NonLogin__c> listOfNonLogin = new List<ss_NonLogin__c>();
		for(User item:nonLoginUsers.values()){
			ss_NonLogin__c indivudual = new ss_NonLogin__c();
			indivudual.Alias__c = item.Alias;
			indivudual.Firstname__c = item.firstname;
			indivudual.Lastname__c = item.lastname;
			indivudual.Username__c = item.Username ;
			indivudual.LastLogin__c = item.lastlogindate;
			indivudual.Profile__c = item.Profile.Name;
			indivudual.Application__c = ''+ systemHistories.get(item.Id);
			indivudual.Name = item.Username;
			indivudual.isActive__c = true;
			listOfNonLogin.add(indivudual);
		}

		try{
			if( listOfNonLogin.size()>0){
				insert listOfNonLogin;
			}

		}catch (Exception ex){
			System.debug('DailyLoginHistory : Error when insert non login user :' + ex.getMessage());
		}

	}
	
}