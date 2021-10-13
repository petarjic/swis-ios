//
//  FollowingScreenVC.swift
//  SWIS
//
//  Created by Rp on 17/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class FollowingScreenVC: UIViewController,UITableViewDelegate,UITableViewDataSource,responseDelegate,didFinishWithSelection,UISearchBarDelegate {
    
    @IBOutlet var tblView : UITableView!
    @IBOutlet var searchBar : UISearchBar!
    
    var arrFollowing = NSMutableArray()
    var refreshView : LGRefreshView!
    var currentPage : NSInteger = 0
    var selectedIndex : NSInteger = -1
    var totalPages : NSInteger = 0
    var dicUserDetail : NSDictionary!
    
    var isRefresh:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tblView.tableFooterView = UIView()
        
        weak var wself = self

        refreshView = LGRefreshView.init(scrollView: self.tblView, refreshHandler: { (refreshView) in
            if (wself != nil)
            {
                self.isRefresh = true
                self.searchBar.text = ""
                self.currentPage = 0
                self.selectedIndex = -1
                self.arrFollowing.removeAllObjects()
                self.getFollowing(strQuery: "", showProgress: false)
            }
        })

        self.getFollowing(strQuery: "", showProgress: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isTranslucent = false
         self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = "Following"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.init(name: "FiraSans-Bold", size: 15),NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.kern:2.0]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back-icon.png"), style: .plain, target: self, action: #selector(self.clickOnBack))
        
        let rightBarBtn = UIBarButtonItem.init(image: UIImage.init(named: "menu"), style: .plain, target: self, action: #selector(clickOnMenu))
        self.navigationItem.rightBarButtonItem = rightBarBtn
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.relaodFollowingList), name: NSNotification.Name(rawValue: "ReloadFollowingList"), object: nil)
    }
    
    @objc func relaodFollowingList()
    {
        self.currentPage = 0
        self.selectedIndex = -1
        self.arrFollowing.removeAllObjects()
        self.searchBar.text = ""
        
        self.getFollowing(strQuery: "", showProgress: true)
    }
    
    @objc func clickOnBack()
    {
        self.navigationController?.popViewController(animated: true)
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
    
    func getFollowing(strQuery:String,showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/followings?user_id=\(dicUserDetail.value(forKey: "id") as! Int)&query=\(strQuery)&page=\(self.currentPage)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "followers", bodyObject: nil, delegate: self, isShowProgress: showProgress)
    }
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            self.refreshView.endRefreshing()
            
            if Response.value(forKey: "responseCode") as! Int == 200{
                
                if ServiceName == "unfollow"
                {
                    let dic = self.arrFollowing.object(at: self.selectedIndex) as! NSMutableDictionary
                    dic.setValue(0, forKey: "followed")
                    self.arrFollowing.replaceObject(at: self.selectedIndex, with: dic)
                    self.selectedIndex = -1
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadFollowing"), object: nil, userInfo: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPost"), object: nil, userInfo: nil)
                    self.tblView.reloadData()
                }
                if ServiceName == "follow-request"
                {
                    let dic = self.arrFollowing.object(at: self.selectedIndex) as! NSMutableDictionary
                    
                    let arrDetails = Response.object(forKey: "details") as! NSArray
                    var dicObject = NSDictionary()
                    
                    if arrDetails.count > 0{
                        dicObject = arrDetails.object(at: 0) as! NSDictionary
                    }
                    if dicObject.count > 0{
                        if dicObject.value(forKey: "status") as! String == "pending"{
                            dic.setValue(0, forKey: "followed")
                        }
                        else{
                            dic.setValue(1, forKey: "followed")
                        }
                    }
                    else{
                        dic.setValue(1, forKey: "followed")
                    }
                    
                    self.arrFollowing.replaceObject(at: self.selectedIndex, with: dic)
                    self.selectedIndex = -1
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadFollowing"), object: nil, userInfo: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPost"), object: nil, userInfo: nil)
                    self.tblView.reloadData()
                    self.view.makeToast((Response.value(forKey: "responseMessage") as! String))
                    
                }
                else if ServiceName == "followers"{
                    
                    let arrayPost = (Response.object(forKey: "followings") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    self.arrFollowing.addObjects(from: arrayPost as! [Any])
                    self.currentPage = Response.value(forKey: "nextPage") as! Int
                    self.totalPages = (Response.value(forKey: "total_page") as! NSNumber).intValue
                    self.tblView.reloadData()
                 }
                
            }
            else{
                self.view.makeToast((Response.value(forKey: "responseMessage") as! String))
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if currentPage < totalPages{
            return self.arrFollowing.count + 1
        }
        
        return self.arrFollowing.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < self.arrFollowing.count{
            return self.setupCell(indexPath: indexPath)
        }
        else{
            return self.loadingCell()!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dicFollowing = self.arrFollowing.object(at: indexPath.row) as! NSDictionary
        
        let profileVC = objMainSB.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationItem.title = ""
        profileVC.dicUserDetail = dicFollowing
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell.tag == 10{
            
            if isRefresh == false {
                self.getFollowing(strQuery: searchBar.text!, showProgress: false)
            } else {
                isRefresh = false
            }
            
        }
    }
    
    @objc func clickOnFollowing(sender:UIButton)
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
        
        
        let indexPath = self.tblView.indexPath(for: cell)
        
        
        let dicFollowing = self.arrFollowing.object(at: indexPath!.row) as! NSDictionary
        
        if dicFollowing.value(forKey: "followed") as! Int == 1
        {
            
            let alertController = UIAlertController.init(title: "SWIS", message: "Are you sure you want to unfollow?", preferredStyle: .alert)
            
            
            let actionNo = UIAlertAction.init(title: "No", style: .default) { (action) in
                
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(actionNo)
            
            let actionYes = UIAlertAction.init(title: "Yes", style: .default) { (action) in
                
                let dicFollow = NSMutableDictionary()
                dicFollow.setValue(dicFollowing.value(forKey: "id") as! Int, forKey: "user_id")
                
                self.selectedIndex = (indexPath?.row)!
                
                let strURL = "\(SERVER_URL)/unfollow"
                
                WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "unfollow", bodyObject: dicFollow as AnyObject, delegate: self, isShowProgress: true)
            }
            
            alertController.addAction(actionYes)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        
        
    }
    
    @objc func clickOnFollow(sender:UIButton)
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
        let dicFollowers = self.arrFollowing.object(at: indexPath!.row) as! NSDictionary
        
        if dicFollowers.value(forKey: "followed") as! Int == 0
        {
            selectedIndex = (indexPath?.row)!
            let strURL = "\(SERVER_URL)/follow-request"
            
            let dicFollow = NSMutableDictionary()
            dicFollow.setValue(dicFollowers.value(forKey: "id") as! Int, forKey: "following_id")
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "follow-request", bodyObject: dicFollow as AnyObject, delegate: self, isShowProgress: true)
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.currentPage = 0
        self.selectedIndex = -1
        self.arrFollowing.removeAllObjects()
        self.getFollowing(strQuery: searchBar.text!, showProgress: true)
        searchBar.resignFirstResponder()
    }
    
    func setupCell(indexPath:IndexPath)->UITableViewCell
    {
        let cell = tblView.dequeueReusableCell(withIdentifier: "cellfollowing", for: indexPath)
        
        let imgViewProfile = cell.contentView.viewWithTag(1001) as! UIImageView
        imgViewProfile.layer.cornerRadius = 5
        imgViewProfile.layer.masksToBounds = true
        
        let lblName = cell.contentView.viewWithTag(1002) as! UILabel
        let lblUserName = cell.contentView.viewWithTag(1003) as! UILabel
        
        let btnFollowing = cell.contentView.viewWithTag(1004) as! UIButton
        btnFollowing.layer.borderWidth = 1
        btnFollowing.layer.borderColor = UIColor.init(red: 45.0/255.0, green: 152.0/255.0, blue: 233.0/255.0, alpha: 1.0).cgColor
        btnFollowing.setTitleColor(UIColor.init(red: 45.0/255.0, green: 152.0/255.0, blue: 233.0/255.0, alpha: 1.0), for: UIControl.State.normal)
        btnFollowing.layer.cornerRadius = btnFollowing.frame.size.height/2
        
        let btnFollow = cell.contentView.viewWithTag(1005) as! UIButton
        
        
        let dicFollowing = self.arrFollowing.object(at: indexPath.row) as! NSDictionary
        
        var stravatar = dicFollowing.value(forKey: "avatar") as? String
        stravatar = stravatar?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        if stravatar != nil{
            imgViewProfile.sd_setImage(with: URL.init(string: stravatar!), placeholderImage: nil, options: .continueInBackground, completed: nil)
        }
        
        lblName.text = dicFollowing.value(forKey: "name") as? String
        lblUserName.text = "@\(dicFollowing.value(forKey: "username") as! String)"
        
        if dicFollowing.value(forKey: "followed") as! Int == 1
        {
            btnFollow.isHidden = true
            btnFollowing.isHidden = false
            
            btnFollowing.setTitle("Following", for: UIControl.State.normal)
            btnFollowing.layer.borderWidth = 1
            btnFollowing.layer.borderColor = UIColor.init(red: 45.0/255.0, green: 152.0/255.0, blue: 233.0/255.0, alpha: 1.0).cgColor
            btnFollowing.layer.cornerRadius = btnFollow.frame.size.height/2
            btnFollowing.backgroundColor = UIColor.white
            btnFollowing.setTitleColor(UIColor.init(red: 45.0/255.0, green: 152.0/255.0, blue: 233.0/255.0, alpha: 1.0), for: UIControl.State.normal)
            
            btnFollowing.addTarget(self, action: #selector(self.clickOnFollowing(sender:)), for: UIControl.Event.touchUpInside)
            
        }
        else{
            
            btnFollow.isHidden = false
            btnFollowing.isHidden = true
            
            btnFollow.setTitle("Follow", for: UIControl.State.normal)
            
            btnFollow.backgroundColor = UIColor.init(red: 45.0/255.0, green: 152.0/255.0, blue: 233.0/255.0, alpha: 1.0)
            btnFollow.setTitleColor(UIColor.white, for: UIControl.State.normal)
            btnFollow.layer.cornerRadius = btnFollow.frame.size.height/2
            
            btnFollow.addTarget(self, action: #selector(self.clickOnFollow(sender:)), for: UIControl.Event.touchUpInside)
            
            if dicFollowing.value(forKey: "id") as! Int == appDelegate.dicLoginDetail.value(forKey: "id") as! Int
            {
                btnFollow.isHidden = true
            }
            else{
                btnFollow.isHidden = false
            }
            
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func loadingCell() -> UITableViewCell? {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = CGPoint.init(x: tblView.frame.size.width/2, y: cell.frame.size.height/2)
        cell.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        cell.tag = 10
        
        return cell
    }
    
    
}
