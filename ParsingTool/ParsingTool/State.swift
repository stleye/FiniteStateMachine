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

    // Private

    private func parseTGFLine(_ line: String) -> StateProperties {
        let idAndName = line.split(separator: Character.space, maxSplits: 1, omittingEmptySubsequences: false)
        let id = String(idAndName.first!)
        let nameAndCondition = String(idAndName.last!)
        var condition: String?
        let conditionRegex = "\\[(.*?)\\]"
        let name = nameAndCondition.replacingOccurrences(of: conditionRegex, with: "", options: .regularExpression)
        if let conditionRange = nameAndCondition.range(of: conditionRegex, options: .regularExpression) {
            condition = String(nameAndCondition[conditionRange])
        }
        return (id, name, condition)
    }

}
