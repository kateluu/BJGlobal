global class batchXeroInvoiceCreateIterator implements Iterable<sfxero.XeroInvoice> {
	private String period = 'Today';

	public batchXeroInvoiceCreateIterator(String period) {
		this.period = period;
	}

	global Iterator<sfxero.XeroInvoice> Iterator() {
		return new batchXeroInvoiceCreateIterable(this.period);
	}
}