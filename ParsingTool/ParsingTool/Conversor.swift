//
//  Conversor.swift
//  TGFToFiniteStateMachine
//
//  Created by Sebastian Tleye on 15/03/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import Foundation

extension Character {
    static var newLine: Character {
        return "\n"
    }

    static var space: Character {
        return " "
    }
    
    static var tab: Character {
        return "\t"
    }
}

extension String {

    static var quote: String {
        return "\""
    }

    var uppercasingFirst: String {
        return prefix(1).uppercased() + dropFirst()
    }

    var lowercasingFirst: String {
        return prefix(1).lowercased() + dropFirst()
    }

    var camelized: String {
        guard !isEmpty else {
            return ""
        }

        let parts = self.components(separatedBy: CharacterSet.alphanumerics.inverted)

        let first = String(describing: parts.first!).lowercasingFirst
        let rest = parts.dropFirst().map({String($0).uppercasingFirst})

        return ([first] + rest).joined(separator: "")
    }

}

class Conversor {

    private static let separatorBetweenStatesAndTransitions = "#"

    static var example = """
    1 not connected
    2 connecting
    3 connected
    4 No Cards
    5 Cards Added
    6 Suspended
    7 Idle
    8 Sending bytes to tpd [ t < 120 ]
    9 bluetoothOff
    10 bluetoothOn
    #
    1 2 connect
    2 3 connected
    3 1 disconnect
    2 1 disconnect
    4 5 card added
    5 4 card removed
    5 6 card suspended
    6 5 card unsuspended
    5 5 suspend
    4 4 add card
    6 6 unsuspend
    5 5 remove card
    8 7 bytes sent
    8 7 failed
    7 8 send bytes { t = 0 }
    8 7 timeout [ t = 120 ]
    9 10 turn on bluetooth
    10 9 turn of bluetooth
    10 10 connect,  connected,  disconnect, add card, card added, remove card, suspend, suspended, unsuspended, unsuspend, card unsuspended, card suspended, card removed, send bytes, bytes sent
    """

    static let fsmStatesName = "FSMStates"
    static let fsmSymbols = "FSMSymbols"

    typealias StateProperties = (id: String, name: String, condition: String?)
    typealias TransitionProperties = (originId: String, destinationId: String, symbols: [String], conditions: [String], actions: [String])

    static func create(from tgfStr: String) -> String {
        let states = self.createStates(from: tgfStr)
        let transitions = self.createTransitions(from: tgfStr)
        return states + String(Character.newLine) + transitions
    }

    private static func createStates(from tgfStr: String) -> String {
        var result: [String] = []
        var statesProperties: [StateProperties] = []
        let lines = tgfStr.split(separator: Character.newLine)
        for line in lines {
            if line == self.separatorBetweenStatesAndTransitions {
                break
            }
            let stateProperties = self.parseStateLine(String(line))
            let state = self.createStateLine(from: stateProperties)
            statesProperties.append(stateProperties)
            result.append(state)
        }
        result.insert(createStatesEnum(from: statesProperties), at: 0)
        return result.reduce("", {
            $0 + String(Character.newLine) + $1
        })
    }

    private static func createStatesEnum(from statesProperties: [StateProperties]) -> String {
        var result = "enum \(fsmStatesName): String {" + String(Character.newLine)
        for properties in statesProperties {
            result = result + String(Character.tab) + "case " + properties.name.camelized + String(Character.newLine)
        }
        result = result + "}" + String(Character.newLine)
        return result
    }

    private static func createStateLine(from properties: StateProperties) -> String {
        let symbol = "\(fsmStatesName).\(properties.name.camelized).rawValue"
        let id = String.quote + properties.id + String.quote
        var stateDefinition = ""
        if var condition = properties.condition {
            condition = "" + condition + ""
            stateDefinition = "FiniteStateMachine.State(\(id), \(symbol), condition: \(condition))"
        } else {
            stateDefinition = "FiniteStateMachine.State(\(id), \(symbol))"
        }
        return "let state\(properties.id) = \(stateDefinition)"
    }

    private static func parseStateLine(_ line: String) -> StateProperties {
        let idAndName = line.split(separator: Character.space, maxSplits: 1, omittingEmptySubsequences: false)
        let id = String(idAndName.first!)
        var name = ""
        let nameAndCondition = String(idAndName.last!)
        if let openingBracket = nameAndCondition.firstIndex(where: { $0 == "[" }) {
            let closingBracket = nameAndCondition.firstIndex(where: { $0 == "]" })!
            name = String(nameAndCondition[nameAndCondition.startIndex..<openingBracket])
            //let condition = nameAndCondition[openingBracket..<closingBracket]
        } else {
            name = nameAndCondition
        }
        return (id, name, nil)
    }

    // Transitions

    private static func createTransitions(from tgfStr: String) -> String {
        var result: [String] = []
        let lines = tgfStr.split(separator: Character.newLine)
        var lineDefinesState = true
        var transitionsProperties: [TransitionProperties] = []
        for line in lines {
            if line == self.separatorBetweenStatesAndTransitions {
                lineDefinesState = false
                continue
            }
            if lineDefinesState {
                continue
            }
            let transitionProperties = self.parseTransitionLine(String(line))
            transitionsProperties.append(transitionProperties)
            result.append(self.createTransitionLine(from: transitionProperties))
        }
        result.insert(self.createTransitionsEnum(from: transitionsProperties), at: 0)
        return result.reduce("", {
            $0 + $1
        })
    }

    private static func createTransitionLine(from properties: TransitionProperties) -> String {
        var transitions: [String] = []
        let originState = "state\(properties.originId)"
        let destinationState = "state\(properties.destinationId)"
        for symbol in properties.symbols {
            let newSymbol = "\(fsmSymbols).\(symbol.camelized).rawValue"
            transitions.append("FiniteStateMachine.Transition(from: \(originState), to: \(destinationState), through: \(newSymbol))" + String(Character.newLine))
        }
        return transitions.reduce("", {
            $0 + $1
        })
    }

    private static func createTransitionsEnum(from transitionsProperties: [TransitionProperties]) -> String {
        var result = String(Character.newLine)
        result = result + "enum \(fsmStatesName): String {" + String(Character.newLine)
        var setOfSymbols: Set<String> = []
        for properties in transitionsProperties {
            for symbol in properties.symbols {
                setOfSymbols.insert(symbol)
            }
        }
        for symbol in setOfSymbols {
            result = result + String(Character.tab) + "case " + symbol.camelized + String(Character.newLine)
        }
        result = result + "}" + String(Character.newLine) + String(Character.newLine)
        return result
    }

    private static func parseTransitionLine(_ line: String) -> TransitionProperties {
        let idsAndSymbol = line.split(separator: Character.space, maxSplits: 2, omittingEmptySubsequences: false)
        let idOrigin = String(idsAndSymbol.first!)
        let idDestination = String(idsAndSymbol[1])
        let symbols = (idsAndSymbol.last!).split(separator: ",").map({ String($0).trimmingCharacters(in: CharacterSet(arrayLiteral: " ")) })
        let conditions = [""]
        let actions = [""]
        return (idOrigin, idDestination, symbols, conditions, actions)
    }

}
