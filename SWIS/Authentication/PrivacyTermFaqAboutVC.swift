//
//  PrivacyTermFaqAboutVC.swift
//  SWIS
//
//  Created by Rp on 05/04/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class PrivacyTermFaqAboutVC: UIViewController {
    
    var strType = String()
    
    @IBOutlet weak var txtDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if strType == "1"{
            
    //        print(appDelegate.strPrivacy)
            
            txtDescription.attributedText = (appDelegate.strPrivacy as String).html2AttributedString
            
        }else if strType == "2"{
            
            txtDescription.attributedText = (appDelegate.strTerm as String).html2AttributedString
            
        }else if strType == "3"{
            
            txtDescription.attributedText = (appDelegate.strFaq as String).html2AttributedString
            
        }else if strType == "4"{
            
            txtDescription.attributedText = (appDelegate.strAbout as String).html2AttributedString
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
       self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.init(name: "FiraSans-Bold", size: 15),NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.kern:2.0]
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.isHidden = false
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back-icon.png"), style: .plain, target: self, action: #selector(self.clickOnBack))
        
        if strType == "1"{
            self.navigationItem.title = "Privacy Policy"
        }else if strType == "2"{
            self.navigationItem.title = "Terms and Condition"
        }else if strType == "3"{
            self.navigationItem.title = "FAQ"
           
        }else if strType == "4"{
            self.navigationItem.title = "About"
        }
    }
    
    @objc func clickOnBack()
    {
        self.navigationController?.popViewController(animated: true)
    }

}
extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
