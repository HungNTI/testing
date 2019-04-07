//
//  SettingsViewController.swift
//  testing
//
//  Created by Nguyễn Hùng on 3/30/19.
//  Copyright © 2019 Quantizen Inc. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: class {
    func settingsViewControllerDidCancel(_ controller: SettingsViewController)
    func settingsViewControllerDidSave(_ controller: SettingsViewController, didFinishSetting warningProfile: Warning)
}

class SettingsViewController: UITableViewController {
    weak var delegate: SettingsViewControllerDelegate?
    
    var warning = Warning()
    var noise = Noise()
    
    @IBOutlet weak var peakRefreshRateLabel: UILabel!
    @IBOutlet weak var avgRefreshRateLabel: UILabel!
    @IBOutlet weak var warningLevelLabel: UILabel!
    @IBOutlet weak var segmentedAlarmModeControl: UISegmentedControl!
    @IBOutlet weak var segmentedEviromentModeControl: UISegmentedControl!
    @IBOutlet weak var warningLevelSlider: UISlider!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    

    // MARK: - Navigation

    @IBAction func peakRefreshRateUp(_ sender: UIButton) {
        noise.dBPeakRefreshRate = noise.dBPeakRefreshRate + 0.1
        peakRefreshRateLabel.text = String(Float(noise.dBPeakRefreshRate))
    }
    @IBAction func peakRefreshRateDown(_ sender: UIButton) {
        noise.dBPeakRefreshRate = noise.dBPeakRefreshRate - 0.1
        peakRefreshRateLabel.text = String(Float(noise.dBPeakRefreshRate))
    }

    @IBAction func avgRefreshRateUp(_ sender: UIButton) {
        noise.dBAvgRefreshRate = noise.dBAvgRefreshRate + 0.1
        avgRefreshRateLabel.text = String(Float(noise.dBAvgRefreshRate))
    }
    @IBAction func avgRefreshRateDown(_ sender: UIButton) {
        noise.dBAvgRefreshRate = noise.dBAvgRefreshRate - 0.1
        avgRefreshRateLabel.text = String(Float(noise.dBAvgRefreshRate))
    }
    @IBAction func setWarningLevel(_ sender: UISlider) {
        warning.warningLevel = Int(warningLevelSlider.value.rounded())
        warningLevelLabel.text = String(warning.warningLevel)
        print(warning.warningLevel)
    }
    @IBAction func selectAlarmMode(_ sender: Any) {
        switch segmentedAlarmModeControl.selectedSegmentIndex {
        case 0:
            warning.warningMode = "Sound"
        case 1:
            warning.warningMode = "Vibrate"
        case 2:
            warning.warningMode = "NoAlarm"
        default:
            break
        }
    }
    @IBAction func selectEviromentMode(_ sender: UISegmentedControl) {
        switch segmentedEviromentModeControl.selectedSegmentIndex {
        case 0:
            warning.warningLevel = 70
        case 1:
            warning.warningLevel = 80
        case 2:
            warning.warningLevel = 55
        default:
            break
        }
       updateUI()
    }
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        delegate?.settingsViewControllerDidCancel(self)
        //navigationController?.popViewController(animated: true)
    }
    @IBAction func save(_ sender: UIBarButtonItem) {
        delegate?.settingsViewControllerDidSave(self, didFinishSetting: warning)
//        warning.warningLevel = Int(warningLevelSlider.value.rounded())
//        print(warning.warningLevel)
//
//        navigationController?.popViewController(animated: true)
    }
    
    func updateUI() {
        warningLevelSlider.value = Float(warning.warningLevel)
        warningLevelLabel.text = String(warning.warningLevel)

    }
    
}
