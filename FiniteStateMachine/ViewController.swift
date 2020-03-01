//
//  ViewController.swift
//  FiniteStateMachine
//
//  Created by Sebastian Tleye on 23/02/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let empty = FiniteStateMachine.State(name: "empty")
//        let full = FiniteStateMachine.State(name: "full")
//        let transition1 = FiniteStateMachine.Transition(origin: empty,
//                                                        input: "ingresa persona",
//                                                        destination: full,
//                                                        action: { fsm in fsm.variables["counter"] = (fsm.variables["counter"] as! Int) + 1 })
//        let transition2 = FiniteStateMachine.Transition(origin: full,
//                                                        input: "ingresa persona",
//                                                        destination: full,
//                                                        action: { fsm in fsm.variables["counter"] = (fsm.variables["counter"] as! Int) + 1 })
//        let transition3 = FiniteStateMachine.Transition(origin: full,
//                                                        input: "egresa persona",
//                                                        destination: full,
//                                                        condition: { fsm in (fsm.variables["counter"] as! Int) > 1 },
//                                                        action: { fsm in fsm.variables["counter"] = (fsm.variables["counter"] as! Int) - 1 })
//        let transition4 = FiniteStateMachine.Transition(origin: full,
//                                                        input: "egresa persona",
//                                                        destination: empty,
//                                                        condition: { fsm in (fsm.variables["counter"] as! Int) == 1 },
//                                                        action: { fsm in fsm.variables["counter"] = (fsm.variables["counter"] as! Int) - 1 })
//        let local = FiniteStateMachine(initialState: empty, transitions: [transition1, transition2, transition3, transition4], variables: ["counter": 0])
//        
//        let alarmaApagada = FiniteStateMachine.State(name: "alarma apagada", condition: { fsm in (fsm.variables["counter"] as! Int) <= 1000 })
//        let alarmaEncendida = FiniteStateMachine.State(name: "alarma encendida", condition: { fsm in (fsm.variables["counter"] as! Int) > 1000 })
//        let transitionA1 = FiniteStateMachine.Transition(origin: alarmaApagada,
//                                                         input: "encender alarma",
//                                                         destination: alarmaEncendida,
//                                                         condition: { fsm in (fsm.variables["counter"] as! Int) > 1000 })
//        let transitionA2 = FiniteStateMachine.Transition(origin: alarmaEncendida,
//                                                         input: "apagar alarma",
//                                                         destination: alarmaApagada,
//                                                         condition: { fsm in (fsm.variables["counter"] as! Int) == 1000 })
//        let alarma = FiniteStateMachine(initialState: alarmaApagada, transitions: [transitionA1, transitionA2])
//
//        let composed = local.composeInParallel(with: alarma)
//
//        print ("\(composed.currentState) + \(String(describing: composed.variables["counter"]))")
//        composed.receive(input: "ingresa persona")
//        print ("\(composed.currentState) + \(String(describing: composed.variables["counter"]))")
//        composed.receive(input: "ingresa persona")
//        print ("\(composed.currentState) + \(String(describing: composed.variables["counter"]))")
//        composed.receive(input: "ingresa persona")
//        print ("\(composed.currentState) + \(String(describing: composed.variables["counter"]))")
//        composed.receive(input: "ingresa persona")
//        print ("\(composed.currentState) + \(String(describing: composed.variables["counter"]))")
//        composed.receive(input: "ingresa persona")
//        print ("\(composed.currentState) + \(String(describing: composed.variables["counter"]))")
//        composed.receive(input: "egresa persona")
//        print ("\(composed.currentState) + \(String(describing: composed.variables["counter"]))")
//        composed.receive(input: "egresa persona")
//        print ("\(composed.currentState) + \(String(describing: composed.variables["counter"]))")
//        composed.receive(input: "egresa persona")
//        print ("\(composed.currentState) + \(String(describing: composed.variables["counter"]))")
//        composed.receive(input: "egresa persona")
//        print ("\(composed.currentState) + \(String(describing: composed.variables["counter"]))")
//        composed.receive(input: "egresa persona")
//        print ("\(composed.currentState) + \(String(describing: composed.variables["counter"]))")
//        composed.receive(input: "egresa persona")
//        print ("\(composed.currentState) + \(String(describing: composed.variables["counter"]))")

