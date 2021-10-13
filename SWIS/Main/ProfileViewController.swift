//
//  ProfileViewController.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 02/02/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit
import SafariServices
import CoreLocation
import SDWebImage
import TTTAttributedLabel

class ProfileViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UITextViewDelegate,responseDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,CLLocationManagerDelegate,TTTAttributedLabelDelegate {
    
    
    @IBOutlet weak var imgBithHieghtConstn: NSLayoutConstraint!
    
    @IBOutlet weak var lblBirthHieghtContant: NSLayoutConstraint!
    
    @IBOutlet var imgProfile : UIImageView!
    @IBOutlet var imgBirthDay : UIImageView!
    @IBOutlet var btnUnFollow : UIButton!
    @IBOutlet var favView : UIView!
    @IBOutlet var searchView : UIView!
    @IBOutlet var btnFav : UIButton!
    @IBOutlet var btnSearch : UIButton!
    @IBOutlet var tblview : UITableView!
    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var lblName : UILabel!
    @IBOutlet weak var lblBirthDate: UILabel!
    @IBOutlet var lblFollowers : UILabel!
    @IBOutlet var lblFollowing : UILabel!
    @IBOutlet var lblSearch : UILabel!
    @IBOutlet var lblJoinNumber : UILabel!
    @IBOutlet var lblBio : UILabel!
    @IBOutlet var followerView : UIView!
    @IBOutlet var followingView : UIView!
    @IBOutlet var imgMore : UIImageView!
    @IBOutlet var btnMore : UIButton!
    @IBOutlet var lblJoinNo : UILabel!
    @IBOutlet var lblCountry : UILabel!
    @IBOutlet var imgBackground : UIImageView!
    @IBOutlet var lblSearchTitle : UILabel!
    @IBOutlet var lblFollowersTitle : UILabel!
    @IBOutlet var lblFollowingTitle : UILabel!
    @IBOutlet var imgLocation : UIImageView!
    @IBOutlet var lblCurrentLocation : UILabel!
    @IBOutlet var imgLive : UIImageView!
    
    var deleteSelectedPostIndex: Int?
    var deleteSelectedWebsiteIndex: Int?

    
    var arrSarchPost = NSMutableArray()
    var arrBookMark = NSMutableArray()
    var currentPage : NSInteger = 0
    var currentPageBookMark : NSInteger = 0
    var dicUserDetail = NSDictionary()
    var followRequestcount : NSInteger = 0
    var isClickOnFav : NSInteger = 0
    var selectedFavIndex : NSInteger = -1
    var selectedDeleteIndex : NSInteger = -1
    var refreshView : LGRefreshView!
    var selectedLikeIndex : NSInteger = -1
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var strCountry : String = ""
    var strCity : String = ""
    var locationManager = CLLocationManager()
    var isFirstTimeOpen : Bool = true
    var totalPagesSearched : NSInteger = 0
    var totalPagesBookMark : NSInteger = 0
    var isFromComment : Bool = false
    var isFromNitification : Bool = false
    var strCommentUserName : String = ""
    var objNotificationID : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let rightBarBtn = UIBarButtonItem.init(image: UIImage.init(named: "menu"), style: .plain, target: self, action: #selector(clickOnMenu))
        self.navigationItem.rightBarButtonItem = rightBarBtn
        
        btnUnFollow.layer.cornerRadius = btnUnFollow.frame.size.height/2
        let profileView = imgProfile.superview as UIView?
        profileView!.layer.cornerRadius = 5
        
        searchView.layer.borderWidth = 1
        favView.layer.borderWidth = 1
        
        searchView.layer.borderColor = UIColor.gray.cgColor
        favView.layer.borderColor = UIColor.gray.cgColor
        
        tblview.tableFooterView = UIView()
        tblview.separatorStyle = .none
        
        let tapGestureFollowers = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnFollowers))
        
        followerView.addGestureRecognizer(tapGestureFollowers)
        
        let tapGestureFollowing = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnFollowing))
        
        followingView.addGestureRecognizer(tapGestureFollowing)
        
        if !self.isFromComment{
            self.getPost(showProgress: true)
            self.getFavouritePost(showProgress: false)
            self.getUserDetails(progress: true)
        }
        else{
            self.getUserDetailsWithName(userName: strCommentUserName, showProgress: true)
            
        }
       
