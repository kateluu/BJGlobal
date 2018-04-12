global class NewVoiceMediaCallHelper {
	
	global void getResponseTimeForVoiceMail(){
		system.debug('NewVoiceMediaCallHelper:getResponseTimeForVoiceMail');
		try{
			// get all current miss calles
	   		List<VoiceMail__c> scope = [SELECT id,  Status__c, Client_Manager__c, Response_Time__c FROM VoiceMail__c WHERE Status__c= 'New'];
	   		Map<Id, VoiceMail__c > missCalles = new Map<Id, VoiceMail__c>();   		
	   		for(VoiceMail__c s : scope){
	   			missCalles.put(s.id, s);
			}     
	   		
	   		// get all related calles 
	   		// with call type = outbound and duration is greater than 30
	   		system.debug('NewVoiceMediaCallHelper:scope size = '+ scope.size());
	   		Set<Id> listIDs = missCalles.keyset();
	   		if(scope.size()>0){
				List<Task> calles = [SELECT id, CallType, CallObject, CallDurationInSeconds , NVMContactWorld__CW_Call_Start_Time__c, NVMContactWorld__CW_Call_End_Time__c , WhatId, NVMContactWorld__Was_Call_Recorded__c
									 FROM Task
									 WHERE  Status = 'Completed'   										
											AND CallType = 'Outbound'
											AND WhatId IN :listIDs];
				if (calles.size() > 0) {
					system.debug('NewVoiceMediaCallHelper:getResponseTimeForVoiceMail: query result = ' + calles.size());
					// checking and process
					Map<Id, VoiceMail__c > updateCalles = new Map<Id, VoiceMail__c>();  
					for (Task item : calles) {
						if (item.CallDurationInSeconds >= 30) {
							VoiceMail__c voicemail = (VoiceMail__c)missCalles.get(item.WhatId);
							voicemail.Response_Time__c = item.NVMContactWorld__CW_Call_Start_Time__c ;
							voicemail.Status__c = 'Closed';
							updateCalles.put(voicemail.id,voicemail);
							SYstem.debug('getResponseTimeForVoiceMail :: ' + voicemail.id + 'updated');
						}
					}
					update updateCalles.values();
				} else {
					system.debug('NewVoiceMediaCallHelper: getResponseTimeForVoiceMail: there is not query result' );
				}
			}
		}catch (Exception ex){
			system.debug('NewVoiceMediaCallHelper:getResponseTimeForVoiceMail: Exception occured :' + ex.getMessage() );
		}
	}
    
    

	public void getResponseTimeForCases(){
		try{
			// get all current escalated cases
	   		List<Cases__c> scope = [SELECT id,  Status__c, First_Success_Call__c FROM Cases__c 
	   								WHERE Status__c= 'Escalated'
	   										AND (Product_Type__c = 'Social Marketing' OR Product_Type__c = 'AdWords Management')
											AND CaseType__c = 'Cancellation'];
	   		Map<Id, Cases__c > escalatedCases = new Map<Id, Cases__c>();   		
	   		for(Cases__c s : scope){
	   			escalatedCases.put(s.id, s);
			}     
	   		
	   		if(scope.size()>0){
		   		Set<id> listIds =escalatedCases.keyset();
		   		List<Task> calles = [SELECT id, CallType, CallObject, CallDurationInSeconds , NVMContactWorld__CW_Call_Start_Time__c, NVMContactWorld__CW_Call_End_Time__c , WhatId, NVMContactWorld__Was_Call_Recorded__c 
		   							 FROM Task 
		   							 WHERE Status = 'Completed'
		   							 AND CallType = 'Outbound'
		   							 AND WhatId IN :listIds];
				
				if(calles.size()>0){	
					// checking and process
					scope.clear();
					for(Task item : calles){
						if (item.CallDurationInSeconds  >= 30){
							Cases__c casesItem = (Cases__c)escalatedCases.get(item.WhatId);
							casesItem.First_Success_Call__c = item.NVMContactWorld__CW_Call_Start_Time__c ;				
							scope.add(casesItem);				
						}			
					}		
					update scope;
				}
			}
		}catch (Exception ex){
			system.debug('NewVoiceMediaCallHelper:getResponseTimeForCases: Exception occured :' + ex.getMessage() );
		}
					
	}

}