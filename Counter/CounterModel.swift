struct CounterModel {
  private(set) var value = 0

  mutating func increment() {
    value += 1
  }
}
