public with sharing class ClientHistoryController {
	public List<productHistory> phs {get; set;}
	public string productHistoryJson {get; set;}
	
	public ClientHistoryController(ApexPages.StandardController controller) {		
		Account acc = (Account)controller.getRecord();

		//Get product list of this account
		Account_Product__c[] aps = [SELECT name, ID FROM Account_Product__c WHERE Account__c =: acc.ID and recurring_period__c != null and recurring_period__c != 'N/A'];
		
		List<productHistory> phs = new List<productHistory>();
		
		for (Account_Product__c ap : aps) {
			List<Client_History__c> chs = [SELECT Type__c, Start_Date__c, End_Date__c FROM Client_History__c WHERE Account_Product__c =: ap.Id ORDER BY Start_Date__c ASC];
			List<history> histories = new List<history>();
					
			for (integer i = 0; i < chs.Size(); i++ ){
				History h = new History();
				h.label = chs[i].Type__c;
				if (h.label == 'Paused') {
					h.customClass = 'ganttOrange';
				} else if (h.label == 'Active') {
					h.customClass = 'ganttGreen';
				} else if (h.label == 'Cancelled') {
					h.customClass = 'ganttRed';
				}else if (h.label == 'Trial') {
					h.customClass = 'ganttYellow';
				}else if (h.label == 'Suspended') {
					h.customClass = 'ganttGrey';
				} else {
					h.customClass = 'ganttBlue';
				}
				DateTime startdate = DateTime.newInstanceGMT(chs[i].Start_Date__c.year(), chs[i].Start_Date__c.month(), chs[i].Start_Date__c.day(), 0, 0, 0);
				h.setFromDate(String.valueOf(startdate.getTime()));
				if (chs[i].End_Date__c == null) {
						h.setToDate(String.valueOf(DateTime.now().getTime()));
						h.desc_c = chs[i].Start_Date__c.format() + ' continuing';
				} else {
					DateTime enddate = DateTime.newInstanceGMT(chs[i].End_Date__c.year(), chs[i].End_Date__c.month(), chs[i].End_Date__c.day(), 0, 0, 0);
					h.setToDate(String.valueOf(enddate.getTime()));
					h.desc_c = chs[i].Start_Date__c.format() + ' to ' + chs[i].End_Date__c.format();
				}
				histories.add(h);
			}
			
			productHistory ph = new productHistory();
			ph.name = ap.name;
			ph.values = histories;
			
			phs.add(ph);
		}
		
		
		//Do the below trick because 'from' and 'desc' are reserved keywords in Apex
		productHistoryJson = JSON.serialize(phs).replaceAll('from_c','from').replaceAll('desc_c','desc');
		//system.debug(productHistoryJson);
	}

	/**
	   The reason we don't serialize Client_History__c object directly and throw it to gantt chart is
	   because the jQuery GanttChart requires a special data pattern, so we create a transitional class.
	**/
	public class history {
		public String from_c{get;set;}
		public String to{get;set;}
		public String desc_c{get;set;}
		public String label{get;set;}		
		/*
			Custom class represent the color of the bar:
			ganttRed
			ganttGreen
			ganttOrange
			ganttBlue
		*/
		public string customClass{get;set;}
		
		public void setToDate(String val)
		{
			to = setDate(val);
		}
		public void setFromDate(String val)
		{
			from_c = setDate(val);
		}
		
		//Date should be in special format as it is used in regular expression
		private String setDate(String val)
		{
			return '/Date('+val+')/';
		}
	}
	
	public class productHistory {
		public String name{get;set;}
		public List<history> values{get;set;}
		
	}
	
	static testMethod void test1() {
		Test.startTest();
		
		Account acc = new Account();
		acc.name = 'acc1';
		insert acc;
		Account_product__c ap = new Account_product__c();
		ap.Account__c = acc.id;
        ap.Product_Price__c = 19.99;
        ap.Last_Invoice_Date__c = Date.today().addMonths(-1);
        ap.Recurring_Period__c ='2 Yearly';
        ap.Payment_Option__c = 'Cheque';
		
		insert ap;
		
		Client_History__c ch1 = new Client_History__c();
		ch1.Account_Product__c = ap.id;
		ch1.Type__c = 'Active';
		ch1.start_date__c = date.newInstance(2011, 1, 1);
		ch1.end_date__c = date.newInstance(2011, 10, 1);
		insert ch1;
		Client_History__c ch2 = new Client_History__c();
		ch2.Account_Product__c = ap.id;
		ch2.Type__c = 'Paused';
		ch2.start_date__c = date.newInstance(2011, 10, 2);
		ch2.end_date__c = date.newInstance(2011, 10, 30);
		insert ch2;
		Client_History__c ch3 = new Client_History__c();
		ch3.Account_Product__c = ap.id;
		ch3.Type__c = 'Cancelled';
		ch3.start_date__c = date.newInstance(2011, 12, 1);
		ch3.end_date__c = date.newInstance(2011, 12, 1);
		insert ch3;Client_History__c ch4 = new Client_History__c();
		ch4.Account_Product__c = ap.id;
		ch4.Type__c = 'Trial';
		ch4.start_date__c = date.newInstance(2011, 12, 1);
		insert ch4;
		Client_History__c ch5 = new Client_History__c();
		ch5.Account_Product__c = ap.id;
		ch5.Type__c = 'Suspended';
		ch5.start_date__c = date.newInstance(2011, 12, 1);
		insert ch5;
		
		
		
		ApexPages.standardController controller = new ApexPages.standardController(acc);
		ClientHistoryController con = new ClientHistoryController(controller);

		
		Test.stopTest();	
	
	}
}