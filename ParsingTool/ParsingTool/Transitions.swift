//
//  Transitions.swift
//  ParsingTool
//
//  Created by Sebastian Tleye on 16/03/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import Foundation

struct Transitions {

    var transitions: [Transition] = []

    private let separatorBetweenStatesAndTransitions = "#"

    init(from tgf: String) {
        self.transitions = self.parseTransitions(from: tgf)
    }

    func printTransitions() -> String {
        var result = ""
        for transition in self.transitions {
            result = result + transition.print()
        }
        return result
    }

    func printEnum() -> String {
        var result = String(Character.newLine)
        result = result + "enum \(Constants.fsmStatesName): String {" + String(Character.newLine)
        var setOfSymbols: Set<String> = []
        for transition in self.transitions {
            for symbol in transition.symbols {
                setOfSymbols.insert(symbol)
            }
        }
        for symbol in setOfSymbols {
            result = result + String(Character.tab) + "case " + symbol.camelized + String(Character.newLine)
        }
        result = result + "}" + String(Character.newLine) + String(Character.newLine)
        return result
    }

    func print() -> String {
        var result = ""
        result += self.printEnum()
        result += String.newLine
        result += self.printTransitions()
        return result
    }

    private func parseTransitions(from tgfStr: String) -> [Transition] {
        var result: [Transition] = []
        for line in self.getTGFTransitionsLines(from: tgfStr) {
            result.append(Transition(from: line))
        }
        return result
    }

    private func getTGFTransitionsLines(from tgfStr: String) -> [String] {
        var result: [String] = []
        let lines = tgfStr.split(separator: Character.newLine)
        var lineDefinesState = true
        for line in lines {
            if line == self.separatorBetweenStatesAndTransitions {
                lineDefinesState = false
                continue
            }
            if lineDefinesState {
                continue
            }
            result.append(String(line))
        }
        return result
    }

}
