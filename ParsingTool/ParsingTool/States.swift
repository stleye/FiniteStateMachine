//
//  States.swift
//  ParsingTool
//
//  Created by Sebastian Tleye on 16/03/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import Foundation

struct States {

    var states: [State] = []

    private let separatorBetweenStatesAndTransitions = "#"

    init(from tgf: String) {
        self.states = self.parseStates(from: tgf)
    }

    func printStates() -> String {
        var result = ""
        for state in self.states {
            result = result + state.print()
            result = result + String.newLine
        }
        return result
    }

    func printEnum() -> String {
        var result = "enum \(Constants.fsmStatesName): String {" + String(Character.newLine)
        for state in self.states {
            result = result + String(Character.tab) + "case " + state.name.camelized + String(Character.newLine)
        }
        result = result + "}" + String(Character.newLine)
        return result
    }

    func print() -> String {
        var result = ""
        result += self.printEnum()
        result += String.newLine
        result += self.printStates()
        return result
    }

    private func parseStates(from tgfStr: String) -> [State] {
        var result: [State] = []
        for stateLine in self.getTGFStatesLines(from: tgfStr) {
            result.append(State(from: stateLine))
        }
        return result
    }

    private func getTGFStatesLines(from tgfStr: String) -> [String] {
        var result: [String] = []
        let lines = tgfStr.split(separator: Character.newLine)
        for line in lines {
            if line == self.separatorBetweenStatesAndTransitions {
                break
            }
            result.append(String(line))
        }
        return result
    }

}
