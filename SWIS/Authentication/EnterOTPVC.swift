//
//  EnterOTPVC.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 07/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class EnterOTPVC: UIViewController,VPMOTPViewDelegate,responseDelegate {
    
    @IBOutlet weak var otpView: VPMOTPView!
    @IBOutlet var lbl1 : UILabel!
    @IBOutlet var lbl2 : UILabel!
    
    var enteredOtp: String = ""
    var strPhone : String = ""
    var isFromForgot : Bool = false
    var isFromUpdate : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        otpView.otpFieldsCount = 4
        otpView.otpFieldDefaultBorderColor = UIColor.white
        otpView.otpFieldEnteredBorderColor = UIColor.white
        otpView.otpFieldErrorBorderColor = UIColor.white
        otpView.otpFieldBorderWidth = 2
        otpView.delegate = self
        otpView.shouldAllowIntermediateEditing = false
        
        
        // Create the UI
        otpView.initializeUI()
        
        lbl1.attributedText = NSAttributedString.init(string: lbl1.text!, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.kern:2.0])
        
        lbl2.attributedText = NSAttributedString.init(string: lbl2.text!, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.kern:2.0])
        
       
        
    }
    
    func hasEnteredAllOTP(hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        
        return enteredOtp == "12345"
    }
    
    func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otpString: String) {
        enteredOtp = otpString
        print("OTPString: \(otpString)")
        
        self.verifyOTP(otpString: otpString)
    }
    
    func verifyOTP(otpString:String)
    {
        
        let strParameters = String.init(format: "otp=%@&phone=%@",otpString,strPhone)
        
        let strURL = "\(SERVER_URL)/otp/verify"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "otp", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
        
        
    }
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            if Response.value(forKey: "responseCode") as! Int == 200
            {
                self.view!.makeToast((Response.value(forKey: "responseMessage") as! String), duration: 1.0, position: CSToastManager.defaultPosition(), title: nil, image: nil, style: CSToastManager.sharedStyle(), completion: { (true) in
                    
                    if Response.value(forKey: "responseMessage") as! String != "OTP is invalid"{
                        
                        if self.isFromForgot{
                            
                            let changePasswordVC = objEditProfileSB.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
                            changePasswordVC.strPhone = self.strPhone
                            self.navigationController?.pushViewController(changePasswordVC, animated: true)
                        }
                        else{
                            
                            if self.isFromUpdate{
                                
                                self.view!.makeToast("Phone number successfully updated", duration: 1.0, position: CSToastManager.defaultPosition(), title: nil, image: nil, style: CSToastManager.sharedStyle(), completion: { (true) in
                                    
                                    appDelegate.dicLoginDetail = Response.object(forKey: "user") as? NSDictionary
                                    
                                    let data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.dicLoginDetail)
                                    
                                    UserDefaults.standard.set(data, forKey: "LoginDetail")
                                    UserDefaults.standard.synchronize()
                                    
                                    self.navigationController?.popToRootViewController(animated: true)
                                    
                                })
                                
                            }
                            else{
                                
                                let profileVC = objAuthenticationSB.instantiateViewController(withIdentifier: "ProfileBioVC") as! ProfileBioVC
                                
                                self.navigationController?.pushViewController(profileVC, animated: true)
                            }
                            
                        }
                    }
                })
                
            }
        }
    }
    
    @IBAction func clickOnBack(sender:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
}

