public with sharing class SingleInvoiceController {

	private final Xero_Invoice__c invoice;
	private final Account account;
	private final Contact contact;
	private final Company__c company;

	public SingleInvoiceController() {
		invoice = [SELECT Id, InvoiceID__c, InvoiceNumber__c, Date__c, DueDate__c, Account__c, Reference__c, LineAmountTypes__c, AmountCredited__c, AmountDue__c, AmountPaid__c, BrandingThemeID__c, Status__c, SubTotal__c, TotalTax__c, Total__c, Type__c, UpdatedDateUTC__c FROM Xero_Invoice__c WHERE Xero_Invoice__c.Id =: ApexPages.currentPage().getParameters().get('id')];
		account = [SELECT Id, Name, Company__c FROM Account WHERE Account.Unique_Id__c =: invoice.Reference__c];
		contact = [SELECT Id, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, Phone FROM Contact WHERE AccountId =: account.Id AND Title = 'Billing'];
		company = [SELECT Id, Address__c, Branding_Theme_Id__c, Business_Name__c, Email__c, Logo_Code__c, Phone__c FROM Company__c WHERE Company__c.Branding_Theme_Id__c =: invoice.BrandingThemeID__c];
	}

	public Xero_Invoice__c getInvoice() {
		return invoice;
	}

	public Account getAccount() {
		return account;
	}

	public Contact getContact() {
		return contact;
	}

	public Company__c getCompany() {
		return company;
	}

	public PageReference save() {
		update invoice;
		return null;
	}

}