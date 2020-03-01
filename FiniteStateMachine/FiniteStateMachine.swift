//
//  FiniteStateMachine.swift
//  FiniteStateMachine
//
//  Created by Sebastian Tleye on 23/02/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import Foundation

class FiniteStateMachine {

    private(set) var currentState: State
    private(set) var initialState: State
    private(set) var variables: [Variable]
    private(set) var timer: Int

    private var states: Set<State>
    private var symbols: Set<Symbol>
    private var transitions: [Transition]
    private var transitionTimer: Timer?
    private var statesTimer: Timer?
    private var stateConditionTimeTolerance: TimeInterval

    init(initialState: State, transitions: [Transition], variables: [Variable] = [], stateConditionTimeTolerance: TimeInterval = 0.5) {
        self.initialState = initialState
        self.states = [initialState]
        self.symbols = []
        self.variables = variables
        for transition in transitions {
            self.states.insert(transition.origin)
            self.states.insert(transition.destination)
            self.symbols.insert(transition.input)
        }
        self.stateConditionTimeTolerance = stateConditionTimeTolerance
        self.transitions = transitions
        self.currentState = initialState
        self.timer = 0
        if self.states.contains(where: { $0.condition != nil }) {
            self.transitionTimer = Timer.scheduledTimer(timeInterval: stateConditionTimeTolerance,
                                                        target: self,
                                                        selector: #selector(checkCurrentStateCondition),
                                                        userInfo: nil,
                                                        repeats: true)
        }
    }

    func receive(input: Symbol) {
        for transition in transitions {
            if transition.origin == self.currentState && transition.input == input && transition.condition(self) {
                self.currentState = transition.destination
                transition.action(self)
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
                    transitions.append(createTransitionFrom(transition1: transitionSelf,
                                                            and: transitionParam))
                }
            }
            if !fsm.symbols.contains(transitionSelf.input) {
                for state in fsm.states {
                    let transition = Transition(from: State(state1: transitionSelf.origin, state2: state),
                                                to: State(state1: transitionSelf.destination, state2: state),
                                                through: transitionSelf.input)
                    transitions.append(transition)
                }
            }
        }
        for transitionFsm in fsm.transitions {
            if !self.symbols.contains(transitionFsm.input) {
                for state in self.states {
                    let transition = Transition(from: State(state1: state, state2: transitionFsm.origin),
                                                to: State(state1: state, state2: transitionFsm.destination),
                                                through: transitionFsm.input)
                    transitions.append(transition)
                }
            }
        }
        let newVariables = self.mergeVariables(self.variables, fsm.variables)
        return FiniteStateMachine(initialState: initialState,
                                  transitions: transitions,
                                  variables: newVariables,
                                  stateConditionTimeTolerance: min(self.stateConditionTimeTolerance, fsm.stateConditionTimeTolerance))
    }

    func resetTimer() {
        if transitionTimer == nil {
            self.transitionTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                        target: self,
                                                        selector: #selector(incrementTimeOneSecond),
                                                        userInfo: nil,
                                                        repeats: true)
        }
        self.timer = 0
    }

    func valueForVariable(_ name: String) -> Any? {
        return self.variables.first(where: { $0.name == name })?.value
    }

    func setVariable(named: String, withValue value: Any) {
        //self.variables
    }

    @objc private func incrementTimeOneSecond() {
        self.timer += 1
    }

    @objc private func checkCurrentStateCondition() {
        if let condition = self.currentState.condition, !condition(self) {
            self.leaveCurrentState()
        }
    }

    private func leaveCurrentState() {
        for transition in transitions where transition.origin == self.currentState {
            if transition.condition(self) {
                self.receive(input: transition.input)
                return
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

    private func mergeVariables(_ variables1: [Variable], _ variables2: [Variable]) -> [Variable] {
        var dictionary: [String: Any] = [:]
        var result: [Variable] = []
        for variable in variables2 {
            dictionary[variable.name] = variable.value
        }
        for variable in variables1 {
            dictionary[variable.name] = variable.value
        }
        for (key, value) in dictionary {
            result.append(Variable(name: key, value: value))
        }
        return result
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
        private(set) var condition: ((FiniteStateMachine) -> Bool)?

        var description: String {
            return self.name
        }

        init(_ name: String, condition: ((FiniteStateMachine) -> Bool)?) {
            self.name = name
            self.condition = condition
        }

        init(_ name: String) {
            self.init(name, condition: nil)
        }

        init(state1: State, state2: State) {
            let condition = { (fsm: FiniteStateMachine) in
                return (state1.condition?(fsm) ?? true) && (state2.condition?(fsm) ?? true)
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

    struct Variable {
        var name: String
        var value: Any
    }

}
