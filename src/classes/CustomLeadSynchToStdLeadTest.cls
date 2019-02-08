@isTest
private class CustomLeadSynchToStdLeadTest
{
	@isTest
	static void testPositiveCase()
	{
		// new account
		//create account
		Company__c company = new Company__c();
        company.Name                = 'SponsoredLinX';
        company.Business_Name__c    = 'SponsoredLinX';
        company.Website__c          = 'www.sponsoredlinx.com';
        company.CurrencyIsoCode     = 'AUD';
        insert company;
        
        Account itemAcc = new Account(Name ='TestAccount1', username__c='TestAccount1', password__c='TestAccount1', CurrencyIsoCode ='AUD', Phone='1300859600',BJB_Company__c = company.Id, Type = 'Employee');
        insert itemAcc;

		//create mew ;ead
		Lead__c myLead = new Lead__c(Email__c ='tet@gmail.com', Assigned_To__c = itemAcc.Id, Assigned_To_Id__c= itemAcc.Id, Lead_Status__c = 'New');
		insert myLead;

		Lead stdlead = new Lead(LastName ='Test', Company = company.Id, Email ='tet@gmail.com',  Status = 'New', Assigned_To__c=null);
		insert stdLead;

		myLead.Lead_Status__c = 'Sale';
		update myLead;

		stdlead = [SELECT Status,Assigned_To__c FROM LEAD WHERE Email = 'tet@gmail.com'];
		
		system.assertEquals(stdlead.Status,myLead.Lead_Status__c );
		system.assertEquals(stdlead.Assigned_To__c,myLead.Assigned_To_Id__c );

	}
}