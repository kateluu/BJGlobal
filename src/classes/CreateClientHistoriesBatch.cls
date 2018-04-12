global class CreateClientHistoriesBatch implements Database.Batchable<sObject>{

	global final String Query;
	
	global CreateClientHistoriesBatch () {
		Query = 'select id, product_status__c, recurring_period__c, createdDate, cancelsmallthanactive__c, cancelsmallthanpause__c, pausesmallthanactive__c, activeat__c, pauseat__c, cancelat__c, start_date__c, Cancellation_Date__c from account_product__c';
	}
	
	global Database.QueryLocator start (Database.BatchableContext BC)
    {
           return Database.getQueryLocator(Query);
    }
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
    	for(sObject ob : scope) {
    		account_product__c ap = (account_product__c)ob;
    		if (ap.product_status__c == 'Active' && ap.pauseat__c == null && ap.activeat__c != null && ap.Recurring_Period__c != null && ap.Recurring_Period__c != 'N/A' && ap.id != 'a0790000002OHLIAA4') {
		    	//skip a0790000002OHLIAA4
		    	createActiveWithoutBreak(ap);
    		}
    		/*
		    if (ap.product_status__c == 'Active' && ap.pauseat__c == null && (ap.Recurring_Period__c == null || ap.Recurring_Period__c == 'N/A')) {
		    	createOnceOff(ap);
		    } else if (ap.product_status__c == 'Active' && ap.pauseat__c == null && ap.activeat__c == null && ap.Recurring_Period__c != null && ap.Recurring_Period__c != 'N/A' && ap.id != 'a0790000002OHLIAA4') {
		    	//skip a0790000002OHLIAA4
		    	createActiveWithoutBreak(ap);
		    } else if (ap.product_status__c == 'Active' && ap.pauseat__c != null && ap.activeat__c == null) {
		    	createActiveWithoutBreak(ap);
		    } else if (ap.id == 'a07900000047U5RAAU') {
		    	createOnceOff(ap);
			} else if (ap.product_status__c == 'Active' && ap.pauseat__c != null && ap.activeat__c != null && ap.cancelat__c == null && (ap.Recurring_Period__c == null || ap.Recurring_Period__c == 'N/A')) {
				createActiveWithBreak(ap);
			} else if (ap.product_status__c == 'Active' && ap.pauseat__c != null && ap.activeat__c != null && ap.cancelat__c == null && ap.Recurring_Period__c != null && ap.Recurring_Period__c != 'N/A' && ap.pauseat__c <= date.today()) {
				createActiveWithBreak(ap);
			} else if (ap.product_status__c == 'Active' && ap.pauseat__c != null && ap.activeat__c != null && ap.cancelat__c == null && ap.Recurring_Period__c != null && ap.Recurring_Period__c != 'N/A' && ap.pauseat__c > date.today()) {
				createActiveWithoutBreak(ap);
			} else if (ap.product_status__c == 'Active' && ap.pauseat__c != null && ap.activeat__c != null && ap.cancelat__c != null) {
				createActiveWithBreak(ap);
			} else if (ap.product_status__c == 'Paused' && ap.pauseat__c != null && ap.activeat__c != null) {
				createOngoingPause(ap);
			} else if (ap.product_status__c == 'Cancelled' && ap.pauseat__c == null && ap.activeat__c == null && ap.cancelat__c == null) {
				if (ap.Start_Date__c != null && ap.cancellation_date__c != null) {
					createOldCancelled(ap);
				}
			} else if (ap.product_status__c == 'Cancelled' && ap.pauseat__c == null && ap.activeat__c == null && ap.cancelat__c != null) {
				createActiveCancel(ap);
			} else if (ap.product_status__c == 'Cancelled' && ap.pauseat__c == null && ap.activeat__c != null && ap.cancelat__c != null) {
				createActiveCancel(ap);
			} else if (ap.product_status__c == 'Cancelled' && ap.pauseat__c != null && ap.activeat__c != null && ap.cancelat__c != null && ap.cancelsmallthanactive__c == 'false' && ap.pausesmallthanactive__c == 'true') {
				createActivePauseActiveCancel(ap);
			} else if (ap.product_status__c == 'Cancelled' && ap.pauseat__c != null && ap.activeat__c != null && ap.cancelat__c != null && ap.cancelsmallthanpause__c == 'false' && ap.pausesmallthanactive__c == 'false') {
				createActivePauseCancel(ap);
			} else if (ap.product_status__c == 'Cancelled' && ap.pauseat__c != null && ap.activeat__c != null && ap.cancelat__c != null && ap.cancelsmallthanactive__c == 'true' && ap.pausesmallthanactive__c == 'true') {
				createActivePauseCancel(ap);
			}
			*/
      	} 
   }
   
   global void finish(Database.BatchableContext BC){
   }
   
   
   private void createActiveWithoutBreak (account_product__c ap) {
		Client_History__c ch = new Client_History__c();
        ch.account_product__c = ap.id;
        date min = Date.newinstance(ap.createdDate.year(),ap.createdDate.month(),ap.createdDate.day());
        if (ap.activeat__c != null && ap.activeat__c < min) min = ap.activeat__c;
        if (ap.start_date__c != null && ap.start_date__c < min) min = ap.start_date__c;
        ch.start_date__c = min;
        ch.type__c = 'Active';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
	}
	
	/*
   //Most once-off paid product are something like 'Adwords Premium Setup' etc. The majority (99%+ I asure) of them are Active products. 
	private void createOnceOff (account_product__c ap) {
		Client_History__c ch = new Client_History__c();
        ch.account_product__c = ap.id;
        date min = Date.newinstance(ap.createdDate.year(),ap.createdDate.month(),ap.createdDate.day());
        if (ap.activeat__c != null && ap.activeat__c < min) min = ap.activeat__c;
        if (ap.start_date__c != null && ap.start_date__c < min) min = ap.start_date__c;
        ch.start_date__c = min;
        ch.end_date__c = min;
        ch.type__c = 'Active';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
	}
	
	private void createActiveWithBreak (account_product__c ap) {
		Client_History__c ch = new Client_History__c();
        ch.account_product__c = ap.id;
        date min = Date.newinstance(ap.createdDate.year(),ap.createdDate.month(),ap.createdDate.day());
        if (ap.start_date__c != null && ap.start_date__c < min) min = ap.start_date__c;
        ch.start_date__c = min;
        ch.end_date__c = ap.pauseat__c.addDays(-1);
        ch.type__c = 'Active';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
        
        ch = new Client_History__c();
        ch.account_product__c = ap.id;
        ch.start_date__c = ap.pauseat__c;
        ch.end_date__c = ap.activeat__c.addDays(-1);
        ch.type__c = 'Paused';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
        
        ch = new Client_History__c();
        ch.account_product__c = ap.id;
        ch.start_date__c = ap.activeat__c;
        ch.type__c = 'Active';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
	}
	
	private void createOngoingPause (account_product__c ap) {
		Client_History__c ch = new Client_History__c();
        ch.account_product__c = ap.id;
        date min = Date.newinstance(ap.createdDate.year(),ap.createdDate.month(),ap.createdDate.day());
        if (ap.start_date__c != null && ap.start_date__c < min) min = ap.start_date__c;
        ch.start_date__c = min;
        ch.end_date__c = ap.pauseat__c.addDays(-1);
        ch.type__c = 'Active';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
        
        ch = new Client_History__c();
        ch.account_product__c = ap.id;
        ch.start_date__c = ap.pauseat__c;
        ch.type__c = 'Paused';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
	}
	
	//old product info from old systems
	private void createOldCancelled (account_product__c ap) {
		Client_History__c ch = new Client_History__c();
        ch.account_product__c = ap.id;
        ch.start_date__c = ap.Start_Date__c;
        ch.end_date__c = ap.Cancellation_Date__c.addDays(-1);
        ch.type__c = 'Active';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
        
        ch = new Client_History__c();
        ch.account_product__c = ap.id;
        ch.start_date__c = ap.Cancellation_Date__c;
        ch.end_date__c = ap.Cancellation_Date__c;
        ch.type__c = 'Cancelled';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
	}
	
	//active -> cancel
	private void createActiveCancel (account_product__c ap) {
		Client_History__c ch = new Client_History__c();
        ch.account_product__c = ap.id;
        date min = Date.newinstance(ap.createdDate.year(),ap.createdDate.month(),ap.createdDate.day());
        if (ap.activeat__c != null && ap.activeat__c < min) min = ap.activeat__c;
        if (ap.start_date__c != null && ap.start_date__c < min) min = ap.start_date__c;
        ch.start_date__c = min;
        ch.end_date__c = ap.cancelat__c.addDays(-1);
        ch.type__c = 'Active';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
        
        ch = new Client_History__c();
        ch.account_product__c = ap.id;
        ch.start_date__c = ap.cancelat__c;
        ch.end_date__c = ap.cancelat__c;
        ch.type__c = 'Cancelled';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
	}
	
	//active -> pause -> cancel
	private void createActivePauseCancel (account_product__c ap) {
		Client_History__c ch = new Client_History__c();
        ch.account_product__c = ap.id;
        date min = Date.newinstance(ap.createdDate.year(),ap.createdDate.month(),ap.createdDate.day());
        if (ap.activeat__c != null && ap.activeat__c < min) min = ap.activeat__c;
        if (ap.start_date__c != null && ap.start_date__c < min) min = ap.start_date__c;
        ch.start_date__c = min;
        ch.end_date__c = ap.pauseat__c.addDays(-1);
        ch.type__c = 'Active';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
        
        ch = new Client_History__c();
        ch.account_product__c = ap.id;
        ch.start_date__c = ap.pauseat__c;
        ch.end_date__c = ap.cancelat__c.addDays(-1);
        ch.type__c = 'Paused';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
        
        ch = new Client_History__c();
        ch.account_product__c = ap.id;
        ch.start_date__c = ap.cancelat__c;
        ch.end_date__c = ap.cancelat__c;
        ch.type__c = 'Cancelled';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
	}
	//active -> pause -> active -> cancel
	private void createActivePauseActiveCancel (account_product__c ap) {
		Client_History__c ch = new Client_History__c();
        ch.account_product__c = ap.id;
        date min = Date.newinstance(ap.createdDate.year(),ap.createdDate.month(),ap.createdDate.day());
        if (ap.start_date__c != null && ap.start_date__c < min) min = ap.start_date__c;
        ch.start_date__c = min;
        ch.end_date__c = ap.pauseat__c.addDays(-1);
        ch.type__c = 'Active';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
        
        ch = new Client_History__c();
        ch.account_product__c = ap.id;
        ch.start_date__c = ap.pauseat__c; 
        ch.end_date__c = ap.activeat__c.addDays(-1);
        ch.type__c = 'Paused';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
        
        ch = new Client_History__c();
        ch.account_product__c = ap.id;
        ch.start_date__c = ap.activeat__c;
        ch.end_date__c = ap.cancelat__c.addDays(-1);
        ch.type__c = 'Active';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
        
        ch = new Client_History__c();
        ch.account_product__c = ap.id;
        ch.start_date__c = ap.cancelat__c;
        ch.end_date__c = ap.cancelat__c;
        ch.type__c = 'Cancelled';
        ch.name = ch.type__c + ' at ' + ch.start_date__c.format();
        upsert(ch);
	}
	*/
	
	public static testMethod void testBatch () {
		Account acc = new Account();
		acc.name = 'testAcc';
		insert acc;
		
		Account_Product__c active = new Account_Product__c();
		active.Account__c = acc.id;
        active.Product_Price__c = 19.99;
        active.product_status__c = 'Active';
        active.Recurring_Period__c ='Weekly';
        active.Payment_Option__c = 'Eway';
        active.start_date__c = date.newinstance(2012, 1, 1);
        active.activeat__c = date.newinstance(2012, 7, 1);
        insert active;
		
		/*
		Account_Product__c active = new Account_Product__c();
		active.Account__c = acc.id;
        active.Product_Price__c = 19.99;
        active.product_status__c = 'Active';
        active.Recurring_Period__c ='Weekly';
        active.Payment_Option__c = 'Eway';
        active.start_date__c = date.newinstance(2012, 1, 1);
        insert active;
        
        Account_Product__c onceoff = new Account_Product__c();
		onceoff.Account__c = acc.id;
        onceoff.Product_Price__c = 199.99;
        onceoff.product_status__c = 'Active';
        onceoff.Payment_Option__c = 'Eway';
        onceoff.start_date__c = date.newinstance(2012, 1, 1);
        insert onceoff;
        
        Account_Product__c activePause = new Account_Product__c();
		activePause.Account__c = acc.id;
        activePause.Product_Price__c = 199.99;
        activePause.product_status__c = 'Paused';
        activePause.Payment_Option__c = 'Eway';
        activePause.start_date__c = date.newinstance(2012, 1, 1);
        activePause.Pauseat__c = date.newinstance(2012, 3, 1);
        activePause.Activeat__c = date.newinstance(2013, 3, 1);
        insert activePause;
        
        Account_Product__c activePauseActive = new Account_Product__c();
		activePauseActive.Account__c = acc.id;
        activePauseActive.Product_Price__c = 199.99;
        activePauseActive.product_status__c = 'Active';
        activePauseActive.Payment_Option__c = 'Eway';
        activePauseActive.start_date__c = date.newinstance(2012, 1, 1);
        activePauseActive.Pauseat__c = date.newinstance(2012, 3, 1);
        activePauseActive.Activeat__c = date.newinstance(2012, 5, 1);
        insert activePauseActive;
        
        Account_Product__c cancel = new Account_Product__c();
		cancel.Account__c = acc.id;
        cancel.Product_Price__c = 199.99;
        cancel.product_status__c = 'Cancelled';
        cancel.Payment_Option__c = 'Eway';
        cancel.start_date__c = date.newinstance(2010, 1, 1);
        cancel.Cancellation_Date__c = date.newinstance(2011, 1, 1);
        insert cancel;

		Account_Product__c activeCancel = new Account_Product__c();
		activeCancel.Account__c = acc.id;
        activeCancel.Product_Price__c = 199.99;
        activeCancel.product_status__c = 'Cancelled';
        activeCancel.Payment_Option__c = 'Eway';
        activeCancel.start_date__c = date.newinstance(2012, 1, 1);
        activeCancel.Cancelat__c = date.newinstance(2012, 5, 1);
        insert activeCancel;
        
        Account_Product__c activePauseCancel = new Account_Product__c();
		activePauseCancel.Account__c = acc.id;
        activePauseCancel.Product_Price__c = 199.99;
        activePauseCancel.product_status__c = 'Cancelled';
        activePauseCancel.Payment_Option__c = 'Eway';
        activePauseCancel.start_date__c = date.newinstance(2012, 1, 1);
        activePauseCancel.Pauseat__c = date.newinstance(2012, 3, 1);
        activePauseCancel.Cancelat__c = date.newinstance(2012, 5, 1);
        activePauseCancel.Activeat__c = date.newinstance(2012, 5, 1);
        insert activePauseCancel;
        
        Account_Product__c activePauseActiveCancel = new Account_Product__c();
		activePauseActiveCancel.Account__c = acc.id;
        activePauseActiveCancel.Product_Price__c = 199.99;
        activePauseActiveCancel.product_status__c = 'Cancelled';
        activePauseActiveCancel.Payment_Option__c = 'Eway';
        activePauseActiveCancel.start_date__c = date.newinstance(2012, 1, 1);
        activePauseActiveCancel.Pauseat__c = date.newinstance(2012, 3, 1);
        activePauseActiveCancel.Activeat__c = date.newinstance(2012, 4, 1);
        activePauseActiveCancel.Cancelat__c = date.newinstance(2012, 5, 1);
        insert activePauseActiveCancel;
        */
		Test.startTest();
		CreateClientHistoriesBatch b = new CreateClientHistoriesBatch();
		ID batchprocessid = Database.executeBatch(b, 50);
		Test.stopTest();
	}
}