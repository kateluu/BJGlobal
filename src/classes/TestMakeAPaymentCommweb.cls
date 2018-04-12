/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestMakeAPaymentCommweb {

    static testMethod void myUnitTest1() {
        // 
        Account testAc = new Account();
      	testAc.Name = 'testacc';
      	testAc.Name_On_Card__c = 'test';
      	testAc.Card_Number__c = '1234123412341234';
      	testAc.Card_Month_Expiry__c = '5';
      	testAc.Card_Year_Expiry__c = '1010';
      	testAc.Card_CVN__c = '123';
      	insert testAc;
      	
      	Account_Product__c testAccPr = new Account_Product__c();
      	testAccPr.Payment_Option__c = 'Commweb';
      	testAccPr.Name_On_Card__c = 'test';
      	testAccPr.Card_Number__c = '1234123412341234';
      	testAccPr.Card_Month_Expiry__c = '5';
      	testAccPr.Card_Year_Expiry__c = '1010';
      	testAccPr.Card_CVN__c = '123';
      	testAccPr.Product_Price__c = 20;
      	insert testAccPr;

      	Invoice__c testInv = new Invoice__c();
      	testInv.Invoice_Number__c = '1';
      	testInv.Amount_Due__c = 50;
      	testInv.Status__c = 'PARTIALLY PAID';
      	testInv.Account__c=testAc.Id;
      	testInv.Account_Product__c = testAccPr.Id;
      	testInv.Payment_Option__c = 'Commweb';
      	insert testInv;
      	
	    Invoice__c testInv2 = new Invoice__c();
      	testInv2.Invoice_Number__c = '2';
      	testInv2.Amount_Due__c = 50;
      	testInv2.Status__c = 'PARTIALLY PAID';
      	testInv2.Account__c=testAc.Id;
      	testInv2.Account_Product__c = testAccPr.Id;
      	testInv2.Payment_Option__c = 'Commweb';
      	insert testInv2;
      	
	    list<Invoice__c> listTestInv = new list<Invoice__c>();
      	listTestInv.add(testInv);
		listTestInv.add(testInv2);

      	Payment__c testPay = new Payment__c();
      	
      	Credit__c testCre = new Credit__c();
      	testCre.Amount__c = 100;
      	testCre.Credit_Used__c = 10;
      	testCre.Account_Product__c = testAccPr.Id;
    	testCre.Valid_From__c = date.today().addDays(-1);
      	insert testCre;
      
      	Contact testContact = new Contact();
      	testContact.AccountId = testAc.Id;
      	testContact.Title = 'Billing';
      	testContact.FirstName = 'test';
      	testContact.LastName = 'test';
      	insert testContact; 
      	
      	List<SelectOption> testSelectOptions = new List<SelectOption>();
      
      	ApexPages.standardController controller = new ApexPages.standardController(testAc);
      	MakeAPaymentCommweb testClass = new MakeAPaymentCommweb(controller);
      	testClass.getinvoiceItems();
      	testClass.PageLoad();
      	testClass.acc = testAc;
      	testClass.isTest = true;
      	testClass.generateErrors = true;
      
      
      	testClass.setinvioce(listTestInv);
      	testClass.Invoice = listTestInv;
      	listTestInv = testClass.getinvoice();
      
      	testClass.setcheckInvioce(listTestInv);
      	testClass.checkInvoice = listTestInv;
      	listTestInv = testClass.getcheckInvoice();
      
      	testClass.setinputPayment(testPay);
      	testPay = testClass.getinputPayment();
      
      	testClass.setInvList(listTestInv);
        testClass.getInvList();
        testClass.getAllInvoiceTotal();
        testClass.getlistOfPayments();
       	testClass.ChangeInvoiceNumber();
      	testClass.ChangePaymentType();
        try{
        	testClass.getUnpaidInvoiceTotal();
        	testClass.paymentAmount = 0;
      		testClass.MakeAPayment();
	      	testClass.paymentAmount = 20;
	      	testClass.MakeAPayment();
	      	testClass.getPaymentTypes();
	      	testClass.getInvoiceNumbers();
	      	
        } catch (Exception E) {}
        testClass.updatePaymentDate();
        testClass.getInvoiceNumbers();
        testClass.getPaymentTypes();
        testClass.returnToAccount();
    }
    
}