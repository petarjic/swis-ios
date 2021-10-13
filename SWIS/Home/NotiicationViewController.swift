//
//  NotiicationViewController.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 11/02/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class NotiicationViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,responseDelegate {

    @IBOutlet var tblView : UITableView!
    
    var arrMenu = ["Likes","Commnets","Follows"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tblView.tableFooterView = UIView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = "Notifications"
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
        Switch.addTarget(self, action: #selector(clickOnSwitch(sender:)), for: .valueChanged)
        if indexPath.row == 0{
            
            if appDelegate.dicLoginDetail.value(forKey: "notification_like") as? Int == 1{
               
                Switch.isOn = true
            }
            else{
                Switch.isOn = false
                
            }
        }
        else if indexPath.row == 1{
            
            if appDelegate.dicLoginDetail.value(forKey: "notification_comment") as? Int == 1{
                
                Switch.isOn = true
            }
            else{
                Switch.isOn = false
                
            }
            
        }
        else{
            if appDelegate.dicLoginDetail.value(forKey: "notification_follow") as? Int == 1{
               
                Switch.isOn = true
            }
            else{
                Switch.isOn = false
            }
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

        if indexPath?.row == 0{
            
            var strStatus : String = ""
            
            if appDelegate.dicLoginDetail.value(forKey: "notification_like") as? Int == 1{

                strStatus = "off"
            }
            else{
                strStatus = "on"
                
            }
            
            let strURL = "\(SERVER_URL)/update/profile"
            
            let strParameters = "notification_like=\(strStatus)"
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "updateProfile", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
        }
        else if indexPath?.row == 1{
            
            var strStatus : String = ""
            
            if appDelegate.dicLoginDetail.value(forKey: "notification_comment") as? Int == 1{
                
                strStatus = "off"
            }
            else{
                strStatus = "on"
            }
            
            let strURL = "\(SERVER_URL)/update/profile"
            
            let strParameters = "notification_comment=\(strStatus)"
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "updateProfile", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
        }
        else{
            var strStatus : String = ""
            
            if appDelegate.dicLoginDetail.value(forKey: "notification_follow") as? Int == 1{
                
                strStatus = "off"
                
            }
            else{
                strStatus = "on"
            }
            
            let strURL = "\(SERVER_URL)/update/profile"
            
            let strParameters = "notification_follow=\(strStatus)"
            
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
