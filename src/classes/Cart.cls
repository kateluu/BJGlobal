public class Cart {
//    public enum paymentTypes {CREDIT_CARD, DIRECT_DEBIT}
    
    public String companyName;

    // Format for storing cookie data. We only want to store the data that the user is allowed to manipulate, not the other properties of this class.
    public class cartPackageData {
        public List<String> productIds = new List<String>();
        public String promocode;
        public String productType;
        public List<cartPackageData> addons = new List<cartPackageData>();
        public DateTime addTime;
    }

    public cartPackageData myPackageData = new cartPackageData();

    public class cartException extends Exception {}

	public Cart(String forCompanyName) {
        // companyName must match the name in SLX_Product__c.company_name__c
        companyName = forCompanyName;
	}

	// Generate the cookie string to store this cart
    public String getCookieJSON(){
        return JSON.serialize(this.myPackageData);
    }

	// Load this cart from a cookie string
    public void setCookieJSON(String cartSerialized){
        this.myPackageData = (cartPackageData) JSON.deserialize(cartSerialized, cartPackageData.class);

        // Prevent null values
        if (this.myPackageData.productIds == null){
	        this.myPackageData.productIds = new List<String>();
	    }

        if (this.myPackageData.addons == null){
	        this.myPackageData.addons = new List<cartPackageData>();
	    }
    }

    // Set the primary product in the cart
	public void setPackage(List<String> addProductIds){
        // We currently only allow one primary package, so we'll first remove any existing package/promocode/addons
        this.clear();

        if (addProductIds != null && addProductIds.size() > 0) {
            Map<Id, SLX_Product__c> productsMap = new Map<Id, SLX_Product__c>([SELECT Id, Name, product_price__c, product_recurring__c, recurring_period__c, company_name__c, Product_Family__c FROM SLX_Product__c WHERE IsActive__c = true AND company_name__c = :companyName AND Id IN :addProductIds]);

            // We must loop through the Ids, not the SOQL results because there's situations where we need two of the same product.
            for ( Id packageProductId : addProductIds ) {
                SLX_Product__c product = productsMap.get(packageProductId);

                if (product == null){
                    throw new cartException('Product ' + packageProductId + ' does not exist for company ' + companyName );
                }

                this.myPackageData.productIds.add(product.Id);

                // Add the product type. This helps us determine which addons to use
                if (product.Product_Family__c != null && product.Product_Family__c != ''){
                    this.myPackageData.productType = product.Product_Family__c;
                }
            }

            // Store the addTime. This helps us debug duplicate signups
            this.myPackageData.addTime = DateTime.now();
        }
	}

    // Add an addon product to the cart
	public void addon(List<String> addProductIds, String promocode){
		cartPackageData addonPackageData = new cartPackageData();

        if (addProductIds != null && addProductIds.size() > 0) {
            for ( SLX_Product__c product : [SELECT Id, Name, product_price__c, product_recurring__c, recurring_period__c, company_name__c, Product_Family__c FROM SLX_Product__c WHERE IsActive__c = true AND company_name__c = :companyName AND Id IN :addProductIds] ) {
                addonPackageData.productIds.add(product.Id);

                // Add the product type.
                if (product.Product_Family__c != null && product.Product_Family__c != ''){
                    addonPackageData.productType = product.Product_Family__c;
                }
            }

    		addonPackageData.promocode = promocode;
        }
        addonPackageData.addTime = DateTime.now();

        // If there is already an addon of this product type, we want to replace it
        for (Integer j = 0; j < this.myPackageData.addons.size(); j++){
            if (this.myPackageData.addons.get(j).productType == addonPackageData.productType){
                this.myPackageData.addons.remove(j);
            }
        }

        // Store the addTime. This helps us debug duplicate signups
		this.myPackageData.addons.add(addonPackageData);
	}

    // Remove all products and promocodes from the cart
    public void clear(){
        this.myPackageData = new cartPackageData();
    }

    // Set the promocode to use
    public void setPromocode(String promocode){

        // Treat empty string as null (no promocode)
        if (promocode == ''){
            promocode = null;
        }

        if (promocode != null) {
            // Check that this promocode exists
            List<Promotions__c> promotionsList = [SELECT Id FROM Promotions__c WHERE IsActive__c = true AND Id IN (SELECT promotions__c FROM promocode__c WHERE IsActive__c = true AND Name = :promocode)];

            // Make sure all the promocodes in the cookies were found in salesforce
            if (promotionsList.size() == 0 ){
                throw new cartException('Could not load promotion ' + promocode);
            }
        }

        this.myPackageData.promocode = promocode;
    }

    // Add a package from cartPackageData (could be either a primary or addon)
	public List<CartItem> getPackageFromPackageData(cartPackageData fromPackageData){
		List<CartItem> items = new List<CartItem>();

        // Load products
        if (fromPackageData.productIds != null){
	        Map<Id, SLX_Product__c> productsMap = new Map<Id, SLX_Product__c>([SELECT Id, Name, product_price__c, product_recurring__c, recurring_period__c, company_name__c, Product_Family__c, Is_Ghost__c, Billed_In_Advance__c FROM SLX_Product__c WHERE IsActive__c = true AND company_name__c = :companyName AND Id IN :fromPackageData.productIds]);

            Id previousProductId;
	        for ( Id packageProductId : fromPackageData.productIds ) {
	        	SLX_Product__c product = productsMap.get(packageProductId);

		        // Make sure all the products in the cookies were found in salesforce
				if (product == null){
					throw new cartException('Could not load product ' + packageProductId);
				}

				items.add(new CartItem(product));

                previousProductId = packageProductId;
	        }
		}

        // Load promocode
        if (fromPackageData.promocode != null){
        	List<Promotions__c> promotionsList = [SELECT Id, Setup_Discount__c, Management_Discount__c, Setup_Discount_Type__c, Management_Discount_Type__c, (SELECT BJB_Product__c, Promotions__c FROM Promotion_Products__r) FROM Promotions__c WHERE IsActive__c = true AND Id IN (SELECT promotions__c FROM promocode__c WHERE IsActive__c = true AND Name = :fromPackageData.promocode)];

			// Make sure all the promocodes in the cookies were found in salesforce
			if (promotionsList.size() == 0 ){
                // Commented out. We don't really want this to stop the cart from loading, it should be a non-fatal error, just don't apply the promo
//				throw new cartException('Could not load promotion ' + fromPackageData.promocode);
			}

            for ( Promotions__c  promotion : promotionsList ) {
                for (CartItem itemB : items){
                    itemB.applyPromotion(promotion);
                }
            }
    	}

    	return items;
	}
}