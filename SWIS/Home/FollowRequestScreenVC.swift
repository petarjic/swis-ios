//
//  FollowRequestScreenVC.swift
//  SWIS
//
//  Created by Rp on 17/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class FollowRequestScreenVC: UIViewController,UITableViewDelegate,UITableViewDataSource,responseDelegate,didFinishWithSelection,UISearchBarDelegate {
    
    @IBOutlet var tblView : UITableView!
    @IBOutlet var searchBar : UISearchBar!

    var arrFollowRequest = NSMutableArray()
    var refreshView : LGRefreshView!
    var currentPage : NSInteger = 0
    var selectedIndex : NSInteger = -1
    var loadNextPage : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tblView.tableFooterView = UIView()
        
        weak var wself = self
        
        refreshView = LGRefreshView.init(scrollView: self.tblView, refreshHandler: { (refreshView) in
            if (wself != nil)
            {
                self.loadNextPage = true
                self.searchBar.text = ""
                self.currentPage = 0
                self.selectedIndex = -1
                self.arrFollowRequest.removeAllObjects()
                self.getFollowRequest(strQuery: "", showProgress: false)
            }
        })
        
        self.getFollowRequest(strQuery: "", showProgress: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.title = "Follow Requests"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.init(name: "FiraSans-Bold", size: 15),NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.kern:2.0]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back-icon.png"), style: .plain, target: self, action: #selector(self.clickOnBack))
        
        
        let rightBarBtn = UIBarButtonItem.init(image: UIImage.init(named: "menu"), style: .plain, target: self, action: #selector(clickOnMenu))
        self.navigationItem.rightBarButtonItem = rightBarBtn
        
    }
    
    @objc func clickOnBack()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getFollowRequest(strQuery:String,showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/pending-request-list?page=\(currentPage)&query=\(strQuery)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "pending-request-list", bodyObject: nil, delegate: self, isShowProgress: showProgress)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrFollowRequest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellfollowrequest", for: indexPath)
        
        let imgViewProfile = cell.contentView.viewWithTag(1001) as! UIImageView
        imgViewProfile.layer.cornerRadius = 5
        imgViewProfile.layer.masksToBounds = true
        
        let lblName = cell.contentView.viewWithTag(1002) as! UILabel
        let lblUserName = cell.contentView.viewWithTag(1003) as! UILabel
        let btnCancleRequest = cell.contentView.viewWithTag(1004) as! UIButton
        let btnAcceptRequest = cell.contentView.viewWithTag(1005) as! UIButton
        let btnAccept = cell.contentView.viewWithTag(1006) as! UIButton
        let btnReject = cell.contentView.viewWithTag(1007) as! UIButton
        
        let dicRequest = self.arrFollowRequest.object(at: indexPath.row) as! NSDictionary
        
        lblName.text = dicRequest.value(forKey: "name") as? String
        lblUserName.text = "@\(dicRequest.value(forKey: "username") as! String)"
        
        btnAcceptRequest.addTarget(self, action: #selector(self.acceptRequest(sender:)), for: UIControl.Event.touchUpInside)
        
        btnCancleRequest.addTarget(self, action: #selector(self.cancelRequest(sender:)), for: UIControl.Event.touchUpInside)
        
        btnAccept.addTarget(self, action: #selector(self.acceptRequest(sender:)), for: UIControl.Event.touchUpInside)
        
        btnReject.addTarget(self, action: #selector(self.cancelRequest(sender:)), for: UIControl.Event.touchUpInside)

        var stravatar = dicRequest.value(forKey: "avatar") as? String
        stravatar = stravatar?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
       
        if stravatar != nil{
            
            imgViewProfile.sd_setImage(with: URL.init(string: stravatar!), placeholderImage: nil, options: .continueInBackground, completed: nil)
        }
        
        if indexPath.row == self.arrFollowRequest.count - 1 && self.loadNextPage && self.arrFollowRequest.count >= 10{
            self.getFollowRequest(strQuery: searchBar.text!, showProgress: true)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dicRequest = self.arrFollowRequest.object(at: indexPath.row) as! NSDictionary
        
        let profileVC = objMainSB.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationItem.title = ""
        profileVC.dicUserDetail = dicRequest
        self.navigationController?.pushViewController(profileVC, animated: true)
    }

    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            if Response.value(forKey: "responseCode") as! Int == 200{
             
                self.refreshView.endRefreshing()
                
                if ServiceName == "pending-request-list"
                {
                 
                    let arrayPost = (Response.object(forKey: "followers") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    if arrayPost.count == 0{
                        
                        self.loadNextPage = false
                    }
                    else{
                        
                        self.loadNextPage = true
                        self.arrFollowRequest.addObjects(from: arrayPost as! [Any])
                        self.currentPage = Response.value(forKey: "nextPage") as! Int
                    }
                    
                    self.tblView.reloadData()

                }
                else if ServiceName == "details"{
                    
                    appDelegate.dicLoginDetail = Response.object(forKey: "user") as? NSDictionary
                    
                    let data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.dicLoginDetail)
                    
                    UserDefaults.standard.set(data, forKey: "LoginDetail")
                    UserDefaults.standard.synchronize()
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCount"), object: nil, userInfo: nil)
                }
                else if ServiceName == "approve-request"{
                    self.view.makeToast("Follow request accepted")
                    self.arrFollowRequest.removeObject(at: self.selectedIndex)
                    self.tblView.reloadData()
                    self.selectedIndex = -1
                    self.getUserDetails(userId: appDelegate.dicLoginDetail.value(forKey: "id") as! Int, showProgress: false)
                }
                else if ServiceName == "decline-request"{
                    self.view.makeToast("Follow request disapproved")
                    self.arrFollowRequest.removeObject(at: self.selectedIndex)
                    self.tblView.reloadData()
                    self.selectedIndex = -1
                    self.getUserDetails(userId: appDelegate.dicLoginDetail.value(forKey: "id") as! Int, showProgress: false)

                }
                else{
                    
                    self.getUserDetails(userId: appDelegate.dicLoginDetail.value(forKey: "id") as! Int, showProgress: false)
                    
                    self.arrFollowRequest.removeObject(at: self.selectedIndex)
                    self.tblView.reloadData()
                    self.selectedIndex = -1
                }
               
            }
        }
    }
    
    func getUserDetails(userId:Int,showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/details?user_id=\(userId)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "details", bodyObject: nil, delegate: self, isShowProgress: showProgress)
    }
   
    @objc func clickOnMenu(){
        
        let homeMenuVC = objMainSB.instantiateViewController(withIdentifier: "HomeMainMenuVC") as! HomeMainMenuVC
        
        self.navigationController?.pushViewController(homeMenuVC, animated: true)
        
    }
    
    
    func didFinishWithSelection(index: NSInteger) {
        
        if index == 8
        {
            let followRequestVC = objHomeSB.instantiateViewController(withIdentifier: "FollowRequestScreenVC") as! FollowRequestScreenVC
            
            self.navigationController?.pushViewController(followRequestVC, animated: true)
            
        }
    }
    
    @objc func acceptRequest(sender:UIButton)
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
        let dicRequest = self.arrFollowRequest.object(at: indexPath!.row) as! NSDictionary

        let dic = NSMutableDictionary()
        dic.setValue(dicRequest.value(forKey: "id") as! Int, forKey: "user_id")
        
        self.selectedIndex = (indexPath?.row)!
        
        let strURL = "\(SERVER_URL)/approve-request"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "approve-request", bodyObject: dic as AnyObject, delegate: self, isShowProgress: true)
    }
    
    @objc func cancelRequest(sender:UIButton)
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
        let dicRequest = self.arrFollowRequest.object(at: indexPath!.row) as! NSDictionary
        
        let strURL = "\(SERVER_URL)/decline-request"
        
        self.selectedIndex = (indexPath?.row)!
        
        let dic = NSMutableDictionary()
        dic.setValue(dicRequest.value(forKey: "id") as! Int, forKey: "user_id")
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "decline-request", bodyObject: dic as AnyObject, delegate: self, isShowProgress: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.currentPage = 0
        self.selectedIndex = -1
        self.loadNextPage = true
        self.arrFollowRequest.removeAllObjects()
        self.getFollowRequest(strQuery: searchBar.text!, showProgress: true)
        searchBar.resignFirstResponder()
    }

}
