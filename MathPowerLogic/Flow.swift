import Foundation

protocol Router {
    associatedtype Calculation
    associatedtype Answer
    
    func routeTo(calculation: Calculation, callBack: @escaping (Answer) -> Void)
    
}

class Flow<R: Router, Calculation, Answer> where Calculation == R.Calculation, Answer == R.Answer {
    private let router: R
    private let calculations: [Calculation]
    
    init(router: R, calculations: [Calculation]) {
        self.router = router
        self.calculations = calculations
    }
    
    func start() {
        if let firstCalculation = calculations.first {
            router.routeTo(calculation: firstCalculation, callBack: { _ in
                self.router.routeTo(calculation: self.calculations[1], callBack: { _ in })
            })
        }
    }
}
