@isTest

private class CommwebTestClass {
	
	public static testMethod void CommwebPaymentTest() {
	    CommwebPayment commweb = new CommwebPayment();
	    commweb.setCommwebMerchTxnRef('inv1000222');
	    commweb.setOrderInfo('testaccount');
	    commweb.setAmount('10000');
	    commweb.setCardNum('1133445566778899');
	    commweb.setCardExp('1100');
	    //commweb.makePayment();
	    
	  }
	  
	  public static testMethod void CommwebPaymentTest2() {
	    CommwebPayment commweb = new CommwebPayment();
	    commweb.setCommwebMerchTxnRef('inv1000222');
	    commweb.setOrderInfo('testaccount');
	    commweb.setAmount('10000');
	    commweb.setCardNum('33333333333311111111223443');
	    commweb.setCardExp('');
	    //commweb.makePayment();
	    
	  }
	  
	  public static testMethod void CommwebReponseTest(){
	  	String resp_text = 'vpc_AVSRequestCode=Z&vpc_AVSResultCode=Unsupported&vpc_AcqAVSRespCode=Unsupported&vpc_AcqCSCRespCode=Unsupported&vpc_AcqResponseCode=51&vpc_Amount=1051&vpc_BatchNo=20150413&vpc_CSCResultCode=Unsupported&vpc_Card=VC&vpc_Command=pay&vpc_Locale=en_AU&vpc_MerchTxnRef=Inv1005&vpc_Merchant=TESTSPOSORMCC01&vpc_Message=Insufficient+Funds&vpc_OrderInfo=Account_Name&vpc_ReceiptNo=510310457197&vpc_TransactionNo=1100000041&vpc_TxnResponseCode=5&vpc_Version=1';
	  	CommwebResponse resp = new CommwebResponse();
	  	resp.loadResponse(resp_text);
	  	resp.setCommWebErrors('error');
	  	
	  	
	  }
	  
	  
}