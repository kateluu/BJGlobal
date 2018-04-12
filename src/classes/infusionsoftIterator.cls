global class infusionsoftIterator implements iterable<Account> {
  global Iterator<Account> Iterator(){
    return new infusionsoftIterable();
  }
  
  public static testMethod void testinfusionsoftIterator() {
        Test.startTest();
        Account account = new Account();
		account.Name = 'Test Account';
		account.Company__c = 'SponsoredLinX';
		account.username__c = 'test@test.com';
		account.password__c = 'test';
		insert account;
        
        infusionsoftIterator infusionsoftIterator = new infusionsoftIterator();
        Iterator<Account> aps = infusionsoftIterator.Iterator();
        Test.stopTest();
  }
}