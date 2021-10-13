//
//  ReportIssueVC.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 06/04/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class ReportIssueVC: UIViewController,UITextViewDelegate,responseDelegate {

    @IBOutlet var txtView : UITextView!
    @IBOutlet var btnSubmit : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        btnSubmit.layer.cornerRadius = btnSubmit.frame.size.height/2
        
        txtView.layer.borderWidth = 0.5
        txtView.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
       self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.init(name: "FiraSans-Bold", size: 15),NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.kern:2.0]
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.title = "Report an Issue"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back-icon.png"), style: .plain, target: self, action: #selector(self.clickOnBack))
    }
    
    
    @IBAction func clickOnSubmit(sender:UIButton)
    {
        if txtView.text == ""
        {
            self.view.makeToast("Please enter message")
        }
        else{
            
            self.view.endEditing(true)
            
            let strURL = "\(SERVER_URL)/support"
            
            let strParameter = "message=\(txtView.text!)"
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "support", bodyObject: strParameter as AnyObject, delegate: self, isShowProgress: true)
        }
    }
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            if Response.value(forKey: "responseCode") as! Int == 200
            {
                self.view.makeToast((Response.value(forKey: "responseMessage") as! String))
                self.txtView.text = ""
            }
            
        }
    }
    
    @objc func clickOnBack()
    {
        self.navigationController?.popViewController(animated: true)
    }

}
