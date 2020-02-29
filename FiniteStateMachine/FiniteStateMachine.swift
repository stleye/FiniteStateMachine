//
//  FiniteStateMachine.swift
//  FiniteStateMachine
//
//  Created by Sebastian Tleye on 23/02/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import Foundation

struct FiniteStateMachine {

    struct State: Hashable {
        var name: String

        init(name: String) {
            self.name = name
        }

        init(state1: State, state2: State) {
            self.init(name: state1.name + ", " + state2.name)
        }
    }

    struct Transition: Hashable {
        var origin: State
        var input: Symbol
        var destination: State
    }

    typealias Symbol = String
    typealias Event = (Transition) -> Void

    private(set) var currentState: State

    private var initialState: State
    private var states: Set<State>
    private var symbols: Set<Symbol>
    private var transitions: [Transition]
    private var events: [Transition: Event]

    init(initialState: State, symbols: Set<Symbol>, transitions: [Transition]) {
        self.initialState = initialState
        self.states = [initialState]
        for transition in transitions {
            self.states.insert(transition.origin)
            self.states.insert(transition.destination)
        }
        self.symbols = symbols
        self.transitions = transitions
        self.currentState = initialState
        self.events = [:]
    }

    mutating func receive(input: Symbol) -> FiniteStateMachine {
        for transition in transitions {
            if transition.origin == self.currentState && transition.input == input {
                self.currentState = transition.destination
                self.events[transition]?(transition)
                break
            }
        }
        return self
    }

    mutating func addEvent(_ event: @escaping Event, to transition: Transition) {
        self.events[transition] = event
    }

    func composeInParallel(with fsm: FiniteStateMachine) -> FiniteStateMachine {
        let initialState = State(state1: self.initialState, state2: fsm.initialState)
        let symbols = self.symbols.union(fsm.symbols)
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
        return FiniteStateMachine(initialState: initialState,
                                  symbols: symbols,
                                  transitions: transitions)
    }

}
