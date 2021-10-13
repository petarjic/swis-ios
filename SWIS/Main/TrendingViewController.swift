//
//  TrendingViewController.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 25/02/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit
import SafariServices

class TrendingViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,responseDelegate,UITextFieldDelegate {
    
    @IBOutlet var tblViewAll : UITableView!
    @IBOutlet var tblViewVideos : UITableView!
    @IBOutlet var tblViewNews : UITableView!
    @IBOutlet var tblViewImage : UITableView!
    @IBOutlet var txtSearch : UITextField!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var btnAll: UIButton!
    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var btnVideo: UIButton!
    @IBOutlet weak var btnNews: UIButton!
    
  //  @IBOutlet var lblLine : UILabel!
    
    var arrAll = NSMutableArray()
    var arrNews = NSMutableArray()
    var arrImage = NSMutableArray()
    var arrVideo = NSMutableArray()
    
    var currentPageAll : NSInteger = 0
    var loadNextPageAll : Bool = true
    
    var currentPageImage : NSInteger = 0
    var loadNextPageImage : Bool = true
    
    var currentPageVideo : NSInteger = 0
    var loadNextPageVideo : Bool = true
    
    var currentPageNews : NSInteger = 0
    var loadNextPageNews : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true
        // Do any additional setup after loading the view.
        
//        tblViewAll.tableFooterView = UIView()
//        tblViewVideos.tableFooterView = UIView()
//        tblViewNews.tableFooterView = UIView()
//        tblViewImage.tableFooterView = UIView()
//
//        tblViewImage.rowHeight = UITableView.automaticDimension
//        tblViewImage.estimatedRowHeight = 225
//
//        tblViewAll.rowHeight = UITableView.automaticDimension
//        tblViewAll.estimatedRowHeight = 250
//
//        tblViewNews.rowHeight = UITableView.automaticDimension
//        tblViewNews.estimatedRowHeight = 250
//
//        viewSearch.layer.cornerRadius = viewSearch.frame.size.height/2
//        viewSearch.layer.borderWidth = 1
//        viewSearch.layer.borderColor = UIColor.gray.cgColor
//        viewSearch.layer.masksToBounds = true
        
