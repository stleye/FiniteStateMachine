//
//  Conversor.swift
//  TGFToFiniteStateMachine
//
//  Created by Sebastian Tleye on 15/03/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import Foundation

class Examples {

    static var example1 = """
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
    5 5 suspend card
    4 4 add card
    6 6 unsuspend card
    5 5 remove card
    8 7 card added, card removed, card suspended, card unsuspended, disconnect, connected, failed
    7 8 add card, remove card, suspend card, unsuspend card, connect { t = 0 }
    8 7 timeout [ t = 120 ]
    9 10 turn on bluetooth
    10 9 turn off bluetooth
    10 10 connect,  connected,  disconnect, timeout, failed
    3 3 add card, remove card, suspend card, unsuspend card, card added, card removed, card suspended, card unsuspended
    """
}
