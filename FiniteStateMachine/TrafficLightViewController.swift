//
//  ViewController.swift
//  FiniteStateMachine
//
//  Created by Sebastian Tleye on 23/02/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import UIKit

class TrafficLightViewController: UIViewController {

    enum Light {
        case red
        case yellow
        case green
    }

    enum Transition: Int {
        case `switch` = 0
    }

    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var yellowView: UIView!
    @IBOutlet weak var greenView: UIView!

    private let timeInGreen = 6
    private let timeInYellow = 2
    private let timeInRed = 3

    lazy var red = FiniteStateMachine.State("red", condition: FiniteStateMachine.State.Condition.timer("t", is: <, than: timeInRed))
    lazy var redyellowgreen = FiniteStateMachine.State("red yellow green", condition: FiniteStateMachine.State.Condition.timer("t", is: <, than: timeInYellow))
    lazy var greenyellowred = FiniteStateMachine.State("green yellow red", condition: FiniteStateMachine.State.Condition.timer("t", is: <, than: timeInYellow))
    lazy var green = FiniteStateMachine.State("green", condition: FiniteStateMachine.State.Condition.timer("t", is: <, than: timeInGreen))

    lazy var fsm = FiniteStateMachine(initialState: red,
                                      transitions: [
        FiniteStateMachine.Transition(from: red, to: redyellowgreen, through: Transition.switch.rawValue, condition: { (fsm) -> Bool in
            fsm.variables.timerValueFor("t") >= self.timeInRed
        }, action: { fsm in
            fsm.variables.resetTimer("t")
            self.turnOn(.yellow)
        }),
        FiniteStateMachine.Transition(from: redyellowgreen, to: green, through: Transition.switch.rawValue, condition: { (fsm) -> Bool in
            fsm.variables.timerValueFor("t") >= self.timeInYellow
        }, action: { fsm in
            fsm.variables.resetTimer("t")
            self.turnOn(.green)
        }),
        FiniteStateMachine.Transition(from: green, to: greenyellowred, through: Transition.switch.rawValue, condition: { (fsm) -> Bool in
            fsm.variables.timerValueFor("t") >= self.timeInGreen
        }, action: { fsm in
            fsm.variables.resetTimer("t")
            self.turnOn(.yellow)
        }),
        FiniteStateMachine.Transition(from: greenyellowred, to: red, through: Transition.switch.rawValue, condition: { (fsm) -> Bool in
            fsm.variables.timerValueFor("t") >= self.timeInYellow
        }, action: { fsm in
            fsm.variables.resetTimer("t")
            self.turnOn(.red)
        })
    ])

    override func viewDidLoad() {
        super.viewDidLoad()
        self.turnOn(.red)
        fsm.variables.resetTimer("t")
    }

    private func turnOn(_ light: Light) {
        self.greenView.backgroundColor = UIColor.lightGray
        self.redView.backgroundColor = UIColor.lightGray
        self.yellowView.backgroundColor = UIColor.lightGray
        switch light {
        case .green:
            self.greenView.backgroundColor = UIColor.green
        case .yellow:
            self.yellowView.backgroundColor = UIColor.yellow
        case .red:
            self.redView.backgroundColor = UIColor.red
        }
    }

}
