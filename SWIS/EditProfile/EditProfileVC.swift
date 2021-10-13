//
//  EditProfileVC.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 27/02/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit
import SVColorPicker

class EditProfileVC: UIViewController,UITextFieldDelegate,responseDelegate,UIPopoverPresentationControllerDelegate,UITextViewDelegate,UIGestureRecognizerDelegate{

    @IBOutlet var txtName : UITextField!
    @IBOutlet var txtUserName : UITextField!
    @IBOutlet var txtBio : UITextView!
    @IBOutlet var txtBirthday : UITextField!
    @IBOutlet var txtLocation : UITextField!
    @IBOutlet var btnUpdate : UIButton!
    @IBOutlet var txtCountry : UITextField!
    @IBOutlet var txtCity : UITextField!
    @IBOutlet var txtPhoneNumber : UITextField!
    @IBOutlet var btnUpdatePhone : UIButton!
    @IBOutlet var txtEmail : UITextField!
    
    @IBOutlet weak var viewColor: UIView!
    
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var colorDisplayView: UIView!
   
    let datePicker = UIDatePicker()
    var popoverVC : ColorPickerViewController!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        btnUpdate.layer.cornerRadius = btnUpdate.frame.size.height/2
        btnUpdatePhone.layer.cornerRadius = btnUpdatePhone.frame.size.height/2

        txtName.text = appDelegate.dicLoginDetail.value(forKey: "name") as? String
        txtUserName.text = appDelegate.dicLoginDetail.value(forKey: "username") as? String
        txtBio.text = appDelegate.dicLoginDetail.value(forKey: "bio") as? String
        txtPhoneNumber.text = appDelegate.dicLoginDetail.value(forKey: "phone") as? String
        txtCountry.text = appDelegate.dicLoginDetail.value(forKey: "country") as? String
        txtCity.text = appDelegate.dicLoginDetail.value(forKey: "city") as? String
        txtLocation.text = appDelegate.dicLoginDetail.value(forKey: "address") as? String
        txtBirthday.text = appDelegate.dicLoginDetail.value(forKey: "dob") as? String
        txtEmail.text = appDelegate.dicLoginDetail.value(forKey: "email") as? String
        
        txtLocation.isUserInteractionEnabled = false

        if appDelegate.dicLoginDetail.value(forKey: "text_color") != nil{
            let color = UIColor.init(hexString: appDelegate.dicLoginDetail.value(forKey: "text_color") as! String, alpha: 1.0)
            self.colorDisplayView.backgroundColor = color

        }
        
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        txtBirthday.inputView = datePicker
        
        let toolBar = UIToolbar.init(frame: CGRect.init(x: 0, y: 240, width: self.view.frame.size.width, height: 44))
        