//--set select bottom tab
//                    var frame = appDelegate.bottomView.frame
//                    frame.origin.x = 0.0 * (UIScreen.main.bounds.width/5)
//                    appDelegate.bottomView.frame  = frame
//
        weak var wself = self
        
        refreshView = LGRefreshView.init(scrollView: self.tblview, refreshHandler: { (refreshView) in
            if (wself != nil)
            {
                
                if self.isClickOnFav == 1
                {
                    self.currentPageBookMark = 0
                    self.arrBookMark.removeAllObjects()
                    self.getFavouritePost(showProgress: false)
                }
                else{
                    
                    self.currentPage = 0
                    self.arrSarchPost.removeAllObjects()
                    self.getPost(showProgress: false)
                }
                
            }
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.relaodPost), name: NSNotification.Name(rawValue: "reloadPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.relaodBookMark), name: NSNotification.Name(rawValue: "reloadBookMark"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setCommentCount(noti:)), name: NSNotification.Name(rawValue: "commentReload"), object: nil)
        
       self.tabBarController?.tabBar.isHidden = false
        
//        var frame = appDelegate.bottomView.frame
//        frame.origin.x = (CGFloat)(4) * (tabBarController!.tabBar.frame.size.width/5)
//        appDelegate.bottomView.frame  = frame
    }
    
    @objc func setCommentCount(noti:NSNotification)
    {
        let dicPost = noti.userInfo!["post"] as! NSDictionary
        let newdicPost = noti.userInfo!["newPost"] as! NSDictionary
        
        let array = self.isClickOnFav == 1 ? self.arrBookMark : self.arrSarchPost
        
        let index = array.index(of: dicPost)
        
        if index < array.count{
            
            if self.isClickOnFav == 1{
                self.arrBookMark.replaceObject(at: index, with: newdicPost)
            }
            else{
                self.arrSarchPost.replaceObject(at: index, with: newdicPost)
            }
            
            self.tblview.reloadData()
        }
        
    }
    
    @objc func relaodBookMark()
    {
        
        if self.isClickOnFav == 1
        {
            self.currentPageBookMark = 0
            self.arrBookMark.removeAllObjects()
            self.getFavouritePost(showProgress: false)
        }
        else{
            
            self.currentPage = 0
            self.arrSarchPost.removeAllObjects()
            self.getPost(showProgress: false)
        }
        
    }
    
    @objc func relaodPost(){
        
        self.currentPage = 0
        self.arrSarchPost.removeAllObjects()
        self.getPost(showProgress: false)
    }
    
    func getPost(showProgress:Bool)
    {
        var userId : Int = appDelegate.dicLoginDetail.value(forKey: "id") as! Int
        
        if dicUserDetail.count == 0{
            
            userId = appDelegate.dicLoginDetail.value(forKey: "id") as! Int
        }
        else{
            userId = dicUserDetail.value(forKey: "id") as! Int
        }
        
        let strURL = "\(SERVER_URL)/fetch-posts?page=\(currentPage)&page_limit=10&user_id=\(userId)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "fetch-posts", bodyObject: nil, delegate: self, isShowProgress: showProgress)
    }
    
    func getFavouritePost(showProgress:Bool)
    {
        var userId : Int = appDelegate.dicLoginDetail.value(forKey: "id") as! Int
        
        if dicUserDetail.count == 0{
            
            userId = appDelegate.dicLoginDetail.value(forKey: "id") as! Int
        }
        else{
            userId = dicUserDetail.value(forKey: "id") as! Int
        }
        
        let strURL = "\(SERVER_URL)/posts/fetch-favourites?page=\(currentPageBookMark)&user_id=\(userId)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "fetch-favourites", bodyObject: nil, delegate: self, isShowProgress: showProgress)
    }
    
    func getUserDetails(userId:Int,showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/details?user_id=\(userId)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "details", bodyObject: nil, delegate: self, isShowProgress: showProgress)
    }
    
    func getUserDetailsWithName(userName:String,showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/username/\(userName)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "userNameAPI", bodyObject: nil, delegate: self, isShowProgress: showProgress)
    }
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            self.refreshView.endRefreshing()
            
            if Response.value(forKey: "responseCode") as! Int == 200{
                
                if ServiceName == "details"{
                    
                    if self.dicUserDetail.count == 0 && !self.isFromComment && !self.isFromNitification{
                        
                        appDelegate.dicLoginDetail = Response.object(forKey: "user") as? NSDictionary
                        
                        let data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.dicLoginDetail)
                        
                        UserDefaults.standard.set(data, forKey: "LoginDetail")
                        UserDefaults.standard.synchronize()
                        
                    }
                    
                    let dicUser = Response.object(forKey: "user") as! NSDictionary
                   
                    self.setupUserDetails(dicUser: dicUser)
                    
                }
                else if ServiceName == "delete_post"
                {
                    if self.isClickOnFav == 1{
                        self.arrBookMark.removeObject(at: self.selectedDeleteIndex)
                    }
                    else{
                        self.arrSarchPost.removeObject(at: self.selectedDeleteIndex)
                    }
                    self.selectedDeleteIndex = -1
                    self.tblview.reloadData()
                    
                }
                else if ServiceName == "toggle-like"
                {
                    var dicPost : NSDictionary!
                    
                    if self.isClickOnFav == 1{
                        dicPost = self.arrBookMark.object(at: self.selectedLikeIndex) as? NSDictionary
                    }
                    else{
                        dicPost = self.arrSarchPost.object(at: self.selectedLikeIndex) as? NSDictionary
                    }
                    
                    if dicPost.value(forKey: "like")  as! Int == 0{
                        dicPost.setValue(1, forKey: "like")
                        let likeCount = dicPost.value(forKey: "like_count") as! Int
                        dicPost.setValue(likeCount+1, forKey: "like_count")
                    }
                    else{
                        dicPost.setValue(0, forKey: "like")
                        let likeCount = dicPost.value(forKey: "like_count") as! Int
                        if likeCount > 0{
                            dicPost.setValue(likeCount-1, forKey: "like_count")
                        }else{
                            dicPost.setValue(0, forKey: "like_count")
                        }
                        
                    }
                    
                    if self.isClickOnFav == 1{
                        self.arrBookMark.replaceObject(at: self.selectedLikeIndex, with: dicPost)
                    }
                    else{
                        self.arrSarchPost.replaceObject(at: self.selectedLikeIndex, with: dicPost)
                        
                    }
                   // self.tblview.reloadRows(at: [NSIndexPath.init(row: self.selectedLikeIndex, section: 0) as IndexPath], with: .none)
                    
                    self.tblview.reloadData()
                    
                    self.selectedLikeIndex = -1
                    
                }
                else if ServiceName == "favourites" || ServiceName == "unfavourites"
                {
                    
                    if self.isClickOnFav == 1{
                        
                        self.arrBookMark.removeObject(at: self.selectedFavIndex)
                        
                        self.selectedFavIndex = -1
                        self.tblview.reloadData()
                    }
                    else{
                        let dicPost = NSMutableDictionary.init(dictionary: self.arrSarchPost.object(at: self.selectedFavIndex) as! NSDictionary)
                        
                        if dicPost.value(forKey: "favourite")  as! Int == 0{
                            dicPost.setValue(1, forKey: "favourite")
                            self.arrBookMark.insert(dicPost, at: 0)
                            
                        }
                        else{
                            self.arrBookMark.remove(dicPost)
                            dicPost.setValue(0, forKey: "favourite")
                            
                        }
                        
                        self.arrSarchPost.replaceObject(at: self.selectedFavIndex, with: dicPost)
                        //self.tblview.reloadRows(at: [NSIndexPath.init(row: self.selectedFavIndex, section: 0) as IndexPath], with: .none)
                        
                        self.tblview.reloadData()
                        self.selectedFavIndex = -1
                    }
                    
                }
                else if ServiceName == "follow-request" || ServiceName == "unfollow"
                {
                    
                    if ServiceName == "follow-request"
                    {
                        self.btnUnFollow.setTitle("Unfollow", for: .normal)
                    }
                    else{
                        self.btnUnFollow.setTitle("Follow", for: .normal)
                    }
                    
                     NotificationCenter.default.post(name: NSNotification.Name(rawValue: "relaodFriend"), object: nil, userInfo: nil)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadFollowing"), object: nil, userInfo: nil)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadFollower"), object: nil, userInfo: nil)

                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadFollowingList"), object: nil, userInfo: nil)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPost"), object: nil, userInfo: nil)
                    
                }
                else if ServiceName == "fetch-favourites"
                {
                    let arrayPost = Response.object(forKey: "favourites") as! NSArray
                    
                    if arrayPost.count > 0{
                        
                        self.arrBookMark.addObjects(from: arrayPost as! [Any])
                        self.currentPageBookMark = Response.value(forKey: "nextPage") as! Int
                        
                        self.totalPagesBookMark = (Response.value(forKey: "total_page") as! NSNumber).intValue
                        
                        self.tblview.reloadData()
                        
                    }
                    
                }
                else if ServiceName == "userNameAPI"{
                    
                    self.dicUserDetail = (Response.object(forKey: "user") as! NSDictionary?)!
                    self.setupUserDetails(dicUser: self.dicUserDetail)
                    self.getPost(showProgress: false)
                    self.getFavouritePost(showProgress: false)
                }
                else if ServiceName == "delete_singel_page"
                {
                    var dicPost : NSDictionary!
                    
                    if self.isClickOnFav == 1{
                        
                        dicPost = self.arrBookMark.object(at: self.deleteSelectedPostIndex!) as? NSDictionary
                    }
                    else{
                        dicPost = self.arrSarchPost.object(at: self.deleteSelectedPostIndex!) as? NSDictionary
                    }
                    
                      let arrWebSite = (dicPost.value(forKey: "websites") as? NSArray)?.mutableCopy() as! NSMutableArray
                    
                    arrWebSite.removeObject(at: self.deleteSelectedWebsiteIndex!)
                    
                    dicPost.setValue(arrWebSite, forKey: "websites")
                    
                    if self.isClickOnFav == 1{
                        self.arrBookMark.replaceObject(at: self.deleteSelectedPostIndex!, with: dicPost)
                    }
                    else{
                        self.arrSarchPost.replaceObject(at: self.deleteSelectedPostIndex!, with: dicPost)
                    }
                    self.deleteSelectedPostIndex = -1
                    self.deleteSelectedWebsiteIndex = -1
                    self.tblview.reloadData()
                }
                else{
                    
                    let arrayPost = Response.object(forKey: "posts") as! NSArray
                    
                    if arrayPost.count > 0{
                        
                        self.arrSarchPost.addObjects(from: arrayPost as! [Any])
                        self.currentPage = Response.value(forKey: "next_page") as! Int
                        self.totalPagesSearched = (Response.value(forKey: "total_page") as! NSNumber).intValue
                        self.tblview.reloadData()
                        
                    }
                    
                }
            } else if Response.value(forKey: "responseCode") as! Int == 400 {
                
                let msg = Response.value(forKey: "responseMessage") as? String
                
                let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    
                    self.navigationController?.popViewController(animated: true)
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func setupUserDetails(dicUser:NSDictionary)
    {
        var strUserImg = dicUser.value(forKey: "avatar") as? String
        strUserImg = strUserImg?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        self.followRequestcount = (dicUser.value(forKey: "follow_request_count") as? Int)!
        
        // self.downloadProfileImage(from: URL.init(string: strUserImg!)!)
        
        self.imgProfile.sd_setImage(with: URL.init(string: strUserImg!), placeholderImage: nil, options: .refreshCached, context: nil)
        
        let bithdate = dicUser.value(forKey: "dob") as? String
        if bithdate == nil || bithdate == "" {
            lblBirthHieghtContant.constant = 0
            imgBithHieghtConstn.constant = 0
        } else {
            self.lblBirthDate.text = bithdate
            lblBirthHieghtContant.constant = 22
            imgBithHieghtConstn.constant = 21
        }
        
        self.lblName.text = dicUser.value(forKey: "name") as? String
        self.lblUserName.text = "@\(dicUser.value(forKey: "username") as! String)"
        self.lblSearch.text = "\(dicUser.value(forKey: "searches_count") as! Int)"
        self.lblFollowers.text = "\(dicUser.value(forKey: "followers_count") as! Int)"
        self.lblFollowing.text = "\(dicUser.value(forKey: "followings_count") as! Int)"
        self.lblJoinNumber.text = "\(dicUser.value(forKey: "id") as! Int)"
        self.lblBio.frame = CGRect.init(x: 10, y: 207, width: UIScreen.main.bounds.size.width-20, height: 21)
        //self.lblBio.numberOfLines = 3
        self.lblBio.text = dicUser.value(forKey: "bio") as? String
        self.lblBio.sizeToFit()
        
        if dicUser.value(forKey: "country") as? String != nil{
            self.lblCountry.text = "Lives in \(dicUser.value(forKey: "city") as! String), \(dicUser.value(forKey: "country") as! String)"
        }
        else{
            self.lblCountry.text = "Lives in"
        }
        
        self.lblCurrentLocation.numberOfLines = 2
        self.lblCurrentLocation.text = dicUser.value(forKey: "address") as? String
        
        if dicUser.value(forKey: "followed") as! Int == 0
        {
            self.btnUnFollow.setTitle("Follow", for: .normal)
        }
        else{
            self.btnUnFollow.setTitle("Unfollow", for: .normal)
        }
        
        if self.dicUserDetail.count == 0{
            self.btnUnFollow.isHidden = true
        }
        else{
            
            if self.dicUserDetail.value(forKey: "id") as! Int == appDelegate.dicLoginDetail.value(forKey: "id") as! Int
            {
                self.btnUnFollow.isHidden = true
            }
            else{
                self.btnUnFollow.isHidden = false
            }
        }
        
        let textColor = dicUser.value(forKey: "text_color") as! String
        let color = UIColor.init(hexString: textColor, alpha: 1.0)
        
        self.lblName.textColor = color
        self.lblUserName.textColor = color
        self.lblSearch.textColor = color
        self.lblFollowers.textColor = color
        self.lblFollowing.textColor = color
        self.lblJoinNumber.textColor = color
        self.lblBio.textColor = color
        self.lblCountry.textColor = color
        self.lblSearchTitle.textColor = color
        self.lblFollowersTitle.textColor = color
        self.lblFollowingTitle.textColor = color
        self.lblJoinNo.textColor = color
        self.lblCurrentLocation.textColor = color
        self.lblBirthDate.textColor = color
        
        self.imgProfile.layer.cornerRadius = 5
        
        self.imgLocation.image = self.imgLocation.image?.withRenderingMode(.alwaysTemplate)
        self.imgLocation.tintColor = color
        
        self.imgLive.image = self.imgLive.image?.withRenderingMode(.alwaysTemplate)
        self.imgLive.tintColor = color
        
        self.imgBirthDay.image = self.imgBirthDay.image?.withRenderingMode(.alwaysTemplate)
        self.imgBirthDay.tintColor = color
        
        self.imgMore.image = self.imgMore.image?.withRenderingMode(.alwaysTemplate)
        self.imgMore.tintColor = color
        
        var strBackgroundImg = dicUser.value(forKey: "background_url") as? String
        strBackgroundImg = strBackgroundImg?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        self.imgBackground.sd_setImage(with: URL.init(string: strBackgroundImg!), placeholderImage: nil, options: .continueInBackground, context: nil)
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadBackgroundImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                
                let img = UIImage(data: data)
                self.imgBackground.image = img
            }
        }
    }
    
    func downloadProfileImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                
                let img = UIImage(data: data)
                self.imgProfile.image = img
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) {_ in
            UIView.animate(withDuration: 1.0, animations: {
                
                self.navigationController?.navigationBar.isTranslucent = false
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.navigationBar.tintColor = UIColor.black
                
                self.navigationItem.title = "Profile"
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.init(name: "FiraSans-Bold", size: 15),NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.kern:2.0]
                
                let rightBarBtn = UIBarButtonItem.init(image: UIImage.init(named: "menu"), style: .plain, target: self, action: #selector(self.clickOnMenu))
                self.navigationItem.rightBarButtonItem = rightBarBtn
                
                if !self.isFirstTimeOpen{
                    
                    self.getUserDetails(progress: false)
                }
                
                self.isFirstTimeOpen = false
                
                Timer.initialize()
            })
            
        }
           
        
    }
    
    
    
    func getUserDetails(progress:Bool)
    {
        
        if dicUserDetail.count == 0
        {
            btnUnFollow.isHidden = true
            imgMore.isHidden = false
            btnMore.isHidden = false
            
            lblJoinNo.isHidden = false
            lblJoinNumber.isHidden = false
            
            followerView.isUserInteractionEnabled = true
            followingView.isUserInteractionEnabled = true
            
            if self.isFromComment {
                 self.getUserDetailsWithName(userName: strCommentUserName, showProgress: progress)
            } else if self.isFromNitification {
                self.getUserDetails(userId: Int(objNotificationID)!, showProgress: progress)
            }
            else{
                self.getUserDetails(userId: appDelegate.dicLoginDetail.value(forKey: "id") as! Int, showProgress: progress)
            }
            
            
        }
        else{
            
            if dicUserDetail.value(forKey: "id") as! Int == appDelegate.dicLoginDetail.value(forKey: "id") as! Int
            {
                btnUnFollow.isHidden = true
                imgMore.isHidden = false
                btnMore.isHidden = false
                
                lblJoinNo.isHidden = false
                lblJoinNumber.isHidden = false
                
                followerView.isUserInteractionEnabled = true
                followingView.isUserInteractionEnabled = true
                
                if self.isFromComment{
                    self.getUserDetailsWithName(userName: strCommentUserName, showProgress: progress)

                }else{
                    self.getUserDetails(userId: appDelegate.dicLoginDetail.value(forKey: "id") as! Int, showProgress: progress)
                 }
                
            }
            else{
                
                btnUnFollow.isHidden = false
                imgMore.isHidden = true
                btnMore.isHidden = true
                
                followerView.isUserInteractionEnabled = true
                followingView.isUserInteractionEnabled = true
                
                self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back-icon.png"), style: .plain, target: self, action: #selector(self.clickOnBack))
                
                if self.isFromComment{
                    self.getUserDetailsWithName(userName: strCommentUserName, showProgress: progress)

                }
                else{
                    self.getUserDetails(userId: dicUserDetail.value(forKey: "id") as! Int, showProgress: progress)

                }
                
                
            }
            
        }
    }
    
    @objc func clickOnBack()
    {
       // appDelegate.setupTabbarcontroller(selectedIndex: 3)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func clickOnMenu(){
        
        let homeMenuVC = objMainSB.instantiateViewController(withIdentifier: "HomeMainMenuVC") as! HomeMainMenuVC
        
        self.navigationController?.pushViewController(homeMenuVC, animated: true)
        
    }
    
    @IBAction func clickOnSearch(sender:UIButton)
    {
        isClickOnFav = 0
        
        btnFav.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        btnSearch.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        searchView.backgroundColor = defaultColor
        favView.backgroundColor = UIColor.white
        
        self.tblview.reloadData()
    }
    
    @IBAction func clickOnFav(sender:UIButton)
    {
        isClickOnFav = 1
        
        btnFav.setTitleColor(UIColor.white, for: UIControl.State.normal)
        btnSearch.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        
        searchView.backgroundColor = UIColor.white
        favView.backgroundColor = defaultColor
        
        self.tblview.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isClickOnFav == 1
        {
            if currentPageBookMark < totalPagesBookMark{
                return self.arrBookMark.count + 1
            }
            
            return self.arrBookMark.count
            
        }
        else{
            
            if currentPage < totalPagesSearched{
                return self.arrSarchPost.count + 1
            }
            
            return self.arrSarchPost.count
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.isClickOnFav == 1{
            
            if indexPath.row < self.arrBookMark.count{
                return self.setupCell(indexPath: indexPath)
            }
            else{
                return self.loadingCell()!
            }
        }
        else{
            if indexPath.row < self.arrSarchPost.count{
                return  self.setupCell(indexPath: indexPath)
            }
            else{
                return self.loadingCell()!
            }
        }
        
    }
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        var str = (url.absoluteString.components(separatedBy: "//") as! NSArray).object(at: 1) as! String
        
        let profileDetailVC = objMainSB.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileDetailVC.strCommentUserName = str
        profileDetailVC.isFromComment = true
        profileDetailVC.hidesBottomBarWhenPushed = false
        
        self.navigationController?.pushViewController(profileDetailVC, animated: true)
    }
    
    func setupCell(indexPath:IndexPath) -> UITableViewCell
    {
        var dicPost : NSDictionary!
        var cell : UITableViewCell!
        
        if self.isClickOnFav == 1{
            
            dicPost = self.arrBookMark.object(at: indexPath.row) as? NSDictionary
            cell = tblview.dequeueReusableCell(withIdentifier: "BookMarkCell", for: indexPath)
            
        }
        else{
            dicPost = self.arrSarchPost.object(at: indexPath.row) as? NSDictionary
            cell = tblview.dequeueReusableCell(withIdentifier: "cellhome", for: indexPath)
            
        }
        
        let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
        
        let imgViewUser = cell.contentView.viewWithTag(1001) as! UIImageView
        imgViewUser.layer.cornerRadius = 5
        imgViewUser.layer.masksToBounds = true
        
        let lblTitle = cell.contentView.viewWithTag(1002) as! UILabel
        
        let collectionView = cell.contentView.viewWithTag(1003) as! UICollectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let imgViewLike = cell.contentView.viewWithTag(1006) as! UIImageView
        let lblLike = cell.contentView.viewWithTag(1007) as! UILabel
        let lblNumberOfComment = cell.contentView.viewWithTag(1009) as! UILabel
        let lblShare = cell.contentView.viewWithTag(1011) as! UILabel
        let lblTime = cell.contentView.viewWithTag(1013) as! UILabel
        let btnLike = cell.contentView.viewWithTag(-11) as! UIButton
        let btnShare = cell.contentView.viewWithTag(-15) as! UIButton
        
        btnShare.addTarget(self, action: #selector(self.clickOnShareWebsite(sender:)), for: UIControl.Event.touchUpInside)
        
        let imgViewVComment = cell.contentView.viewWithTag(1014) as! UIImageView
        imgViewVComment.layer.cornerRadius = 5
        imgViewVComment.layer.masksToBounds = true
        
        let lblComment = cell.contentView.viewWithTag(1015) as! TTTAttributedLabel
        let btnViewAllComments = cell.contentView.viewWithTag(1016) as! UIButton
        
        btnViewAllComments.addTarget(self, action: #selector(self.clickOnViewCommnet(sender:)), for: UIControl.Event.touchUpInside)
        
        let imgViewCommentProfile = cell.contentView.viewWithTag(1017) as! UIImageView
        imgViewCommentProfile.layer.cornerRadius = 5
        imgViewCommentProfile.layer.masksToBounds = true
        
        let imgFav = cell.contentView.viewWithTag(10) as! UIImageView
        imgFav.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnFav(gesture:)))
        imgFav.addGestureRecognizer(tapGesture)
        
        imgViewLike.isUserInteractionEnabled = true
        let tapGestureLike = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnLike(gesture:)))
        imgViewLike.addGestureRecognizer(tapGestureLike)
        
        btnLike.addTarget(self, action: #selector(self.clickOnShare(sender:)), for: UIControl.Event.touchUpInside)
        
        let strCreatedAt = dicPost.value(forKey: "created_at") as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: strCreatedAt!)
        
        lblTime.text = date?.timeAgoSimple
        
        let btnComment = cell.contentView.viewWithTag(1018) as! UIButton
        btnComment.addTarget(self, action: #selector(self.clickOnViewCommnet(sender:)), for: UIControl.Event.touchUpInside)
        
        if self.isClickOnFav == 0{
            
            if dicPost.value(forKey: "favourite")  as! Int == 0{
                imgFav.image = UIImage.init(named: "unfav.png")
            }
            else{
                imgFav.image = UIImage.init(named: "fav.png")
            }
            
            if dicPost.value(forKey: "like")  as! Int == 0{
                imgViewLike.image = UIImage.init(named: "like.png")
            }
            else{
                imgViewLike.image = UIImage.init(named: "likeblue.png")
            }
            
        }
        else{
            if dicPost.value(forKey: "favourite")  as! Int == 0{
                imgFav.image = UIImage.init(named: "unfav.png")
            }
            else{
                imgFav.image = UIImage.init(named: "fav.png")
            }
            
            if dicPost.value(forKey: "like")  as! Int == 0{
                imgViewLike.image = UIImage.init(named: "like.png")
            }
            else{
                imgViewLike.image = UIImage.init(named: "likeblue.png")
            }
            
        }
        
         let dicWebsite = arrWebsite.object(at: 0) as! NSDictionary
    
        let title = dicWebsite.object(forKey: "search_term") as? String
        if(title != nil) {
            lblTitle.text = String(htmlString: title!)
        }else {
            lblTitle.text = ""
        }
            
        lblNumberOfComment.text = "\(dicPost.value(forKey: "comment_count") as! Int)"
        lblLike.text = "\(dicPost.value(forKey: "like_count") as! Int)"
        lblShare.text = "\(dicPost.value(forKey: "comment_count") as! Int)"
        
        lblTitle.isUserInteractionEnabled  = true
        
        let tapGestureSearchTerm = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnSearchTerm(gesture:)))
        
        lblTitle.addGestureRecognizer(tapGestureSearchTerm)
        
        let commentViewCount = cell.contentView.viewWithTag(8001) as UIView?
        
        let tapGestureCommentView = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnCommentView(gesture:)))
        
        commentViewCount!.addGestureRecognizer(tapGestureCommentView)
        
        let arrCommnet = dicPost.object(forKey: "comments") as! NSArray
        
        
        let commentView = cell.contentView.viewWithTag(8000) as UIView?
        let mainView = cell.contentView.viewWithTag(999) as UIView?
        let enterCommentView = cell.contentView.viewWithTag(99) as UIView?
        
        commentView?.translatesAutoresizingMaskIntoConstraints = true
        enterCommentView?.translatesAutoresizingMaskIntoConstraints = true
        mainView?.translatesAutoresizingMaskIntoConstraints = true
        
        var frame = CGRect()
        
        if arrCommnet.count > 0{
            
            let dicComment = arrCommnet.lastObject as! NSDictionary
            
            lblComment.text = (dicComment.value(forKey: "comment") as! String)
            let LinkAttributes = NSMutableDictionary(dictionary: lblComment.linkAttributes)
            LinkAttributes[NSAttributedString.Key.underlineStyle] =  NSNumber(value: false)
            lblComment.linkAttributes = LinkAttributes as NSDictionary as! [AnyHashable: Any]
            
            let arrayName = (lblComment.text! as! String).components(separatedBy: " ") as! NSArray
            
            for index in 0..<arrayName.count
            {
                let strUserName = arrayName.object(at: index) as! String
                
                let range = (lblComment.text as! NSString).range(of: "\(strUserName)")
                
                lblComment.delegate = self
                
                if strUserName.contains("@"){
                    let strLinkUserName = strUserName.replacingOccurrences(of: "@", with: "")
                    
                    var url = "http://\(strLinkUserName)"
                    url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    
                    lblComment.addLink(to: URL.init(string: url), with: range)
                    lblComment.isUserInteractionEnabled = true
                }
            }
            
            let dicUserComment = dicComment.object(forKey: "user") as! NSDictionary
            var stravatar = dicUserComment.value(forKey: "avatar") as? String
            
            stravatar = stravatar?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            if stravatar != nil {
                
                imgViewVComment.sd_setImage(with: URL.init(string: stravatar!), placeholderImage: nil, options: .continueInBackground, completed: nil)
            }
            
            frame = (commentView?.frame)!
            frame.origin.y = 550
            frame.size.width = tblview.frame.size.width
            frame.size.height = 80
            commentView?.frame = frame
            
            frame = (enterCommentView?.frame)!
            frame.size.width = tblview.frame.size.width
            frame.origin.y = 629
            enterCommentView?.frame = frame
        }
        else{
            
            frame = (commentView?.frame)!
            frame.size.width = tblview.frame.size.width
            frame.size.height = 0
            commentView?.frame = frame
            
            frame = (enterCommentView?.frame)!
            frame.size.width = tblview.frame.size.width
            frame.origin.y = 550
            enterCommentView?.frame = frame
            
        }
        
        frame = (mainView?.frame)!
        frame.size.width = tblview.frame.size.width
        frame.size.height = (enterCommentView?.frame.origin.y)! + (enterCommentView?.frame.size.height)!
        mainView?.frame = frame
        
        var strUserImg = appDelegate.dicLoginDetail.value(forKey: "avatar") as? String
        strUserImg = strUserImg?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        imgViewCommentProfile.sd_setImage(with: URL.init(string: strUserImg!), placeholderImage: nil, options: .continueInBackground, completed: nil)
        
        if (dicPost.object(forKey: "user") as AnyObject).isKind(of: NSDictionary.self){
            
            let dicUser = dicPost.object(forKey: "user") as! NSDictionary
            
            var stravatar = dicUser.value(forKey: "avatar") as? String
            stravatar = stravatar?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            imgViewUser.sd_setImage(with: URL.init(string: stravatar!), placeholderImage: nil, options: .continueInBackground, completed: nil)
            
            imgViewUser.isUserInteractionEnabled = true
            
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnUserImg(gesture:)))
            imgViewUser.addGestureRecognizer(tapGesture)
        }
        
        
        collectionView.accessibilityLabel = String.init(format: "%d", indexPath.row)
        
        collectionView.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .centeredHorizontally, animated: true)

        
        let btnMore = cell.contentView.viewWithTag(11) as! UIButton
        btnMore.addTarget(self, action: #selector(self.clickOnMorePost(sender:)), for: UIControl.Event.touchUpInside)
        
        let dicUser = dicPost.object(forKey: "user") as! NSDictionary
        
        if "\(dicUser.value(forKey: "id") as! Int)" == "\(appDelegate.dicLoginDetail.value(forKey: "id") as! Int)"
        {
            btnMore.isHidden = false
        }
        else{
            btnMore.isHidden = true
        }
        
        
        let lblCount = cell.contentView.viewWithTag(2006) as! UILabel
        lblCount.text = "\(1)/\(arrWebsite.count)"
        lblCount.adjustsFontSizeToFitWidth = true
        
        let pageControl = cell.contentView.viewWithTag(2004) as! UIPageControl
        
        pageControl.numberOfPages = arrWebsite.count
        pageControl.currentPage = 0
        
        let countView = cell.contentView.viewWithTag(2005) as UIView?
        countView?.layer.cornerRadius = (countView?.frame.size.height)!/2
        
        if arrWebsite.count > 1 {
            countView?.isHidden = false
            pageControl.isHidden  = false
        }
        else{
            countView?.isHidden = true
            pageControl.isHidden  = true
        }
        
        cell.selectionStyle = .none
        
        collectionView.reloadData()
        
        return cell
    }
    
    @objc func tapOnUserImg(gesture:UITapGestureRecognizer)
    {
        if self.isClickOnFav == 1{
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
            let indexPath = tblview.indexPath(for: cell)
            if indexPath != nil
            {
                if indexPath!.row <= arrBookMark.count-1
                {
                    let dicPost = self.arrBookMark.object(at: indexPath!.row) as! NSDictionary
                    
                    let profileVC = objMainSB.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                    self.navigationItem.title = ""
                    profileVC.dicUserDetail = (dicPost.object(forKey: "user") as? NSDictionary)!
                    self.navigationController?.pushViewController(profileVC, animated: true)
                }
            }
        }
    }

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell.tag == 10{
            
            if self.isClickOnFav == 1{
                self.getFavouritePost(showProgress: false)
            }
            else{
                self.getPost(showProgress: false)
            }
        }
    }
    
    
    func loadingCell() -> UITableViewCell? {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = CGPoint.init(x: tblview.frame.size.width/2, y: cell.frame.size.height/2)
        cell.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        cell.tag = 10
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //return UITableView.automaticDimension
        
        let count = self.isClickOnFav == 1 ? self.arrBookMark.count : self.arrSarchPost.count
        
        if indexPath.row < count{
            
            let cell = tblview.dequeueReusableCell(withIdentifier: "cellhome")
            
            var dicPost : NSDictionary!
            
            if self.isClickOnFav == 1{
                dicPost = self.arrBookMark.object(at: indexPath.row) as? NSDictionary
            }
            else{
                dicPost = self.arrSarchPost.object(at: indexPath.row) as? NSDictionary
            }
            
            let arrCommnet = dicPost.object(forKey: "comments") as! NSArray
            
            let commentView = cell!.contentView.viewWithTag(8000) as UIView?
            let mainView = cell!.contentView.viewWithTag(999) as UIView?
            let enterCommentView = cell!.contentView.viewWithTag(99) as UIView?
            
            commentView?.translatesAutoresizingMaskIntoConstraints = true
            enterCommentView?.translatesAutoresizingMaskIntoConstraints = true
            mainView?.translatesAutoresizingMaskIntoConstraints = true
            
            var frame = CGRect()
            
            if arrCommnet.count > 0{
                
                frame = (commentView?.frame)!
                frame.origin.y = 550
                frame.size.height = 80
                commentView?.frame = frame
                
                frame = (enterCommentView?.frame)!
                frame.origin.y = 629
                enterCommentView?.frame = frame
            }
            else{
                
                frame = (commentView?.frame)!
                frame.size.height = 0
                commentView?.frame = frame
                
                frame = (enterCommentView?.frame)!
                frame.origin.y = 550
                enterCommentView?.frame = frame
                
            }
            
            frame = (mainView?.frame)!
            frame.size.height = (enterCommentView?.frame.origin.y)! + (enterCommentView?.frame.size.height)!
            mainView?.frame = frame
            
            return (mainView?.frame.origin.y)! + (mainView?.frame.size.height)!
        }
        return 70
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let index = (Int)(collectionView.accessibilityLabel!)
        
        var dicPost : NSDictionary!
        
        if self.isClickOnFav == 1{
            dicPost = self.arrBookMark.object(at: index!) as? NSDictionary
        }
        else{
            dicPost = self.arrSarchPost.object(at: index!) as? NSDictionary
        }
        
        let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
        
        return arrWebsite.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WebsiteCell", for: indexPath)
        
        let imgView = cell.contentView.viewWithTag(2001) as! UIImageView
        
        let index = (Int)(collectionView.accessibilityLabel!)
        
        var dicPost : NSDictionary!
        
        if self.isClickOnFav == 1{
            dicPost = self.arrBookMark.object(at: index!) as? NSDictionary
        }
        else{
            dicPost = self.arrSarchPost.object(at: index!) as? NSDictionary
        }
        
        let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
        
        let dicWebsite = arrWebsite.object(at: indexPath.item) as! NSDictionary
        
        let contentLabel = cell.contentView.viewWithTag(1100) as! UILabel
        let viewLabel = cell.contentView.viewWithTag(1220) as! UIView
        var strWebsiteImg = dicWebsite.value(forKey: "image") as! String
        //  strWebsiteImg = strWebsiteImg.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let strContentMsg = dicWebsite.value(forKey: "content") as? String
        
        if strWebsiteImg == ""
        {
            viewLabel.isHidden = false
            contentLabel.isHidden = false
            imgView.isHidden = true
            contentLabel.text = strContentMsg
            contentLabel.setLineHeight(lineHeight: 1.2)
            
        } else {
            viewLabel.isHidden = true
            contentLabel.isHidden = true
            imgView.isHidden = false
            
            imgView.sd_setImage(with: URL.init(string: strWebsiteImg), placeholderImage: nil, options: .continueInBackground) { (image,error,cacheType,url) in
                
                if image == nil{
                    
                    let array = strWebsiteImg.components(separatedBy: "?")
                    if (array.count) > 1{
                        let strImageNew = array[0]
                        
                        imgView.sd_setImage(with: URL.init(string: strImageNew), placeholderImage: nil, options: .continueInBackground, completed: nil)
                    }
                }
                else{
                    imgView.image = image
                }
            }
        }
        
        if indexPath.row == 0 {
            
            let tableCell = collectionView.superview?.superview!.superview?.superview as! UITableViewCell
            
            let lblDescription = tableCell.viewWithTag(2002) as! UILabel
            
            if arrWebsite.count > 1{
                
                lblDescription.frame = CGRect.init(x: 15, y: 15, width: UIScreen.main.bounds.size.width-60, height: 20)
            }
            else{
                lblDescription.frame = CGRect.init(x: 15, y: 5, width: UIScreen.main.bounds.size.width-60, height: 20)
            }
            
            lblDescription.numberOfLines = 2
          //  lblDescription.text = dicWebsite.value(forKey: "title") as? String
            let Description = dicWebsite.value(forKey: "title") as? String
            lblDescription.text = String(htmlString: Description!)
            lblDescription.sizeToFit()
            
            lblDescription.isUserInteractionEnabled = true
            lblDescription.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.taponWebSiteURL(gesture:))))
            
            if dicWebsite.value(forKey: "type") as? String == "video"
            {
                cell.viewWithTag(-10)?.isHidden = false
                let btnPlay = cell.viewWithTag(-10) as! UIButton
                btnPlay.addTarget(self, action: #selector(self.clickOnPlay(sender:)), for: UIControl.Event.touchUpInside)
            }
            else{
                cell.viewWithTag(-10)?.isHidden = true
            }
            
            let lblWeb = tableCell.viewWithTag(2003) as! UILabel
            lblWeb.text = dicWebsite.value(forKey: "website") as? String
            
            lblWeb.isUserInteractionEnabled = true
            lblWeb.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.taponWebSiteURL(gesture:))))
            
            lblWeb.frame = CGRect.init(x: 15, y: lblDescription.frame.origin.y + lblDescription.frame.size.height + 5, width: UIScreen.main.bounds.size.width-30, height: 20)
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let index = (Int)(collectionView.accessibilityLabel!)
        
        var dicPost : NSDictionary!
        
        if self.isClickOnFav == 1{
            dicPost = self.arrBookMark.object(at: index!) as? NSDictionary
        }
        else{
            dicPost = self.arrSarchPost.object(at: index!) as? NSDictionary
        }
        
        let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
        
        let dicWebsite = arrWebsite.object(at: indexPath.item) as! NSDictionary
        
        let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
        browserVC.hidesBottomBarWhenPushed = true
        browserVC.strURL = dicWebsite.value(forKey: "website") as! String
        browserVC.isFromSearch = false
        browserVC.strTitle = dicWebsite.value(forKey: "title") as! String
        self.navigationController?.pushViewController(browserVC, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize.init(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        return size
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets.init(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    @objc func clickOnPlay(sender:UIButton)
    {
        var tempView = sender as UIView
        var cell : UICollectionViewCell!
        
        while true {
            
            tempView = tempView.superview!
            
            if tempView.isKind(of: UICollectionViewCell.self)
            {
                cell = (tempView as! UICollectionViewCell)
                break
            }
        }
        
        let collectionView = cell.superview as! UICollectionView
        let indexPath = collectionView.indexPath(for: cell)
        
        let index = (Int)(collectionView.accessibilityLabel!)
        
        var dicPost : NSDictionary!
        
        if self.isClickOnFav == 1{
            dicPost = self.arrBookMark.object(at: index!) as? NSDictionary
        }
        else{
            dicPost = self.arrSarchPost.object(at: index!) as? NSDictionary
        }
        
        let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
        
        let dicWebsite = arrWebsite.object(at: (indexPath?.row)!) as! NSDictionary
        
        let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
        browserVC.hidesBottomBarWhenPushed = true
        browserVC.strURL = dicWebsite.value(forKey: "website") as! String
        self.navigationController?.pushViewController(browserVC, animated: true)
        
    }
    
    
    @objc func tapOnFollowers()
    {
        let followersVC = objHomeSB.instantiateViewController(withIdentifier: "FollowersScreeenVC") as! FollowersScreeenVC
        followersVC.dicUserDetail = self.dicUserDetail.count == 0 ? appDelegate.dicLoginDetail : self.dicUserDetail
        self.navigationController?.pushViewController(followersVC, animated: true)
    }
    
    @objc func tapOnFollowing()
    {
        let followingVC = objHomeSB.instantiateViewController(withIdentifier: "FollowingScreenVC") as! FollowingScreenVC
        followingVC.dicUserDetail = self.dicUserDetail.count == 0 ? appDelegate.dicLoginDetail : self.dicUserDetail
        self.navigationController?.pushViewController(followingVC, animated: true)
    }
    
    @objc func tapOnSearchTerm(gesture:UITapGestureRecognizer)
    {
        let searchVC = objHomeSB.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        searchVC.strSearchTerm = (gesture.view as! UILabel).text!
        searchVC.hidesBottomBarWhenPushed  = true
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc func taponWebSiteURL(gesture:UITapGestureRecognizer)
    {
        var tempView = gesture.view as! UIView
        var tableCell : UITableViewCell!
        
        while true {
            
            tempView = tempView.superview!
            
            if tempView.isKind(of: UITableViewCell.self)
            {
                tableCell = (tempView as! UITableViewCell)
                break
            }
        }
        
        let collectionView = tableCell?.viewWithTag(1003) as! UICollectionView
        let cell = collectionView.visibleCells.last
        
        let indexpath = collectionView.indexPath(for: cell!)
        
        let index = (Int)(collectionView.accessibilityLabel!)
        
        var dicPost : NSDictionary!
        
        if self.isClickOnFav == 1{
            dicPost = self.arrBookMark.object(at: index!) as? NSDictionary
        }
        else{
            dicPost = self.arrSarchPost.object(at: index!) as? NSDictionary
        }
        
        let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
        
        let dicWebsite = arrWebsite.object(at: (indexpath?.row)!) as! NSDictionary
        
        let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
        browserVC.hidesBottomBarWhenPushed = true
        browserVC.strURL = dicWebsite.value(forKey: "website") as! String
        self.navigationController?.pushViewController(browserVC, animated: true)
    }
    
    @objc func clickOnShare(sender:UIButton)
    {
        var tempView = sender as! UIView
        var cell : UITableViewCell!
        
        while true {
            
            tempView = tempView.superview!
            
            if tempView.isKind(of: UITableViewCell.self)
            {
                cell = (tempView as! UITableViewCell)
                break
            }
        }
        
        let indexPath = tblview.indexPath(for: cell)
        
        var dicPost : NSDictionary!
        
        if self.isClickOnFav == 1{
            dicPost = self.arrBookMark.object(at: (indexPath?.row)!) as? NSDictionary
        }
        else{
            dicPost = self.arrSarchPost.object(at: (indexPath?.row)!) as? NSDictionary
        }
        
        let likeVC = objHomeSB.instantiateViewController(withIdentifier: "LikeViewController") as! LikeViewController
        likeVC.dicPostDetail = dicPost
        self.navigationController?.pushViewController(likeVC, animated: true)
        
    }
    
    @IBAction func clickOnMore(sender:UIButton)
    {
        let settingVC = objEditProfileSB.instantiateViewController(withIdentifier: "SettingViewcontroller") as! SettingViewcontroller
        
        settingVC.followRequestCount = self.followRequestcount
        
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    @objc func tapOnFav(gesture:UITapGestureRecognizer)
    {
        var tempView = gesture.view as! UIView
        var cell : UITableViewCell!
        
        while true {
            
            tempView = tempView.superview!
            
            if tempView.isKind(of: UITableViewCell.self)
            {
                cell = (tempView as! UITableViewCell)
                break
            }
        }
        
        
        let indexPath = tblview.indexPath(for: cell)
        
        var dicPost : NSDictionary!
        
        if self.isClickOnFav == 1{
            dicPost = self.arrBookMark.object(at: (indexPath?.row)!) as? NSDictionary
        }
        else{
            dicPost = self.arrSarchPost.object(at: (indexPath?.row)!) as? NSDictionary
        }
        
        self.selectedFavIndex = (indexPath?.row)!
        
        let strURL = "\(SERVER_URL)/posts/favourites"
        
        let dicFav = NSMutableDictionary()
        dicFav.setValue(dicPost.value(forKey: "id") as! Int, forKey: "post_id")
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "favourites", bodyObject: dicFav as AnyObject, delegate: self, isShowProgress: true)
        
    }
    
    @objc func tapOnCommentView(gesture:UITapGestureRecognizer)
    {
        var tempView = gesture.view as! UIView
        var cell : UITableViewCell!
        
        while true {
            
            tempView = tempView.superview!
            
            if tempView.isKind(of: UITableViewCell.self)
            {
                cell = (tempView as! UITableViewCell)
                break
            }
        }
        
        let indexPath = self.tblview.indexPath(for: cell)
        
        var dicPost : NSDictionary!
        
        if self.isClickOnFav == 1{
            dicPost = self.arrBookMark.object(at: (indexPath?.row)!) as? NSDictionary
        }
        else{
            dicPost = self.arrSarchPost.object(at: (indexPath?.row)!) as? NSDictionary
        }
        
        let collectionView = cell.contentView.viewWithTag(1003) as! UICollectionView
        
        let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
        let visibleCell = collectionView.visibleCells.last
        
        let index = collectionView.indexPath(for: visibleCell!)
        let dicWebsite = arrWebsite.object(at: (index?.item)!) as! NSDictionary
        
        let commentVC = objHomeSB.instantiateViewController(withIdentifier: "CommnetViewController") as! CommnetViewController
        commentVC.dicPost = dicPost
        commentVC.strWebsite = dicWebsite.value(forKey: "website") as? String
        commentVC.isFromHome = true
        commentVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    
    @objc func tapOnLike(gesture:UITapGestureRecognizer)
    {
        var tempView = gesture.view as! UIView
        var cell : UITableViewCell!
        
        while true {
            
            tempView = tempView.superview!
            
            if tempView.isKind(of: UITableViewCell.self)
            {
                cell = (tempView as! UITableViewCell)
                break
            }
        }
        
        
        let indexPath = tblview.indexPath(for: cell)
        
        var dicPost : NSDictionary!
        
        if self.isClickOnFav == 1{
            dicPost = self.arrBookMark.object(at: (indexPath?.row)!) as? NSDictionary
        }
        else{
            dicPost = self.arrSarchPost.object(at: (indexPath?.row)!) as? NSDictionary
        }
        
        selectedLikeIndex = (indexPath?.row)!
        
        let strURL = "\(SERVER_URL)/posts/toggle-like"
        
        let dicFav = NSMutableDictionary()
        dicFav.setValue(dicPost.value(forKey: "id") as! Int, forKey: "post_id")
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "toggle-like", bodyObject: dicFav as AnyObject, delegate: self, isShowProgress: true)
    }
    
    @objc func clickOnShareWebsite(sender:UIButton)
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
        
        
        let indexPath = self.tblview.indexPath(for: cell)
        let collectionView = cell.contentView.viewWithTag(1003) as! UICollectionView
        
        var dicPost : NSDictionary!
        
        if self.isClickOnFav == 1{
            dicPost = self.arrBookMark.object(at: (indexPath?.row)!) as? NSDictionary
        }
        else{
            dicPost = self.arrSarchPost.object(at: (indexPath?.row)!) as? NSDictionary
        }
        let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
        let visibleCell = collectionView.visibleCells.last
        
        let index = collectionView.indexPath(for: visibleCell!)
        let dicWebsite = arrWebsite.object(at: (index?.item)!) as! NSDictionary
        
        let shareURL = URL.init(string: dicWebsite.value(forKey: "website") as! String)
        
        let strMessage = "\(shareURL as! URL)\n Join me on SWIS to See What I Search"

        let acitvityController = UIActivityViewController.init(activityItems: [strMessage], applicationActivities: nil)
        
        self.present(acitvityController, animated: true, completion: nil)
    }
    
    @objc func clickOnViewCommnet(sender:UIButton)
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
        
        
        let indexPath = self.tblview.indexPath(for: cell)
        
        var dicPost : NSDictionary!
        
        if self.isClickOnFav == 1{
            dicPost = self.arrBookMark.object(at: (indexPath?.row)!) as? NSDictionary
        }
        else{
            dicPost = self.arrSarchPost.object(at: (indexPath?.row)!) as? NSDictionary
        }
        
        let collectionView = cell.contentView.viewWithTag(1003) as! UICollectionView
        
        let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
        let visibleCell = collectionView.visibleCells.last
        
        let index = collectionView.indexPath(for: visibleCell!)
        let dicWebsite = arrWebsite.object(at: (index?.item)!) as! NSDictionary
        
        let commentVC = objHomeSB.instantiateViewController(withIdentifier: "CommnetViewController") as! CommnetViewController
        commentVC.dicPost = dicPost
        commentVC.strWebsite = dicWebsite.value(forKey: "website") as? String
        commentVC.isFromHome = sender.tag == 1018 ? true : false
        commentVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(commentVC, animated: true)
        
    }
    
    
    @objc func clickOnMorePost(sender:UIButton)
    {
        var tempView = sender as! UIView
        var cell : UITableViewCell!
        
        while true {
            
            tempView = tempView.superview!
            
            if tempView.isKind(of: UITableViewCell.self)
            {
                cell = (tempView as! UITableViewCell)
                break
            }
        }
        
        let indexPath = tblview.indexPath(for: cell)
        deleteSelectedPostIndex = indexPath?.row
        
        var dicPost : NSDictionary!
        
        if self.isClickOnFav == 1{
            dicPost = self.arrBookMark.object(at: (indexPath?.row)!) as? NSDictionary
        }
        else{
            dicPost = self.arrSarchPost.object(at: (indexPath?.row)!) as? NSDictionary
        }
 
        let alertController = UIAlertController.init(title: "SWIS", message: "To make changes to a search journey, please choose below.", preferredStyle: .actionSheet)
        
        let arrWebsite1 = dicPost.value(forKey: "websites") as! NSArray
        
        if arrWebsite1.count > 1 {
            
            let actionNo = UIAlertAction.init(title: "Delete single search?", style: .default) { (action) in
                
                //    self.selectedDeleteIndex = (indexPath?.row)!
                
                let strURL = "\(SERVER_URL)/posts/delete_website"
                
                let dicFav = NSMutableDictionary()
                
                let arrWebSite = dicPost.value(forKey: "websites") as? NSArray
                
                let collectionView = cell.contentView.viewWithTag(1003) as! UICollectionView
                
                let cell = collectionView.visibleCells.last
                
                let indexpath1 = collectionView.indexPath(for: cell!)
                self.deleteSelectedWebsiteIndex = indexpath1?.row
                
                let dicWebsite = arrWebSite?.object(at: (indexpath1?.item)!) as! NSDictionary
                
                //            let websiteId = dicWebsite.value(forKey: "id") as! Int
                
                dicFav.setValue(dicPost.value(forKey: "id") as! Int, forKey: "postId")
                
                dicFav.setValue(dicWebsite.value(forKey: "id") as! Int, forKey: "websiteId")
                
                print(dicFav)
                
                WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_DELETE, ServiceName: "delete_singel_page", bodyObject: dicFav as AnyObject, delegate: self, isShowProgress: true)
            }
            
            alertController.addAction(actionNo)

        }
        
        let actionYes = UIAlertAction.init(title: "Delete entire search journey?", style: .default) { (action) in
            
            self.selectedDeleteIndex = (indexPath?.row)!
            
            let strURL = "\(SERVER_URL)/posts/delete_post"
            
            let dicFav = NSMutableDictionary()
            dicFav.setValue(dicPost.value(forKey: "id") as! Int, forKey: "postId")
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "delete_post", bodyObject: dicFav as AnyObject, delegate: self, isShowProgress: true)
        }
        
        alertController.addAction(actionYes)
        
        let actionCancle = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(actionCancle)
        
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func clickOnFollow(sender:UIButton)
    {
        if self.btnUnFollow.titleLabel?.text == "Unfollow"
        {
            let dicFollow = NSMutableDictionary()
            dicFollow.setValue(dicUserDetail.value(forKey: "id") as! Int, forKey: "user_id")
            
            let strURL = "\(SERVER_URL)/unfollow"
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "unfollow", bodyObject: dicFollow as AnyObject, delegate: self, isShowProgress: true)
        }
        else{
            let strURL = "\(SERVER_URL)/follow-request"
            
            let dicFollow = NSMutableDictionary()
            dicFollow.setValue(dicUserDetail.value(forKey: "id") as! Int, forKey: "following_id")
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "follow-request", bodyObject: dicFollow as AnyObject, delegate: self, isShowProgress: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        for view in scrollView.subviews
        {
            if view.isKind(of: UICollectionViewCell.self)
            {
                let cell = view as! UICollectionViewCell
                let collectionView = cell.superview as! UICollectionView
                
                let tableCell = collectionView.superview?.superview!.superview?.superview as! UITableViewCell
                
                let pageControl = tableCell.contentView.viewWithTag(2004) as! UIPageControl
                let lblCount = tableCell.contentView.viewWithTag(2006) as! UILabel
                
                let index = scrollView.contentOffset.x/scrollView.frame.size.width
                
                let i = (Int)(collectionView.accessibilityLabel!)
                
                var dicPost : NSDictionary!
                
                if self.isClickOnFav == 1{
                    dicPost = self.arrBookMark.object(at: i!) as? NSDictionary
                }
                else{
                    dicPost = self.arrSarchPost.object(at: i!) as? NSDictionary
                }
                
                let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
                
                pageControl.currentPage = (Int)(index)
                lblCount.text = "\((Int)(index+1))/\(arrWebsite.count)"
                lblCount.adjustsFontSizeToFitWidth = true
                
                let dicWebsite = arrWebsite.object(at: (Int)(index)) as! NSDictionary
                
                let lblDescription = tableCell.viewWithTag(2002) as! UILabel
                
                if arrWebsite.count > 1{
                    
                    lblDescription.frame = CGRect.init(x: 15, y: 15, width: UIScreen.main.bounds.size.width-30, height: 20)
                }
                else{
                    lblDescription.frame = CGRect.init(x: 15, y: 5, width: UIScreen.main.bounds.size.width-30, height: 20)
                }
                
                lblDescription.numberOfLines = 2
                //lblDescription.text = dicWebsite.value(forKey: "title") as? String
                let Description = dicWebsite.value(forKey: "title") as? String
                lblDescription.text = String(htmlString: Description!)
                lblDescription.sizeToFit()
                
                let lblWeb = tableCell.viewWithTag(2003) as! UILabel
                lblWeb.text = dicWebsite.value(forKey: "website") as? String
                
                let lblTitle = tableCell.contentView.viewWithTag(1002) as! UILabel
               // lblTitle.text = dicWebsite.value(forKey: "search_term") as? String
                let title = dicWebsite.value(forKey: "search_term") as? String
                if(title != nil){
                    lblTitle.text = String(htmlString: title!)
                }else {
                    lblTitle.text = ""
                }
                

                                
                lblWeb.frame = CGRect.init(x: 15, y: lblDescription.frame.origin.y + lblDescription.frame.size.height + 5, width: UIScreen.main.bounds.size.width-30, height: 20)
                
            }
        }
        
    }
    
}
extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}
extension UIImageView {
    
    func setImageFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async {
                self.image = image
            }
            }.resume()
    }
    
    func setImageFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        setImageFrom(url: url, contentMode: mode)
    }
}
