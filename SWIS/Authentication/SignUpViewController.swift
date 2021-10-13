//
//  PageViewController.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 07/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit
import CoreLocation

class SignUpViewController: UIViewController,responseDelegate,UITextFieldDelegate,CLLocationManagerDelegate,UIGestureRecognizerDelegate {

    @IBOutlet var txtuserName : DTTextField!
    @IBOutlet var txtFullName : DTTextField!
    @IBOutlet var txtEmail : DTTextField!
    @IBOutlet var txtPassword : DTTextField!
    @IBOutlet var txtRepeatPassword : DTTextField!
    @IBOutlet var btnSignUp : UIButton!
    @IBOutlet var btnAlready : UIButton!
    @IBOutlet weak var imgViewCheckMark: UIImageView!
    
    var isAlreadyUserName : Bool = false
    var isAlreadyEmail : Bool = false
    var strCountry : String = ""
    var strCity : String = ""
    var strZip : String = ""
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var isAcceptTerms : Bool = false
    
    var isFromCreatedAcount: Bool = false
    var locationManager = CLLocationManager()

    
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
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapOnCheckMark(gesture:)))
        tapGesture.delegate = self
        imgViewCheckMark.isUserInteractionEnabled = true
        imgViewCheckMark.addGestureRecognizer(tapGesture)
     
        self.setupUnderline()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isFromCreatedAcount == true {
            txtuserName.isUserInteractionEnabled = false
            txtPassword.isUserInteractionEnabled = false
            txtRepeatPassword.isUserInteractionEnabled = false
        } else {
            txtuserName.isUserInteractionEnabled = true
            txtPassword.isUserInteractionEnabled = true
            txtRepeatPassword.isUserInteractionEnabled = true
        }
    }
    
    @objc func tapOnCheckMark(gesture:UITapGestureRecognizer){
        
        if imgViewCheckMark.image == UIImage.init(named: "UncheckMarkImg")
        {
            self.isAcceptTerms = true
            imgViewCheckMark.image = UIImage.init(named: "CeckMarkImg")
            
        }else{
            
            self.isAcceptTerms = false
            imgViewCheckMark.image = UIImage.init(named: "UncheckMarkImg")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        latitude = (location?.coordinate.latitude)!
        longitude = (location?.coordinate.longitude)!
        
    }
    
    func setupTextField(textField:DTTextField)
    {
        textField.floatingDisplayStatus = .never
        textField.borderStyle = .none
        
        textField.attributedPlaceholder = NSAttributedString.init(string: textField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.kern:2.0])
    }
    
    func setupUnderline()
    {
        let strTextbtnSignUp = "Already have an account? Sign in" as! NSString
        
        let attribute = NSMutableAttributedString.init(string: strTextbtnSignUp as String)
        
        let range = strTextbtnSignUp.range(of: "Sign in")
        let range2 = strTextbtnSignUp.range(of: "Already have an account?")
        
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range2)
        
        attribute.addAttribute(NSAttributedString.Key.font, value: UIFont.init(name: "FiraSans-LightItalic", size: 16), range: NSMakeRange(0, strTextbtnSignUp.length))
        
        attribute.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range)
        
        btnAlready.setAttributedTitle(attribute, for: .normal)
        
    }
    
    @IBAction func clickOnSignIn(sender:UIButton)
    {
        let loginVC = objAuthenticationSB.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
   
    @IBAction func clickOnBack(sender:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickOnSignUp(sender:UIButton)
    {
        self.view.endEditing(true)
        
        if txtuserName.text == ""
        {
            self.view.makeToast("Please enter username")
        }
        else if txtFullName.text == ""
        {
            self.view.makeToast("Please enter fullname")
        }
        else if txtEmail.text == ""
        {
            self.view.makeToast("Please enter email")
        }
        else if !self.isValidEmail(testStr: txtEmail.text!)
        {
            self.view.makeToast("Please enter valid email")
        }
        else if txtPassword.text == ""
        {
            self.view.makeToast("Please enter password")
        }
        else if (txtPassword.text?.count)! < 6
        {
            self.view.makeToast("Password must contain at least 6 characters")
        }
        else if txtPassword.text != txtRepeatPassword.text
        {
            self.view.makeToast("Repeat password does not match")
        }
        else if !self.isAcceptTerms
        {
            self.view.makeToast("Please accept our Terms & Conditions and Privacy Policy")
        }
        else{
            
            if !self.isAlreadyUserName && !self.isAlreadyEmail
            {
            
                if isFromCreatedAcount == true {
                    
                    let strURL = "\(SERVER_URL)/update/profile"
                    
                    let strParameters = String.init(format: "username=%@&name=%@&email=%@",self.txtuserName.text!,txtFullName.text!,txtEmail.text!)
                    
                    WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "updateProfile", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
                    
                } else {
                    let strParameters = String.init(format: "name=%@&username=%@&email=%@&password=%@&device_type=ios&device_token=%@&device_id=%@",self.txtFullName.text!,self.txtuserName.text!,self.txtEmail.text!,self.txtPassword.text!,appDelegate.strDeviceToken,UIDevice.current.identifierForVendor!.uuidString)
                    
                    let strURL = "\(SERVER_URL)/register"
                    
                    WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "register", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
                }
               
            }
        }
    }
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            if ServiceName == "email"
            {
                if Response.value(forKey: "responseCode") as? Int != 200
                {
                    self.isAlreadyEmail = true
                    
                    self.txtEmail.showError(message: Response.value(forKey: "responseMessage") as? String)
                }
                else{
                    self.isAlreadyEmail = false
                }
                
            }
            else if ServiceName == "username"
            {
                if Response.value(forKey: "responseCode") as? Int != 200
                {
                    self.isAlreadyUserName = true
                   
                    self.txtuserName.showError(message: Response.value(forKey: "responseMessage") as? String)
                }
                else{
                    self.isAlreadyUserName = false
                }
            }
            else if ServiceName == "update-location"{
                
            } else if ServiceName == "updateProfile" {
                
                appDelegate.dicLoginDetail = Response.object(forKey: "user") as? NSDictionary
                
                let data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.dicLoginDetail)
                
                UserDefaults.standard.set(data, forKey: "LoginDetail")
                UserDefaults.standard.synchronize()
                
                self.isFromCreatedAcount = true
                let enterPhoneVC = objAuthenticationSB.instantiateViewController(withIdentifier: "EnterPhoneNumberVC") as! EnterPhoneNumberVC
                
                self.navigationController?.pushViewController(enterPhoneVC, animated: true)
                
            } else{
                
                if Response.value(forKey: "responseCode") as? Int == 200
                {
                    self.view!.makeToast((Response.value(forKey: "responseMessage") as! String), duration: 1.0, position: CSToastManager.defaultPosition(), title: nil, image: nil, style: CSToastManager.sharedStyle(), completion: { (true) in
                        
                        self.isFromCreatedAcount = true
                        let enterPhoneVC = objAuthenticationSB.instantiateViewController(withIdentifier: "EnterPhoneNumberVC") as! EnterPhoneNumberVC
                        
                        self.navigationController?.pushViewController(enterPhoneVC, animated: true)
                    })
                    
                    appDelegate.dicLoginDetail = Response.object(forKey: "user") as? NSDictionary
                    
                    let data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.dicLoginDetail)
                    
                    UserDefaults.standard.set(data, forKey: "LoginDetail")
                    UserDefaults.standard.synchronize()
                    
                    UserDefaults.standard.set(appDelegate.dicLoginDetail.value(forKey: "api_token"), forKey: "api_token")
                    UserDefaults.standard.synchronize()
                    
                    self.getAddress(handler: { (strAddress) in
                        
                        let dic = NSMutableDictionary()
                        dic.setValue(strAddress, forKey: "address")
                        dic.setValue(self.strCity, forKey: "city")
                        dic.setValue(self.strCountry, forKey: "country")
                        dic.setValue(self.strZip, forKey: "zip")
                        dic.setValue("\(self.latitude)", forKey: "latitude")
                        dic.setValue("\(self.longitude)", forKey: "longitude")
                        
                        let strURL = "\(SERVER_URL)/update-location"
                        
                        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "update-location", bodyObject: dic as AnyObject, delegate: self, isShowProgress: false)
                    })
                    
                }
                else if ServiceName == "update-location"
                {
                    appDelegate.dicLoginDetail = Response.object(forKey: "user") as? NSDictionary
                    
                    let data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.dicLoginDetail)
                    
                    UserDefaults.standard.set(data, forKey: "LoginDetail")
                    UserDefaults.standard.synchronize()
                    
                }
            }
            
        }
    }
    
    func getAddress(handler: @escaping (String) -> Void)
    {
        var address: String = ""
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        //selectedLat and selectedLon are double values set by the app in a previous process
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark?
            placeMark = placemarks?[0]
            
            // Location name
            if let locationName = placeMark?.name {
                address += locationName + ", "
            }
            
            // City
            if let city = placeMark?.addressDictionary?["City"] as? String {
                address += city + ", "
                self.strCity = city
            }
            
            if let subLocality = placeMark?.subLocality {
                address += subLocality + ", "
            }
            
            if let state = placeMark?.administrativeArea {
                address += state + ", "
            }
            
            // Zip code
            if let zip = placeMark?.addressDictionary?["ZIP"] as? String {
                address += zip + ", "
                self.strZip = zip
            }
            
            // Country
            if let country = placeMark?.addressDictionary?["Country"] as? String {
                address += country
                self.strCountry = country
            }
            
            // Passing address back
            handler(address)
        })
    }
    
    func verifyEmail()
    {
        let strParameters = String.init(format: "email=%@",txtEmail.text!)
        
        let strURL = "\(SERVER_URL)/verify/email"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "email", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: false)
    }
    
    func isValidEmail(testStr:String) -> Bool {
       
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    @IBAction func textFiledDidChange(textField:UITextField)
    {
        if textField == txtEmail
        {
            if self.isValidEmail(testStr: txtEmail.text!)
            {
                self.verifyEmail()
            }
        }
        else if textField == txtuserName
        {
            self.txtuserName.text = self.txtuserName.text?.replacingOccurrences(of: " ", with: "_")
            
            self.perform(#selector(self.checkUserName), with: nil, afterDelay: 2.0)
        }
    }
    
    @objc func checkUserName()
    {
        let strParameters = String.init(format: "username=%@",txtuserName.text!)
        
        let strURL = "\(SERVER_URL)/verify/username"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "username", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    @IBAction func clickOnBackTop(sender:UIButton)
    {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func btnPrivcy(_ sender: Any) {
        
        if imgViewCheckMark.image == UIImage.init(named: "UncheckMarkImg")
        {
            self.isAcceptTerms = true
            imgViewCheckMark.image = UIImage.init(named: "CeckMarkImg")
            
        }else{
            
            self.isAcceptTerms = false
            imgViewCheckMark.image = UIImage.init(named: "UncheckMarkImg")
        }
    }
    
}
