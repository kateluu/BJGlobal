public with sharing class livestats {
	
	private Integer time_to_check = 5;
	
	public String getPlaySoundForNewSignup() {
		Datetime d = System.now();
		Datetime myDT = DateTime.newInstance(d.year(),d.month(),d.day(),d.hour(),d.minute()-time_to_check,d.second());		
		List<Sign_Up__c> last5minsignups = [SELECT id,name,Signup_Date__c,Status__c,CreatedDate  FROM Sign_Up__c WHERE CreatedDate >=:myDT];
		
		String rtndata = '';
		
		if(last5minsignups.size()>=1) {
			rtndata += 'http://livesignups.bjbglobal.com.au/woohoo.wav';
		}
		return rtndata;
	}
	
	public String getPlaySoundForNewCancellation() {		
		Datetime d = System.now();
		Datetime myDT = DateTime.newInstance(d.year(),d.month(),d.day(),d.hour(),d.minute()-time_to_check,d.second());		
		List<Cases__c> last5mincancellations = [SELECT Id,Name,Account_Resolution__c FROM Cases__c WHERE Account_Resolution__c='Cancellation' and Status__c IN ('Closed','Unresolved') and Cancellation_Date__c >= TODAY and LastModifiedDate >= :myDT];
		
		String rtndata = '';
		
		if(last5mincancellations.size()>=1) {
			rtndata += 'http://livesignups.bjbglobal.com.au/doh.wav';
		}
		return rtndata;
	}

	public Integer getNumberOfSignupsToday() {
		List<Sign_Up__c> todayssignups = [SELECT id,name,Signup_Date__c,Status__c,CreatedDate  FROM Sign_Up__c WHERE CreatedDate >= TODAY];
		return todayssignups.size();
	}  
	
	public Integer getNumberOfCancellationsToday() {
		List<Cases__c> todayscancellations = [SELECT Id,Name,Account_Resolution__c FROM Cases__c WHERE Account_Resolution__c='Cancellation' and Status__c IN ('Closed','Unresolved') and Cancellation_Date__c >= TODAY];
		return todayscancellations.size();
	}

}