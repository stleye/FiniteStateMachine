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

    lazy var stateWithCondition = FiniteStateMachine.State("State With Condition", condition: FiniteStateMachine.State.Condition.allwaysTrue())

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
                                                                          action: { fsm in
                                                fsm.variables.set(value: fsm.variables.intValueFor("counter") + 1, to: "counter")
                                            }),
                                            FiniteStateMachine.Transition("full", "full", "enter person", action: { fsm in
                                                fsm.variables.set(value: fsm.variables.intValueFor("counter") + 1, to: "counter")
                                            }),
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

    func testFSMComposedStateShouldContainOtherStates() {
        let state1 = FiniteStateMachine.State("state1")
        let state2 = FiniteStateMachine.State("state2")
        let state3 = FiniteStateMachine.State("state3")
        let composedStateWithState1AndState2_1 = FiniteStateMachine.State(state1: state1, state2: state2)
        let composedStateWithState1AndState2_2 = FiniteStateMachine.State(state1: state1, state2: state2)
        let composedStateWithState2AndState1 = FiniteStateMachine.State(state1: state2, state2: state1)
        let composedStateWithState1AndState2AndState3 = FiniteStateMachine.State(state1: composedStateWithState1AndState2_1, state2: state3)
        XCTAssert(composedStateWithState1AndState2_1.contains(state1))
        XCTAssert(composedStateWithState1AndState2_1.contains(state2))
        XCTAssert(composedStateWithState1AndState2AndState3.contains(state1))
        XCTAssert(composedStateWithState1AndState2AndState3.contains(state2))
        XCTAssert(composedStateWithState1AndState2AndState3.contains(state3))
        XCTAssertEqual(composedStateWithState1AndState2_1, composedStateWithState1AndState2_2)
        XCTAssertNotEqual(composedStateWithState1AndState2_2, composedStateWithState2AndState1)
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

    func testTransitionIsEqualToAnotherTransition() {
        let t1 = FiniteStateMachine.Transition(from: initialState1, to: initialState2, through: "a")
        let t2 = FiniteStateMachine.Transition(from: initialState1, to: initialState2, through: "a")
        let t3 = FiniteStateMachine.Transition(from: initialState1, to: initialState2, through: "b")
        let t4 = FiniteStateMachine.Transition(from: finalState, to: initialState2, through: "a")
        XCTAssertEqual(t1, t2)
        XCTAssertNotEqual(t2, t3)
        XCTAssertNotEqual(t1, t4)
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
        let alarmOff = FiniteStateMachine.State("alarm off", condition: FiniteStateMachine.State.Condition.variable("counter", is: <=, than: self.storeLimit))
        let alarmOn = FiniteStateMachine.State("alarm on", condition: FiniteStateMachine.State.Condition.variable("counter", is: >, than: self.storeLimit))
        let transition1 = FiniteStateMachine.Transition(from: alarmOff,
                                                        to: alarmOn,
                                                        through: "turn on alarm",
                                                        condition: { fsm in
            fsm.variables.intValueFor("counter") > self.storeLimit
        })
        let transition2 = FiniteStateMachine.Transition(from: alarmOn,
                                                        to: alarmOff,
                                                        through: "turn off alarm",
                                                        condition: { fsm in
            fsm.variables.intValueFor("counter") == self.storeLimit
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
        XCTAssertEqual(composed.currentState.name, "full, alarm on")
        composed.receive(input: "exit person")
        composed.receive(input: "exit person")
        XCTAssertEqual(composed.variables.intValueFor("counter"), 4)
        XCTAssertEqual(composed.currentState.name, "full, alarm off")
    }

    func testTimedFSM() {
        let alarmShouldBeTurnedOn = XCTestExpectation(description: "sprinkler turned on")
        let alarmShouldBeTurnedOff = XCTestExpectation(description: "sprinkler turned off")

        let timeTurnedOn = 2
        let timeTurnedOff = 5

        let sprinklerOff = FiniteStateMachine.State("sprinkler off",
                                                    condition: FiniteStateMachine.State.Condition.timer("t", is: <, than: timeTurnedOff) )
        let sprinklerOn = FiniteStateMachine.State("sprinkler on",
                                                   condition: FiniteStateMachine.State.Condition.timer("u", is: <, than: timeTurnedOn) )

        let transition1 = FiniteStateMachine.Transition(from: sprinklerOff,
                                                        to: sprinklerOn,
                                                        through: "open tap",
                                                        condition: { fsm in
            fsm.variables.timerValueFor("t") == timeTurnedOff
        }, action: { fsm in
            alarmShouldBeTurnedOn.fulfill()
            fsm.variables.resetTimer("u")
        })
        let transition2 = FiniteStateMachine.Transition(from: sprinklerOn,
                                                        to: sprinklerOff,
                                                        through: "close tap",
                                                        condition: { fsm in
            fsm.variables.timerValueFor("u") == timeTurnedOn
        }, action: { fsm in
            alarmShouldBeTurnedOff.fulfill()
            fsm.variables.resetTimer("t")
        })
        let fsm = FiniteStateMachine(initialState: sprinklerOff,
                                     transitions: [transition1, transition2])
        fsm.variables.resetTimer("t")
        fsm.variables.resetTimer("u")
        XCTAssertEqual(fsm.currentState, sprinklerOff)
        wait(for: [alarmShouldBeTurnedOn], timeout: 10)
        XCTAssertEqual(fsm.currentState, sprinklerOn)
        wait(for: [alarmShouldBeTurnedOff], timeout: 10)
        XCTAssertEqual(fsm.currentState, sprinklerOff)
    }

}
