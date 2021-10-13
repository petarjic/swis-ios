//
//  ViewController.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 05/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit
import Crashlytics

class ViewController: UIViewController {
    
    @IBOutlet var btnSignIn : UIButton!
    @IBOutlet var btnSignUp : UIButton!
    @IBOutlet var btnTermsAndCondition : UIButton!
    @IBOutlet var btnPrivacyPolicy : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btnSignIn.layer.cornerRadius = btnSignIn.frame.size.height/2
        btnSignUp.layer.cornerRadius = btnSignUp.frame.size.height/2
        
        btnSignUp.layer.borderWidth = 1
        btnSignUp.layer.borderColor = UIColor.white.cgColor
        
        let attrs = [
            NSAttributedString.Key.font : UIFont.init(name: "FiraSans-Book", size: 14),
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.underlineStyle : 1] as [NSAttributedString.Key : Any]
        
        var attributedString = NSMutableAttributedString(string:"")
        
        let buttonTermsStr = NSMutableAttributedString(string:"Terms and Conditions", attributes:attrs)
        attributedString.append(buttonTermsStr)
        btnTermsAndCondition.setAttributedTitle(attributedString, for: .normal)
        
        let attrs2 = [
            NSAttributedString.Key.font : UIFont.init(name: "FiraSans-Book", size: 14),
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.underlineStyle : 1] as [NSAttributedString.Key : Any]
        
        var attributedString2 = NSMutableAttributedString(string:"")
        
        let buttonPrivacyStr = NSMutableAttributedString(string:"Privacy Policy", attributes:attrs2)
        attributedString2.append(buttonPrivacyStr)
        btnPrivacyPolicy.setAttributedTitle(attributedString2, for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.barTintColor = navigationColor
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
    }
    
    @IBAction func clikcOnSingIn(sender:UIButton)
    {
        
        let loginVC = objAuthenticationSB.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        
        self.navigationController?.pushViewController(loginVC, animated: true)
        
    }
    
    @IBAction func clickOnSignUp(sender:UIButton)
    {
        let signUpVC = objAuthenticationSB.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        
        self.navigationController?.pushViewController(signUpVC, animated: true)
        
    }
    
    @IBAction func clickOnPrivacyAndPolicy(btn:UIButton){
        
        let PrivacyVC = objAuthenticationSB.instantiateViewController(withIdentifier: "PrivacyTermFaqAboutVC") as! PrivacyTermFaqAboutVC
        self.navigationItem.title = ""
        PrivacyVC.strType = "1"
        self.navigationController?.pushViewController(PrivacyVC, animated: true)
        
    }
    
    @IBAction func clickOnTermsAndCondition(_ sender: Any) {
        
        let TermsVC = objAuthenticationSB.instantiateViewController(withIdentifier: "PrivacyTermFaqAboutVC") as! PrivacyTermFaqAboutVC
        self.navigationItem.title = ""
        TermsVC.strType = "2"
        self.navigationController?.pushViewController(TermsVC, animated: true)
        
    }
    
}

