import Testing

@testable import Counter

@MainActor
struct CounterModelTests {
  @Test func startsAtZero() {
    let model = CounterModel()
    #expect(model.value == 0)
  }

  @Test func incrementAddsOne() {
    var model = CounterModel()
    model.increment()
    #expect(model.value == 1)
  }
}
