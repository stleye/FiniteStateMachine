//
//  State.swift
//  ParsingTool
//
//  Created by Sebastian Tleye on 16/03/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import Foundation

struct State {

    typealias StateProperties = (id: String, name: String, condition: String?)

    var id: String!
    var name: String!
    var condition: String?

    init(from tgfLine: String) {
        let properties = self.parseTGFLine(tgfLine)
        self.id = properties.id
        self.name = properties.name
        self.condition = properties.condition
    }

    func print() -> String {
        let symbol = "\(Constants.fsmStatesName).\(name.camelized).rawValue"
        let id = String.quote + self.id + String.quote
        var stateDefinition = ""
        if var condition = condition {
            condition = "" + condition + ""
            stateDefinition = "FiniteStateMachine.State(\(id), \(symbol), condition: \(condition))"
        } else {
            stateDefinition = "FiniteStateMachine.State(\(id), \(symbol))"
        }
        return "let state\(self.id!) = \(stateDefinition)"
    }

    private func parseTGFLine(_ line: String) -> StateProperties {
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

}
