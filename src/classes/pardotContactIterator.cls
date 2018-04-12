global class pardotContactIterator implements iterable<Account> {
  global Iterator<Account> Iterator(){
    return new pardotContactIterable();
  }
}