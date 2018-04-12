trigger EndofMonthAfterCreate on End_of_Month__c (after insert) {
	for (End_of_Month__c eom : Trigger.new ){
		call_monitoring__c[] update_calls = new List<call_monitoring__c>();
		call_monitoring__c[] calls = [select End_of_Month__c 
		                              	from call_monitoring__c 
		                              where End_of_month__c = '' 
		                              and OwnerId =: eom.Client_manager__c 
		                              order by createddate desc 
		                              limit 5];
		for(call_monitoring__c call : calls){
		    call.End_of_Month__c = eom.id;
		    update_calls.add(call);
		}   
		update update_calls;
		
		
		Spot_Check__c[] update_spotchecks = New List<Spot_Check__c>();
		Spot_Check__c[] spotchecks = [select End_of_Month__c
									   from Spot_Check__c 
									   where
									   		OwnerId =: eom.Client_manager__c
									   and
									   		RecordType.Name = 'Spot Check'
									   	order by createddate desc 
		                              limit 5];
		for(Spot_Check__c spotcheck : spotchecks){
			spotcheck.End_of_Month__c = eom.id;
			update_spotchecks.add(spotcheck);
		}
		update update_spotchecks;
	}
	

}