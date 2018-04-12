/*
	Caculate the total lost revenue of both cancelled and paused products for each client manager in last month
*/

public with sharing class LostRevenue {
	//Key is CM's name, value is his/her lost revenue.
	public Map<String, Map<String, Decimal>> teamAMap  {get; set;}
	public Map<String, Map<String, Decimal>> teamBMap  {get; set;}
	public Map<String, Map<String, Decimal>> teamCMap  {get; set;}
	public String lastMonth {get; set;}
	
	public LostRevenue () {
		Date lastDayLastMonth = Date.today().toStartOfMonth().addDays(-1);
		lastMonth = datetime.newInstance(lastDayLastMonth.year(), lastDayLastMonth.month(), lastDayLastMonth.day()).format('MMMMM yyyy');
		
		Set<string> cmAs = new Set<String>();
		List<User> teamA = [select name from user where isActive = true and UserRole.name like '%Client Manager Team A%'];		
		for(User u : teamA){
			cmAs.add(u.name);
		}
		
		Set<string> cmBs = new Set<String>();
		List<User> teamB = [select name from user where isActive = true and UserRole.name like '%Client Manager Team B%'];
		for(User u : teamB){
			cmBs.add(u.name);
		}
		
		Set<string> cmCs = new Set<String>();
		List<User> teamC = [select name from user where isActive = true and (UserRole.name = 'Client Manager Team C' or UserRole.name = 'Client Manager Retentions Team')];
		for(User u : teamC){
			cmCs.add(u.name);
		}
		
		teamAMap  = new Map<String, Map<String, Decimal>>();
		teamBMap  = new Map<String, Map<String, Decimal>>();
		teamCMap  = new Map<String, Map<String, Decimal>>();
		
		//Initial lost map, in case some client manager has no cancelled product in last month. Should display them in table as well
		for (string s : cmAs) {
			teamAMap.put(s, new Map<String, Decimal>{'Cancel'=>0, 'Pause'=>0});
		}
		for (string s : cmBs) {
			teamBMap.put(s, new Map<String, Decimal>{'Cancel'=>0, 'Pause'=>0});
		}
		for (string s : cmCs) {
			teamCMap.put(s, new Map<String, Decimal>{'Cancel'=>0, 'Pause'=>0});
		}			
		
		/*
			Part 1, Caculate and update Cancel Revenue
		*/
		//Get the cancelled account list from cancellation cases. Avoid counting in the downgrade/upgrade cancellation product
		Set<Id> cancelAccs = new Set<Id>();
		Cases__c[] cas = [select
							account__c
						from
							cases__c
						where
							CaseType__c = 'Cancellation'
						and
							cancellation_date__c = last_month
						];
		for(Cases__c ca : cas) {
			cancelAccs.add(ca.account__c);
		}
		
		Account_product__c[] aps = [select
									product_price__c, 
									last_invoice_date__c, 
									cancelat__c, 
									Recurring_Period__c,
									owner.name
								from
									Account_Product__c
								Where
									Product_Status__c = 'Cancelled'
								And
									Recurring_Period__c != null
								And
									Recurring_Period__c != 'N/A'
								And
									Name Like '%Adwords%'
								And
									cancelat__c = Last_month
								And
									(Owner.name in :cmAs or Owner.name in :cmBs or Owner.name in :cmCs )
								And
									account__c in :cancelAccs	
								];
								
		//Caculate the lost for each individual product and update respective map
		if (aps.size() > 0) {
			for(Account_product__c ap : aps) {
				Decimal singleProductLost = caculateCancelLost(ap.Recurring_Period__c, ap.Product_Price__c, ap.cancelat__c, ap.Last_Invoice_Date__c);
	    		Decimal tmp;
	    		Map<String, Decimal> tmpMap;
	    		if (cmAs.contains(ap.owner.Name)) {
	    			tmpMap = teamAMap.get(ap.owner.Name);
	    			tmp = tmpMap.get('Cancel');
	    			tmp += singleProductLost;
	    			tmpMap.put('Cancel', tmp);
	    			teamAMap.put(ap.owner.Name, tmpMap);
	    		} else if(cmBs.contains(ap.owner.Name)) {
	    			tmpMap = teamBMap.get(ap.owner.Name);
	    			tmp = tmpMap.get('Cancel');
	    			tmp += singleProductLost;
	    			tmpMap.put('Cancel', tmp);
	    			teamBMap.put(ap.owner.Name, tmpMap);
	    		} else if(cmCs.contains(ap.owner.Name)) {
	    			tmpMap = teamCMap.get(ap.owner.Name);
	    			tmp = tmpMap.get('Cancel');
	    			tmp += singleProductLost;
	    			tmpMap.put('Cancel', tmp);
	    			teamCMap.put(ap.owner.Name, tmpMap);
	    		} 
			}
		}
		
		/*
			Part 2, Caculate and update Pause Revenue
		*/
				aps = [select
							product_price__c, 
							pauseat__c,
 							activeat__c, 
							Recurring_Period__c,
							owner.name
						from
							Account_Product__c
						Where
							Recurring_Period__c != null
						And
							Recurring_Period__c != 'N/A'
						And
							Name Like '%Adwords%'
						And
							(pauseat__c = Last_month or (pauseat__c < Last_month and (activeat__c = Last_month or activeat__c > Last_Month)))
						And
							activeat__c != null
						And
							(Owner.name in :cmAs or Owner.name in :cmBs or Owner.name in :cmCs)];
							
		if (aps.size() > 0) {
			for(Account_product__c ap : aps) {
				Decimal singleProductLost = caculatePauseLost(ap.Recurring_Period__c, ap.Product_Price__c, ap.pauseat__c, ap.activeat__c);
				Decimal tmp;
	    		Map<String, Decimal> tmpMap;
	    		if (cmAs.contains(ap.owner.Name)) {
	    			tmpMap = teamAMap.get(ap.owner.Name);
	    			tmp = tmpMap.get('Pause');
	    			tmp += singleProductLost;
	    			tmpMap.put('Pause', tmp);
	    			teamAMap.put(ap.owner.Name, tmpMap);
	    		} else if(cmBs.contains(ap.owner.Name)) {
	    			tmpMap = teamBMap.get(ap.owner.Name);
	    			tmp = tmpMap.get('Pause');
	    			tmp += singleProductLost;
	    			tmpMap.put('Pause', tmp);
	    			teamBMap.put(ap.owner.Name, tmpMap);
	    		} else if(cmCs.contains(ap.owner.Name)) {
	    			tmpMap = teamCMap.get(ap.owner.Name);
	    			tmp = tmpMap.get('Pause');
	    			tmp += singleProductLost;
	    			tmpMap.put('Pause', tmp);
	    			teamCMap.put(ap.owner.Name, tmpMap);
	    		} 
			}
		}
		
		//Update total cancel and pause revenue for each team
		teamAMap.put('#Total', new Map<String, Decimal>{'Cancel'=>sumup('Team A', 'Cancel'), 'Pause'=>sumup('Team A', 'Pause')});
		teamBMap.put('#Total', new Map<String, Decimal>{'Cancel'=>sumup('Team B', 'Cancel'), 'Pause'=>sumup('Team B', 'Pause')});
		teamCMap.put('#Total', new Map<String, Decimal>{'Cancel'=>sumup('Team C', 'Cancel'), 'Pause'=>sumup('Team C', 'Pause')});
		
	}
	
	public void send() {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String emailBody;
		emailBody = '<h3>Lost Revenue For </h3>' + lastMonth;
		
		emailBody += '<table border=1 rules="all" cellpadding="10">';
		emailBody += '<caption style="font-size:25px;font-weight:bold;">Team A</caption>';
		emailBody += '<thead>';
		emailBody += '<tr>';
	    emailBody += '<th style="width:250px; text-align:center;">Client Manager</th>';
	    emailBody += '<th style="width:250px; text-align:center;">Cancel Revenue</th>';
	    emailBody += '<th style="width:250px; text-align:center;">Pause Revenue</th>';
	    emailBody += '</tr>';
	    emailBody += '</thead>';
	    emailBody += '<tbody>';
	    List<String> cmsA = new List<String>(); 
	    cmsA.addAll(teamAMap.keySet());
	    cmsA.sort();
		for(String name : cmsA) {
		    emailBody += '<tr>';
		    emailBody += '<td>'+ name + '</td>';
		    emailBody += '<td style="text-align:right;">' + teamAMap.get(name).get('Cancel') + '</td>';
			emailBody += '<td style="text-align:right;">' + teamAMap.get(name).get('Pause') + '</td>';
		    emailBody += '</tr>';
		}
		emailBody += '</tbody>';
		emailBody += '</table>';
		emailBody += '<br><br>';
		
		emailBody += '<table border=1 rules="all" cellpadding="10">';
		emailBody += '<caption style="font-size:25px;font-weight:bold;">Team B</caption>';
		emailBody += '<thead>';
		emailBody += '<tr>';
	    emailBody += '<th style="width:250px; text-align:center;">Client Manager</th>';
	    emailBody += '<th style="width:250px; text-align:center;">Cancel Revenue</th>';
	    emailBody += '<th style="width:250px; text-align:center;">Pause Revenue</th>';
	    emailBody += '</tr>';
	    emailBody += '</thead>';
	    emailBody += '<tbody>';
	    List<String> cmsB = new List<String>(); 
	    cmsB.addAll(teamBMap.keySet());
	    cmsB.sort();
		for(String name : cmsB) {
		    emailBody += '<tr>';
		    emailBody += '<td>'+ name + '</td>';
		    emailBody += '<td style="text-align:right;">' + teamBMap.get(name).get('Cancel') + '</td>';
			emailBody += '<td style="text-align:right;">' + teamBMap.get(name).get('Pause') + '</td>';
		    emailBody += '</tr>';
		}
		emailBody += '</tbody>';
		emailBody += '</table>';
		emailBody += '<br><br>';
		
		emailBody += '<table border=1 rules="all" cellpadding="10">';
		emailBody += '<caption style="font-size:25px;font-weight:bold;">Team C</caption>';
		emailBody += '<thead>';
		emailBody += '<tr>';
	    emailBody += '<th style="width:250px; text-align:center;">Client Manager</th>';
	    emailBody += '<th style="width:250px; text-align:center;">Cancel Revenue</th>';
	    emailBody += '<th style="width:250px; text-align:center;">Pause Revenue</th>';
	    emailBody += '</tr>';
	    emailBody += '</thead>';
	    emailBody += '<tbody>';
	    List<String> cmsC = new List<String>(); 
	    cmsC.addAll(teamCMap.keySet());
	    cmsC.sort();
		for(String name : cmsC) {
		    emailBody += '<tr>';
		    emailBody += '<td>'+ name + '</td>';
		    emailBody += '<td style="text-align:right;">' + teamCMap.get(name).get('Cancel') + '</td>';
			emailBody += '<td style="text-align:right;">' + teamCMap.get(name).get('Pause') + '</td>';
		    emailBody += '</tr>';
		}
		emailBody += '</tbody>';
		emailBody += '</table>';
		emailBody += '<br><br>';
		
				
		try {
			String emailAddress = 'william.zhang@sponsoredlinx.com';
			String[] toAddresses = new String[] {emailAddress};
			//String[] toAddresses = new String[] {'bill.zhang@sponsoredlinx.com'};
			mail.setToAddresses(toAddresses);
			mail.setSenderDisplayName('Lost Revenue Report');
			mail.setSubject('Lost Revenue Report');
			mail.setBccSender(false);
			mail.setUseSignature(false);
			mail.setHtmlBody(emailBody);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		} catch (Exception e) {
			emailBody = 'Fail to send lost revenue report!';
			String[] toAddresses = new String[] {'bill.zhang@sponsoredlinx.com'};
			mail.setToAddresses(toAddresses);
			mail.setSenderDisplayName('Lost Revenue Report Error');
			mail.setSubject('Send Lost Revenue Report Failed');
			mail.setBccSender(false);
			mail.setUseSignature(false);
			mail.setHtmlBody(emailBody);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}
	
	
	private Decimal caculateCancelLost(String recurPeriod, Decimal price, Date cancelDate, Date lastInvoiceDate ) {
		Decimal sum = 0;
		
		Date firstDayOfMonth = cancelDate.toStartOfMonth();
		Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1); 
		
		integer days = lastInvoiceDate.daysBetween(lastDayOfMonth);
		
		integer cycle = 0;
		if (recurPeriod == 'Weekly') {
			cycle = days/7;
		} else if (recurPeriod == 'Monthly') {
			if (lastInvoiceDate.month() != cancelDate.month()) {
				cycle = 1;
			}
		}
		sum = cycle * price;
		sum = sum.setScale(2, RoundingMode.HALF_UP);
		
		return sum;
	}
	
	private Decimal caculatePauseLost(String recurPeriod, Decimal price, Date pauseDate, Date activeDate ) {
		Decimal sum = 0;
		
		Date ld = Date.today().toStartOfMonth().addDays(-1);
		Date fd = ld.toStartOfMonth();
		
		integer days = 0;
		
		if (pauseDate >= fd && activeDate <= ld) {
			days = pauseDate.daysBetween(activeDate);
		} else if (pauseDate >= fd && activeDate >= ld) {
			days = pauseDate.daysBetween(ld); 
		} else if (pauseDate <= fd && activeDate <= ld) {
			days = fd.daysBetween(activeDate);
		} else if (pauseDate <= fd && activeDate >= ld) {
			days = fd.daysBetween(ld);
		}
		
		double cycle = 0;
		if (recurPeriod == 'Weekly') {
			cycle = days/7;
		} else if (recurPeriod == 'Monthly') {
			cycle = days/fd.daysBetween(ld);
		}
		sum = cycle * price;
		sum = sum.setScale(2, RoundingMode.HALF_UP);
		
		return sum;
	}
	
	public Decimal sumup (String teamName, String lostType) {
		//Caculate the total cancel or pause lost for the whole team
		Decimal total = 0;
		
		Map<String, Map<String, Decimal>> sumMap;
		if (teamName.equals('Team A')) {
			sumMap = teamAMap;
		} else if (teamName.equals('Team B')) {
			sumMap = teamBMap;
		} else if (teamName.equals('Team C')) {
			sumMap = teamCMap;
		} 
		
		List<Decimal> revenues = new List<Decimal>();
		for (Map<String, Decimal> m : sumMap.values()){
			revenues.add(m.get(lostType));
		}
		
		for (Decimal d : revenues) {
			total += d;
		}
		return total;
	}
	
	@isTest(SeeAllData=true)
	static void coverageTest () {
		Test.startTest();
		Account acc = new Account();
		acc.name = 'Alister Dunlop';
		insert acc;
		
        User u = [select id, name from user where isActive = true and UserRole.name like '%Client Manager Team A%' limit 1];
        system.debug(u.name + '********************');		
        
        Cases__c ca = new Cases__c();
        ca.account__c = acc.id;
        ca.CaseType__c = 'Cancellation';
        ca.cancellation_date__c = Date.today().toStartOfMonth().addDays(-15);
        ca.X2012_Action_Taken_to_Save__c = 'blah blah';
        insert ca;
		
		Account_product__c ap = new Account_product__c();
		ap.Account__c = acc.id;
		ap.Ownerid = u.id;
		ap.name = 'Adwords Management';
        ap.Product_Price__c = 69.0;
        ap.Recurring_Period__c ='Weekly';
        ap.Payment_Option__c = 'Eway';
        ap.product_status__c = 'Cancelled';
        ap.cancelat__c = Date.today().toStartOfMonth().addDays(-15);
        ap.Last_Invoice_Date__c = Date.today().toStartOfMonth().addDays(-17);
		insert ap;
		
		Account_product__c ap1 = new Account_product__c();
		ap1.Account__c = acc.id;
		ap1.Ownerid = u.id;
		ap1.name = 'Adwords Management';
        ap1.Product_Price__c = 69.0;
        ap1.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap1.Recurring_Period__c ='Monthly';
        ap1.Payment_Option__c = 'Eway';
        ap1.product_status__c = 'Cancelled';
        ap1.cancelat__c = Date.today().toStartOfMonth().addDays(-15);
        ap1.Last_Invoice_Date__c = Date.today().toStartOfMonth().addDays(-20);
		insert ap1;
		
		LostRevenue lr = new LostRevenue();
		lr.send();
		system.assert(lr.teamAMap.get(u.name).get('Cancel')>0);
		
		Test.stopTest();
	}

}