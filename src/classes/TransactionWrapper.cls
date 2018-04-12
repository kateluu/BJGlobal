global class TransactionWrapper implements Comparable {
	
		public Transaction__c trans {get;set;}
				
		public TransactionWrapper(Transaction__c trans){
			this.trans = trans;
		}
		
		global Integer compareTo(Object compareTo) {
			TransactionWrapper compareToTrans = (TransactionWrapper)compareTo;
			Integer returnValue = 0;
			if(this.trans.Date__c > compareToTrans.trans.Date__c ) return 1;
			else if (this.trans.Date__c < compareToTrans.trans.Date__c ) return -1;
			return 0;
		}
}