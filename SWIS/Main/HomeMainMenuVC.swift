//
//  HomeMainMenuVC.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 28/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class HomeMainMenuVC: UIViewController,UITableViewDataSource,UITableViewDelegate,responseDelegate {
    
    @IBOutlet var tblView : UITableView!
    
    var arrMenu = ["Edit Profile","Notifications","Share Searches","Share Searches Locally","Privacy Policy","Terms and Conditions","FAQ","About","Report an Issue","Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tblView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.title = "Settings"
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.init(name: "FiraSans-Bold", size: 15),NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.kern:2.0]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back-icon.png"), style: .plain, target: self, action: #selector(self.clickOnBack))
        
    }
    
    @objc func clickOnBack()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrMenu.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let lblTitle = cell.contentView.viewWithTag(1001) as! UILabel
        
        lblTitle.text = arrMenu[indexPath.row]
        
        let Switch = cell.contentView.viewWithTag(1003) as! UISwitch
        
        if lblTitle.text == "Share Searches" || lblTitle.text == "Share Searches Locally"
        {
            cell.contentView.viewWithTag(1002)?.isHidden = true
            Switch.isHidden = false
            
            if indexPath.row == 2{
                
                if appDelegate.dicLoginDetail.value(forKey: "hide_searches") as? Int == 1{
                    
                    Switch.isOn = false
                }
                else{
                    Switch.isOn = true
                }
            }
            else{
                
                if appDelegate.dicLoginDetail.value(forKey: "share_local_search") as? Int == 0{
                    
                    Switch.isOn = false
                }
                else{
                    Switch.isOn = true
                    
                }
                
            }
            
            Switch.addTarget(self, action: #selector(clickOnSwitch(sender:)), for: .valueChanged)
        }
        else{
            cell.contentView.viewWithTag(1002)?.isHidden = false
            Switch.isHidden = true
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        }
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let strMenu = arrMenu[indexPath.row]
        
        if strMenu == "Edit Profile"
        {
            let settingVC = objEditProfileSB.instantiateViewController(withIdentifier: "SettingViewcontroller") as! SettingViewcontroller
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(settingVC, animated: true)
        }
        else if strMenu == "Notifications"
        {
            let notificationVC = objHomeSB.instantiateViewController(withIdentifier: "NotiicationViewController") as! NotiicationViewController
            
            self.navigationController?.pushViewController(notificationVC, animated: true)
            
        }else if strMenu == "Privacy Policy"{
            
            let PrivacyVC = objAuthenticationSB.instantiateViewController(withIdentifier: "PrivacyTermFaqAboutVC") as! PrivacyTermFaqAboutVC
            self.navigationItem.title = ""
            PrivacyVC.strType = "1"
            self.navigationController?.pushViewController(PrivacyVC, animated: true)
            
        }else if strMenu == "Terms and Conditions"{
            
            let TermsVC = objAuthenticationSB.instantiateViewController(withIdentifier: "PrivacyTermFaqAboutVC") as! PrivacyTermFaqAboutVC
            self.navigationItem.title = ""
            TermsVC.strType = "2"
            self.navigationController?.pushViewController(TermsVC, animated: true)
            
        }else if strMenu == "FAQ"{
            
            let FaqVC = objAuthenticationSB.instantiateViewController(withIdentifier: "PrivacyTermFaqAboutVC") as! PrivacyTermFaqAboutVC
            self.navigationItem.title = ""
            FaqVC.strType = "3"
            self.navigationController?.pushViewController(FaqVC, animated: true)
            
        }else if strMenu == "About"{
            
            let AboutVC = objAuthenticationSB.instantiateViewController(withIdentifier: "PrivacyTermFaqAboutVC") as! PrivacyTermFaqAboutVC
            self.navigationItem.title = ""
            AboutVC.strType = "4"
            self.navigationController?.pushViewController(AboutVC, animated: true)
            
        }
        else if strMenu == "Report an Issue"{
            
            let reportIssueVC = objMainSB.instantiateViewController(withIdentifier: "ReportIssueVC") as! ReportIssueVC
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(reportIssueVC, animated: true)
            
        }
        
        else if strMenu == "Log Out"
        {
            self.clickOnSignOut()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
    
    func clickOnSignOut()
    {
        let alertController = UIAlertController.init(title: "SWIS", message: "Are you sure you want to logout ?", preferredStyle: .alert)
        
        
        let actionNo = UIAlertAction.init(title: "No", style: .default) { (action) in
            
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(actionNo)
        
        let actionYes = UIAlertAction.init(title: "Yes", style: .default) { (action) in
            
            let strURL = "\(SERVER_URL)/logout"
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "logout", bodyObject: nil, delegate: self, isShowProgress: true)
        }
        
        alertController.addAction(actionYes)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func clickOnSwitch(sender:UISwitch)
    {
        var tempView = sender as UIView
        var cell : UITableViewCell!
        
        while true {
            
            tempView = tempView.superview!
            
            if tempView.isKind(of: UITableViewCell.self)
            {
                cell = (tempView as! UITableViewCell)
                break
            }
        }
        
        let indexPath = tblView.indexPath(for: cell)
        
        let Switch = cell.contentView.viewWithTag(1003) as! UISwitch
        
        if indexPath?.row == 2{
            
            var strStatus : String = ""
            
            if appDelegate.dicLoginDetail.value(forKey: "hide_searches") as? Int == 0{
                
                strStatus = "on"
            }
            else{
                strStatus = "off"
                
            }
            
            let strURL = "\(SERVER_URL)/update/profile"
            
            let strParameters = "hide_searches=\(strStatus)"
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "updateProfile", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
        }
        else if indexPath?.row == 3{
            
            var strStatus : String = ""
            
            if appDelegate.dicLoginDetail.value(forKey: "share_local_search") as? Int == 0{
                
                strStatus = "1"
            }
            else{
                strStatus = "0"
            }
            
            let strURL = "\(SERVER_URL)/update/profile"
            
            let strParameters = "share_local_search=\(strStatus)"
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "updateProfile", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
        }
        
    }
    
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            if Response.value(forKey: "responseCode") as! Int == 200{
                
                if ServiceName == "logout"{
                    
                    UserDefaults.standard.removeObject(forKey: "LoginDetail")
                    UserDefaults.standard.synchronize()
                    
                    appDelegate.setupRootVC()
                }
                else{
                    
                    appDelegate.dicLoginDetail = Response.object(forKey: "user") as? NSDictionary
                    
                    let data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.dicLoginDetail)
                    
                    UserDefaults.standard.set(data, forKey: "LoginDetail")
                    UserDefaults.standard.synchronize()
                    
                    self.tblView.reloadData()
                }
                
            }
        }
    }
    
}