        let btnCancel = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(self.clickOnCancel))
        
        let btnDone = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(self.clickOnDone))

        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolBar.tintColor = UIColor.black
        
        toolBar.items = [btnCancel,flexibleSpace,btnDone]
        
        txtBirthday.inputAccessoryView = toolBar
        
        colorDisplayView.layer.cornerRadius = colorDisplayView.frame.width * 0.5
        colorDisplayView.layer.borderColor = UIColor.black.cgColor
        colorDisplayView.layer.borderWidth = 2
        
        // ColorPickerView initialisation
        let colorPickerframe = sliderContainerView.bounds
        let colorPicker = ColorPickerView(frame: colorPickerframe)
        colorPicker.didChangeColor = { [unowned self] color in
            
            self.colorDisplayView.backgroundColor = color
        }
        sliderContainerView.addSubview(colorPicker)

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(clickOnColor(gesture:)))
        tapGesture.delegate = self
        viewColor.isUserInteractionEnabled = true
        viewColor.addGestureRecognizer(tapGesture)
    }
    
    @objc func clickOnCancel(){
        txtBirthday.resignFirstResponder()
    }
    
    @objc func clickOnDone()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
        txtBirthday.text = dateFormatter.string(from: datePicker.date)
        
        txtBirthday.resignFirstResponder()

    }
    
    @IBAction func colorPickerButton(_ sender: UIButton) {
        
        popoverVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "colorPickerPopover") as? ColorPickerViewController
    
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: 284, height: 446)
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 85, height: 30)
            popoverController.permittedArrowDirections = .any
            popoverController.delegate = self
            popoverVC.delegate = self
        }
        present(popoverVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    
    func setButtonColor (_ color: UIColor) {
        self.colorDisplayView.backgroundColor = color
        popoverVC.dismiss(animated: true, completion: nil)
    }
    
    func rgbToHex(color: UIColor) -> String {
        
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.isHidden = false
        
        self.navigationItem.title = "Edit Profile"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.init(name: "FiraSans-Bold", size: 15),NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.kern:2.0]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back-icon.png"), style: .plain, target: self, action: #selector(self.clickOnBack))
    }
    
    @objc func clickOnBack()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickOnUpdate(sender:UIButton)
    {
        if txtName.text == ""
        {
            self.view.makeToast("Please enter name")
        }
        else if txtBio.text == ""
        {
            self.view.makeToast("Please enter bio")
        }
        else if txtLocation.text == ""
        {
            self.view.makeToast("Please enter location")
        }
        else{
            let strURL = "\(SERVER_URL)/update/profile"
            
            let strParameters = String.init(format: "name=%@&bio=%@&dob=%@&country=%@&city=%@&text_color=%@&email=%@",txtName.text!,txtBio.text!,txtBirthday.text!,txtCountry.text!,txtCity.text!,self.rgbToHex(color: self.colorDisplayView.backgroundColor!),txtEmail.text!)
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "updateProfile", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
        }
    }
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            if Response.value(forKey: "responseCode") as? Int == 200
            {
                
                let alertController = UIAlertController.init(title: "SWIS", message: Response.value(forKey: "responseMessage") as? String, preferredStyle: .alert)
                
                let actionOk = UIAlertAction.init(title: "OK", style: .default) { (action) in
                    
                    appDelegate.dicLoginDetail = Response.object(forKey: "user") as? NSDictionary
                    
                    let data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.dicLoginDetail)
                    
                    UserDefaults.standard.set(data, forKey: "LoginDetail")
                    UserDefaults.standard.synchronize()
                    
                    alertController.dismiss(animated: true, completion: nil)
                    
                }
                
                alertController.addAction(actionOk)
                
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                let alertController = UIAlertController.init(title: "SWIS", message: Response.value(forKey: "responseMessage") as? String, preferredStyle: .alert)
                
                let actionOk = UIAlertAction.init(title: "OK", style: .default) { (action) in
                    
                    alertController.dismiss(animated: true, completion: nil)
                }
                
                alertController.addAction(actionOk)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == txtBirthday
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            
            txtBirthday.text = dateFormatter.string(from: datePicker.date)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"{
            textView.resignFirstResponder()
        }
        
        if textView.text.count < 160 || text == ""{
            
            return true
        }
        
        return false
    }
    
    @IBAction func clickOnUpdatePhone(sender:UIButton)
    {
        let enterPhoneVC = objAuthenticationSB.instantiateViewController(withIdentifier: "EnterPhoneNumberVC") as! EnterPhoneNumberVC
        enterPhoneVC.isFromUpdatePhone = true
        enterPhoneVC.hidesBottomBarWhenPushed  = true
        self.navigationController?.pushViewController(enterPhoneVC, animated: true)
    
    }
    
    @objc func clickOnColor(gesture:UITapGestureRecognizer){
        
        popoverVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "colorPickerPopover") as? ColorPickerViewController
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: 284, height: 446)
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = gesture.view
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 85, height: 30)
            popoverController.permittedArrowDirections = .any
            popoverController.delegate = self
            popoverVC.delegate = self
        }
        present(popoverVC, animated: true, completion: nil)

    }

}
