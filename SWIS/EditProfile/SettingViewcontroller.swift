//
//  SettingViewcontroller.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 12/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

protocol didFinishWithSelection {
    
    func didFinishWithSelection(index:NSInteger)
}

class SettingViewcontroller: UIViewController,UITableViewDataSource,UITableViewDelegate,responseDelegate {
    
    @IBOutlet var tblView : UITableView!
    
    var followRequestCount : NSInteger = 0
    
    var arrMenu = NSMutableArray.init(array: ["Bio","Profile Pic","Background Image","Share Searched","Share Bookmarks","Auto Accept Follows"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if appDelegate.dicLoginDetail.value(forKey: "follow_request_count") != nil{
             self.followRequestCount = (appDelegate.dicLoginDetail.value(forKey: "follow_request_count") as? Int)!
        }
        
        let strRequest = "Follow Requests (\(self.followRequestCount))"
        self.arrMenu.add(strRequest)
        
        
        tblView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupCount), name: NSNotification.Name(rawValue: "reloadCount"), object: nil)
        
    }
    
    @objc func setupCount()
    {
        arrMenu.removeLastObject()

        self.followRequestCount = (appDelegate.dicLoginDetail.value(forKey: "follow_request_count") as? Int)!
        let strRequest = "Follow Requests (\(followRequestCount))"
        arrMenu.add(strRequest)
        self.tblView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.title = "Profile"
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
        
        let Switch = cell.contentView.viewWithTag(1003) as! UISwitch
        
        if indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5
        {
            cell.contentView.viewWithTag(1002)?.isHidden = true
            Switch.isHidden = false
            
            if indexPath.row == 3{
                
                if appDelegate.dicLoginDetail.value(forKey: "hide_searched") as? Int == 1{
                    
                    Switch.isOn = false
                }
                else{
                    Switch.isOn = true
                }
                
            }
            else if indexPath.row == 4{
                
                if appDelegate.dicLoginDetail.value(forKey: "hide_favourite") as? Int == 1{
                    
                    Switch.isOn = false
                }
                else{
                    Switch.isOn = true
                }
            }
            else if indexPath.row == 5{
                
                if appDelegate.dicLoginDetail.value(forKey: "auto_accept") as? Int == 1{
                    
                    Switch.isOn = true
                }
                    
                else{
                    Switch.isOn = false
                }
            }
            
            Switch.addTarget(self, action: #selector(clickOnSwitch(sender:)), for: .valueChanged)
        }
        else{
            cell.contentView.viewWithTag(1002)?.isHidden = false
            Switch.isHidden = true
        }
        
        if indexPath.row == 6{
            
            let str = arrMenu.object(at: indexPath.row) as! NSString
            let attribute = NSMutableAttributedString.init(string: str as String)
            
            let range = str.range(of: "(\(followRequestCount))")
            let range2 = str.range(of: "Follow Requests")
            
            attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: range)
            attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range: range2)
            
            lblTitle.attributedText = attribute
            
        }
        else{
            lblTitle.text =  arrMenu.object(at: indexPath.row) as? String
            
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
        
        if indexPath.row == 0{
            
            let editProfileVC = objEditProfileSB.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(editProfileVC, animated: true)
        }
        else if indexPath.row == 1{
            
            let changeProfileVC = objEditProfileSB.instantiateViewController(withIdentifier: "ChangeProfileVC") as! ChangeProfileVC
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(changeProfileVC, animated: true)
        }
        else if indexPath.row == 2{
            
            let changeBackgroundVC = objEditProfileSB.instantiateViewController(withIdentifier: "ChangeBackgroundVC") as! ChangeBackgroundVC
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(changeBackgroundVC, animated: true)
        }
        else if indexPath.row == 6 {
            
            let followRequestVC = objHomeSB.instantiateViewController(withIdentifier: "FollowRequestScreenVC") as! FollowRequestScreenVC
            
            self.navigationController?.pushViewController(followRequestVC, animated: true)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
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
        
        if indexPath?.row == 3{
            
            var strStatus : String = ""
            
            if appDelegate.dicLoginDetail.value(forKey: "hide_searched") as? Int == 0{
                
                strStatus = "1"
                
            }
            else{
                strStatus = "0"
            }
            
            let strURL = "\(SERVER_URL)/update/profile"
            
            let strParameters = "hide_searched=\(strStatus)"
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "updateProfile", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
        }
        else if indexPath?.row == 4{
            
            var strStatus : String = ""
            
            if appDelegate.dicLoginDetail.value(forKey: "hide_favourite") as? Int == 1{
                
                strStatus = "0"
                
            }
            else{
                strStatus = "1"
            }
            
            let strURL = "\(SERVER_URL)/update/profile"
            
            let strParameters = "hide_favourite=\(strStatus)"
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "updateProfile", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
        }
        else if indexPath?.row == 5{
            
            var strStatus : String = ""
            
            if appDelegate.dicLoginDetail.value(forKey: "auto_accept") as? Int == 1{
                
                strStatus = "off"
                
            }
            else{
                strStatus = "on"
            }
            
            let strURL = "\(SERVER_URL)/update/profile"
            
            let strParameters = "auto_accept=\(strStatus)"
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "updateProfile", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
        }
        
    }
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
          
            appDelegate.dicLoginDetail = Response.object(forKey: "user") as? NSDictionary
            
            let data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.dicLoginDetail)
            
            UserDefaults.standard.set(data, forKey: "LoginDetail")
            UserDefaults.standard.synchronize()
            
        }
    }
    
}
