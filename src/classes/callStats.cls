public with sharing class callStats {
	public Set<String> PhoneNumbers  {get; set;}
	
	public callStats(ApexPages.StandardController controller){
		PhoneNumbers = new Set<String>();
		String PhoneNumber = '';
		Account acc = (Account)controller.getRecord();	
		try{
			Contact[] contacts = [select Phone, MobilePhone from Contact where AccountID =: acc.Id];
			for(Contact contact : contacts){
				if(contact.Phone != null) {
					PhoneNumber = contact.Phone.deleteWhitespace().remove('(').remove(')');
					if(PhoneNumber.startsWith('61')){
						system.debug(PhoneNumber);
						PhoneNumber = PhoneNumber.replaceFirst('61', '0');
						system.debug(PhoneNumber);
						}
					if(PhoneNumber.startsWith('07')){
						String remove_prefix = PhoneNumber.replaceFirst('07', '');
						system.debug(remove_prefix);
						PhoneNumbers.add(remove_prefix);
					}
					if(PhoneNumber.length() == 8){
						String add_prefix = '07' + PhoneNumber;
						system.debug(add_prefix);
						PhoneNumbers.add(add_prefix);
					}
					PhoneNumbers.add(PhoneNumber);
				}
				if(contact.MobilePhone != null) {
					PhoneNumber = contact.MobilePhone.deleteWhitespace().remove('(').remove(')');
					if(PhoneNumber.startsWith('61')) {
						system.debug(PhoneNumber);
						PhoneNumber = PhoneNumber.replaceFirst('61', '0');
						system.debug(PhoneNumber);
						}
					if(PhoneNumber.startsWith('07')){
						String remove_prefix = PhoneNumber.replaceFirst('07', '');
						system.debug(remove_prefix);
						PhoneNumbers.add(remove_prefix);
					}
					if(PhoneNumber.length() == 8){
						String add_prefix = '07' + PhoneNumber;
						system.debug(add_prefix);
						PhoneNumbers.add(add_prefix);
					}
					PhoneNumbers.add(PhoneNumber);
				}
			}
		}
		catch(Exception e){
			system.debug(e.getMessage());
		}
		
		system.debug(PhoneNumbers);
	}

}