//
//  FiniteStateMachine.swift
//  FiniteStateMachine
//
//  Created by Sebastian Tleye on 23/02/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import Foundation

class FiniteStateMachine {

    private(set) var variables: Variables
    private(set) var currentState: State
    private(set) var initialState: State

    private var states: Set<State>
    private var symbols: Set<Symbol>
    private var transitions: [Transition]
    private var transitionTimer: Timer?

    init(initialState: State, transitions: [Transition], variables: Variables = Variables(), stateConditionTimeTolerance: TimeInterval = 0.5) {
        self.initialState = initialState
        self.states = [initialState]
        self.symbols = []
        for transition in transitions {
            self.states.insert(transition.origin)
            self.states.insert(transition.destination)
            self.symbols.insert(transition.input)
        }
        self.transitions = transitions
        self.currentState = initialState
        self.variables = variables
        self.variables.fsm = self
    }

    func receive(input: Symbol) {
        for transition in transitions {
            if transition.origin == self.currentState && transition.input == input && transition.condition(self) {
                self.currentState = transition.destination
                transition.action(self)
                self.checkCurrentStateCondition()
                break
            }
        }
    }

    func composeInParallel(with fsm: FiniteStateMachine) -> FiniteStateMachine {
        let initialState = State(state1: self.initialState, state2: fsm.initialState)
        var transitions: [Transition] = []
        for transitionSelf in self.transitions {
            for transitionParam in fsm.transitions {
                if transitionSelf.input == transitionParam.input {
                    transitions.append(createTransitionFrom(transition1: transitionSelf, and: transitionParam))
                }
            }
            if !fsm.symbols.contains(transitionSelf.input) {
                for state in fsm.states {
                    let transition = Transition(from: State(state1: transitionSelf.origin, state2: state),
                                                to: State(state1: transitionSelf.destination, state2: state),
                                                through: transitionSelf.input,
                                                condition: transitionSelf.condition,
                                                action: transitionSelf.action)
                    transitions.append(transition)
                }
            }
        }
        for transitionFsm in fsm.transitions {
            if !self.symbols.contains(transitionFsm.input) {
                for state in self.states {
                    let transition = Transition(from: State(state1: state, state2: transitionFsm.origin),
                                                to: State(state1: state, state2: transitionFsm.destination),
                                                through: transitionFsm.input,
                                                condition: transitionFsm.condition,
                                                action: transitionFsm.action)
                    transitions.append(transition)
                }
            }
        }
        return FiniteStateMachine(initialState: initialState,
                                  transitions: transitions,
                                  variables: self.variables.merge(with: fsm.variables))
    }

    @objc private func checkCurrentStateCondition() {
        if let condition = self.currentState.condition, !condition(self.variables) {
            self.leaveCurrentState()
        }
    }

    private func leaveCurrentState() {
        for transition in transitions where transition.origin == self.currentState {
            //the if below may not correct,
            //the action in the transition may change the variables so it may be fine to take a transition to the same state in those cases
            if transition.destination != transition.origin {
                if transition.condition(self) {
                    self.receive(input: transition.input)
                    return
                }
            }
        }
        //DEADLOCK
    }

    private func createTransitionFrom(transition1: Transition, and transition2: Transition) -> Transition {
        let action = { (fsm: FiniteStateMachine) in
            transition1.action(fsm)
            transition2.action(fsm)
        }
        let condition = { (fsm: FiniteStateMachine) in
            return transition1.condition(fsm) && transition2.condition(fsm)
        }
        return Transition(from: State(state1: transition1.origin, state2: transition2.origin),
                          to: State(state1: transition1.destination, state2: transition2.destination),
                          through: transition1.input,
                          condition: condition,
                          action: action)
    }

}

// Structs and Aliases
extension FiniteStateMachine {

    typealias Symbol = String
    typealias Event = (Transition) -> Void

    struct State: Hashable {
        var hashValue: Int {
            return name.hashValue
        }

        static func == (lhs: FiniteStateMachine.State, rhs: FiniteStateMachine.State) -> Bool {
            return lhs.name == rhs.name
        }

        private(set) var name: String
        private(set) var condition: ((Variables) -> Bool)?

        var description: String {
            return self.name
        }

        init(_ name: String, condition: ((Variables) -> Bool)?) {
            self.name = name
            self.condition = condition
        }

        init(_ name: String) {
            self.init(name, condition: nil)
        }

        init(state1: State, state2: State) {
            let condition = { (variables: Variables) in
                return (state1.condition?(variables) ?? true) && (state2.condition?(variables) ?? true)
            }
            self.init(state1.name + ", " + state2.name, condition: condition )
        }
    }

    struct Transition: Hashable {
        var hashValue: Int {
            return origin.hashValue ^ input.hashValue ^ destination.hashValue
        }

        static func == (lhs: FiniteStateMachine.Transition, rhs: FiniteStateMachine.Transition) -> Bool {
            return lhs.origin == rhs.origin && lhs.input == rhs.input && lhs.destination == rhs.destination
        }

        var origin: State
        var input: Symbol
        var destination: State
        var condition: ((FiniteStateMachine) -> Bool)
        var action: ((FiniteStateMachine) -> Void)

        init(from origin: State,
             to destination: State,
             through input: Symbol,
             condition: @escaping ((FiniteStateMachine) -> Bool) = { _ in true },
             action: @escaping ((FiniteStateMachine) -> Void) = { _ in }) {
            self.origin = origin
            self.input = input
            self.destination = destination
            self.condition = condition
            self.action = action
        }

        init(_ from: String,
             _ to: String,
             _ through: Symbol,
             condition: @escaping ((FiniteStateMachine) -> Bool) = { _ in true },
             action: @escaping ((FiniteStateMachine) -> Void) = { _ in }) {
            self.init(from: State(from), to: State(to), through: through, condition: condition, action: action)
        }
    }

    class Variables {

        weak var fsm: FiniteStateMachine?
        
        private var timers: [String: Int] = [:]
        private var variables: [String: Any] = [:]
        private var timer: Timer?

        init(_ values: (String, Any)...) {
            for value in values {
                self.variables[value.0] = value.1
            }
        }

        func valueFor(_ name: String) -> Any? {
            return self.variables[name]
        }

        func intValueFor(_ name: String) -> Int {
            return self.valueFor(name) as! Int
        }

        func stringValueFor(_ name: String) -> String {
            return self.valueFor(name) as! String
        }

        func timerValueFor(_ name: String) -> Int {
            return self.timers[name]!
        }

        func set(value: Any, to name: String) {
            self.variables[name] = value
            fsm?.checkCurrentStateCondition()
        }

        func merge(with variables: Variables) -> Variables {
            let result: Variables = variables
            for (name, value) in self.variables {
                result.set(value: value, to: name)
            }
            return result
        }

        func resetTimer(_ name: String) {
            if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(incrementTimeOneSecond),
                                             userInfo: nil,
                                             repeats: true)
            }
            timers[name] = 0
        }

        @objc private func incrementTimeOneSecond() {
            for key in timers.keys {
                timers[key] = timers[key]! + 1
            }
            fsm?.checkCurrentStateCondition()
        }

    }

}
