//
//  FiniteStateMachine.swift
//  FiniteStateMachine
//
//  Created by Sebastian Tleye on 23/02/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import Foundation

class FiniteStateMachine<T1: Hashable, T2: Hashable> {
    
    struct Transition: Hashable {
        var origin: State
        var input: Symbol
        var destination: State
    }

    typealias State = T1
    typealias Symbol = T2
    typealias Event = (Transition) -> Void

    private(set) var currentState: T1

    private var initialState: T1
    private var states: Set<T1>
    private var symbols: Set<Symbol>
    private var transitions: [Transition]
    private var events: [Transition: Event]

    init?(initialState: State, states: Set<State>, symbols: Set<Symbol>, transitions: [Transition]) {
        if !states.contains(initialState) {
            return nil
        }
        self.initialState = initialState
        self.states = states
        self.symbols = symbols
        self.transitions = transitions
        self.currentState = initialState
        self.events = [:]
    }

    func receive(input: Symbol) -> FiniteStateMachine {
        for transition in transitions {
            if transition.origin == self.currentState && transition.input == input {
                self.currentState = transition.destination
                self.events[transition]?(transition)
                break
            }
        }
        return self
    }

    func addEvent(_ event: @escaping Event, to transition: Transition) {
        self.events[transition] = event
    }

}
