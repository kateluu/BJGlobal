public with sharing class accountDisplayGrid {
	
	public List<customAccount> userCustomAccount = new List<customAccount>();
	public Integer pageSize = 10;
	public Integer PageNumber;
	public Integer totalPageNumber;
	public String newAccOwner {get;set;}
	public List<Account> totalAccounts;
	public List<Account> pagedAccounts;
	
	public accountDisplayGrid() {
		ID userid = UserInfo.getUserId();
		this.newAccOwner = (String)userid;
		this.updateAccOwnerList();		
	}
	public List<Account> getPagedAccounts() {
		List<Account> rtnAccounts = new List<Account>();
		try {			
			Integer counter = 0;
			Integer min = 0;
			for(Integer i=0;i<this.pageNumber-1;i++) {
				if(this.pageNumber>1) {
					min = min + this.pageSize;
				} else {
					min = min + this.pageSize-1;
				}	
			}
			Integer max = min + this.pageSize;
			System.debug('min: '+min);
			System.debug('max: '+max);
			System.debug('pageNo: '+this.pageNumber);
			for(Account singleAcc : this.totalAccounts){
				if((counter>=min) && (counter<max)) {
					rtnAccounts.add(singleAcc);			
				}
				counter++;	
			}
		} catch(Exception e) {
			
		}
		System.debug('rtnAccounts size: '+rtnAccounts.size());
		System.debug('rtnAccounts: '+rtnAccounts);
		return rtnAccounts;	
	}
	public List<customAccount> getuserAccount() {
		customAccount newuserAccount;
		
		Integer results = 1;
		this.pagedAccounts = new List<Account>();
		this.pagedAccounts = this.getPagedAccounts();
		this.userCustomAccount = new List<customAccount>();
		for(Account uacc : this.pagedAccounts) {
			
			Contact accContact;
			try{
				System.debug('id:'+uacc.Id);
				accContact = [SELECT FirstName,LastName,Email,Phone FROM Contact WHERE Title='Reports' and AccountId=:uacc.Id];
			} catch(Exception e) {
				accContact = new Contact(FirstName='',LastName='',Email='');
			}			
			try {
				List<Account_Product__c> accProduct = [SELECT Id,Name,Product_Category__c,Product_Status__c FROM Account_Product__c WHERE Account__c=:uacc.Id and Recurring_Frequency__c!=0];
				for(Account_Product__c accP : accProduct) {
					newuserAccount = new customAccount();
					newuserAccount.accountid = uacc.Id;
					newuserAccount.accname = uacc.Name;
					newuserAccount.contactperson = accContact.FirstName + ' ' + accContact.LastName;
					newuserAccount.contactphone = accContact.Phone;
					newuserAccount.reportemail = accContact.Email;
					newuserAccount.billingstatus = accP.Product_Status__c;
					newuserAccount.subscription = accP.Name;
					newuserAccount.subscriptiontype = accP.Product_Category__c;
					this.userCustomAccount.add(newuserAccount);
				}
			} catch(Exception e) {}	
		}
		return this.userCustomAccount;
	}
	public List<SelectOption> getAccOwnerList() {
		List<SelectOption> options = new List<SelectOption>();
		List<AggregateResult> owners = [SELECT Owner.Name,Owner.Id FROM Account GROUP BY Owner.Name,Owner.Id];
		for(AggregateResult owner : owners) {
			options.add(new SelectOption((String)owner.get('Id'),(String)owner.get('Name')));
		}
        return options;
	}
	public Integer getPageNumber() {
		return this.PageNumber;
	}
	
	public Integer getTotalPageNumber()	{
		if (this.totalPageNumber == 0 && this.totalAccounts !=null) {
			this.totalPageNumber = this.totalAccounts.size() / this.pageSize;
			Integer mod = this.totalAccounts.size() - (this.totalPageNumber * this.pageSize);
			if (mod > 0) {
				this.totalPageNumber++;
			}
		}
		return this.totalPageNumber;
	}
	
	public PageReference nextBtnClick() {
		System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
	    System.debug('2.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
	    System.debug('3.Number of script statements used so far : ' +  Limits.getDmlStatements());
	    System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
	    System.debug('5.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
		//this.seoPageWebsites = this.getSeoWebsitesList(this.PageNumber++);
		System.debug('NEXT Old PageNumber:'+this.PageNumber);
		this.PageNumber++;
		System.debug('NEXT new PageNumber:'+this.PageNumber);
		return null;	
	}
	
	public PageReference previousBtnClick() {
		System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
	    System.debug('2.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
	    System.debug('3.Number of script statements used so far : ' +  Limits.getDmlStatements());
	    System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
	    System.debug('5.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
		//this.seoPageWebsites = this.getSeoWebsitesList(this.PageNumber--);
		System.debug('PREVIOUS old PageNumber:'+this.PageNumber);
		this.PageNumber--;
		System.debug('PREVIOUS new PageNumber:'+this.PageNumber);
		return null;
	}
	
	public Boolean getPreviousButtonEnabled() {
		return !(this.pageNumber > 1);
	}
	public Boolean getNextButtonDisabled() {
		if (this.totalAccounts == null) {
			return true;
		} else {
			return ((this.pageNumber * this.pageSize) >= this.totalAccounts.size());
		}
	}
	
	public PageReference updateAccOwnerList() {
		this.PageNumber = 1;
		this.totalPageNumber = 0;
		try {
			this.totalAccounts = [SELECT Id,Name FROM Account WHERE OwnerID=:this.newAccOwner LIMIT 30];			
		} catch(Exception e) { }
		return null;	
	}
	public static testMethod void testaccountDisplayGrid() {
		Test.startTest();
		
		accountDisplayGrid acc = new accountDisplayGrid();
		acc.getuserAccount();
		acc.getAccOwnerList();
		acc.getNextButtonDisabled();
		acc.getPreviousButtonEnabled();
		acc.getTotalPageNumber();
		acc.getuserAccount();
		acc.nextBtnClick();
		acc.previousBtnClick();
		
		Test.stopTest();
	}
}