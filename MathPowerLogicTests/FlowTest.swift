import Foundation
import XCTest
@testable import MathPowerLogic

class FlowTest: XCTestCase {
    
    func test_noCalculation_doesNotRouteToCalculation() {
        let router = DummyRouter()
        let sut = Flow<DummyRouter, String, String>(router: router, calculations: [])
        sut.start()
        
        XCTAssertEqual(router.calculations.count, 0)
    }
    
    func test_oneCalculation_routesToCalculation() {
        let router = DummyRouter()
        let sut = Flow<DummyRouter, String, String>(router: router, calculations: ["1+1"])
        sut.start()
        
        XCTAssertEqual(router.calculations.count, 1)
    }
    
    func test_twoCalculations_routesFromFirstToSecondCalculation() {
        let router = DummyRouter()
        let sut = Flow<DummyRouter, String, String>(router: router, calculations: ["1+1", "2+2"])
        sut.start()
        router.answerCallback("A1")
        
        XCTAssertEqual(router.calculations.count, 2)
        XCTAssertEqual(router.calculations, ["1+1", "2+2"])
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


