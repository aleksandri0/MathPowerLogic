import Foundation

public protocol Router {
    associatedtype Calculation: Hashable
    associatedtype Difficulty: Hashable
    associatedtype Answer

    func routeToDifficulties(_ difficulties: [Difficulty], callback: @escaping (Difficulty) -> Void)
    func routeToCalculation(_ calculation: Calculation, difficulty: Difficulty, callback: @escaping (Answer) -> Void)
    func routeToResult(_ result: [Calculation: Answer]?, restartCallback: @escaping () -> Void)
}
