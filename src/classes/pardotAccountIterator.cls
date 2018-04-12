global class pardotAccountIterator implements iterable<Account> {
  global Iterator<Account> Iterator(){
    return new pardotAccountIterable();
  }
}