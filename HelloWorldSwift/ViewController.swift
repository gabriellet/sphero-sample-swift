//
//  Copyright (c) 2011-2014 orbotix. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var robot: RKConvenienceRobot!
    var ledON = false
    var units = 1.0
    var dir = "forward"
    
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var leftStepper: UIStepper!
    @IBOutlet weak var rightStepper: UIStepper!
    @IBOutlet weak var forwardStepper: UIStepper!
    @IBOutlet weak var backwardStepper: UIStepper!
    @IBOutlet weak var leftUnitsAmount: UILabel!
    @IBOutlet weak var rightUnitsAmount: UILabel!
    @IBOutlet weak var forwardUnitsAmount: UILabel!
    @IBOutlet weak var backwardUnitsAmount: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.appWillResignActive(_:)), name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.appDidBecomeActive(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        RKRobotDiscoveryAgent.sharedAgent().addNotificationObserver(self, selector: #selector(ViewController.handleRobotStateChangeNotification(_:)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        connectionLabel = nil;
    }

    /* required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    } */
    
    @IBAction func sleepButtonTapped(sender: AnyObject) {
        if let robot = self.robot {
            connectionLabel.text = "Sleeping"
            robot.sleep()
        }
    }
    
    @IBAction func rightStepperPressed(sender: UIStepper) {
        rightUnitsAmount.text = String(sender.value)
    }
    @IBAction func forwardStepperPressed(sender: UIStepper) {
        forwardUnitsAmount.text = String(sender.value)
    }
    @IBAction func backwardStepperPressed(sender: UIStepper) {
        backwardUnitsAmount.text = String(sender.value)
    }
    @IBAction func leftStepperPressed(sender: UIStepper) {
        leftUnitsAmount.text = String(sender.value)
    }
    @IBAction func leftButtonPressed(sender: UIButton) {
        driveRobot("left", units: leftStepper.value)
    }
    @IBAction func rightButtonPressed(sender: UIButton) {
        driveRobot("right", units: rightStepper.value)
    }
    @IBAction func forwardButtonPressed(sender: UIButton) {
        driveRobot("forward", units: forwardStepper.value)
    }
    @IBAction func backwardButtonPressed(sender: UIButton) {
        driveRobot("backward", units: backwardStepper.value)
        
    }
    
    func appWillResignActive(note: NSNotification) {
        RKRobotDiscoveryAgent.disconnectAll()
        stopDiscovery()
    }
    
    func appDidBecomeActive(note: NSNotification) {
        startDiscovery()
    }
    
    func handleRobotStateChangeNotification(notification: RKRobotChangedStateNotification) {
        let noteRobot = notification.robot
        
        switch (notification.type) {
        case .Connecting:
            connectionLabel.text = "\(notification.robot.name()) Connecting"
            break
        case .Online:
            let conveniencerobot = RKConvenienceRobot(robot: noteRobot);
            
            if (UIApplication.sharedApplication().applicationState != .Active) {
                conveniencerobot.disconnect()
            } else {
                self.robot = RKConvenienceRobot(robot: noteRobot);
                
                connectionLabel.text = noteRobot.name()
                toggleRed()
                //driveBackward()
                //togleLED()
                
            }
            break
        case .Disconnected:
            connectionLabel.text = "Disconnected"
            startDiscovery()
            robot = nil;
            
            break
        default:
            NSLog("State change with state: \(notification.type)")
        }
    }
    
    func startDiscovery() {
        connectionLabel.text = "Discovering Robots"
        RKRobotDiscoveryAgent.startDiscovery()
    }
    
    func stopDiscovery() {
        RKRobotDiscoveryAgent.stopDiscovery()
    }
    
    func driveRobot(dir: String, units: Double) {
        var head = 0.0
        if let robot = self.robot {
            switch dir {
                case "forward": head = 0.0
                case "right": head = 90.0
                case "backward": head = 180.0
                case "left": head = 270.0
                default: break
            }
            robot.sendCommand(RKRollCommand(heading: Float(head), velocity: 1.0, andDistance: Float(units)))
        }
    }
    
    func driveForward() {
        if let robot = self.robot {
            robot.sendCommand(RKSetHeadingCommand(heading: 0.0))
            robot.sendCommand(RKRollCommand(heading: 0.0, velocity: 1.0))
            
            let delay = Int64(0.5 * Float(NSEC_PER_SEC))
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), { () -> Void in
                self.driveBackward()
                self.toggleRed()
            })
        }
    }
    
    func driveBackward() {
        if let robot = self.robot {
            robot.sendCommand(RKRollCommand(heading: 180.0, velocity: 1.0))
        }
    }

    
    func toggleGreen() {
        if let robot = self.robot {
            if (ledON) {
                robot.setLEDWithRed(0.0, green: 0.0, blue: 0.0)
            } else {
                robot.setLEDWithRed(0.0, green: 0.8, blue: 0.0)
            }
            ledON = !ledON
            
            let delay = Int64(0.5 * Float(NSEC_PER_SEC))
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), { () -> Void in
                self.toggleGreen()
            })
        }
    }
    
    func toggleRed() {
        if let robot = self.robot {
            if (ledON) {
                robot.setLEDWithRed(0.0, green: 0.0, blue: 0.0)
            } else {
                robot.setLEDWithRed(0.8, green: 0.0, blue: 0.0)
            }
            ledON = !ledON
            
            let delay = Int64(0.5 * Float(NSEC_PER_SEC))
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), { () -> Void in
                self.toggleRed()
            })
        }
    }
}

