//
//  Extensions.swift
//  ParsingTool
//
//  Created by Sebastian Tleye on 16/03/2020.
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
    
    static var newLine: String {
        return String(Character.newLine)
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
