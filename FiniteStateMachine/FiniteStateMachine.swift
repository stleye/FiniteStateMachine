//
//  FiniteStateMachine.swift
//  FiniteStateMachine
//
//  Created by Sebastian Tleye on 23/02/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import Foundation

class FiniteStateMachine {

    struct State: Hashable {
        private(set) var name: String

        var description: String {
            return self.name
        }

        init(name: String) {
            self.name = name
        }

        init(state1: State, state2: State) {
            self.init(name: state1.name + ", " + state2.name)
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
        var condition: ((FiniteStateMachine) -> Bool) = { _ in true }
        var action: ((FiniteStateMachine) -> Void) = { _ in }
    }

    typealias Symbol = String
    typealias Event = (Transition) -> Void

    var variables: [String: Any] = [:]

    private(set) var timer: Int
    private(set) var currentState: State
    private(set) var initialState: State

    private var states: Set<State>
    private var symbols: Set<Symbol>
    private var transitions: [Transition]
    private var internalTimer: Timer?

    init(initialState: State, transitions: [Transition], variables: [String: Any] = [:]) {
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
        self.timer = 0
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
                    let transition = Transition(origin: State(state1: transitionSelf.origin, state2: transitionParam.origin),
                                                input: transitionSelf.input,
                                                destination: State(state1: transitionSelf.destination, state2: transitionParam.destination))
                    transitions.append(transition)
                }
            }
            if !fsm.symbols.contains(transitionSelf.input) {
                for state in fsm.states {
                    let transition = Transition(origin: State(state1: transitionSelf.origin, state2: state),
                                                input: transitionSelf.input,
                                                destination: State(state1: transitionSelf.destination, state2: state))
                    transitions.append(transition)
                }
            }
        }
        for transitionFsm in fsm.transitions {
            if !self.symbols.contains(transitionFsm.input) {
                for state in self.states {
                    let transition = Transition(origin: State(state1: state, state2: transitionFsm.origin),
                                                input: transitionFsm.input,
                                                destination: State(state1: state, state2: transitionFsm.destination))
                    transitions.append(transition)
                }
            }
        }
        return FiniteStateMachine(initialState: initialState, transitions: transitions)
    }

    func resetTimer() {
        if internalTimer == nil {
            self.internalTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(incrementTimeOneSecond), userInfo: nil, repeats: true)
        }
        self.timer = 0
    }

    @objc private func incrementTimeOneSecond() {
        self.timer += 1
    }

}
