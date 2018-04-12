public with sharing class ActivityReportDaily {
	public ActivityReportDaily() {
		Set<string> cms = new Set<String>{'Ramsay Pontin'};
		
		Map<string, report> result = new Map<string, report>();
		for (string s : cms) {
			result.put(s, new report(s));
		}
		
		Set<id> activeAccounts = new set<id>();
		List<Account_Product__c> aps = [select
											account__c
										from
											account_product__c
										where
											(name like '%adwords%' or name like '%facebook%' or name like '%yahoo%')
										and
											Recurring_Period__c != null
										and
											Recurring_Period__c != 'N/A'
										and
											product_status__c = 'Active'
										and
											createdDate < LAST_N_DAYS:14
										];
										
		for(Account_Product__c ap : aps) {
			activeAccounts.add(ap.account__c);
		}
				
		List <Task> tks = [select
                          		accountid
                           from
                           		task
                           where
                           		isClosed = true
                           and
                           		(LastModifiedDate = LAST_N_DAYS:14 or LastModifiedDate = today)
                           and
                          		accountid in :activeAccounts];
	    for(task t : tks) {
	        activeAccounts.remove(t.accountid);
	    }
		
		for (account acc : [select id, name, owner.name from account where id in :activeAccounts and owner.name in :cms]) {
			if(result.containsKey(acc.owner.name)) {
				result.get(acc.owner.name).numbers++;
				result.get(acc.owner.name).accounts.put(acc.id, acc.name);
			}
		}
		
		Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
		String emailBody;
		Messaging.SingleEmailMessage mail;
		String[] toAddresses;
		
		//Send report to the CM
		for(String name : result.keyset()) {
			emailBody = '<table border=1 rules="all" cellpadding="10" style="text-align:left;">';
			emailBody += '<thead>';
			emailBody += '<tr>';
		    emailBody += '<th>Client Manager</th>';
		    emailBody += '<th>No Account Activities In Last 2 Weeks</th>';
		    emailBody += '<th>Account List</th>';
		    emailBody += '</tr>';
		    emailBody += '</thead>';
		    emailBody += '<tbody>';
		    emailBody += '<tr>';
		    emailBody += '<td>'+ name + '</td>';
		    emailBody += '<td style="text-align:center;">' + result.get(name).numbers + '</td>';
		    emailBody += '<td>';
		    emailBody += '<table>';
	    	for(id i : result.get(name).accounts.keySet()) {
	    		string url = 'https://ap1.salesforce.com/'+i;
	    		emailBody += '<tr>';
		    	emailBody += '<td><a href="'+url+'">'+result.get(name).accounts.get(i)+'</a></td>';
		    	emailBody += '</tr>';
		    }
		    emailBody += '</table>';
		    emailBody += '</td>';
		    emailBody += '</tr>';
			emailBody += '</tbody>';
			emailBody += '</table>';
			emailBody += '<br>';
			emailbody += '<p>Note:</p>';
			emailbody += '<ul>';
			emailbody += '<li>Only scan clients with a currently active Facebook or AdWords management product.</li>';
			emailbody += '<li>New sign up accounts (created within 2 weeks) excluded.</li>';
			emailbody += '<li>If last modified time of latest ActivityHistory is within 2 weeks, this account skip the list.</li>';
			emailbody += '</ul>';
			
			mail = new Messaging.SingleEmailMessage();
			String emailAddress = [select email from User where name =: name limit 1].email;
			toAddresses = new String[] {emailAddress};
			//toAddresses = new String[] {'bill.zhang@sponsoredlinx.com'};
			mail.setToAddresses(toAddresses);
			mail.setSenderDisplayName('Activity Report');
			mail.setSubject('Client Manager Daily Activity Report');
			mail.setBccSender(false);
			mail.setUseSignature(false);
			mail.setHtmlBody(emailBody);
			mails.add(mail);
		}
		Messaging.sendEmail(mails);
	}
	
	public class report {
    	String name {get; set;}
    	integer numbers {get; set;}
    	Map<Id, string> accounts {get; set;}
    	
    	public report(String CMname) {
            this.name = CMname;
            this.numbers = 0;
            this.accounts = new Map<Id, string>();
        }
    }
    
    public static testMethod void ActivityReportDailyTest() {
		Test.StartTest();

		ActivityReportDaily ar = new ActivityReportDaily();

		Test.stopTest();
	}
}