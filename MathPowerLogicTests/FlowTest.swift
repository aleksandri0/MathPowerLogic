import Foundation
import XCTest
@testable import MathPowerLogic

class FlowTest: XCTestCase {
    
    let router = DummyRouter()
    
    func test_noCalculation_doesNotRouteToCalculation() {
        makeSUT().start()
        
        XCTAssertEqual(router.calculations.count, 0)
    }
    
    func test_oneCalculation_routesToCalculation() {
        makeSUT(calculations: ["1+1"]).start()
        
        XCTAssertEqual(router.calculations.count, 1)
    }
    
    func test_twoCalculationsAnswerFirst_routesFromFirstToSecondCalculation() {
        let sut = makeSUT(calculations: ["1+1", "2+2"])
        
        sut.start()
        router.answerCallback("A1")
        
        XCTAssertEqual(router.calculations, ["1+1", "2+2"])
    }
    
    func test_answerFirstAndSecond_routesFromSecondToThirdCalculation() {
        let sut = makeSUT(calculations: ["1+1", "2+2", "3+3"])
        
        sut.start()
        router.answerCallback("A1")
        router.answerCallback("A2")
        
        XCTAssertEqual(router.calculations, ["1+1", "2+2", "3+3"])
    }
    
    func test_twoCalculations_routesToFirstCalculation() {
        let sut = makeSUT(calculations: ["1+1", "2+2"])
        sut.start()
        
        XCTAssertEqual(router.calculations, ["1+1"])
    }
    
    func test_oneCalculation_doesNotRouteToUnexistentCalculation() {
        let sut = makeSUT(calculations: ["1+1"])
        sut.start()
        sut.start()
        
        XCTAssertEqual(router.calculations, ["1+1", "1+1"])
    }
    
    func makeSUT(calculations: [String] = []) -> Flow<DummyRouter, String, String> {
        return Flow<DummyRouter, String, String>(router: router, calculations: calculations)
    }
    
    class DummyRouter: Router {
        var calculations: [String] = []
        var answerCallback: (String) -> Void = { _ in }
        
        func routeTo(calculation: String, callBack: @escaping (String) -> Void) {
            calculations.append(calculation)
            self.answerCallback = callBack
        }
    }
    
}


