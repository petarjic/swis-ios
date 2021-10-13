//
//  BrowserViewController.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 02/04/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController,WKUIDelegate,WKNavigationDelegate,responseDelegate {
    
    @IBOutlet weak var mainView: UIView!
    var webView : WKWebView!
    @IBOutlet var btnBack : UIButton!
    @IBOutlet var btnNext : UIButton!
    @IBOutlet var btnCount : UIButton!
    @IBOutlet var imgWindow : UIImageView!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var imgNext: UIImageView!
    @IBOutlet weak var imgSearch: UIImageView!
    @IBOutlet weak var imgShare: UIImageView!
    
    
    var strURL: String? = ""
    var indicator : UIActivityIndicatorView!
    var searchType : String!
    var selectedIndexHistory : NSInteger = -1
    var strTitle : String = ""
    var isFromSearch : Bool = true
    var objId: String?
    var objSearchTitle: String?
    var isFromPreviousPage : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        
        imgWindow.image = imgWindow.image?.withRenderingMode(.alwaysTemplate)
        imgWindow.tintColor = UIColor.black
        
        //--
        imgBack.image = imgBack.image?.withRenderingMode(.alwaysTemplate)
        imgBack.tintColor = UIColor.black
        
        //--
        imgNext.image = imgNext.image?.withRenderingMode(.alwaysTemplate)
        imgNext.tintColor = UIColor.black
        
        //--
        imgSearch.image = imgSearch.image?.withRenderingMode(.alwaysTemplate)
        imgSearch.tintColor = UIColor.black
        
        //--
        imgShare.image = imgShare.image?.withRenderingMode(.alwaysTemplate)
        imgShare.tintColor = UIColor.black
        
        // Do any additional setup after loading the view.
        
        //        if !self.isFromSearch{
        //
        //            var arrSaveSearch = NSMutableArray()
        //
        //            if UserDefaults.standard.object(forKey: "SaveSearch") != nil{
        //
        //                let arrObject = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "SaveSearch") as! Data) as! NSMutableArray
        //
        //                arrSaveSearch = NSMutableArray.init(array: arrObject)
        //
        //            }
        //
        //            self.imgWindow.isHidden = false
        //            self.btnCount.isHidden = false
        //            self.btnCount.setTitle("\(arrSaveSearch.count+1)", for: UIControl.State.normal)
        //
        //        }
        
        
        self.navigationItem.title = self.strTitle.html2String
        
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        
        print(self.mainView.frame.size.height)
        
        //        webView = WKWebView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 170), configuration: configuration)
        var finalHeight = UIScreen.main.bounds.height
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            finalHeight = UIScreen.main.bounds.height - (window?.safeAreaInsets.bottom)!
        }
        finalHeight = finalHeight - statusBarHeight() - 90
        
        webView = WKWebView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: finalHeight), configuration: configuration)
        
        strURL = strURL!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        // strURL = strURL!.replacingOccurrences(of: " ", with: "%20")
        if let urlString = strURL {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                webView.load(URLRequest.init(url: url as URL))
            }
        }
        indicator = UIActivityIndicatorView.init(style: .gray)
        indicator.hidesWhenStopped = true
        
        self.webView.navigationDelegate = self
        self.webView.uiDelegate  = self
        self.webView.contentMode = .scaleToFill
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
        
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        
        self.mainView.addSubview(webView)
        
        self.mainView.layoutIfNeeded()
        self.view.layoutIfNeeded()
        
        
    }
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
        }
        
    }
    func statusBarHeight() -> CGFloat {
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        return Swift.min(statusBarSize.width, statusBarSize.height)
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isTranslucent  = false
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back-icon.png"), style: .plain, target: self, action: #selector(self.clickOnBackAction))
        
        //if self.isFromSearch{
        if UserDefaults.standard.object(forKey: "SaveSearch") != nil{
            
            let arrObject = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "SaveSearch") as! Data) as! NSMutableArray
            
            if arrObject.count > 0{
                
                let predicate = NSPredicate.init(format: "searchType!=%@","Home")
                let filtered = arrObject.filtered(using: predicate) as! NSArray
                
                btnCount.isHidden = false
                imgWindow.isHidden = false
                btnCount.setTitle("\(filtered.count)", for: UIControl.State.normal)
                
            }else{
                btnCount.isHidden = true
                imgWindow.isHidden = true
            }
        }
        else{
            btnCount.isHidden = true
            imgWindow.isHidden = true
            
        }
        // }
    }
    
    @objc func clickOnBackAction()
    {
        //  if self.isFromSearch{
        self.perform(#selector(self.setSaveSearch), on: Thread.main, with: nil, waitUntilDone: true)
        //  }
        //        else{
        //
        //            var arrSaveSearch = NSMutableArray()
        //
        //            if UserDefaults.standard.object(forKey: "SaveSearch") != nil{
        //
        //                let arrObject = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "SaveSearch") as! Data) as! NSMutableArray
        //
        //                arrSaveSearch = NSMutableArray.init(array: arrObject)
        //
        //            }
        //
        //            let predicate = NSPredicate.init(format: "Recent=%@","1")
        //            let filteredArray = arrSaveSearch.filtered(using: predicate) as NSArray
        //
        //            if filteredArray.count > 0{
        //                arrSaveSearch.remove(filteredArray.object(at: 0))
        //            }
        //
        //            let image = self.webView.takeScreenshot()
        //
        //            let dicRecentSearch = NSMutableDictionary()
        //            dicRecentSearch.setValue(image, forKey: "searchImage")
        //            dicRecentSearch.setValue(webView.url?.absoluteString, forKey: "searchText")
        //            dicRecentSearch.setValue(self.searchType, forKey: "searchType")
        //            dicRecentSearch.setValue("0", forKey: "Recent")
        //
        //            arrSaveSearch.insert(dicRecentSearch, at: 0)
        //
        //
        //            let data = NSKeyedArchiver.archivedData(withRootObject: arrSaveSearch)
        //            UserDefaults.standard.setValue(data, forKey: "SaveSearch")
        //            UserDefaults.standard.synchronize()
        //
        //        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?  , change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        let youtubeUrl = webView.url?.absoluteString
        print(youtubeUrl)
        
        let youtubeId1 = strURL?.youtubeID
        let youtubeId2 = youtubeUrl?.youtubeID
        
        
        if youtubeId1 != youtubeId2{
            
            if (youtubeUrl?.contains("youtube"))!{
                
                if !(youtubeUrl?.contains("search_query"))! && !self.isFromPreviousPage{
                    
                    self.perform(#selector(self.setupTitle), with: nil, afterDelay: 1.0)
                    
                    let strURL1 = "\(SERVER_URL)/save-search"
                    
                    let dic = NSMutableDictionary()
                    dic.setValue(youtubeUrl, forKey: "website")
                    dic.setValue("text", forKey: "type")
                    dic.setValue(appDelegate.ObjRandomNumber, forKey: "journey_id")
                    print(dic)
                    WebParserWS.fetchDataWithURL(url: strURL1 as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "save-search", bodyObject: dic as AnyObject, delegate: self, isShowProgress: false)
                }
            }
            
        }
        /*else{
         self.perform(#selector(self.setupTitle), with: nil, afterDelay: 1.0)
         
         let strURL1 = "\(SERVER_URL)/save-search"
         
         let dic = NSMutableDictionary()
         dic.setValue(youtubeUrl, forKey: "website")
         dic.setValue("text", forKey: "type")
         dic.setValue(appDelegate.ObjRandomNumber, forKey: "journey_id")
         print(dic)
         WebParserWS.fetchDataWithURL(url: strURL1 as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "save-search", bodyObject: dic as AnyObject, delegate: self, isShowProgress: false)
         }*/
        
        isFromPreviousPage = false
        
        if keyPath == #keyPath(WKWebView.canGoBack) || keyPath == #keyPath(WKWebView.canGoForward) {
            self.perform(#selector(self.setupTitle), with: nil, afterDelay: 1.0)
            btnBack.isEnabled = webView.canGoBack
            btnNext.isEnabled = webView.canGoForward
        }
    }
    
    @objc func setupTitle()
    {
        self.navigationItem.title = webView.title
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        SVProgressHUD.dismiss()
        
        indicator.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: indicator)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        self.navigationItem.title = webView.title
        
        self.navigationItem.rightBarButtonItem = nil
        
        // let javascript = "var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=10.0, user-scalable=yes');document.getElementsByTagName('head')[0].appendChild(meta);"
        
        // webView.evaluateJavaScript(javascript, completionHandler: nil)
        
        //  if self.isFromSearch{
        self.perform(#selector(self.setSaveSearch), on: Thread.main, with: nil, waitUntilDone: true)
        // }
        
    }
    
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
    
            return nil
        }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        self.navigationItem.rightBarButtonItem = nil
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        
        print(navigationAction.request.description)
        print((navigationAction.request.url?.absoluteString)!)
        let strurl = (navigationAction.request.url?.absoluteString)!
        
        if navigationAction.navigationType == WKNavigationType.linkActivated{
            decisionHandler(WKNavigationActionPolicy.allow)
            
            let strURL1 = "\(SERVER_URL)/save-search"
            
            let dic = NSMutableDictionary()
            dic.setValue(strurl, forKey: "website")
            dic.setValue("text", forKey: "type")
            dic.setValue(appDelegate.ObjRandomNumber, forKey: "journey_id")
            WebParserWS.fetchDataWithURL(url: strURL1 as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "save-search", bodyObject: dic as AnyObject, delegate: self, isShowProgress: false)
            webView.load(URLRequest.init(url: URL.init(string: strurl)!))
            return
        } else {
            
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        decisionHandler(.allow)
    }
    
    
    @IBAction func clickOnBack(sender:UIButton)
    {
        // self.webView.navigationDelegate = self
        self.webView.goBack()
        
    }
    
    @IBAction func clickOnNext(sender:UIButton)
    {
        self.webView.goForward()
        
    }
    
    @IBAction func clickOnOpenSearchList(sender:UIButton)
    {
        // if self.isFromSearch{
        self.perform(#selector(self.setSaveSearch), on: Thread.main, with: nil, waitUntilDone: true)
        //}
        
        let saveSearchVC = objHomeSB.instantiateViewController(withIdentifier: "SaveSearchViewcontroller") as! SaveSearchViewcontroller
        
        self.navigationController?.pushViewController(saveSearchVC, animated: true)
    }
    
    @IBAction func clickOnSearch(sender:UIButton)
    {
        // if self.isFromSearch == true{
        self.perform(#selector(self.setSaveSearchWithNew), on: Thread.main, with: nil, waitUntilDone: true)
        // }
        
        if let viewControllers = self.navigationController?.viewControllers {
            for vc in viewControllers {
                if vc.isKind(of: SearchViewController.classForCoder()) {
                    self.navigationController?.popToRootViewController(animated: true)
                    break
                }
                else{
                    let searchVC = objHomeSB.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
                    
                    self.navigationController?.pushViewController(searchVC, animated: true)
                    
                    break
                }
            }
        }
        
    }
    
    @IBAction func clickOnShare(sender:UIButton)
    {
        if strURL != ""
        {
            let shareURL = webView.url
            
            let strMessage = "\(shareURL as! URL)\n Join me on SWIS to See What I Search"
            
            let activityController = UIActivityViewController.init(activityItems: [strMessage], applicationActivities: nil)
            
            self.present(activityController, animated: true, completion: nil)
        }
        
    }
    
    @objc func setSaveSearchWithNew()
    {
        
        let image = self.webView.takeScreenshot()
        
        var arrSaveSearch = NSMutableArray()
        
        if UserDefaults.standard.object(forKey: "SaveSearch") != nil{
            
            let arrObject = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "SaveSearch") as! Data) as! NSMutableArray
            
            arrSaveSearch = NSMutableArray.init(array: arrObject)
            
        }
        
        if self.selectedIndexHistory != -1{
            
            var dicRecentSearch = arrSaveSearch.object(at: self.selectedIndexHistory) as! NSMutableDictionary
            dicRecentSearch.setValue(image, forKey: "searchImage")
            dicRecentSearch.setValue(webView.url?.absoluteString, forKey: "searchText")
            dicRecentSearch.setValue(self.searchType, forKey: "searchType")
            
            arrSaveSearch.replaceObject(at: self.selectedIndexHistory, with: dicRecentSearch)
        }
        else{
            
            if !self.isFromSearch{
                
                let predicate = NSPredicate.init(format: "Recent=%@","1")
                let filteredArray = arrSaveSearch.filtered(using: predicate) as NSArray
                
                if filteredArray.count > 0{
                    arrSaveSearch.remove(filteredArray.object(at: 0))
                }
                
                let dicRecentSearch = NSMutableDictionary()
                dicRecentSearch.setValue(image, forKey: "searchImage")
                dicRecentSearch.setValue(webView.url?.absoluteString, forKey: "searchText")
                dicRecentSearch.setValue(self.searchType, forKey: "searchType")
                dicRecentSearch.setValue("1", forKey: "Recent")
                
                arrSaveSearch.insert(dicRecentSearch, at: 0)
            }
            else{
                
                let predicate = NSPredicate.init(format: "Recent=%@","1")
                let filteredArray = arrSaveSearch.filtered(using: predicate) as NSArray
                
                if filteredArray.count > 0{
                    arrSaveSearch.remove(filteredArray.object(at: 0))
                }
                
                let dicRecentSearch = NSMutableDictionary()
                dicRecentSearch.setValue(image, forKey: "searchImage")
                dicRecentSearch.setValue(webView.url?.absoluteString, forKey: "searchText")
                dicRecentSearch.setValue(self.searchType, forKey: "searchType")
                dicRecentSearch.setValue("1", forKey: "Recent")
                
                arrSaveSearch.insert(dicRecentSearch, at: 0)
            }
            
        }
        
        for index in 0..<arrSaveSearch.count{
            let dic = arrSaveSearch.object(at: index) as! NSMutableDictionary
            dic.setValue("0", forKey: "Recent")
            arrSaveSearch.replaceObject(at: index, with: dic)
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: arrSaveSearch)
        UserDefaults.standard.setValue(data, forKey: "SaveSearch")
        UserDefaults.standard.synchronize()
        
        //  if self.isFromSearch{
        
        self.imgWindow.isHidden = false
        self.btnCount.isHidden = false
        self.btnCount.setTitle("\(arrSaveSearch.count)", for: UIControl.State.normal)
        
        // }
        
    }
    
    @objc func setSaveSearch()
    {
        
        let image = self.webView.takeScreenshot()
        
        var arrSaveSearch = NSMutableArray()
        
        if UserDefaults.standard.object(forKey: "SaveSearch") != nil{
            
            let arrObject = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "SaveSearch") as! Data) as! NSMutableArray
            
            arrSaveSearch = NSMutableArray.init(array: arrObject)
            
        }
        
        if self.selectedIndexHistory != -1{
            
            var dicRecentSearch = arrSaveSearch.object(at: self.selectedIndexHistory) as! NSMutableDictionary
            dicRecentSearch.setValue(image, forKey: "searchImage")
            dicRecentSearch.setValue(webView.url?.absoluteString, forKey: "searchText")
            dicRecentSearch.setValue(self.searchType, forKey: "searchType")
            
            arrSaveSearch.replaceObject(at: self.selectedIndexHistory, with: dicRecentSearch)
        }
        else{
            
            if !self.isFromSearch{
                
                let predicate = NSPredicate.init(format: "Recent=%@","1")
                let filteredArray = arrSaveSearch.filtered(using: predicate) as NSArray
                
                if filteredArray.count > 0{
                    arrSaveSearch.remove(filteredArray.object(at: 0))
                }
                
                let dicRecentSearch = NSMutableDictionary()
                dicRecentSearch.setValue(image, forKey: "searchImage")
                dicRecentSearch.setValue(webView.url?.absoluteString, forKey: "searchText")
                dicRecentSearch.setValue(self.searchType, forKey: "searchType")
                dicRecentSearch.setValue("1", forKey: "Recent")
                
                arrSaveSearch.insert(dicRecentSearch, at: 0)
            }
            else{
                
                let predicate = NSPredicate.init(format: "Recent=%@","1")
                let filteredArray = arrSaveSearch.filtered(using: predicate) as NSArray
                
                if filteredArray.count > 0{
                    arrSaveSearch.remove(filteredArray.object(at: 0))
                }
                
                let dicRecentSearch = NSMutableDictionary()
                dicRecentSearch.setValue(image, forKey: "searchImage")
                dicRecentSearch.setValue(webView.url?.absoluteString, forKey: "searchText")
                dicRecentSearch.setValue(self.searchType, forKey: "searchType")
                dicRecentSearch.setValue("1", forKey: "Recent")
                
                arrSaveSearch.insert(dicRecentSearch, at: 0)
            }
            
        }
        
        
        let data = NSKeyedArchiver.archivedData(withRootObject: arrSaveSearch)
        UserDefaults.standard.setValue(data, forKey: "SaveSearch")
        UserDefaults.standard.synchronize()
        
        //  if self.isFromSearch{
        
        self.imgWindow.isHidden = false
        self.btnCount.isHidden = false
        self.btnCount.setTitle("\(arrSaveSearch.count)", for: UIControl.State.normal)
        
        // }
        
    }
    
}
extension String {
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)
        
        guard let result = regex?.firstMatch(in: self, range: range) else {
            return nil
        }
        
        return (self as NSString).substring(with: result.range)
    }
}
