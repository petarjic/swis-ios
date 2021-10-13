//
//  LikeViewController.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 26/02/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class LikeViewController: UIViewController,responseDelegate,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var tblView : UITableView!
    @IBOutlet var imgPost : UIImageView!
    @IBOutlet var lblTitlePost : UILabel!
    
    
    var dicPostDetail : NSDictionary!
    var arrLike = NSMutableArray()
    var loadNextPage : Bool = true
    var currentPage : NSInteger = 0
    var refreshView : LGRefreshView!
    var selectedIndex : NSInteger = -1
    var strPostId : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tblView.tableFooterView = UIView()
        
        weak var wself = self
        
        refreshView = LGRefreshView.init(scrollView: self.tblView, refreshHandler: { (refreshView) in
            if (wself != nil)
            {
                self.loadNextPage = true
                self.currentPage = 0
                self.arrLike.removeAllObjects()
                self.getLike(showProgress: false)
            }
        })
        
        if self.strPostId == ""
        {
            self.setupPostDetail()
            self.getLike(showProgress: true)
        }
        else{
            self.getPostDetail()
        }
        
        self.imgPost.layer.cornerRadius = 5
        self.imgPost.layer.masksToBounds = true
    }
    
    func setupPostDetail()
    {
        if dicPostDetail.value(forKey: "comment") as? String ?? "" != ""
        {
            lblTitlePost.text = dicPostDetail.value(forKey: "comment") as? String
        }
        else
        {
            let arrWebsite = dicPostDetail.value(forKey: "websites") as! NSArray
            
            if arrWebsite.count > 0{
                
                let dicFirstObj = arrWebsite.object(at: 0) as! NSDictionary
                lblTitlePost.text = dicFirstObj.value(forKey: "search_term") as? String

            }
            
        }
        
        
        if (dicPostDetail.object(forKey: "user") as AnyObject).isKind(of: NSDictionary.self){
            
            let dicUser = dicPostDetail.object(forKey: "user") as! NSDictionary
            
            var stravatar = dicUser.value(forKey: "avatar") as? String
            stravatar = stravatar?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            self.imgPost.sd_setImage(with: URL.init(string: stravatar!), placeholderImage: nil, options: .continueInBackground, completed: nil)
            
        }
    }
    
    func getPostDetail()
    {
        let strURL = "\(SERVER_URL)/posts/\(strPostId)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "postsDetail", bodyObject: nil, delegate: self, isShowProgress: false)
    }
    
    
    func getLike(showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/posts/liked-users?page=\(self.currentPage)&post_id=\(dicPostDetail.value(forKey: "id") as! Int)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "liked-users", bodyObject: nil, delegate: self, isShowProgress: showProgress)
    }
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            self.refreshView.endRefreshing()
            
            if Response.value(forKey: "responseCode") as! Int == 200{
                
                if ServiceName == "follow-request"{
                    
                    let dic = self.arrLike.object(at: self.selectedIndex) as! NSMutableDictionary
                    
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
                    
                    self.arrLike.replaceObject(at: self.selectedIndex, with: dic)
                    self.selectedIndex = -1
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadFollowing"), object: nil, userInfo: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPost"), object: nil, userInfo: nil)
                    self.tblView.reloadData()
                    self.view.makeToast((Response.value(forKey: "responseMessage") as! String))
                    
                }
                else if ServiceName == "unfollow"
                {
                    let dic = self.arrLike.object(at: self.selectedIndex) as! NSMutableDictionary
                    dic.setValue(0, forKey: "followed")
                    self.arrLike.replaceObject(at: self.selectedIndex, with: dic)
                    self.selectedIndex = -1
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadFollowing"), object: nil, userInfo: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPost"), object: nil, userInfo: nil)
                    self.tblView.reloadData()
                    
                }
                else if ServiceName == "postsDetail"
                {
                    self.dicPostDetail = Response.object(forKey: "post") as? NSDictionary
                    
                    self.setupPostDetail()
                    self.getLike(showProgress:true)
                }
                else{
                    
                    let arrayLike = (Response.object(forKey: "users") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    if arrayLike.count == 0{
                        
                        self.loadNextPage = false
                    }
                    else{
                        self.loadNextPage = true
                        self.arrLike.addObjects(from: arrayLike as! [Any])
                        self.currentPage = Response.value(forKey: "nextPage") as! Int
                    }
                    self.tblView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isTranslucent = false
         self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = "Likes"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.init(name: "FiraSans-Bold", size: 15),NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.kern:2.0]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back-icon.png"), style: .plain, target: self, action: #selector(self.clickOnBack))
        
        let rightBarBtn = UIBarButtonItem.init(image: UIImage.init(named: "menu"), style: .plain, target: self, action: #selector(clickOnMenu))
        self.navigationItem.rightBarButtonItem = rightBarBtn
        
    }
    
    @objc func clickOnBack()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func clickOnMenu(){
        
        let homeMenuVC = objMainSB.instantiateViewController(withIdentifier: "HomeMainMenuVC") as! HomeMainMenuVC
        
        self.navigationController?.pushViewController(homeMenuVC, animated: true)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrLike.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "likeCell", for: indexPath)
        
        let imgViewProfile = cell.contentView.viewWithTag(1001) as! UIImageView
        imgViewProfile.layer.cornerRadius = 5
        imgViewProfile.layer.masksToBounds = true
        
        imgViewProfile.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnProfile(gesture:)))
        
        imgViewProfile.addGestureRecognizer(tapGesture)
        
        let lblName = cell.contentView.viewWithTag(1002) as! UILabel
        let lblUserName = cell.contentView.viewWithTag(1003) as! UILabel
        
        let tapGestureUserName = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnProfile(gesture:)))
        lblUserName.isUserInteractionEnabled = true
        lblUserName.addGestureRecognizer(tapGestureUserName)
        
        let btnFollowing = cell.contentView.viewWithTag(1005) as! UIButton
        btnFollowing.layer.borderWidth = 1
        btnFollowing.layer.borderColor = UIColor.init(red: 45.0/255.0, green: 152.0/255.0, blue: 233.0/255.0, alpha: 1.0).cgColor
        btnFollowing.setTitleColor(UIColor.init(red: 45.0/255.0, green: 152.0/255.0, blue: 233.0/255.0, alpha: 1.0), for: UIControl.State.normal)
        btnFollowing.layer.cornerRadius = btnFollowing.frame.size.height/2
        
        let btnFollow = cell.contentView.viewWithTag(1004) as! UIButton
        
        let dicLike = self.arrLike.object(at: indexPath.row) as! NSDictionary
        
        if dicLike.value(forKey: "followed") as! Int == 1
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
         
        }
      
        if appDelegate.dicLoginDetail.value(forKey: "id") as! Int == dicLike.value(forKey: "id") as! Int
        {
            btnFollow.isHidden = true
        }
        else{
            btnFollow.isHidden = false
        }
        
        var stravatar = dicLike.value(forKey: "avatar") as? String
        stravatar = stravatar?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        if stravatar != nil{
            imgViewProfile.sd_setImage(with: URL.init(string: stravatar!), placeholderImage: nil, options: .continueInBackground, completed: nil)
        }
        
        lblName.text = dicLike.value(forKey: "name") as? String
        lblUserName.text = "@\(dicLike.value(forKey: "username") as! String)"
        
        
        if indexPath.row == self.arrLike.count - 1 && self.loadNextPage && self.arrLike.count >= 10{
            self.getLike(showProgress: true)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
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
        
        
        let dicFollowing = self.arrLike.object(at: indexPath!.row) as! NSDictionary
        
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
        self.selectedIndex = (indexPath?.row)!
        let dicFollowers = self.arrLike.object(at: indexPath!.row) as! NSDictionary
        let strURL = "\(SERVER_URL)/follow-request"
        
        let dicFollow = NSMutableDictionary()
        dicFollow.setValue(dicFollowers.value(forKey: "id") as! Int, forKey: "following_id")
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "follow-request", bodyObject: dicFollow as AnyObject, delegate: self, isShowProgress: true)
    }
    
    @objc func tapOnProfile(gesture:UITapGestureRecognizer)
    {
        let imgView = gesture.view
        var tempView = imgView as! UIView
        
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
        let dicLike = self.arrLike.object(at: indexPath!.row) as! NSDictionary
        
        let profileVC = objMainSB.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationItem.title = ""
        profileVC.dicUserDetail = dicLike
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    
}