   //     self.setupTextField(textField: txtSearch)
        
//        self.btnImage.setTitleColor(UIColor.gray, for: .normal)
//        self.btnAll.setTitleColor(UIColor.blue, for: .normal)
//        self.btnNews.setTitleColor(UIColor.gray, for: .normal)
//        self.btnVideo.setTitleColor(UIColor.gray, for: .normal)
//
       // self.getAll()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        self.navigationItem.title = "SEARCH"
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.init(name: "FiraSans-Book", size: 15),NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.kern:2.0]
//
//        self.navigationController?.navigationBar.isTranslucent = false
//
//        let rightBarBtn = UIBarButtonItem.init(image: UIImage.init(named: "menu"), style: .plain, target: self, action: #selector(clickOnMenu))
//        self.navigationItem.rightBarButtonItem = rightBarBtn
        
        let serachVC = objHomeSB.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        self.navigationItem.title = ""
        serachVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(serachVC, animated: false)
        //self.tabBarController?.tabBar.isHidden = true

        
    }
    
    @objc func clickOnMenu(){
        
        let homeMenuVC = objMainSB.instantiateViewController(withIdentifier: "HomeMainMenuVC") as! HomeMainMenuVC
        
        self.navigationController?.pushViewController(homeMenuVC, animated: true)
        
    }
    
    func getAll()
    {
        let strURL = "\(SERVER_URL)/search/trending"
        
        let strParameters = "type=news&offset=\(self.currentPageAll)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "trendingAll", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
    }
    
    func getAllNews()
    {
        let strURL = "\(SERVER_URL)/search/trending"
        
        let strParameters = "type=news&offset=\(self.currentPageNews)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "trendingNews", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
    }
    
    func getImages()
    {
        let strURL = "\(SERVER_URL)/search/trending"
        
        let strParameters = "type=image&offset=\(self.currentPageImage)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "trendingImage", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
    }
    
    func getVideos()
    {
        let strURL = "\(SERVER_URL)/search/trending"
        
        let strParameters = "type=video&offset=\(self.currentPageVideo)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "trendingVideo", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
    }
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            if Response.value(forKey: "responseCode") as? Int == 200{
                
                if ServiceName == "trendingAll"
                {
                    let arrayAll = (Response.object(forKey: "searchResults") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    if arrayAll.count == 0{
                        
                        self.loadNextPageAll = false
                    }
                    else{
                        self.loadNextPageAll = true
                        self.arrAll.addObjects(from: arrayAll as! [Any])
                        self.currentPageAll = Response.value(forKey: "nextOffset") as! Int
                    }
                    self.tblViewAll.reloadData()
                    
                }
                else if ServiceName == "trendingImage"
                {
                    let arrayImage = (Response.object(forKey: "searchResults") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    if arrayImage.count == 0{
                        
                        self.loadNextPageImage = false
                    }
                    else{
                        self.loadNextPageImage = true
                        self.arrImage.addObjects(from: arrayImage as! [Any])
                        self.currentPageImage = Response.value(forKey: "nextOffset") as! Int
                    }
                    self.tblViewImage.reloadData()
                }
                else if ServiceName == "trendingVideo"
                {
                    let arrayVideo = (Response.object(forKey: "searchResults") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    if arrayVideo.count == 0{
                        
                        self.loadNextPageVideo = false
                    }
                    else{
                        self.loadNextPageVideo = true
                        self.arrVideo.addObjects(from: arrayVideo as! [Any])
                       // self.currentPageVideo = Response.value(forKey: "nextOffset") as! Int
                    }
                    self.tblViewVideos.reloadData()
                }
                else if ServiceName == "trendingNews"{
                    let arrayNews = (Response.object(forKey: "searchResults") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    if arrayNews.count == 0{
                        
                        self.loadNextPageNews = false
                    }
                    else{
                        self.loadNextPageNews = true
                        self.arrNews.addObjects(from: arrayNews as! [Any])
                        self.currentPageNews = Response.value(forKey: "nextOffset") as! Int
                    }
                    self.tblViewNews.reloadData()
                }
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tblViewAll{
            return arrAll.count
        }
        else if tableView == tblViewNews{
            return arrNews.count
        }
        else if tableView == tblViewImage{
            return arrImage.count
        }
        else{
            return arrVideo.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tblViewAll{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewTraddingTopCell", for: indexPath)
            
            let dicAll = self.arrAll.object(at: indexPath.row) as! NSDictionary
            
            let lblTitle = cell.contentView.viewWithTag(1001) as! UILabel
            let imgView = cell.contentView.viewWithTag(1002) as! UIImageView
            let lblProvider = cell.contentView.viewWithTag(1003) as! UILabel
            let lblTime = cell.contentView.viewWithTag(1004) as! UILabel
            let ImgViewDescript = cell.contentView.viewWithTag(1005) as! UIImageView
            
            let view = cell.contentView.viewWithTag(1000) as! UIView
            view.layer.cornerRadius = 5
            
            view.layer.shadowColor = UIColor.gray.cgColor
            view.layer.shadowOpacity = 0.5
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowRadius = 6
            
            lblProvider.frame = CGRect.init(x: 45, y: 353.5, width: 150, height: 21)

            lblTitle.text  = dicAll.value(forKey: "description") as? String
            lblProvider.text = dicAll.value(forKey: "provider") as? String
            lblTime.text = dicAll.value(forKey: "datetime") as? String
            
            lblProvider.translatesAutoresizingMaskIntoConstraints = true
            lblProvider.sizeToFit()
            lblProvider.frame = CGRect.init(x: 45, y: 353.5, width: lblProvider.frame.size.width, height: lblProvider.frame.size.height)

            
            lblTime.translatesAutoresizingMaskIntoConstraints = true
            lblTime.frame = CGRect.init(x: lblProvider.frame.origin.x + lblProvider.frame.size.width + 10, y: 353.5, width: 110, height: lblProvider.frame.size.height)
            
            imgView.sd_setImage(with: URL.init(string: dicAll.value(forKey: "image") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
            
            ImgViewDescript.sd_setImage(with: URL.init(string: dicAll.value(forKey: "provider_icon") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
            
            cell.selectionStyle = .none
            
            if indexPath.row == self.arrAll.count - 1 && self.loadNextPageAll{
                self.getAll()
            }
            
            return cell
        }
        else if tableView == tblViewNews
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
            
            let dicNews = self.arrNews.object(at: indexPath.row) as! NSDictionary
            
            let lblTitle = cell.contentView.viewWithTag(1001) as! UILabel
            let imgView = cell.contentView.viewWithTag(1002) as! UIImageView
            let lblProvider = cell.contentView.viewWithTag(1003) as! UILabel
            let lblTime = cell.contentView.viewWithTag(1004) as! UILabel
            let ImgViewDescript = cell.contentView.viewWithTag(1005) as! UIImageView
            
            let view = cell.contentView.viewWithTag(1000) as! UIView
            view.layer.cornerRadius = 5
            
            view.layer.shadowColor = UIColor.gray.cgColor
            view.layer.shadowOpacity = 0.5
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowRadius = 6
            
            lblProvider.frame = CGRect.init(x: 45, y: 353.5, width: 150, height: 21)
            
            lblTitle.text  = dicNews.value(forKey: "description") as? String
            lblProvider.text = dicNews.value(forKey: "provider") as? String
            lblTime.text = dicNews.value(forKey: "datetime") as? String
            
            lblProvider.translatesAutoresizingMaskIntoConstraints = true
            lblProvider.sizeToFit()
            lblProvider.frame = CGRect.init(x: 45, y: 353.5, width: lblProvider.frame.size.width, height: lblProvider.frame.size.height)
            
            
            lblTime.translatesAutoresizingMaskIntoConstraints = true
            lblTime.frame = CGRect.init(x: lblProvider.frame.origin.x + lblProvider.frame.size.width + 10, y: 353.5, width: 110, height: lblProvider.frame.size.height)

            
            imgView.sd_setImage(with: URL.init(string: dicNews.value(forKey: "image") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
            
            ImgViewDescript.sd_setImage(with: URL.init(string: dicNews.value(forKey: "provider_icon") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)

                        
            cell.selectionStyle = .none
            
            if indexPath.row == self.arrNews.count - 1 && self.loadNextPageNews{
                self.getAllNews()
            }
            
            return cell
        }
        else if tableView == tblViewImage
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
            
            let view = cell.contentView.viewWithTag(1000) as! UIView
            view.layer.cornerRadius = 5
           
            view.layer.shadowColor = UIColor.gray.cgColor
            view.layer.shadowOpacity = 0.5
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowRadius = 6
            
            let lblTitle = cell.contentView.viewWithTag(1002) as! UILabel
            let lblWeb = cell.contentView.viewWithTag(1003) as! UILabel
            let imgView = cell.contentView.viewWithTag(1004) as! UIImageView
            
            let dicImage = self.arrImage.object(at: indexPath.row) as! NSDictionary
            
            lblTitle.text  = dicImage.value(forKey: "title") as? String
            lblWeb.text  = dicImage.value(forKey: "website") as? String
            
            var strURL = dicImage.value(forKey: "image") as! String
            strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            imgView.sd_setImage(with: URL.init(string: strURL), placeholderImage: nil, options: .continueInBackground, completed: nil)
            
            cell.selectionStyle = .none
            
            if indexPath.row == self.arrImage.count - 1 && self.loadNextPageImage{
                self.getImages()
            }
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
            
            let view = cell.contentView.viewWithTag(1000) as! UIView
            view.layer.cornerRadius = 5

            view.layer.shadowColor = UIColor.gray.cgColor
            view.layer.shadowOpacity = 0.5
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowRadius = 6
            
            let btnVideo = cell.contentView.viewWithTag(100) as! UIButton
            btnVideo.addTarget(self, action: #selector(self.clickOnVideo(sender:)), for: UIControl.Event.touchUpInside)
            
            let dicVideo = self.arrVideo.object(at: indexPath.row) as! NSDictionary
            
            let lblTitle = cell.contentView.viewWithTag(1002) as! UILabel
            let lblWeb = cell.contentView.viewWithTag(1003) as! UILabel
            let imgView = cell.contentView.viewWithTag(1004) as! UIImageView
            
            lblTitle.text  = dicVideo.value(forKey: "title") as? String
            lblWeb.text  = dicVideo.value(forKey: "website") as? String
            
            imgView.sd_setImage(with: URL.init(string: dicVideo.value(forKey: "image") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
            
            cell.selectionStyle = .none
            
           // if indexPath.row == self.arrVideo.count - 1 && self.loadNextPageVideo{
              //  self.getVideos()
           // }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tblViewAll{
            
            let dicAll = self.arrAll.object(at: indexPath.row) as! NSDictionary
            
            let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
            browserVC.hidesBottomBarWhenPushed = true
            browserVC.strURL = dicAll.value(forKey: "website") as! String
            self.navigationController?.pushViewController(browserVC, animated: true)
            
            let strURL = "\(SERVER_URL)/save-search"
            
            let strParameters = String.init(format: "query=%@&title=%@&website=%@&description=%@&type=text&bing_id=%@&image=%@",dicAll.value(forKey: "title") as! String,dicAll.value(forKey: "title") as! String,dicAll.value(forKey: "website") as! String,dicAll.value(forKey: "description") as! String,dicAll.value(forKey: "id") as! String,dicAll.value(forKey: "image") as! String)
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "save-search", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: false)
            
        }
        else if tableView == tblViewImage
        {
            let dicImage = self.arrImage.object(at: indexPath.row) as! NSDictionary

            let browserVC = self.storyboard?.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
            browserVC.hidesBottomBarWhenPushed = true
            browserVC.strURL = dicImage.value(forKey: "website") as! String
            self.navigationController?.pushViewController(browserVC, animated: true)
        
            
            let strURL = "\(SERVER_URL)/save-search"
            
            let strParameters = String.init(format: "journey_id=%d&query=%@&title=%@&website=%@&description=%@&type=image&bing_id=%@&image=%@",appDelegate.ObjRandomNumber!,dicImage.value(forKey: "title") as! String,dicImage.value(forKey: "title") as! String,dicImage.value(forKey: "website") as! String,dicImage.value(forKey: "title") as! String,dicImage.value(forKey: "id") as! String,dicImage.value(forKey: "image") as! String)
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "save-search", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: false)
        }
        else if tableView == tblViewVideos
        {
            let dicVideo = self.arrVideo.object(at: indexPath.row) as! NSDictionary
           
            let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
            browserVC.hidesBottomBarWhenPushed = true
            browserVC.strURL = dicVideo.value(forKey: "website") as! String
            self.navigationController?.pushViewController(browserVC, animated: true)
            
            let strURL = "\(SERVER_URL)/save-search"
            
            let strParameters = String.init(format: "journey_id=%d&query=%@&title=%@&website=%@&description=%@&type=video&bing_id=%@&image=%@",appDelegate.ObjRandomNumber!,dicVideo.value(forKey: "title") as! String,dicVideo.value(forKey: "title") as! String,dicVideo.value(forKey: "website") as! String,dicVideo.value(forKey: "description") as! String,dicVideo.value(forKey: "id") as! String,dicVideo.value(forKey: "image") as! String)
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "save-search", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: false)
            
        }
        else if tableView == tblViewNews
        {
            let dicNews = self.arrNews.object(at: indexPath.row) as! NSDictionary
           
            let browserVC = self.storyboard?.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
            browserVC.hidesBottomBarWhenPushed = true
            browserVC.strURL = dicNews.value(forKey: "website") as! String
            self.navigationController?.pushViewController(browserVC, animated: true)
            
            let strURL = "\(SERVER_URL)/save-search"
            
            let strParameters = String.init(format: "journey_id=%d&query=%@&title=%@&website=%@&description=%@&type=news&bing_id=%@&image=%@",appDelegate.ObjRandomNumber!,dicNews.value(forKey: "title") as! String,dicNews.value(forKey: "title") as! String,dicNews.value(forKey: "website") as! String,dicNews.value(forKey: "description") as! String,dicNews.value(forKey: "id") as! String,dicNews.value(forKey: "image") as! String)
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "save-search", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: false)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
    
    @objc func clickOnVideo(sender:UIButton)
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
        
        
        let indexPath = tblViewVideos.indexPath(for: cell)
        
        let dicVideo = self.arrVideo.object(at: indexPath!.row) as! NSDictionary
       
        let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
        browserVC.hidesBottomBarWhenPushed = true
        browserVC.strURL = dicVideo.value(forKey: "website") as! String
        self.navigationController?.pushViewController(browserVC, animated: true)
        
        let strURL = "\(SERVER_URL)/save-search"
        
        let strParameters = String.init(format: "journey_id=%d&query=%@&title=%@&website=%@&description=%@&type=video&bing_id=%@&image=%@",appDelegate.ObjRandomNumber!,dicVideo.value(forKey: "title") as! String,dicVideo.value(forKey: "title") as! String,dicVideo.value(forKey: "website") as! String,dicVideo.value(forKey: "description") as! String,dicVideo.value(forKey: "id") as! String,dicVideo.value(forKey: "image") as! String)
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "save-search", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: false)

    }
    
    @IBAction func clickOnAll(sender:UIButton)
    {
        UIView.animate(withDuration: 0.5) {
            
//            var frame = CGRect()
//            frame = self.lblLine.frame
//            frame.origin.x = sender.frame.origin.x
//            frame.size.width = sender.frame.size.width
//            self.lblLine.frame = frame
            
            self.btnAll.setTitleColor(UIColor.blue, for: .normal)
            self.btnNews.setTitleColor(UIColor.gray, for: .normal)
            self.btnImage.setTitleColor(UIColor.gray, for: .normal)
            self.btnVideo.setTitleColor(UIColor.gray, for: .normal)
            
            self.tblViewAll.isHidden = false
            self.tblViewNews.isHidden = true
            self.tblViewImage.isHidden = true
            self.tblViewVideos.isHidden = true
            
            if self.arrAll.count == 0{
                self.getAll()
            }
        }
        
    }
    
    @IBAction func clickOnNews(sender:UIButton)
    {
        UIView.animate(withDuration: 0.5) {
            
//            var frame = CGRect()
//            frame = self.lblLine.frame
//            frame.origin.x = sender.frame.origin.x
//            frame.size.width = sender.frame.size.width
//            self.lblLine.frame = frame
            
            self.btnNews.setTitleColor(UIColor.blue, for: .normal)
            self.btnAll.setTitleColor(UIColor.gray, for: .normal)
            self.btnImage.setTitleColor(UIColor.gray, for: .normal)
            self.btnVideo.setTitleColor(UIColor.gray, for: .normal)
            
            self.tblViewAll.isHidden = true
            self.tblViewNews.isHidden = false
            self.tblViewImage.isHidden = true
            self.tblViewVideos.isHidden = true
            
            if self.arrNews.count == 0{
                self.getAllNews()
            }
        }
        
    }
    
    @IBAction func clickOnImage(sender:UIButton)
    {
        UIView.animate(withDuration: 0.5) {
            
//            var frame = CGRect()
//            frame = self.lblLine.frame
//            frame.origin.x = UIScreen.main.bounds.size.height > 667 ?  sender.frame.origin.x - 10 : sender.frame.origin.x
//            frame.size.width = 40
//            self.lblLine.frame = frame
            
            
            self.btnImage.setTitleColor(UIColor.blue, for: .normal)
            self.btnAll.setTitleColor(UIColor.gray, for: .normal)
            self.btnNews.setTitleColor(UIColor.gray, for: .normal)
            self.btnVideo.setTitleColor(UIColor.gray, for: .normal)
            
            self.tblViewAll.isHidden = true
            self.tblViewNews.isHidden = true
            self.tblViewImage.isHidden = false
            self.tblViewVideos.isHidden = true
            
            if self.arrImage.count == 0{
                self.getImages()
            }
        }
    }
    
    @IBAction func clickOnVideos(sender:UIButton)
    {
        UIView.animate(withDuration: 0.5) {
            
//            var frame = CGRect()
//            frame = self.lblLine.frame
//            frame.origin.x = sender.frame.origin.x
//            frame.size.width = sender.frame.size.width
//            self.lblLine.frame = frame
            
            self.btnVideo.setTitleColor(UIColor.blue, for: .normal)
            self.btnAll.setTitleColor(UIColor.gray, for: .normal)
            self.btnNews.setTitleColor(UIColor.gray, for: .normal)
            self.btnImage.setTitleColor(UIColor.gray, for: .normal)
            
            self.tblViewAll.isHidden = true
            self.tblViewNews.isHidden = true
            self.tblViewImage.isHidden = true
            self.tblViewVideos.isHidden = false
            
            if self.arrVideo.count == 0{
                self.getVideos()
            }
        }
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let serachVC = objHomeSB.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        self.navigationItem.title = ""
        serachVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(serachVC, animated: true)
        
        return false
    }
    
//    func setupTextField(textField:UITextField)
//    {
//        let leftView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 0))
//        textField.leftView = leftView
//        textField.leftViewMode = .always
//
//        textField.attributedPlaceholder = NSAttributedString.init(string: textField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor:UIColor.black])
//
//        textField.layer.borderWidth = 0.5
//        textField.layer.cornerRadius = 5
//
//        let view = UIView()
//        view.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
//
//        let imgview = UIImageView()
//        imgview.frame = CGRect.init(x: 5, y: 7, width: 15, height: 15)
//        imgview.image = UIImage.init(named: "search")
//
//        imgview.image = imgview.image?.withRenderingMode(.alwaysTemplate)
//        imgview.tintColor = UIColor.black
//
//        view.addSubview(imgview)
//
//        textField.leftView = view
//
//        textField.delegate = self
//
//    }
    
}
