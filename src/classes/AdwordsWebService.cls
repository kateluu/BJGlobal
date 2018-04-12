global class AdwordsWebService {
	public class InvalidParamsException extends Exception {}

	global class WebServiceResultAdwordsProduct {
		WebService Boolean status;
		WebService List<Account_Product__c> result;
		WebService String message;
	}


	WebService static WebServiceResultAdwordsProduct getActiveAdwordsProducts() {
		WebServiceResultAdwordsProduct return_result = new WebServiceResultAdwordsProduct();

		List<Account_Product__c> account_products =
			[
				SELECT
					Name,
					Description__c,
					Adwords_ID__c,
					Adwords_Email__c,
					Product_Status__c,
					Product_Package__c,
					Product_Category__c,
					SLX_Product__c,
					Recurring_Frequency__c,
					Recurring_Period__c,
					Reseller__r.Name,
					Reseller__r.Template_Name__c,
					Account__r.Name
				FROM Account_Product__c
				WHERE Product_Status__c = 'Active'
				AND Name LIKE '%Adwords%' AND (NOT Name LIKE '%Setup%')
				AND (Adwords_ID__c != '' AND Adwords_ID__c != NULL)
				AND CreatedDate < LAST_WEEK
			];

		if(account_products.size() > 0) {
			return_result.status = true;
			return_result.result = account_products;
			return_result.message = 'Successfully fetch active AdWords products';
			System.debug('Account Products: ' + account_products);
		}
		else {
			return_result.status = false;
			return_result.result = null;
			return_result.message = 'There is no active AdWords product';
		}

		return return_result;
	}

	static testMethod void getActiveAdwordsProductsTest() {
		AdwordsWebService.getActiveAdwordsProducts();
	}

}