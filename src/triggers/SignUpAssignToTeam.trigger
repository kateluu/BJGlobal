trigger SignUpAssignToTeam on Sign_Up__c (before update) {
	for(Sign_Up__c newSignUp : Trigger.new) {
		Sign_Up__c oldSignUp = Trigger.oldMap.get(newSignUp.Id);
		if(newSignUp.Product_Type__c != null && newSignUp.Product_Type__c.contains('AdWords') 
				&& oldSignUp.Status__c != newSignUp.Status__c && newSignUp.Status__c == 'Pending CM Call'
				&& oldSignUp.Assign_to_Team__c == null) {
			Sign_Up_Note__c[] notes = [select id from Sign_Up_Note__c where Sign_up__c =: newSignUp.Id];
			if(notes.size() > 0) {
				Account acc = [select name from account where id = :newSignUp.account__c];
				if(acc.name.contains('GetMoreTraffic')) {
					Schema.DescribeFieldResult fieldResult = Sign_Up__c.Assign_to_Team__c.getDescribe();
					List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); //get team list from sign up object field picklist
					List<Schema.PicklistEntry> teams = new List<Schema.PicklistEntry>(); //remove GMT from team list by creating a new list
					for(Schema.PicklistEntry p : ple) {
						if(p.getValue().contains('GMT')) {
							teams.add(p);
						}
					}
					
					try{
						//found the latest team assignment which is not GMT
						String lastTeamAssignment = 'GMT Team B'; //Team A as a safe net if last 50 sign ups all goes to GMT in next line of code
						Sign_Up__History[] shs = [select OldValue, NewValue, field from Sign_Up__History where field='Assign_to_Team__c' order by createdDate desc limit 50];
						for(Sign_Up__History sh : shs) {
							if(String.valueOf(sh.NewValue).contains('GMT')) {
								lastTeamAssignment = String.valueOf(sh.NewValue);
								break;
							}
						}
						Iterator<Schema.PicklistEntry> iter = teams.iterator();
						while(iter.hasNext()) {
							if(iter.next().getValue() == lastTeamAssignment) {//if this one is assigned, assign to next one
								if(iter.hasNext()) {//if next one exist
									newSignUp.Assign_To_Team__c = iter.next().getValue();
								} else {
									newSignUp.Assign_To_Team__c = teams[0].getValue(); //if last element, assign to first element.
								}
								break;
							}
						}
					} catch (Exception e) {
						newSignUp.Assign_To_Team__c = teams[0].getValue();
					}
				} else {
                    Schema.DescribeFieldResult fieldResult = Sign_Up__c.Assign_to_Team__c.getDescribe();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); //get team list from sign up object field picklist
                    List<Schema.PicklistEntry> teams = new List<Schema.PicklistEntry>(); //remove GMT from team list by creating a new list
                    for (Schema.PicklistEntry p : ple) {
                        if ((!p.getValue().contains('GMT')) && (p.getValue() != 'Team C')) {
                            teams.add(p);
                        }
                    }

                    try {
                        //found the latest team assignment which is not GMT
                        String lastTeamAssignment = 'Team B'; //Team A as a safe net if last 50 sign ups all goes to GMT in next line of code
                        Sign_Up__History[] shs = [select OldValue, NewValue, field from Sign_Up__History where field = 'Assign_to_Team__c' order by createdDate desc limit 50];
                        for (Sign_Up__History sh : shs) {
                            if ((!String.valueOf(sh.NewValue).contains('GMT')) && (!String.valueOf(sh.NewValue).contains('Team C'))) {
                                lastTeamAssignment = String.valueOf(sh.NewValue);
                                break;
                            }
                        }
                        Iterator<Schema.PicklistEntry> iter = teams.iterator();
                        while (iter.hasNext()) {
                            if (iter.next().getValue() == lastTeamAssignment) {//if this one is assigned, assign to next one
                                if (iter.hasNext()) {//if next one exist
                                    newSignUp.Assign_To_Team__c = iter.next().getValue();
                                } else {
                                    newSignUp.Assign_To_Team__c = teams[0].getValue(); //if last element, assign to first element.
                                }
                                break;
                            }
                        }


                    } catch (Exception e) {
                        newSignUp.Assign_To_Team__c = teams[0].getValue();
                    }
                }
			}
		}else if(newSignUp.Product_Type__c != null && newSignUp.Product_Type__c == 'Social Marketing' 
				&& oldSignUp.Status__c != newSignUp.Status__c && newSignUp.Status__c == 'Pending CM Call'
				&& oldSignUp.Assign_to_Team__c == null){
					newSignUp.Assign_To_Team__c = 'Team C';
				}
	}
}