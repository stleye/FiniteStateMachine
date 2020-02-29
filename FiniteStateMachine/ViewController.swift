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

        let stateA1 = FiniteStateMachine.State(name: "A1")
        let stateA2 = FiniteStateMachine.State(name: "A2")
        let fsm1 = FiniteStateMachine(initialState: stateA1,
                                      transitions: [FiniteStateMachine.Transition(origin: stateA1, input: "a", destination: stateA2),
                                                    FiniteStateMachine.Transition(origin: stateA2, input: "c", destination: stateA2),
                                                    FiniteStateMachine.Transition(origin: stateA2, input: "b", destination: stateA1)])

        let stateB1 = FiniteStateMachine.State(name: "B1")
        let stateB2 = FiniteStateMachine.State(name: "B2")
        let stateB3 = FiniteStateMachine.State(name: "B3")
        let fsm2 = FiniteStateMachine(initialState: stateB1,
                                      transitions: [FiniteStateMachine.Transition(origin: stateB1, input: "a", destination: stateB2),
                                                    FiniteStateMachine.Transition(origin: stateB2, input: "d", destination: stateB3),
                                                    FiniteStateMachine.Transition(origin: stateB3, input: "b", destination: stateB1)])

        var composedFsm = fsm1.composeInParallel(with: fsm2)

        print (composedFsm.currentState)
        composedFsm.receive(input: "a")
        print (composedFsm.currentState)
        composedFsm.receive(input: "a")
        print (composedFsm.currentState)
        composedFsm.receive(input: "a")
        print (composedFsm.currentState)
        composedFsm.receive(input: "a")
        print (composedFsm.currentState)
        composedFsm.receive(input: "b")
        print (composedFsm.currentState)
        composedFsm.receive(input: "b")
        print (composedFsm.currentState)
        
//        fsm1.addEvent({ _ in
//            print ("Bla bla")
//        }, to: FiniteStateMachine.Transition(origin: state1, input: .a, destination: state2))

    }

}
