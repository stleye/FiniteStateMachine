//
//  Transition.swift
//  ParsingTool
//
//  Created by Sebastian Tleye on 16/03/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import Foundation

struct Transition {

    typealias Properties = (originId: String, destinationId: String, symbols: [String], conditions: [String], actions: [String])

    var originId: String!
    var destinationId: String!
    var symbols: [String] = []
    var conditions: [String] = []
    var actions: [String] = []

    init(from tgfLine: String) {
        let properties = self.parseTGFLine(tgfLine)
        self.originId = properties.originId
        self.destinationId = properties.destinationId
        self.symbols = properties.symbols
        self.conditions = properties.conditions
        self.actions = properties.actions
    }

    func print() -> String {
        var result = ""
        let originState = "state\(self.originId!)"
        let destinationState = "state\(self.destinationId!)"
        for symbol in self.symbols {
            let newSymbol = "\(Constants.fsmSymbols).\(symbol.camelized).rawValue"
            result += "FiniteStateMachine.Transition(from: \(originState), to: \(destinationState), through: \(newSymbol))" + String(Character.newLine)
        }
        return result
    }

    private func parseTGFLine(_ line: String) -> Properties {
        let idsAndSymbol = line.split(separator: Character.space, maxSplits: 2, omittingEmptySubsequences: false)
        let idOrigin = String(idsAndSymbol.first!)
        let idDestination = String(idsAndSymbol[1])
        let symbols = (idsAndSymbol.last!).split(separator: ",").map({ String($0).trimmingCharacters(in: CharacterSet(arrayLiteral: " ")) })
        let conditions = [""]
        let actions = [""]
        return (idOrigin, idDestination, symbols, conditions, actions)
    }

}
