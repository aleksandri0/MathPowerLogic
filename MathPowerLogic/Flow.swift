import Foundation

class Flow<R: Router, Calculation, Answer, Difficulty> where Calculation == R.Calculation, Answer == R.Answer, Difficulty == R.Difficulty {
    private let router: R
    private let calculations: [Difficulty: [Calculation]]
    private var answers: [Calculation: Answer] = [:]
    private var difficulty: Difficulty?
    
    init(_ router: R, _ calculations: [Difficulty: [Calculation]]) {
        self.router = router
        self.calculations = calculations
    }

    var difficulties: [Difficulty] {
        return calculations.map { $0.0 }
    }

    func selectDifficulty() {
        router.routeToDifficulties(difficulties) { [weak self] difficulty in
            self?.difficulty = difficulty
        }
    }
    
    func start() {
        guard let difficulty = difficulty else {
            fatalError("Difficulty is not set")
        }
        
        if let calculations = calculations[difficulty], let firstCalculation = calculations.first {
            router.routeToCalculation(firstCalculation, difficulty: difficulty, callback: calculationCallback(for: firstCalculation))
        } else {
            router.routeToResult(nil, restartCallback: restartCallback())
        }
    }
    
    private func calculationCallback(for calculation: Calculation) -> (Answer) -> Void {
        return { [weak self] in
            self?.handleCalculationCallback(calculation, $0)
        }
    }
    
    private func restartCallback() -> () -> Void {
        return { [weak self] in
            self?.selectDifficulty()
        }
    }
    
    private func handleCalculationCallback(_ calculation: Calculation, _ answer: Answer) {
        guard let difficulty = difficulty else {
            fatalError("Difficulty is not set")
        }
        
        guard let calculations = calculations[difficulty], let currentIndex = calculations.index(of: calculation) else {
            fatalError("Didn't find calculation in array")
        }
        answers[calculation] = answer
        let nextIndex = currentIndex + 1
        if nextIndex < calculations.count {
            router.routeToCalculation(calculations[nextIndex], difficulty: difficulty, callback: calculationCallback(for: calculations[nextIndex]))
        } else {
            router.routeToResult(answers, restartCallback: restartCallback())
        }
    }
}
