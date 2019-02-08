public class CasesExtension {
	public Account_Product__c myproduct{get;set;}

	//The custom class support setup init value for standard page new case which call from acount products	
	public CasesExtension(ApexPages.StandardSetController stdController){
		String productId = apexpages.currentpage().getparameters().get('id') ;

		this.myproduct = [SELECT Id, Name , Account__r.Name, Account__c FROM Account_Product__c WHERE Id = :productid LIMIT 1];
		system.debug('CasesExtension :: /a0K/e?CF00N6F00000H4XpE=' + myProduct.Name + '&CF00N6F00000H4XpE_lkid=' + myProduct.Account__c + '&retURL=%2F' + + myProduct.Account__c + '&CF00N90000001tTi3=' + + myProduct.Account__r.Name);
	}

}