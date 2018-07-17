@isTest
private class QuestionnaireControllerTest
{

	@testSetup	static void setup(){	
		Company__c company = new Company__c();
        company.Name                = 'SponsoredLinX';
        company.Business_Name__c    = 'SponsoredLinX';
        company.Website__c          = 'www.sponsoredlinx.com';
        company.CurrencyIsoCode     = 'AUD';
        insert company;
        Company__c company2 = new Company__c();
        company.Name                = 'GetMoreTraffice';
        company.Business_Name__c    = 'GetMoreTraffice';
        company.Website__c          = 'www.GetMoreTraffice.com';
        company.CurrencyIsoCode     = 'AUD';
        insert company2;

		Account acc = new Account();
		acc.name = 'acc1';
		acc.BJB_Company__c  = company2.Id;
		insert acc;
		
		
		SFDC_Projects__c p = new SFDC_Projects__c();
    	p.account__c = acc.id;
    	p.name = 'name';
    	p.Sold_by__c = 'ss';
    	p.Phone_Number__c = '123456789';
    	p.Email__c = 'fdas@jlkdfs.com';
    	insert p;
	}

	@isTest
	static void testSaveQuestionnaire()
	{
		QuestionnaireController ques = new QuestionnaireController();
		Account acc =[SELECT id FROM Account limit 1];
		SFDC_Projects__c p = [SELECT id FROM SFDC_Projects__c limit 1];
		ApexPages.currentPage().getParameters().put('accId', acc.id);
		ApexPages.currentPage().getParameters().put('projectId', p.id);
		ques.save();
		System.assertEquals(ques.step, '2', 'Error');

	}


}