//        let bluetoothOn = FiniteStateMachine.State(name: "Bluetooth On")
//        let bluetoothOff = FiniteStateMachine.State(name: "Bluetooth Off")
//        let fsmBluetooth = FiniteStateMachine(initialState: bluetoothOn,
//                                              transitions: [FiniteStateMachine.Transition(origin: bluetoothOff, input: "turn on bluetooth", destination: bluetoothOn),
//                                                            FiniteStateMachine.Transition(origin: bluetoothOn, input: "turn off bluetooth", destination: bluetoothOff),
//                                                            FiniteStateMachine.Transition(origin: bluetoothOn, input: "connect", destination: bluetoothOn),
//                                                            FiniteStateMachine.Transition(origin: bluetoothOn, input: "remove card", destination: bluetoothOn),
//                                                            FiniteStateMachine.Transition(origin: bluetoothOn, input: "unsuspend", destination: bluetoothOn),
//                                                            FiniteStateMachine.Transition(origin: bluetoothOn, input: "add card", destination: bluetoothOn),
//                                                            FiniteStateMachine.Transition(origin: bluetoothOn, input: "suspend", destination: bluetoothOn)])
//
//        let noCards = FiniteStateMachine.State(name: "No Cards")
//        let cardsAdded = FiniteStateMachine.State(name: "Cards Added")
//        let cardsSuspended = FiniteStateMachine.State(name: "Suspended")
//        let fsmCards = FiniteStateMachine(initialState: noCards,
//                                          transitions: [FiniteStateMachine.Transition(origin: noCards, input: "add card", destination: cardsAdded),
//                                                        FiniteStateMachine.Transition(origin: cardsAdded, input: "remove card", destination: noCards),
//                                                        FiniteStateMachine.Transition(origin: cardsAdded, input: "suspend", destination: cardsSuspended),
//                                                        FiniteStateMachine.Transition(origin: cardsSuspended, input: "unsuspend", destination: cardsAdded)])
//
//        let noDevice = FiniteStateMachine.State(name: "No Device")
//        let connecting = FiniteStateMachine.State(name: "Connecting")
//        let connected = FiniteStateMachine.State(name: "Connected")
//        let fsmTPD = FiniteStateMachine(initialState: noDevice,
//                                        transitions: [FiniteStateMachine.Transition(origin: noDevice, input: "connect", destination: connecting),
//                                                      FiniteStateMachine.Transition(origin: connecting, input: "connect", destination: connected),
//                                                      FiniteStateMachine.Transition(origin: connected, input: "add card", destination: connected),
//                                                      FiniteStateMachine.Transition(origin: connected, input: "remove card", destination: connected),
//                                                      FiniteStateMachine.Transition(origin: connected, input: "disconnect", destination: noDevice),
//                                                      FiniteStateMachine.Transition(origin: connecting, input: "disconnect", destination: noDevice),
//                                                      FiniteStateMachine.Transition(origin: connecting, input: "turn off bluetooth", destination: noDevice),
//                                                      FiniteStateMachine.Transition(origin: connected, input: "turn off bluetooth", destination: noDevice),
//                                                      FiniteStateMachine.Transition(origin: noDevice, input: "turn off bluetooth", destination: noDevice),
//                                                      FiniteStateMachine.Transition(origin: connected, input: "suspend", destination: connected),
//                                                      FiniteStateMachine.Transition(origin: connected, input: "unsuspend", destination: connected)])
//
//        var composedFsm = fsmTPD.composeInParallel(with: fsmBluetooth).composeInParallel(with: fsmCards)
//
//        print(composedFsm.currentState)
//        composedFsm.receive(input: "turn off bluetooth")
//        print(composedFsm.currentState)
//        composedFsm.receive(input: "turn on bluetooth")
//        print(composedFsm.currentState)
//        composedFsm.receive(input: "connect")
//        print(composedFsm.currentState)
//        composedFsm.receive(input: "connect")
//        print(composedFsm.currentState)
//        composedFsm.receive(input: "remove card")
//        print(composedFsm.currentState)
//        composedFsm.receive(input: "add card")
//        print(composedFsm.currentState)
//        composedFsm.receive(input: "turn off bluetooth")
//        print(composedFsm.currentState)
//        composedFsm.receive(input: "turn on bluetooth")
        
        

    }

}
