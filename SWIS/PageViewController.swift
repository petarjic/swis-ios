//
//  PageViewController.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 07/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {

    @IBOutlet var txtuserName : UITextField!
    @IBOutlet var txtFullName : UITextField!
    @IBOutlet var txtEmail : UITextField!
    @IBOutlet var txtPassword : UITextField!
    @IBOutlet var txtRepeatPassword : UITextField!
    @IBOutlet var btnSignUp : UIButton!
    @IBOutlet var btnAlready : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        btnSignUp.layer.cornerRadius = btnSignUp.frame.size.height/2
        btnSignUp.layer.borderWidth = 1
        btnSignUp.layer.borderColor = UIColor.white.cgColor

        self.setupTextField(textField: txtuserName)
        self.setupTextField(textField: txtFullName)
        self.setupTextField(textField: txtEmail)
        self.setupTextField(textField: txtPassword)
        self.setupTextField(textField: txtRepeatPassword)

      
        
    }
    
    func setupTextField(textField:UITextField)
    {
        textField.attributedPlaceholder = NSAttributedString.init(string: textField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.kern:2.0])
    }
   
    @IBAction func clickOnBack(sender:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
}
