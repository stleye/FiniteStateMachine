//
//  FiniteStateMachines.swift
//  ParsingTool
//
//  Created by Sebastian Tleye on 16/03/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import Foundation

struct FiniteStateMachines {

    var graph = Graph<String>()
    
    private var states: [State]
    private var transitions: Transitions

    init(from tgf: String) {
        self.states = States(from: tgf).states
        self.transitions = Transitions(from: tgf)

        for state in states {
            graph.createVertex(data: state.id)
        }

        for transition in transitions.transitions {
            graph.addDirectedEdge(from: Graph.Vertex(data: transition.originId),
                                  to: Graph.Vertex(data: transition.destinationId),
                                  weight: nil)
        }
    }

    func print() -> String {
        var result = ""
        var counter = 0
        for fsm in fsms() {
            counter += 1
            result += String.newLine
            result += "var transitions\(counter) = [ \(String.newLine)"
            result += fsm
            result += "]"
            result += String.newLine
            result += String.newLine
            result += "var fsm\(counter) = FiniteStateMachine(initialState: red, transitions: transitions)"
            result += String.newLine
        }
        return result
    }

    private func fsms() -> [String] {
        var components: [String] = []
        for component in graph.getComponents() {
            components.append(transitions.printTransitions(filteredBy: self.filterFor(component)))
        }
        return components
    }

    private func filterFor(_ component: [Graph<String>.Vertex]) -> ((Transition) -> Bool) {
        let statesInComponent = self.states.filter({ component.map({ $0.data }).contains( $0.id! ) })
        let filter: ((Transition) -> Bool) = { transition in
            return statesInComponent.contains(where: { state in
                state.id == transition.originId || state.id == transition.destinationId
            })
        }
        return filter
    }

}
