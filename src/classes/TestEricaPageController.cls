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
private class TestEricaPageController {

    static testMethod void testEricaPage() {
        User teamleader = [select Id from User where UserRole.Name like '%Client Operations Manager%' and isActive = true limit 1];
        Mcc_Login__c mcc1 = new Mcc_Login__c(Name='cm1@mcc.sponsoredlinx.com', Adwords_Password__c = 'test', OwnerId=teamleader.Id);
        User teammember = [select Id from User where UserRole.Name like '%Team A Member%' and isActive = true limit 1];
        RoleUtils.getRoleSubordinateUsers(teamleader.Id);
        
        System.runAs(teamleader) {
        	EricaPageController controller = new EricaPageController();
        	controller.getMccList();
        	controller.selected_mcc = 'cm2@mcc.sponsoredlinx.com';
        	controller.updateEricaView();
        }
        System.runAs(teammember) {
        	Mcc_Login__c mcc2 = new Mcc_Login__c(Name='cm2@mcc.sponsoredlinx.com', Adwords_Password__c = 'test', OwnerId=teammember.Id);
        	system.debug(mcc2);
        	EricaPageController controller = new EricaPageController();
        	//controller.mcc = new List<Mcc_Login__c>{mcc1};
        }
    }
}