//
//  LoginViewController.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 06/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit
import CoreLocation

class LoginViewController: UIViewController,responseDelegate,CLLocationManagerDelegate {

    @IBOutlet var txtEmail : UITextField!
    @IBOutlet var txtPassword : UITextField!
    @IBOutlet var btnSignIn : UIButton!
    
    var locationManager = CLLocationManager()
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var strCountry : String = ""
    var strCity : String = ""
    var strZip : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        btnSignIn.layer.cornerRadius = btnSignIn.frame.size.height/2
        
        self.setupTextField(textField: txtEmail)
        self.setupTextField(textField: txtPassword)
        
//        txtEmail.text = "dharmesh.sonani6061@gmail.com"
//        txtPassword.text = "123456"
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        latitude = (location?.coordinate.latitude)!
        longitude = (location?.coordinate.longitude)!
    }
    
    func setupTextField(textField:UITextField)
    {
        textField.attributedPlaceholder = NSAttributedString.init(string: textField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.kern:2.0])
    }
    
    @IBAction func clickOnBack(sender:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
   
    @IBAction func clickOnLogin(sender:UIButton)
    {
        if txtEmail.text == ""
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
        else{
        
        self.view.endEditing(true)
        
            let DeviceToken = UserDefaults.standard.object(forKey: "DeviceToken") as? String ?? ""
            
        let strParameters = String.init(format: "email=%@&password=%@&device_type=ios&device_token=%@&device_id=%@",txtEmail.text!,txtPassword.text!,DeviceToken,UIDevice.current.identifierForVendor!.uuidString)
        
        let strURL = "\(SERVER_URL)/login"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "login", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
        }
    }

    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            if ServiceName == "login"{
            
                if Response.value(forKey: "responseCode") as? Int == 200
                {
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
                        
                        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "update-location", bodyObject: dic as AnyObject, delegate: self, isShowProgress: true)
                    })
                    
                    if appDelegate.dicLoginDetail.value(forKey: "phone") as? String == ""
                    {
                        let enterPhoneVC = objAuthenticationSB.instantiateViewController(withIdentifier: "EnterPhoneNumberVC") as! EnterPhoneNumberVC
                        
                        self.navigationController?.pushViewController(enterPhoneVC, animated: true)
                    }
                    else if appDelegate.dicLoginDetail.value(forKey: "bio") as? String == ""
                    {
                        let profileVC = objAuthenticationSB.instantiateViewController(withIdentifier: "ProfileBioVC") as! ProfileBioVC
                        
                        self.navigationController?.pushViewController(profileVC, animated: true)
                    }
                    else{
                        appDelegate.setupTabbarcontroller(selectedIndex: 0)
                    }
 
                }
                else{
                    
                    if Response.value(forKey: "responseMessage") as? String == nil{
                        self.view.makeToast("Server error, please try again")
                    }
                    else{
                        self.view.makeToast(Response.value(forKey: "responseMessage") as? String)
                    }
                }
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
    
    func getUserDetails()
    {
        let strURL = "\(SERVER_URL)/details"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "details", bodyObject: nil, delegate: self, isShowProgress: true)
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
    
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    @IBAction func clickOnForgotPassword(sender:UIButton)
    {
        let enterPhoneVC = self.storyboard?.instantiateViewController(withIdentifier: "EnterPhoneNumberVC") as! EnterPhoneNumberVC
        enterPhoneVC.isFromForgotPassword = true
        self.navigationController?.pushViewController(enterPhoneVC, animated: true)
    }
    
}
