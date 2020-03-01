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
                                            variables: FiniteStateMachine.Variables(("counter", 3)))

    lazy var smallFSM2 = FiniteStateMachine(initialState: FiniteStateMachine.State("1'"),
                                            transitions: [FiniteStateMachine.Transition("1'", "2'", "b"),
                                                          FiniteStateMachine.Transition("2'", "3'", "a"),
                                                          FiniteStateMachine.Transition("3'", "1'", "c")],
                                            variables: FiniteStateMachine.Variables(("counter", 0),
                                                                                    ("greetings", "hello")))

    lazy var storeLimit = 5
    lazy var storeFSM = FiniteStateMachine(initialState: FiniteStateMachine.State("empty"),
                                           transitions: [
                                            FiniteStateMachine.Transition("empty", "full", "enter person",
                                                                          action: { fsm in fsm.variables.set(value: fsm.variables.intValueFor("counter") + 1, to: "counter") }),
                                            FiniteStateMachine.Transition("full", "full", "enter person",
                                                                          action: { fsm in fsm.variables.set(value: fsm.variables.intValueFor("counter") + 1, to: "counter") }),
                                            FiniteStateMachine.Transition("full", "full", "exit person",
                                                                          condition: { fsm in fsm.variables.intValueFor("counter") > 1 },
                                                                          action: { fsm in fsm.variables.set(value: fsm.variables.intValueFor("counter") - 1, to: "counter") }),
                                            FiniteStateMachine.Transition("full", "empty", "exit person",
                                                                          condition: { fsm in fsm.variables.intValueFor("counter") == 1 },
                                                                          action: { fsm in fsm.variables.set(value: fsm.variables.intValueFor("counter") - 1, to: "counter") })],
                                           variables: FiniteStateMachine.Variables(("counter", 0)))

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
        XCTAssertEqual(smallFSM1.variables.intValueFor("counter"), 3)
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
        XCTAssertEqual(composed.variables.intValueFor("counter"), 3)
        XCTAssertEqual(composed.variables.stringValueFor("greetings"), "hello")
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

    func testFSMConditionsAndActions() {
        XCTAssertEqual(storeFSM.variables.intValueFor("counter"), 0)
        XCTAssertEqual(storeFSM.currentState.name, "empty")
        storeFSM.receive(input: "enter person")
        XCTAssertEqual(storeFSM.variables.intValueFor("counter"), 1)
        XCTAssertEqual(storeFSM.currentState.name, "full")
        storeFSM.receive(input: "enter person")
        XCTAssertEqual(storeFSM.variables.intValueFor("counter"), 2)
        XCTAssertEqual(storeFSM.currentState.name, "full")
        storeFSM.receive(input: "enter person")
        XCTAssertEqual(storeFSM.variables.intValueFor("counter"), 3)
        XCTAssertEqual(storeFSM.currentState.name, "full")
        storeFSM.receive(input: "exit person")
        XCTAssertEqual(storeFSM.variables.intValueFor("counter"), 2)
        XCTAssertEqual(storeFSM.currentState.name, "full")
        storeFSM.receive(input: "exit person")
        XCTAssertEqual(storeFSM.variables.intValueFor("counter"), 1)
        XCTAssertEqual(storeFSM.currentState.name, "full")
        storeFSM.receive(input: "exit person")
        XCTAssertEqual(storeFSM.variables.intValueFor("counter"), 0)
        XCTAssertEqual(storeFSM.currentState.name, "empty")
        storeFSM.receive(input: "exit person")
        XCTAssertEqual(storeFSM.variables.intValueFor("counter"), 0)
        XCTAssertEqual(storeFSM.currentState.name, "empty")
        storeFSM.receive(input: "enter person")
        XCTAssertEqual(storeFSM.variables.intValueFor("counter"), 1)
        XCTAssertEqual(storeFSM.currentState.name, "full")
    }

    func testConditionalStates() {
        let alarmShouldBeTurnedOn = XCTestExpectation(description: "alarm turned on")
        let alarmShouldBeTurnedOff = XCTestExpectation(description: "alarm turned off")
        let alarmOff = FiniteStateMachine.State("alarm off", condition: { fsm in
            fsm.variables.intValueFor("counter") <= self.storeLimit
        })
        let alarmOn = FiniteStateMachine.State("alarm on", condition: { fsm in
            fsm.variables.intValueFor("counter") > self.storeLimit
        })
        let transition1 = FiniteStateMachine.Transition(from: alarmOff,
                                                        to: alarmOn,
                                                        through: "turn on alarm",
                                                        condition: { fsm in
            fsm.variables.intValueFor("counter") > self.storeLimit
        }, action: { _ in
            alarmShouldBeTurnedOn.fulfill()
        })
        let transition2 = FiniteStateMachine.Transition(from: alarmOn,
                                                        to: alarmOff,
                                                        through: "turn off alarm",
                                                        condition: { fsm in
            fsm.variables.intValueFor("counter") == self.storeLimit
        }, action: { _ in
            alarmShouldBeTurnedOff.fulfill()
        })
        let alarmFSM = FiniteStateMachine(initialState: alarmOff,
                                          transitions: [transition1, transition2],
                                          variables: FiniteStateMachine.Variables(("counter", 0)))

        let composed = storeFSM.composeInParallel(with: alarmFSM)
        composed.receive(input: "enter person")
        composed.receive(input: "enter person")
        composed.receive(input: "enter person")
        composed.receive(input: "enter person")
        composed.receive(input: "enter person")
        XCTAssertEqual(composed.variables.intValueFor("counter"), 5)
        XCTAssertEqual(composed.currentState.name, "full, alarm off")
        composed.receive(input: "enter person")
        XCTAssertEqual(composed.variables.intValueFor("counter"), 6)
        wait(for: [alarmShouldBeTurnedOn], timeout: 1.0)
        XCTAssertEqual(composed.currentState.name, "full, alarm on")
        composed.receive(input: "exit person")
        composed.receive(input: "exit person")
        XCTAssertEqual(composed.variables.intValueFor("counter"), 4)
        wait(for: [alarmShouldBeTurnedOff], timeout: 1.0)
        XCTAssertEqual(composed.currentState.name, "full, alarm off")
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
