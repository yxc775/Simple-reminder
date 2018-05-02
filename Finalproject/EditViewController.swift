//
//  EditViewController.swift
//  Final project
//
//  Created by Yufan Chen on 2018/4/26.
//  Copyright © 2018年 Yufan Chen. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var content: UITextField!
    
    @IBOutlet weak var date: UIDatePicker!
    
    @IBOutlet weak var priority: UISlider!
    
    var storep: Float?
    var storec: String?
    var stored: Date?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(stored != nil){
            date.setDate(stored!, animated: true)
        }
        
        if(storec != nil){
            content.text = storec!;
        }
        
        if(storep != nil){
            priority.setValue(storep!, animated: true)
        }
        
        
        // Do any additional setup after loading the view.
        content.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //weightField.resignFirstResponder()
        //heightField.resignFirstResponder()
        self.view.endEditing(true)
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
