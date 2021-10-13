//
//  InviteViewController.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 08/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class InviteViewController: UIViewController,EPPickerDelegate {
    
    @IBOutlet var topView : UIView!
    @IBOutlet var SMSView : UIView!
    @IBOutlet var emailView : UIView!
    @IBOutlet var btnEmail : UIButton!
    @IBOutlet var btnSMS : UIButton!
    var isFromSMS : Bool = true
    @IBOutlet var lblLine : UILabel!
    var lblTotlaSend = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        if self.isFromSMS{
            self.clickOnSMS(sender: btnSMS)
        }
        else{
            self.clickOnEmail(sender: btnEmail)
        }
        
        let topView = self.view.viewWithTag(10) as! UIView
        
        lblTotlaSend = UILabel.init()
        lblTotlaSend.frame = CGRect.init(x: 0, y: 68, width: UIScreen.main.bounds.size.width-10, height: 22)
        lblTotlaSend.isUserInteractionEnabled = true
        lblTotlaSend.textAlignment = .right
        lblTotlaSend.text = "Send (0)"
        lblTotlaSend.isHidden = true
        lblTotlaSend.font = UIFont.init(name: "FiraSans-Book", size: 15)
        lblTotlaSend.textColor = UIColor.init(red: 36.0/255.0, green: 169.0/255.0, blue: 237.0/255.0, alpha: 1.0)
        topView.addSubview(lblTotlaSend)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapOnEmail(gesture:)))
        
        lblTotlaSend.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupSend), name: NSNotification.Name(rawValue: "SendCount"), object: nil)
    }
    
    @objc func setupSend(noti:NSNotification)
    {
        lblTotlaSend.isHidden  = false
        lblTotlaSend.text = noti.object as? String
    }
    
    @objc func tapOnEmail(gesture:UITapGestureRecognizer)
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendEmail"), object: nil, userInfo: nil)
    }
    
    func setupLine(sender:UIButton)
    {
        UIView.animate(withDuration: 1.0) {
            
            var frame = CGRect()
            frame = self.lblLine.frame
            frame.origin.x = sender.frame.origin.x + 10
            frame.size.width = 45
            self.lblLine.frame = frame
        }
        
        
    }
    
    @IBAction func clickOnShare(sender:UIButton)
    {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func clickOnSMS(sender:UIButton)
    {
        lblTotlaSend.isHidden = true
        self.setupLine(sender: sender)
        
        emailView.isHidden = true
        SMSView.isHidden = false
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadSearch"), object: nil, userInfo: nil)
        
        
        if SMSView.viewWithTag(-10) == nil{
            
            let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:true, subtitleCellType: SubtitleCellValue.phoneNumber)
            contactPickerScene.isSMS = true
            contactPickerScene.tableView.frame = CGRect.init(x: 0, y: 0, width: SMSView.frame.size.width, height: SMSView.frame.size.height)
            contactPickerScene.tableView.tag = -10
            SMSView.addSubview(contactPickerScene.view)
            self.addChild(contactPickerScene)
            contactPickerScene.didMove(toParent: self)
            
        }
    }
    
    @IBAction func clickOnEmail(sender:UIButton)
    {
        lblTotlaSend.isHidden  = false
        self.setupLine(sender: sender)
        
        SMSView.isHidden = true
        emailView.isHidden = false
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadSearch"), object: nil, userInfo: nil)
        
        if emailView.viewWithTag(-11) == nil
        {
            let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:true, subtitleCellType: SubtitleCellValue.email)
            contactPickerScene.tableView.tag = -11
            contactPickerScene.isSMS = false
            contactPickerScene.tableView.frame = CGRect.init(x: 0, y: 0, width: emailView.frame.size.width, height: emailView.frame.size.height)
            emailView.addSubview(contactPickerScene.view)
            self.addChild(contactPickerScene)
            contactPickerScene.didMove(toParent: self)
        }
    }
    
    //MARK: EPContactsPicker delegates
    func epContactPicker(_: EPContactsPicker, didContactFetchFailed error : NSError)
    {
        print("Failed with error \(error.description)")
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectContact contact : EPContact)
    {
        print("Contact \(contact.displayName()) has been selected")
    }
    
    func epContactPicker(_: EPContactsPicker, didCancel error : NSError)
    {
        print("User canceled the selection");
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact]) {
        print("The following contacts are selected")
        for contact in contacts {
            print("\(contact.displayName())")
        }
    }
    
    @IBAction func clickOnBack(sender:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
}
