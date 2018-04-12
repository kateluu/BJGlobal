public with sharing class general {
	public static boolean sendAdminEmail(String errObj, String errMsg) {
		try {
			// all done, we start setting the default email fields
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses 	= new String[] { 'mathew.carter@bjbglobal.com.au' };
			String[] bccAddresses  	= new String[] { 'krishna.silalahi@bjbglobal.com.au' };
			mail.setToAddresses(toAddresses);
			mail.setBccAddresses(bccAddresses);
			mail.setReplyTo('salesforce@sponsoredlinx.com.');
			mail.setSenderDisplayName('Salesforce Programming');
			mail.setSubject('Salesforce Error Occurred In '+errObj);
			mail.setUseSignature(false);
			// and set the email content
			mail.setHtmlBody(errMsg);
			// and send the email
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			return true;
		} catch(Exception e) {
			return false;
		}
	}
	public static String searchMovementString(Decimal current, Decimal original) {
		System.debug('current:'+current);
		System.debug('original:'+original);		
		if(current==null) { current = 0; }
		if(original==null) { original = 0; }
		System.debug('current:'+current);
		System.debug('original:'+original);
		Integer intCurrent = Math.round(current);//;Integer.valueOf(String.valueOf(Math.roundToLong(current)));
		Integer intOriginal = Math.round(original);//Integer.valueOf(String.valueOf(Math.roundToLong(original)));
		System.debug('current:'+intCurrent);
		System.debug('original:'+intOriginal);
		if (intOriginal == 0) {
			intOriginal = 100;
			if (intCurrent == 0) {
				intCurrent = 100;	
			}				
		}
		Integer movement = intOriginal - intCurrent;
		String returnStr = String.valueOf(intCurrent);
		if(returnStr == '100') {
			returnStr = '-';
		}
		if(movement < 0) {
			String strmovement = String.valueOf(movement);
			returnStr = returnStr +' (- '+strmovement.replace('-','')+')';	
		}		
		if(movement > 0) {
			returnStr = returnStr +' (+ '+String.valueOf(movement)+')';
		}
		
		System.debug('returnStr: '+returnStr);
		return returnStr;
	}
	
	public static testMethod void testsendAdminEmail() {
		Test.startTest();
		general.sendAdminEmail('errorObject','errorMessage');
		Test.stopTest();
	}
	
	public static testMethod void testGeneralFunctions() {
		Test.startTest();
		
		
		System.debug(general.searchMovementString(null,null));
		System.debug(general.searchMovementString(5,5));
		System.debug(general.searchMovementString(15,5));
		System.debug(general.searchMovementString(5,15));
		
		Test.stopTest();
	}
}