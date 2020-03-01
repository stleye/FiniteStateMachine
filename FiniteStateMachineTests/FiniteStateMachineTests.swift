//
//  FiniteStateMachineTests.swift
//  FiniteStateMachineTests
//
//  Created by Sebastian Tleye on 01/03/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import XCTest
@testable import FiniteStateMachine

class FiniteStateMachineTests: XCTestCase {

    lazy var initialState1 = FiniteStateMachine.State("Initial")
    lazy var initialState2 = FiniteStateMachine.State("Initial")
    lazy var finalState = FiniteStateMachine.State("Final")
    lazy var stateWithCondition = FiniteStateMachine.State("State With Condition", condition: { _ in true })
    lazy var composedState = FiniteStateMachine.State(state1: initialState1, state2: finalState)
    lazy var transition1 = FiniteStateMachine.Transition(from: initialState1,
                                                         to: finalState,
                                                         through: "a")
    lazy var transition2 = FiniteStateMachine.Transition(from: initialState1,
                                                         to: finalState,
                                                         through: "b",
                                                         condition: { fsm in return true },
                                                         action: { fsm in })
    lazy var smallFSM1 = FiniteStateMachine(initialState: FiniteStateMachine.State("1"),
                                            transitions: [FiniteStateMachine.Transition("1", "2", "a"),
                                                          FiniteStateMachine.Transition("2", "3", "d"),
                                                          FiniteStateMachine.Transition("3", "1", "c")],
                                            variables: [FiniteStateMachine.Variable(name: "counter", value: 3)])
    lazy var smallFSM2 = FiniteStateMachine(initialState: FiniteStateMachine.State("1'"),
                                            transitions: [FiniteStateMachine.Transition("1'", "2'", "b"),
                                                          FiniteStateMachine.Transition("2'", "3'", "a"),
                                                          FiniteStateMachine.Transition("3'", "1'", "c")],
                                            variables: [FiniteStateMachine.Variable(name: "counter", value: 0),
                                                        FiniteStateMachine.Variable(name: "greetings", value: "hello")])

    override func setUp() {
    }

    override func tearDown() {
    }

    func testFSMStateIsCorrectlyCreated() {
        XCTAssertNil(initialState1.condition)
        XCTAssertEqual(initialState1.name, "Initial")
        XCTAssertNotNil(stateWithCondition.condition)
        XCTAssertEqual(stateWithCondition.name, "State With Condition")
        XCTAssertNotNil(composedState.condition)
        XCTAssertEqual(composedState.name, "\(initialState1.name), \(finalState.name)")
    }

    func testFSMStateShouldBeEqualToAnotherStateWithSameName() {
        XCTAssertEqual(initialState1, initialState2)
        XCTAssertNotEqual(initialState1, finalState)
    }

    func testFSMTransitionIsCorrectlyCreated() {
        XCTAssertNotNil(transition1.condition)
        XCTAssertEqual(transition1.origin, initialState1)
        XCTAssertEqual(transition1.destination, finalState)
        XCTAssertNotNil(transition2.condition)
        XCTAssertEqual(transition2.origin, initialState1)
        XCTAssertEqual(transition2.destination, finalState)
        XCTAssertNotNil(transition2.action)
    }

    func testFSMCorrectlyCreated() {
        XCTAssertEqual(smallFSM1.initialState.name, "1")
        XCTAssertEqual(smallFSM1.currentState, smallFSM1.initialState)
        XCTAssertFalse(smallFSM1.variables.isEmpty)
        XCTAssertNotNil(smallFSM1.valueForVariable("counter"))
        XCTAssertEqual(smallFSM1.valueForVariable("counter") as! Int, 3)
    }

    func testFSMTracesAreCorrect() {
        //Valid traces are -> a, d, c, a, d, c...
        XCTAssertEqual(smallFSM1.currentState.name, "1")
        smallFSM1.receive(input: "a")
        XCTAssertEqual(smallFSM1.currentState.name, "2")
        smallFSM1.receive(input: "a")
        XCTAssertEqual(smallFSM1.currentState.name, "2")
        smallFSM1.receive(input: "b")
        XCTAssertEqual(smallFSM1.currentState.name, "2")
        smallFSM1.receive(input: "c")
        XCTAssertEqual(smallFSM1.currentState.name, "2")
        smallFSM1.receive(input: "d")
        XCTAssertEqual(smallFSM1.currentState.name, "3")
        smallFSM1.receive(input: "a")
        XCTAssertEqual(smallFSM1.currentState.name, "3")
        smallFSM1.receive(input: "b")
        XCTAssertEqual(smallFSM1.currentState.name, "3")
        smallFSM1.receive(input: "c")
        XCTAssertEqual(smallFSM1.currentState.name, "1")
    }

    func testComposeInParallelIsCorrectlyCreated() {
        let composed = smallFSM1.composeInParallel(with: smallFSM2)
        XCTAssertEqual(composed.initialState, FiniteStateMachine.State(state1: smallFSM1.initialState, state2: smallFSM2.initialState))
        XCTAssertEqual(composed.currentState, composed.initialState)
        XCTAssertEqual(composed.variables.count, 2)
        XCTAssertEqual(composed.valueForVariable("counter") as! Int, 3)
        XCTAssertEqual(composed.valueForVariable("greetings") as! String, "hello")
    }

    func testComposedFSMTracesAreCorrect() {
        let composed = smallFSM1.composeInParallel(with: smallFSM2)
        XCTAssertEqual(composed.currentState.name, "1, 1'")
        composed.receive(input: "a")
        XCTAssertEqual(composed.currentState.name, "1, 1'")
        composed.receive(input: "c")
        XCTAssertEqual(composed.currentState.name, "1, 1'")
        composed.receive(input: "b")
        XCTAssertEqual(composed.currentState.name, "1, 2'")
        composed.receive(input: "b")
        XCTAssertEqual(composed.currentState.name, "1, 2'")
        composed.receive(input: "a")
        XCTAssertEqual(composed.currentState.name, "2, 3'")
        composed.receive(input: "b")
        XCTAssertEqual(composed.currentState.name, "2, 3'")
        composed.receive(input: "d")
        XCTAssertEqual(composed.currentState.name, "3, 3'")
        composed.receive(input: "c")
        XCTAssertEqual(composed.currentState.name, "1, 1'")
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
