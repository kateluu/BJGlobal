public class CheckAmex {	
	public static boolean isAmex(String card) {
		card = card.replace('-','');
		
		boolean ret = true;
		//prefix: 34 or 37
		ret = ret && (checkPrefix(card, '34') || checkPrefix(card, '37'));
		//length: 15
		//ret = ret && card.length()==15;

		return ret;
	}
	
	private static Boolean checkPrefix(String CardNumber, String Prefix)
	{
		return CardNumber.startsWith(Prefix);
	}
	
	static testMethod void test() 
    {
		system.assertEquals(true, CheckAmex.isAmex('3400-0000-0000-009'));
    } 	
		
	
}