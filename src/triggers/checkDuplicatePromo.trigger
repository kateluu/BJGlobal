trigger checkDuplicatePromo on Promocode__c (before insert) {
	for (Integer i = 0; i < Trigger.new.size(); i++) {
		Promocode__c newPromo = Trigger.new[i];
		Promocode__c[] promocode = [SELECT Name FROM Promocode__c WHERE Name=:newPromo.Name];
		if (promocode.size() > 0) {
          newPromo.Name.addError('This promocode already exists in the system');
      } 		
	}	
}