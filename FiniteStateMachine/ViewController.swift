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

        enum FSMStates {
            case A1
            case A2
        }

        enum FSMEvents {
            case a
            case b
            case c
        }

        let myFSM = FiniteStateMachine(initialState: FSMStates.A1,
                                       states: [.A1, .A2],
                                       symbols: [.a, .b],
                                       transitions: [FiniteStateMachine.Transition(origin: .A1, input: FSMEvents.a, destination: .A2),
                                                     FiniteStateMachine.Transition(origin: .A2, input: .c, destination: .A2),
                                                     FiniteStateMachine.Transition(origin: .A2, input: .b, destination: .A1)])
        
        myFSM?.addEvent({ _ in 
            print ("Bla bla")
        }, to: FiniteStateMachine.Transition(origin: .A1, input: .a, destination: .A2))
        
        let currentState = myFSM?.receive(input: .a).receive(input: .b).currentState
        
        //print (myFSM?.receiveEvent(.a)?.receiveEvent(.b).currentState)

    }

    
    
}

