import Foundation
import XCTest
@testable import MathPowerLogic

class FlowTest: XCTestCase {
    
    let router = DummyRouter()
    
    func test_noCalculation_doesNotRouteToCalculation() {
        makeReadyToStartSUT().start()
        
        XCTAssertEqual(router.calculations.count, 0)
    }
    
    func test_oneCalculation_routesToCalculation() {
        makeReadyToStartSUT(calculations: ["1+1"]).start()
        
        XCTAssertEqual(router.calculations.count, 1)
    }
    
    func test_twoCalculationsAnswerFirst_routesFromFirstToSecondCalculation() {
        let sut = makeReadyToStartSUT(calculations: ["1+1", "2+2"])
        
        sut.start()
        router.answerCallback("A1")
        
        XCTAssertEqual(router.calculations, ["1+1", "2+2"])
    }
    
    func test_answerFirstAndSecond_routesFromSecondToThirdCalculation() {
        let sut = makeReadyToStartSUT(calculations: ["1+1", "2+2", "3+3"])
        
        sut.start()
        router.answerCallback("A1")
        router.answerCallback("A2")
        
        XCTAssertEqual(router.calculations, ["1+1", "2+2", "3+3"])
    }
    
    func test_twoCalculations_routesToFirstCalculation() {
        let sut = makeReadyToStartSUT(calculations: ["1+1", "2+2"])
        sut.start()
        
        XCTAssertEqual(router.calculations, ["1+1"])
    }
    
    func test_oneCalculation_doesNotRouteToUnexistentCalculation() {
        let sut = makeReadyToStartSUT(calculations: ["1+1"])
        sut.start()
        sut.start()
        
        XCTAssertEqual(router.calculations, ["1+1", "1+1"])
    }
    
    func test_noCalculations_doesNotRouteToResult() {
        let sut = makeReadyToStartSUT(calculations: [])
        sut.start()
        
        XCTAssertNil(router.result)
    }
    
    func test_oneCalculationAndAnswerFirst_routesToResult() {
        let sut = makeReadyToStartSUT(calculations: ["1+1"])
        sut.start()
        router.answerCallback("A1")
        
        guard let result = router.result else {
            XCTFail("Expected a result")
            return
        }
        
        XCTAssertEqual(result, ["1+1": "A1"])
    }

    func test_twoCalculationsAndAnswerFirst_doesNotRouteToResult() {
        let sut = makeReadyToStartSUT(calculations: ["1+1", "2+2"])
        sut.start()
        router.answerCallback("A1")

        XCTAssertNil(router.result)

    }

    func test_twoCalculationsAndAnswerFirstAndSecond_routesToResult() {
        let sut = makeReadyToStartSUT(calculations: ["1+1", "2+2"])
        sut.start()
        router.answerCallback("A1")
        router.answerCallback("A2")
        
        guard let result = router.result else {
            XCTFail("Expected a result")
            return
        }
        
        XCTAssertEqual(result, ["1+1": "A1", "2+2": "A2"])
    }
    
    func test_difficultySelected_isRouted() {
        let difficulty = Difficulty.easy
        let sut = makeReadyToStartSUT(calculations: ["1+1"], difficulty)
        sut.start()
        XCTAssertEqual(router.difficulty, difficulty)
    }
    
    func test_difficultySelected_gameNotStarted_calculationsArrayIsEmpty() {
        let sut = makeSUT()
        sut.selectDifficulty()
        router.difficultyCallback(.easy)
        
        XCTAssertEqual(router.calculations.count, 0)
    }
    
    func test_difficultySelected_gameNotStarted_ResultAreNil() {
        let sut = makeSUT()
        sut.selectDifficulty()
        router.difficultyCallback(.easy)
        
        XCTAssertNil(router.result)
    }
    
    func test_gameEndedAndRestartedToDifficultyScreen_ContentIsCleared() {
        let firstDifficulty = Difficulty.easy
        let firstCalculations = ["1+1"]
        let sut = makeReadyToStartSUT(calculations: firstCalculations, firstDifficulty)
        sut.start()
        router.answerCallback("A1")
        router.restartCallback()
        
        XCTAssertNil(router.difficulty)
        XCTAssertNil(router.result)
        XCTAssertEqual(router.calculations.count, 0)
    }
    
    func makeSUT(_ calculations: [Difficulty: [String]] = [:]) -> Flow<DummyRouter, String, String> {
        return Flow<DummyRouter, String, String>(router, calculations)
    }
    
    func makeReadyToStartSUT(calculations: [String] = [], _ difficulty: Difficulty = .easy) -> Flow<DummyRouter, String, String> {
        let sut = makeSUT([difficulty: calculations])
        sut.selectDifficulty()
        router.difficultyCallback(difficulty)
        
        return sut
    }
    
    class DummyRouter: Router {

        var calculations: [String] = []
        var answerCallback: (String) -> Void = { _ in }
        var restartCallback: () -> Void = { }
        var difficultyCallback: (Difficulty) -> Void = { _ in }
        var result: [String: String]?
        var difficulty: Difficulty?
        
        func routeToDifficulty(callBack: @escaping (Difficulty) -> Void) {
            difficulty = nil
            calculations = []
            result = nil
            self.difficultyCallback = callBack
        }
        
        func routeTo(calculation: String, difficulty: Difficulty, callBack: @escaping (String) -> Void) {
            calculations.append(calculation)
            self.answerCallback = callBack
            self.difficulty = difficulty
        }

        func routeTo(result: [String: String]?, restartCallBack: @escaping () -> Void) {
            self.result = result
            self.restartCallback = restartCallBack
        }
    }
    
}


