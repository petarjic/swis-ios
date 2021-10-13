//
//  HomeViewController.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 12/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit
import SafariServices
import SDWebImage
import TTTAttributedLabel

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,responseDelegate,UIScrollViewDelegate,TTTAttributedLabelDelegate {
    
    @IBOutlet var tblview : UITableView!
    @IBOutlet var collectionViewFollowing : UICollectionView!
    @IBOutlet var topViewHeight : NSLayoutConstraint!
    @IBOutlet var topView : UIView!
    
    var arrPost = NSMutableArray()
    var arrFollowing = NSMutableArray()
    
    var currentPage : NSInteger = 0
    var selectedIndex : NSInteger = -1
    var selectedFavIndex : NSInteger = -1
    var selectedLikeIndex : NSInteger = -1
    var refreshView : LGRefreshView!
    var currentPageFollowing : NSInteger = 0
    var loadNextPageFollowing : Bool = true
    var totalPages : NSInteger = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tblview.rowHeight = UITableView.automaticDimension
        tblview.estimatedRowHeight = 632
        tblview.tableFooterView = UIView()
        tblview.separatorStyle = .none
        
        var strProfile = appDelegate.dicLoginDetail.value(forKey: "avatar") as! String
        strProfile = strProfile.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        self.arrFollowing.removeAllObjects()
        self.collectionViewFollowing.reloadData()
        self.currentPageFollowing = 0
        self.getFollowing()
        
        
        self.downloadImage(from: URL.init(string: strProfile)!)
        self.getPost(showProgress: false)
        
        weak var wself = self
        
        refreshView = LGRefreshView.init(scrollView: self.tblview, refreshHandler: { (refreshView) in
            if (wself != nil)
            {
                self.currentPageFollowing = 0
                self.getFollowing()
                
                self.selectedIndex = -1
                self.collectionViewFollowing.reloadData()
                self.currentPage = 0
                self.totalPages = 0
                self.arrPost = NSMutableArray()
                self.tblview.reloadData()
                self.getPost(showProgress: false)
            }
        })
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.relaodPost), name: NSNotification.Name(rawValue: "reloadPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setCommentCount(noti:)), name: NSNotification.Name(rawValue: "commentReload"), object: nil)
    }
    
    @objc func setCommentCount(noti:NSNotification)
    {
        let dicPost = noti.userInfo!["post"] as! NSDictionary
        let newdicPost = noti.userInfo!["newPost"] as! NSDictionary
        
        let index = self.arrPost.index(of: dicPost)
        
        if index < self.arrPost.count{
            
            self.arrPost.replaceObject(at: index, with: newdicPost)
            self.tblview.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
        }
        
    }
    
    @objc func relaodPost(){
        
        self.selectedIndex = -1
        self.collectionViewFollowing.reloadData()
        self.currentPage = 0
        self.arrPost.removeAllObjects()
        self.tblview.reloadData()
        self.getPost(showProgress: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        appDelegate.setHome()
        self.collectionViewFollowing.reloadData()
        
        self.tblview.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = "SWIS"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.init(name: "FiraSans-Bold", size: 15),NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.kern:2.0]
        
        
        let image = UIImage(named: "menu")?.withRenderingMode(.alwaysOriginal)
        
        let rightBarBtn = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(clickOnMenu))
        self.navigationItem.rightBarButtonItem = rightBarBtn
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadFollowing), name: NSNotification.Name(rawValue: "reloadFollowing"), object: nil)
        
    }
    
    
    @objc func reloadFollowing()
    {
        self.currentPageFollowing = 0
        self.arrFollowing = NSMutableArray()
        self.collectionViewFollowing.reloadData()
        self.getFollowing()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                
                let tabBarController = appDelegate.window?.rootViewController as! UITabBarController
                let img = UIImage(data: data)
                var image = img?.circularImage(size: CGSize.init(width: 30, height: 30))
                image = image?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                tabBarController.tabBar.items![4].image = image
                tabBarController.tabBar.items![4].selectedImage = image
                
            }
        }
    }
    
    func getFollowing()
    {
        let strURL = "\(SERVER_URL)/followings/feed?page=\(currentPageFollowing)&user_id=\(appDelegate.dicLoginDetail.value(forKey: "id") as! Int)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "followings", bodyObject: nil, delegate: self, isShowProgress: false)
    }
    
    func getPost(showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/fetch-posts?page=\(currentPage)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "fetch-posts", bodyObject: nil, delegate: self, isShowProgress: showProgress)
    }
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            self.refreshView.endRefreshing()
            
            if Response.value(forKey: "responseCode") as? Int == 200{
                
                if ServiceName == "followings"
                {
                    print(Response)
                    
                    let arrayFollowing = (Response.object(forKey: "followings") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    if arrayFollowing.count > 0{
                        
                        self.loadNextPageFollowing = true
                        if(self.arrFollowing != nil && self.arrFollowing.count > 0 && self.currentPageFollowing == 0){
                            self.arrFollowing.removeAllObjects()
                        }
                        self.arrFollowing.addObjects(from: arrayFollowing as! [Any])
                        self.collectionViewFollowing.reloadData()
                        if(self.arrFollowing != nil && self.arrFollowing.count > 0 && self.currentPageFollowing == 0){
                            self.collectionViewFollowing.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .centeredHorizontally, animated: true)
                        }
                        self.currentPageFollowing = Response.value(forKey: "nextPage") as! Int
                    }
                    else{
                        self.loadNextPageFollowing = false
                    }
                    
                    if self.arrFollowing.count == 0{
                        
                        self.topViewHeight.constant = 0
                        
                        var frame = CGRect()
                        frame = self.topView.frame
                        frame.size.height = 0
                        self.topView.frame = frame
                    }
                    else{
                        self.topViewHeight.constant = 125
                        
                        var frame = CGRect()
                        frame = self.topView.frame
                        frame.size.height = 110
                        self.topView.frame = frame
                        
                        self.tblview.reloadData()
                        
                    }
                    
                    self.collectionViewFollowing.reloadData()
                }
                else if ServiceName == "favourites" || ServiceName == "unfavourites"
                {
                    
                    if self.selectedFavIndex < self.arrPost.count{
                        
                        let dicPost = NSMutableDictionary.init(dictionary: self.arrPost.object(at: self.selectedFavIndex) as! NSDictionary)
                        
                        if dicPost.value(forKey: "favourite")  as! Int == 0{
                            dicPost.setValue(1, forKey: "favourite")
                        }
                        else{
                            dicPost.setValue(0, forKey: "favourite")
                        }
                        
                        self.arrPost.replaceObject(at: self.selectedFavIndex, with: dicPost)
                        
                        self.tblview.reloadData()
                        //self.tblview.reloadRows(at: [NSIndexPath.init(row: self.selectedFavIndex, section: 0) as IndexPath], with: .none)
                        
                        self.selectedFavIndex = -1
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadBookMark"), object: nil, userInfo: [:])
                    }
                    
                    
                }
                else if ServiceName == "toggle-like"
                {
                    
                    if self.selectedLikeIndex < self.arrPost.count{
                        
                        let dicPost = NSMutableDictionary.init(dictionary: self.arrPost.object(at: self.selectedLikeIndex) as! NSDictionary)
                        
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
                        
                        self.arrPost.replaceObject(at: self.selectedLikeIndex, with: dicPost)
                        // self.tblview.reloadRows(at: [NSIndexPath.init(row: self.selectedLikeIndex, section: 0) as IndexPath], with: .none)
                        
                        self.tblview.reloadData()
                        
                        self.selectedLikeIndex = -1
                    }
                    
                }
                else if ServiceName == "fetch-posts-top"
                {
                    let arrayPost = Response.object(forKey: "posts") as! NSArray
                    
                    self.arrPost.addObjects(from: arrayPost as! [Any])
                    self.currentPage = Response.value(forKey: "next_page") as! Int
                    self.totalPages = (Response.value(forKey: "total_page") as! NSNumber).intValue
                    
                    self.tblview.reloadData()
                    
                }
                else{
                    
                    
                    print(Response)
                    let arrayPost = Response.object(forKey: "posts") as! NSArray
                    
                    self.arrPost.addObjects(from: arrayPost as! [Any])
                    self.currentPage = Response.value(forKey: "next_page") as! Int
                    self.totalPages = (Response.value(forKey: "total_page") as! NSNumber).intValue
                    
                    self.tblview.reloadData()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if currentPage < totalPages{
            return self.arrPost.count + 1
        }
        
        return self.arrPost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < self.arrPost.count{
            return self.setupCell(indexPath: indexPath)
        }
        else{
            return self.loadingCell()!
        }
    }
    
    func setupCell(indexPath:IndexPath)->UITableViewCell
    {
        let dicPost = self.arrPost.object(at: indexPath.item) as! NSDictionary
        
        var cell : UITableViewCell!
        
        let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
        
        cell = tblview.dequeueReusableCell(withIdentifier: "cellhome", for: indexPath)
        
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
        
        let imgViewVComment = cell.contentView.viewWithTag(1014) as! UIImageView
        imgViewVComment.layer.cornerRadius = 5
        imgViewVComment.layer.masksToBounds = true
        
        let lblComment = cell.contentView.viewWithTag(1015) as! TTTAttributedLabel
        let btnViewAllComments = cell.contentView.viewWithTag(1016) as! UIButton
        
        btnViewAllComments.addTarget(self, action: #selector(self.clickOnViewCommnet(sender:)), for: UIControl.Event.touchUpInside)
        
        btnShare.addTarget(self, action: #selector(self.clickOnShareWebsite(sender:)), for: UIControl.Event.touchUpInside)
        
        let imgViewCommentProfile = cell.contentView.viewWithTag(1017) as! UIImageView
        imgViewCommentProfile.layer.cornerRadius = 5
        imgViewCommentProfile.layer.masksToBounds = true
        
        let imgFav = cell.contentView.viewWithTag(10) as! UIImageView
        imgFav.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnFav(gesture:)))
        imgFav.addGestureRecognizer(tapGesture)
        
        let strCreatedAt = dicPost.value(forKey: "created_at") as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: strCreatedAt!)
        
        lblTime.text = date?.timeAgoSimple
        
        let btnComment = cell.contentView.viewWithTag(1018) as! UIButton
        btnComment.addTarget(self, action: #selector(self.clickOnViewCommnet(sender:)), for: UIControl.Event.touchUpInside)
        
        if dicPost.value(forKey: "favourite")  as! Int == 0{
            imgFav.image = UIImage.init(named: "unfav.png")
        }
        else{
            imgFav.image = UIImage.init(named: "fav.png")
        }
        
        imgViewLike.isUserInteractionEnabled = true
        let tapGestureLike = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnLike(gesture:)))
        imgViewLike.addGestureRecognizer(tapGestureLike)
        
        if dicPost.value(forKey: "like")  as! Int == 0{
            imgViewLike.image = UIImage.init(named: "like.png")
        }
        else{
            imgViewLike.image = UIImage.init(named: "likeblue.png")
        }
        
        btnLike.addTarget(self, action: #selector(self.clickOnShare(sender:)), for: UIControl.Event.touchUpInside)
        
        lblTitle.numberOfLines = 2
        //   lblTitle.text = dicPost.value(forKey: "search_term") as? String
        
        let dicWebsite = arrWebsite.object(at: 0) as! NSDictionary
        
        let title = dicWebsite.object(forKey: "search_term") as? String
        if(title != nil){
            lblTitle.text = String(htmlString: title!)
        }else {
            lblTitle.text = ""
        }
        
        lblNumberOfComment.text = "\(dicPost.value(forKey: "comment_count") as! Int)"
        lblLike.text = "\(dicPost.value(forKey: "like_count") as! Int)"
        lblShare.text = "0"
        
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
            
            if dicComment.object(forKey: "user") != nil{
                
                let dicUserComment = dicComment.object(forKey: "user") as! NSDictionary
                
                var stravatar = dicUserComment.value(forKey: "avatar") as? String
                
                stravatar = stravatar?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                
                if stravatar != nil{
                    
                    imgViewVComment.sd_setImage(with: URL.init(string: stravatar!), placeholderImage: nil, options: .continueInBackground, completed: nil)
                }
                
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
        
        let lblCount = cell.contentView.viewWithTag(2006) as! UILabel
        lblCount.text = "\(1)/\(arrWebsite.count)"
        lblCount.adjustsFontSizeToFitWidth = true
        
        let pageControl = cell.contentView.viewWithTag(2004) as! UIPageControl
        
        pageControl.numberOfPages = arrWebsite.count
        pageControl.currentPage = 0
        
        let countView = cell.contentView.viewWithTag(2005) as UIView?
        countView?.layer.cornerRadius = (countView?.frame.size.height)!/2
        
        if arrWebsite.count > 1{
            
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
    
    
    func loadingCell() -> UITableViewCell? {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = CGPoint.init(x: tblview.frame.size.width/2, y: cell.frame.size.height/2)
        cell.addSubview(activityIndicator)
        
        // activityIndicator.startAnimating()
        
        cell.tag = 10
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //return UITableView.automaticDimension
        if indexPath.row < self.arrPost.count{
            let cell = tblview.dequeueReusableCell(withIdentifier: "cellhome")
            
            let dicPost = self.arrPost.object(at: indexPath.item) as! NSDictionary
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
        else{
            return 70
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell.tag == 10{
            
            if self.selectedIndex == -1{
                self.getPost(showProgress: false)
                
            }
            else{
                self.getPostSelectedUser(showProgress: false)
            }
            
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.collectionViewFollowing{
            
            return self.arrFollowing.count
        }
        else{
            
            
            let index = (Int)(collectionView.accessibilityLabel!)
            
            let dicPost = self.arrPost.object(at: index!) as! NSDictionary
            let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
            
            return arrWebsite.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionViewFollowing
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellfollowing", for: indexPath)
            
            let lblFirstName = cell.contentView.viewWithTag(1002) as! UILabel
            let imgUser = cell.contentView.viewWithTag(1001) as! UIImageView
            imgUser.layer.cornerRadius = 5
            imgUser.layer.masksToBounds = true
            
            let dicFollowing = self.arrFollowing.object(at: indexPath.item) as! NSDictionary
            
            let strName = dicFollowing.value(forKey: "name") as! String
            let array = strName.components(separatedBy: " ") as NSArray
            
            lblFirstName.text = array.object(at: 0) as? String
            
            var strUserImg = dicFollowing.value(forKey: "avatar") as! String
            strUserImg = strUserImg.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            imgUser.sd_setImage(with: URL.init(string: strUserImg), placeholderImage: nil, options: .continueInBackground, completed: nil)
            
            if selectedIndex == indexPath.item
            {
                imgUser.layer.borderWidth = 2
                imgUser.layer.borderColor = UIColor.init(red: 45.0/255.0, green: 152.0/255.0, blue: 233.0/255.0, alpha: 1.0).cgColor
            }
            else{
                imgUser.layer.borderWidth = 0
            }
            
            if indexPath.item == self.arrFollowing.count - 1 && self.loadNextPageFollowing{
                self.getFollowing()
            }
            
            return cell
            
        }
        else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WebsiteCell", for: indexPath)
            
            let imgView = cell.contentView.viewWithTag(2001) as! UIImageView
            
            let index = (Int)(collectionView.accessibilityLabel!)
            
            let dicPost = self.arrPost.object(at: index!) as! NSDictionary
            let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
            let dicWebsite = arrWebsite.object(at: indexPath.item) as! NSDictionary
            let contentLabel = cell.contentView.viewWithTag(1100) as! UILabel
            let viewLabel = cell.contentView.viewWithTag(1220) as! UIView
            
            var strWebsiteImg = dicWebsite.value(forKey: "image") as? String
            //strWebsiteImg = strWebsiteImg.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
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
                
                imgView.sd_setImage(with: URL.init(string: strWebsiteImg!), placeholderImage: nil, options: .continueInBackground) { (image,error,cacheType,url) in
                    
                    if image == nil{
                        
                        let array = strWebsiteImg?.components(separatedBy: "?")
                        if (array?.count)! > 1{
                            let strImageNew = array![0]
                            
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
                
                if arrWebsite.count > 1 {
                    
                    lblDescription.frame = CGRect.init(x: 15, y: 15, width: UIScreen.main.bounds.size.width-30, height: 20)
                }
                else {
                    lblDescription.frame = CGRect.init(x: 15, y: 5, width: UIScreen.main.bounds.size.width-30, height: 20)
                }
                
                lblDescription.numberOfLines = 2
                //                lblDescription.text = dicWebsite.value(forKey: "title") as? String
                let Description = dicWebsite.value(forKey: "title") as? String
                lblDescription.text = String(htmlString: Description!)
                lblDescription.sizeToFit()
                
                lblDescription.isUserInteractionEnabled = true
                lblDescription.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.taponWebSiteURL(gesture:))))
                
                /*if dicWebsite.value(forKey: "type") as? String == "video"
                 {
                 cell.viewWithTag(-10)?.isHidden = false
                 let btnPlay = cell.viewWithTag(-10) as! UIButton
                 btnPlay.addTarget(self, action: #selector(self.clickOnPlay(sender:)), for: UIControl.Event.touchUpInside)
                 
                 }
                 else{
                 cell.viewWithTag(-10)?.isHidden = true
                 }*/
                
                let lblWeb = tableCell.viewWithTag(2003) as! UILabel
                lblWeb.text = dicWebsite.value(forKey: "website") as? String
                lblWeb.isUserInteractionEnabled = true
                lblWeb.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.taponWebSiteURL(gesture:))))
                
                lblWeb.frame = CGRect.init(x: 15, y: lblDescription.frame.origin.y + lblDescription.frame.size.height + 5, width: UIScreen.main.bounds.size.width-30, height: 20)
                
            }
            if dicWebsite.value(forKey: "type") as? String == "video"
            {
                cell.viewWithTag(-10)?.isHidden = false
                let btnPlay = cell.viewWithTag(-10) as! UIButton
                btnPlay.addTarget(self, action: #selector(self.clickOnPlay(sender:)), for: UIControl.Event.touchUpInside)
                
            }
            else{
                cell.viewWithTag(-10)?.isHidden = true
            }
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.collectionViewFollowing
        {
            let divide : CGFloat = UIScreen.main.bounds.size.height > 667 ? 5.0 : 4.0
            
            if selectedIndex == indexPath.item
            {
                
                
                //    let size = CGSize.init(width: (collectionView.frame.size.width/divide)+5, height: (collectionView.frame.size.width/divide)+5)
                
                // return size
                
                if UIScreen.main.bounds.size.height > 667
                {
                    let size = CGSize.init(width: 90, height: 90)
                    
                    return size
                }
                else{
                    let size = CGSize.init(width: 85, height: 85)
                    
                    return size
                }
            }
            else{
                
                if UIScreen.main.bounds.size.height > 667
                {
                    let size = CGSize.init(width: 85, height: 85)
                    
                    return size
                }
                else{
                    let size = CGSize.init(width: 80, height: 80)
                    
                    return size
                }
                
            }
            
            
            
            
        }
        else{
            let size = CGSize.init(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
            return size
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionViewFollowing
        {
            if indexPath.item == self.selectedIndex
            {
                self.selectedIndex = -1
                self.collectionViewFollowing.reloadData()
                self.currentPage = 0
                self.arrPost.removeAllObjects()
                self.tblview.reloadData()
                self.getPost(showProgress: false)
                
            }
            else{
                
                self.selectedIndex = indexPath.item
                self.collectionViewFollowing.reloadData()
                
                self.currentPage = 0
                self.arrPost.removeAllObjects()
                
                self.getPostSelectedUser(showProgress: false)
            }
        }
        else{
            let index = (Int)(collectionView.accessibilityLabel!)
            
            let dicPost = self.arrPost.object(at: index!) as! NSDictionary
            let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
            
            let dicWebsite = arrWebsite.object(at: indexPath.item) as! NSDictionary
            
            let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
            browserVC.hidesBottomBarWhenPushed = true
            browserVC.strURL = dicWebsite.value(forKey: "website") as! String
            browserVC.isFromSearch = false
            browserVC.strTitle = dicWebsite.value(forKey: "title") as! String
            self.navigationController?.pushViewController(browserVC, animated: true)
            
        }
        
    }
    
    func getPostSelectedUser(showProgress:Bool)
    {
        let dicFollowing = self.arrFollowing.object(at: selectedIndex) as! NSDictionary
        
        let strURL = "\(SERVER_URL)/fetch-posts?page=\(currentPage)&user_id=\(dicFollowing.value(forKey: "id") as! Int)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "fetch-posts-top", bodyObject: nil, delegate: self, isShowProgress: showProgress)
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
        
        let dicPost = self.arrPost.object(at: index!) as! NSDictionary
        let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
        
        let dicWebsite = arrWebsite.object(at: (indexpath?.row)!) as! NSDictionary
        
        let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
        browserVC.hidesBottomBarWhenPushed = true
        browserVC.strURL = dicWebsite.value(forKey: "website") as! String
        self.navigationController?.pushViewController(browserVC, animated: true)
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
        let dicPost = self.arrPost.object(at: indexPath!.row) as! NSDictionary
        
        let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
        let visibleCell = collectionView.visibleCells.last
        
        let index = collectionView.indexPath(for: visibleCell!)
        let dicWebsite = arrWebsite.object(at: (index?.item)!) as! NSDictionary
        
        let shareURL = URL.init(string: dicWebsite.value(forKey: "website") as! String)
        
        let strMessage = "\(shareURL as! URL)\n Join me on SWIS to See What I Search"
        
        let acitvityController = UIActivityViewController.init(activityItems: [strMessage], applicationActivities: nil)
        
        self.present(acitvityController, animated: true, completion: nil)
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
        let dicPost = self.arrPost.object(at: indexPath!.row) as! NSDictionary
        
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
        let dicPost = self.arrPost.object(at: indexPath!.row) as! NSDictionary
        
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
        
        let dicPost = self.arrPost.object(at: index!) as! NSDictionary
        let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
        
        let dicWebsite = arrWebsite.object(at: (indexPath?.row)!) as! NSDictionary
        
        let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
        browserVC.hidesBottomBarWhenPushed = true
        browserVC.strURL = dicWebsite.value(forKey: "website") as! String
        self.navigationController?.pushViewController(browserVC, animated: true)
        
    }
    
    @objc func clickOnMenu(){
        
        let homeMenuVC = objMainSB.instantiateViewController(withIdentifier: "HomeMainMenuVC") as! HomeMainMenuVC
        
        self.navigationController?.pushViewController(homeMenuVC, animated: true)
        
    }
    
    func moveCollectionToFrame(contentOffset : CGFloat) {
        
        let frame: CGRect = CGRect(x : contentOffset ,y : self.collectionViewFollowing.contentOffset.y ,width : self.collectionViewFollowing.frame.width,height : self.collectionViewFollowing.frame.height)
        self.collectionViewFollowing.scrollRectToVisible(frame, animated: true)
    }
    
    @IBAction func clickOnNext(sender:UIButton)
    {
        let collectionBounds = self.collectionViewFollowing.bounds
        let contentOffset = CGFloat(floor(self.collectionViewFollowing.contentOffset.x + collectionBounds.size.width))
        self.moveCollectionToFrame(contentOffset: contentOffset)
        
    }
    
    @IBAction func clickOnBack(sender:UIButton)
    {
        let collectionBounds = self.collectionViewFollowing.bounds
        let contentOffset = CGFloat(floor(self.collectionViewFollowing.contentOffset.x - collectionBounds.size.width))
        self.moveCollectionToFrame(contentOffset: contentOffset)
    }
    
    @objc func tapOnUserImg(gesture:UITapGestureRecognizer)
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
        
        let indexPath = tblview.indexPath(for: cell)
        let dicPost = self.arrPost.object(at: indexPath!.row) as! NSDictionary
        
        let profileVC = objMainSB.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationItem.title = ""
        profileVC.dicUserDetail = (dicPost.object(forKey: "user") as? NSDictionary)!
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        var str = (url.absoluteString.components(separatedBy: "//") as! NSArray).object(at: 1) as! String
        
        let profileDetailVC = objMainSB.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileDetailVC.strCommentUserName = str
        profileDetailVC.isFromComment = true
        profileDetailVC.hidesBottomBarWhenPushed = false
        
        self.navigationController?.pushViewController(profileDetailVC, animated: true)
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
        let dicPost = self.arrPost.object(at: indexPath!.row) as! NSDictionary
        
        selectedFavIndex = (indexPath?.row)!
        
        let strURL = "\(SERVER_URL)/posts/favourites"
        
        let dicFav = NSMutableDictionary()
        dicFav.setValue(dicPost.value(forKey: "id") as! Int, forKey: "post_id")
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "favourites", bodyObject: dicFav as AnyObject, delegate: self, isShowProgress: true)
        
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
        let dicPost = self.arrPost.object(at: indexPath!.row) as! NSDictionary
        
        selectedLikeIndex = (indexPath?.row)!
        
        let strURL = "\(SERVER_URL)/posts/toggle-like"
        
        let dicFav = NSMutableDictionary()
        dicFav.setValue(dicPost.value(forKey: "id") as! Int, forKey: "post_id")
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "toggle-like", bodyObject: dicFav as AnyObject, delegate: self, isShowProgress: true)
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
        let dicPost = self.arrPost.object(at: indexPath!.row) as! NSDictionary
        
        let likeVC = objHomeSB.instantiateViewController(withIdentifier: "LikeViewController") as! LikeViewController
        likeVC.dicPostDetail = dicPost
        self.navigationController?.pushViewController(likeVC, animated: true)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        for view in scrollView.subviews
        {
            if view.isKind(of: UICollectionViewCell.self)
            {
                let cell = view as! UICollectionViewCell
                let collectionView = cell.superview as! UICollectionView
                
                if collectionView != collectionViewFollowing{
                    let tableCell = collectionView.superview?.superview!.superview?.superview as! UITableViewCell
                    
                    let lblTitle = tableCell.contentView.viewWithTag(1002) as! UILabel
                    let pageControl = tableCell.contentView.viewWithTag(2004) as! UIPageControl
                    let lblCount = tableCell.contentView.viewWithTag(2006) as! UILabel
                    
                    let index = scrollView.contentOffset.x/scrollView.frame.size.width
                    
                    let i = (Int)(collectionView.accessibilityLabel!)
                    
                    let dicPost = self.arrPost.object(at: i!) as! NSDictionary
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
                    let Description = dicWebsite.value(forKey: "title") as? String
                    lblDescription.text = String(htmlString: Description!)
                    
                    //                   lblDescription.text = dicWebsite.value(forKey: "title") as? String
                    
                    lblDescription.sizeToFit()
                    
                    let title = dicWebsite.value(forKey: "search_term") as? String
                    
                    if(title != nil){
                        lblTitle.text = String(htmlString: title!)
                    }else {
                        lblTitle.text = ""
                    }
                    
                    let lblWeb = tableCell.viewWithTag(2003) as! UILabel
                    lblWeb.text = dicWebsite.value(forKey: "website") as? String
                    
                    lblWeb.frame = CGRect.init(x: 15, y: lblDescription.frame.origin.y + lblDescription.frame.size.height + 5, width: UIScreen.main.bounds.size.width-30, height: 20)
                }
            }
        }
        
    }
    
}

extension UIImage {
    
    func circularImage(size: CGSize?) -> UIImage {
        let newSize = size ?? self.size
        
        let minEdge = min(newSize.height, newSize.width)
        let size = CGSize(width: minEdge, height: minEdge)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        self.draw(in: CGRect(origin: CGPoint.zero, size: size), blendMode: .copy, alpha: 1.0)
        
        context!.setBlendMode(.copy)
        context!.setFillColor(UIColor.clear.cgColor)
        
        let rectPath = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: size))
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
        rectPath.append(circlePath)
        rectPath.usesEvenOddFillRule = true
        rectPath.fill()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result!
    }
}
extension UILabel {
    func setLineHeight(lineHeight: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.0
        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.alignment = self.textAlignment
        
        let attrString = NSMutableAttributedString()
        if (self.attributedText != nil) {
            attrString.append( self.attributedText!)
        } else {
            attrString.append( NSMutableAttributedString(string: self.text!))
            attrString.addAttribute(NSAttributedString.Key.font, value: self.font, range: NSMakeRange(0, attrString.length))
        }
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        self.attributedText = attrString
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}


extension String {
    
    init(htmlString: String) {
        self.init()
        guard let encodedData = htmlString.data(using: .utf8) else {
            self = htmlString
            return
        }
        
        let attributedOptions: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        do {
            let attributedString = try NSAttributedString(data: encodedData,
                                                          options: attributedOptions,
                                                          documentAttributes: nil)
            self = attributedString.string
        } catch {
            print("Error: \(error.localizedDescription)")
            self = htmlString
        }
    }
}
