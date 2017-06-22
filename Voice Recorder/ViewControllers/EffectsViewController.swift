//
//  EffectsViewController.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 6/19/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import UIKit

class EffectsViewController: UIViewController {

    var fileName: String!
    
    @IBOutlet weak var echoSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Selected file name is \(fileName)")
    }
    
    @IBAction func echoSliderValueChanged(_ sender: Any) {
        
        print("Slider value is \(echoSlider.value)")
    }
    
    
    
    @IBAction func resetAllNavItemAction(_ sender: Any) {
        resetAllEffects()
    }
    
    func resetAllEffects() {
        
        print("All effects are reset.")
        echoSlider.setValue(0.5, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
