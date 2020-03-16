//
//  Conversor.swift
//  TGFToFiniteStateMachine
//
//  Created by Sebastian Tleye on 15/03/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import Foundation

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

    static func create(from tgfStr: String) -> String {
        let states = States(from: tgfStr).print()
        let transitions = Transitions(from: tgfStr).print()
        return states + String(Character.newLine) + transitions
    }

}
