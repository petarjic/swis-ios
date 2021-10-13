//
//  ChangePasswordVC.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 01/04/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController,UITextFieldDelegate,responseDelegate {

    @IBOutlet var btnConfirm : UIButton!
    @IBOutlet var txtPassword : UITextField!
    @IBOutlet var txtConfirm : UITextField!

    var strPhone : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        btnConfirm.layer.cornerRadius = btnConfirm.frame.size.height/2
        
    }
    
    @IBAction func clickOnConfirm(sender:UIButton)
    {
        if txtPassword.text == ""
        {
            self.view.makeToast("Please enter password")
        }
        else if txtPassword.text != txtConfirm.text
        {
            self.view.makeToast("Repeat password does not match")
        }
        else{
            let strParameters = String.init(format: "phone=%@&password=%@",strPhone,txtPassword.text!)
            
            let strURL = "\(SERVER_URL)/password/reset"
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "password", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
            
        }

    }

    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            if Response.value(forKey: "responseCode") as! Int == 200
            {
                self.view!.makeToast((Response.value(forKey: "responseMessage") as! String), duration: 1.0, position: CSToastManager.defaultPosition(), title: nil, image: nil, style: CSToastManager.sharedStyle(), completion: { (true) in
                  
                    self.navigationController?.popToRootViewController(animated: true)

                })
                
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }

}
