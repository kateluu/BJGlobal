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
private class TestChargebacks {

    static testMethod void myUnitTest() {
        Account testAc = new Account();
      	testAc.Name = 'testacc';
      	insert testAc;
    	Test.startTest();
    	ApexPages.standardController controller = new ApexPages.standardController(testAc);
      	Chargebacks testClass = new Chargebacks(controller);
      	testClass.invoiceNumber = '1';
      	
      	Invoice__c testInv = new Invoice__c();
    	testInv.Invoice_Number__c = '1';
    	testInv.Amount_Due__c = 0;
    	testInv.Amount_Paid__c = 50;
    	testInv.Amount_Refunded__c = 0;
    	testInv.Invoice_Total__c = 50;
    	testInv.Status__c = 'PAID';
    	testInv.Account__c=testAc.Id;
    	testInv.Checked__c = true;
    	insert testInv;
    	
      	Payment__c payment  = new Payment__c();
      	list<Invoice__c> invoices = new list<Invoice__c>();
      	invoices.add(testInv);
      	
      	
      	testClass.PageLoad();
      	testClass.setinvoices(invoices);
      	testClass.getinvoices();
      	
      	testClass.ChangeInvoiceNumber();
      	testClass.getinputPayment();
      	testClass.setinputPayment(payment);
      	testClass.getinputPaymentPartial();
      	testClass.setinputPaymentPartial(payment);
      	
      	
      	List<SelectOption> testOp = new List<SelectOption>();
      	testOp = testClass.getInvoiceNumbers();
      	testClass.SingleChargeback();
      	
      	testClass.returnToAccount();
      	Test.stopTest();
    }
}