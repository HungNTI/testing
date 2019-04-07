//
//  ViewController.swift
//  testing
//
//  Created by Nguyễn Hùng on 3/30/19.
//  Copyright © 2019 Quantizen Inc. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import AudioToolbox

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate, SettingsViewControllerDelegate {
    
    var noiseRecorder: AVAudioRecorder!
    var levelTimer = Timer()
    var levelTimerArg = Timer()
    var alarmSound: AVAudioPlayer!
    var warningLevel = 70
    var warningMode = false
    var alertNoise = Warning()
    var noise = Noise()

    let correction: Float = 100.0
//    @IBOutlet weak var warningModeSwitch: UISwitch!
//    @IBOutlet weak var segmentedModeControl: UISegmentedControl!
//    @IBOutlet weak var warningLevelLabel: UILabel!
//    @IBOutlet weak var warningLevelSlider: UISlider!
    @IBOutlet weak var peakLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var avgLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        updateUI()
//        warningModeSwitch.isOn = false
    }

    
//    @IBAction func warningModeOnOff(_ sender: UISwitch) {
//        //warningModeSwitch.isOn = !warningModeSwitch.isOn
//        warningMode = warningModeSwitch.isOn
//        print(warningMode)
//    }
//    @IBAction func setWarningLevel(_ sender: UISlider) {
//        print(warningLevelSlider.value.rounded())
//        warningLevel = Int(warningLevelSlider.value.rounded())
//        warningLevelLabel.text = String(alertNoise.warningLevel)
//    }
    @IBAction func measureNoise(_ sender: Any) {
        startRecordingNoise()
    }
//    @IBAction func selectModeWarning(_ sender: UISegmentedControl) {
//        switch segmentedModeControl.selectedSegmentIndex {
//        case 0:
//            print("Classroom")
//            warningLevel = 70
//        case 1:
//            print("Hallway")
//            warningLevel = 80
//        case 2:
//            print("Library")
//            warningLevel = 55
//        default:
//            break
//        }
//        print(warningLevel)
//        updateUI()
//    }
    func updateUI() {
//        warningLevelSlider.value = Float(warningLevel)
//        warningLevelLabel.text = String(warningLevel)
    }
    
    func playSound(){
        let path = Bundle.main.path(forResource: "signal-alert4", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            alarmSound = try AVAudioPlayer(contentsOf: url)
            alarmSound?.numberOfLoops = -1
            alarmSound?.play()
        } catch {
            // couldn't load file :(
        }
    }
    
    func stopSound(){
        alarmSound?.stop()
    }
    
    func showWarning(){
        let message = "Press OK To Stop Warning"
        let warning = UIAlertController(title: "TOO NOISY!!!", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler:
        {
            action in
            self.stopSound()}
        )
        warning.addAction(action)
        present(warning,animated: true, completion: nil)
    }
    
    func startRecordingNoise(){
        let audioFilename = getDocumentsDirectory().appendingPathComponent("noise.caf")
        let recordSettings : [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleIMA4,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: 12800,
            AVLinearPCMBitDepthKey: 16,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        let noiseRecordingSession = AVAudioSession.sharedInstance()
        do {
            try noiseRecordingSession.setCategory(.playAndRecord, mode: .default)
            try noiseRecordingSession.setActive(true)
            try noiseRecorder = AVAudioRecorder(url: audioFilename, settings: recordSettings)
        } catch {
            return
        }
        
        noiseRecorder.prepareToRecord()
        noiseRecorder.isMeteringEnabled = true
        noiseRecorder.record()
        
        levelTimer = Timer.scheduledTimer(timeInterval: noise.dBPeakRefreshRate, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
        levelTimerArg = Timer.scheduledTimer(timeInterval: noise.dBAvgRefreshRate, target: self, selector: #selector(levelTimerCallbackArg), userInfo: nil, repeats: true)
    }
    
    @objc func levelTimerCallback(){
        
        noiseRecorder.updateMeters()
        
        noise.dBPeakValue = Int(noiseRecorder.peakPower(forChannel: 0) + correction)
        if noise.dBPeakValue > noise.dBMaxValue {
            noise.dBMaxValue = noise.dBPeakValue
        }
        
        peakLabel.text = String(Int(noise.dBPeakValue))
        maxLabel.text = String(Int(noise.dBMaxValue))
    }
    
    @objc func levelTimerCallbackArg(){
        noiseRecorder.updateMeters()
        
        let averageNoise = noiseRecorder.averagePower(forChannel: 0) + correction
        
        avgLabel.text = String(Int(averageNoise))
        let isLoud = Int(averageNoise) > alertNoise.warningLevel
        if isLoud && alertNoise.warningMode == "Sound" {
            playSound()
            showWarning()
        } else if isLoud && alertNoise.warningMode == "Vibration" {
            
            showWarning()
        }
        
    }
    
    func getDocumentsDirectory()->URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settings" {
            let controller = segue.destination as! SettingsViewController
            controller.delegate = self
        }
    }
    
    func settingsViewControllerDidCancel(_ controller: SettingsViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func settingsViewControllerDidSave(_ controller: SettingsViewController, didFinishSetting warningProfile: Warning) {
        alertNoise = warningProfile
        navigationController?.popViewController(animated: true)
    }
}

