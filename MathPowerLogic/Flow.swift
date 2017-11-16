import Foundation

protocol Router {
    associatedtype Calculation
    associatedtype Answer
    
    func routeTo(calculation: Calculation, callBack: @escaping (Answer) -> Void)
    
}

class Flow<R: Router, Calculation: Hashable, Answer> where Calculation == R.Calculation, Answer == R.Answer {
    private let router: R
    private let calculations: [Calculation]
    private var answers: [Calculation: Answer] = [:]
    
    init(router: R, calculations: [Calculation]) {
        self.router = router
        self.calculations = calculations
    }
    
    func start() {
        if let firstCalculation = calculations.first {
            router.routeTo(calculation: firstCalculation, callBack: nextCallback(from: firstCalculation))
                           
        }
    }
    
    private func nextCallback(from calculation: Calculation) -> (Answer) -> Void {
        return { [weak self] in
            self?.handleCallback(calculation, $0)
        }
    }
    
    private func handleCallback(_ calculation: Calculation, _ answer: Answer) {
        guard let currentIndex = calculations.index(of: calculation) else {
            fatalError("Didn't found calculation in array")
        }
        let nextIndex = currentIndex + 1
        if nextIndex < calculations.count {
            router.routeTo(calculation: calculations[nextIndex], callBack: nextCallback(from: calculations[nextIndex]))
        }
    }
}
