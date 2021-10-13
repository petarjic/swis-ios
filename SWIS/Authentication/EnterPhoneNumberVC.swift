//
//  EnterPhoneNumberVC.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 07/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit


class EnterPhoneNumberVC: UIViewController,UITextFieldDelegate,responseDelegate,CountryListDelegate {

    @IBOutlet var lblEnterPhone : UILabel!
    @IBOutlet var phoneView : UIView!
    @IBOutlet var lblBottomText : UILabel!
    @IBOutlet var txtPhone : DTTextField!
    @IBOutlet var imgDelete : UIImageView!
    @IBOutlet var btnCountryCode : UIButton!
    @IBOutlet var lblCode : UILabel!
    @IBOutlet var imgDropDown : UIImageView!

    var isValidPhone : Bool  = false
    var isFromForgotPassword : Bool  = false
    var isFromUpdatePhone : Bool  = false
    var strCountryCode : String = "1"
   // var isVerifyPhone : Bool  = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        phoneView.layer.borderWidth = 1
        phoneView.layer.borderColor = UIColor.white.cgColor
        phoneView.layer.cornerRadius = phoneView.frame.size.height/2
        
        lblEnterPhone.attributedText = NSAttributedString.init(string: lblEnterPhone.text!, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.kern:2.0])
        
      //  lblBottomText.attributedText = NSAttributedString.init(string: lblBottomText.text!, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.kern:2.0])
        
        let tapgesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnDelete))
        imgDelete.addGestureRecognizer(tapgesture)
        
        if self.isFromUpdatePhone{
            
            lblEnterPhone.text = "Enter your registered phone number and we will send you an otp to verify"
        }
        
        let toolBar = UIToolbar.init(frame: CGRect.init(x: 0, y: 240, width: self.view.frame.size.width, height: 44))
        
        let btnCancel = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(self.clickOnCancel))
        
        let btnDone = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(self.clickOnDone))
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolBar.tintColor = UIColor.black
        
        toolBar.items = [btnCancel,flexibleSpace,btnDone]
        
        txtPhone.inputAccessoryView = toolBar
        
        self.lblCode.text = "+1"
        self.lblCode.sizeToFit()
        
        var frame = CGRect()
        
        frame = lblCode.frame
        frame.origin.y = 5
        frame.size.height = 30
        lblCode.frame = frame
        
        frame = imgDropDown.frame
        frame.origin.x = lblCode.frame.origin.x + lblCode.frame.size.width + 5
        imgDropDown.frame = frame
    }
    
    @objc func clickOnCancel()
    {
        txtPhone.resignFirstResponder()
    }
    @objc func clickOnDone()
    {
        //txtPhone.resignFirstResponder()
        
      //  if self.isFromForgotPassword{
            self.sendOTP()
       // }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden = true

        txtPhone.becomeFirstResponder()
    }

    @IBAction func textFiledDidChange(textField:UITextField)
    {
        var strPhone = textField.text!
        
        if strPhone.count == 10
        {
            if self.isFromForgotPassword{
              
            }
            else{
              //  self.isVerifyPhone = true
              //  self.verifyPhone()
            }
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func verifyPhone()
    {
        let strPhone = "\(self.strCountryCode)\(txtPhone.text!)"

        let strParameters = String.init(format: "phone=%@",strPhone)
            
        let strURL = "\(SERVER_URL)/verify/phone"
            
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "phone", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: false)
        
    }
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            if ServiceName == "phone"
            {
              //  self.isVerifyPhone = false
                
                if Response.value(forKey: "responseCode") == nil{
                    
                    self.isValidPhone = false
                    let arrPhone = Response.object(forKey: "phone") as! NSArray
                    if arrPhone.count > 0{
                        self.txtPhone.showError(message: (arrPhone.object(at: 0) as! String))
                    }
                    
                }else{
                    if Response.value(forKey: "responseCode") as? Int != 200
                    {
                        self.isValidPhone = false
                        self.txtPhone.showError(message: Response.value(forKey: "responseMessage") as? String)
                    }
                    else{
                        self.isValidPhone = true
                    }
                }
              
                
            }
            else{
                
                if Response.value(forKey: "responseCode") as? Int == 200
                {
                    let enterOTPVC = objAuthenticationSB.instantiateViewController(withIdentifier: "EnterOTPVC") as! EnterOTPVC
                    if self.isFromForgotPassword{
                        enterOTPVC.isFromForgot = true
                    }
                    else if self.isFromUpdatePhone{
                        enterOTPVC.isFromUpdate = true
                    }
                    enterOTPVC.strPhone =  "\(self.strCountryCode)\(self.txtPhone.text!)"

                   self.navigationController?.pushViewController(enterOTPVC, animated: true)
                }
                else{
                    
                    DispatchQueue.main.async {
                       // self.view.endEditing(true)
                        self.txtPhone.showError(message: Response.value(forKey: "responseMessage") as? String)
                        //self.view.makeToast(Response.value(forKey: "responseMessage") as? String)
                    }
                }
            }
        }
    }
    
    @objc func tapOnDelete()
    {
        self.txtPhone.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       
        let strPhone = textField.text!
        
        if strPhone.count < 10{
            self.view.makeToast("Please enter correct phone number.")
        }
        else{
            
          //  if self.isVerifyPhone{
              //  GlobalFunction.showAlertMessage("Phone validation in progress...")
           // }
           // else{
               // if self.isFromForgotPassword{
                    //self.sendOTP()
              //  }
            //}
          
        }
    
    }
    
    func sendOTP()
    {
        let strPhone = "\(self.strCountryCode)\(txtPhone.text!)"
        
        if self.isFromForgotPassword{
            
            let strParameters = String.init(format: "phone=%@&old_user=1",strPhone)
            
            let strURL = "\(SERVER_URL)/otp/send"
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "send", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
        }
        else{
            
            let strParameters = String.init(format: "phone=%@",strPhone)
            
            let strURL = "\(SERVER_URL)/otp/send"
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "send", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
        }
       
    }
    
    @IBAction func clickOnBack(sender:UIButton)
    {       
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickOnSelectCountry(sender:UIButton)
    {
        let countryListVC = CountryList()
        countryListVC.delegate = self
        
        let navigation = UINavigationController.init(rootViewController: countryListVC)
        self.present(navigation, animated: true, completion: nil)
    }
    
    func selectedCountry(country: Country) {
        
        self.strCountryCode = country.phoneExtension
        
        self.lblCode.text = "+\(country.phoneExtension)"
        self.lblCode.sizeToFit()
        
        var frame = CGRect()
        
        frame = lblCode.frame
        frame.origin.y = 5
        frame.size.height = 30
        lblCode.frame = frame
        
        frame = imgDropDown.frame
        frame.origin.x = lblCode.frame.origin.x + lblCode.frame.size.width + 5
        imgDropDown.frame = frame
        
        frame = txtPhone.frame
        frame.origin.x = imgDropDown.frame.origin.x + imgDropDown.frame.size.width + 5
        txtPhone.frame = frame
    }

}
