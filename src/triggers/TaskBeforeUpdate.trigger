/**
*Version:             1.0
*Company:             BJB GLOBAL
*Author:              Will Z
*Date:                26/10/2016
*Description:         Lock Admin & Accounts teams tasks, even for users who have 'Edit Tasks' and 'Modify All' permission on related object.
*History:             
**/

trigger TaskBeforeUpdate on Task (before update) {
	// get current users profile name
	//String profileid = UserInfo.getProfileId();
	//String currUserProfile = [select Name from Profile where id =:profileid limit 1].Name;
	
	//for(Task task : Trigger.new){
		// get task owner's profile
	//	User taskOwner = [select ProfileId from User where id =: task.OwnerId];
	//	String taskOwnerProfile = [select Name from Profile where Id =: taskOwner.ProfileId limit 1].Name;
		
	//	if(taskOwnerProfile == 'Accounts & Admin' && currUserProfile != taskOwnerProfile && currUserProfile!= 'System Administrator'){
	//		task.addError('You don\'t have permission to edit Accounts & Admins tasks');
	//	}
	//s}

}