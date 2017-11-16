import Foundation

protocol Router {
    associatedtype Calculation: Hashable
    associatedtype Answer
    
    func routeTo(calculation: Calculation, callBack: @escaping (Answer) -> Void)
    func routeTo(result: [Calculation: Answer]?)

}

class Flow<R: Router, Calculation, Answer> where Calculation == R.Calculation, Answer == R.Answer {
    private let router: R
    private let calculations: [Calculation]
    private var answers: [Calculation: Answer] = [:]
    
    init(router: R, calculations: [Calculation]) {
        self.router = router
        self.calculations = calculations
    }
    
    func start() {
        if let firstCalculation = calculations.first {
            router.routeTo(calculation: firstCalculation, callBack: callback(for: firstCalculation))
        } else {
            router.routeTo(result: nil)
        }
    }
    
    private func callback(for calculation: Calculation) -> (Answer) -> Void {
        return { [weak self] in
            self?.handleCallback(calculation, $0)
        }
    }
    
    private func handleCallback(_ calculation: Calculation, _ answer: Answer) {
        guard let currentIndex = calculations.index(of: calculation) else {
            fatalError("Didn't found calculation in array")
        }
        answers[calculation] = answer
        let nextIndex = currentIndex + 1
        if nextIndex < calculations.count {
            router.routeTo(calculation: calculations[nextIndex], callBack: callback(for: calculations[nextIndex]))
        } else {
            router.routeTo(result: answers)
        }
    }
}
