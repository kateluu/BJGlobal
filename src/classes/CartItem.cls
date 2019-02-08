public class CartItem {

    public SLX_Product__c product { get; set; }
    //public String name { get; set; }
    public Integer qty { get; set; }
    public Decimal total { get; set; }
    public Decimal priceGross { get; set; }
    public Decimal discount { get; set; }
    public Decimal priceNet { get; set; }
    public CartItem setupItem { get; set; }
    public Boolean isGhost { get; set; } // Set to true if product should be displayed in checkout but not created as account_product, such as SEO Setup

    public CartItem(SLX_Product__c product) {
        this.product = product;

        this.qty = 1;
        this.discount = 0.00;
        this.priceGross = product.product_price__c;
        this.priceNet = product.product_price__c - discount;
        this.isGhost = product.Is_Ghost__c;
    }

    // Get the family of product for this cart item (refers to list in slx_product__c.Product_Family__c)
    public string getProductFamily(){
        return this.product.Product_Family__c;
    }

    // Get the type of product for this cart item (refers to list in sign_up__c.Product_Type__c)
    // This picklist is different to the one in slx_product__c.Product_Family__c, so we need to do some conversions
    public string getProductType(){
        // Start with the product family and then modify into product type        
        String productType = this.product.Product_Family__c;

        if ( productType == 'Adwords' ){
            productType = 'AdWords Management';
        } else if ( productType == 'Facebook' ){
            productType = 'Social Marketing';
        } else if ( productType == 'AdMob' ){
            productType = 'Admob Management';
        }else if ( productType == 'Web' ){
            productType = 'ConvertoPages';
        }

        return productType;
    }

    // Is this item chargable at the time of order. This includes setup products, and recurring products that are billed in advance.
    public boolean isChargeableAtOrder(){
        boolean chargeable = true;

        if (this.isGhost == true){
            // Ghost products, such as the SEO Setup product is not chargeable
            chargeable = false;
        } else {
            chargeable = ( this.product.recurring_period__c == null || this.product.recurring_period__c == 'N/A' || this.product.Billed_In_Advance__c == true );
        }

        return chargeable;
    }


    public Integer isPendingBillCircle(){
        Integer pending = 0;
        system.debug('this.product.Bill_Pending_Time__c = ' + this.product.Bill_Pending_Time__c);
        pending = ( this.product.Bill_Pending_Time__c == null)?0:Integer.valueOf(this.product.Bill_Pending_Time__c);
        return pending;
    }

    // Apply a promotion to discount this item
    public boolean applyPromotion(promotions__c promotion){
        this.discount = 0.00;

        // Create a lookup set of the promotion product ids
        set<string> promotionProductIds = new set<string>(); 
        For(Promotion_Product__c pp :promotion.Promotion_Products__r){ 
            promotionProductIds.add(pp.BJB_Product__c); 
        }

        // The promotion can be applied if this productid is in the promotion_products, or if there are NO promotion_products
        boolean applicable = (promotion.Promotion_Products__r.size() == 0 || promotionProductIds.contains(product.Id));

        if ( applicable ) {
            if (product.product_recurring__c != 'Yes' && promotion.Setup_Discount__c > 0) {
                // This is a recurring product, so only apply the management discount
                if ( promotion.Setup_Discount_Type__c == '%' ) {
                    this.discount = product.product_price__c * (promotion.Setup_Discount__c / 100);
                } else {
                    this.discount = promotion.Setup_Discount__c;
                }
            } else if (product.product_recurring__c == 'Yes' && promotion.Management_Discount__c > 0) {
                // This is a setup product, so only apply the setup discount
                if ( promotion.Management_Discount_Type__c == '%' ) {
                    this.discount = product.product_price__c * (promotion.Management_Discount__c / 100);
                } else {
                    this.discount = promotion.Management_Discount__c;
                }
            }
        }

        // Restrict to two decimals
        this.discount = this.discount.setScale(2);

        // Don't allow the discount to be more than the price
        if (discount > product.product_price__c) {
            this.discount = product.product_price__c;
        }

        // Recalculate the net price with the discount
        this.priceNet = product.product_price__c - discount;

        return applicable;
    }
}