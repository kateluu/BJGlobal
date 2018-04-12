global class ProductActiveDaysIterator implements Iterable<Account> {
	
	public ProductActiveDaysIterator() {
		
	}

	global Iterator<Account> Iterator() {
		return new ProductActiveDaysIterable();
		
	}
	
}