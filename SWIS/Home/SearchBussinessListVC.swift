//
//  SearchBussinessListVC.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 29/08/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class SearchBussinessListVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var tblView: UITableView!
    
    var objArrAllSearchBussiness: NSMutableArray?
    var objTitle: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitle.text = objTitle
        tblView.delegate = self
        tblView.dataSource = self
        tblView.tableFooterView = UIView()
        self.navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (objArrAllSearchBussiness?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchBussinessListCell", for: indexPath)
        
        let view = cell.contentView.viewWithTag(1000) as! UIView
//        view.layer.cornerRadius = 5
//
//        view.layer.shadowColor = UIColor.gray.cgColor
//        view.layer.shadowOpacity = 0.5
//        view.layer.shadowOffset = CGSize.zero
//        view.layer.shadowRadius = 6
        
//        let viewLine = cell.contentView.viewWithTag(1005) as! UIView
//
//        let lastRowIndex = tableView.numberOfRows(inSection: tableView.numberOfSections-1)
//
//        if (indexPath.row == lastRowIndex - 1) {
//            viewLine.isHidden = true
//        } else{
//            viewLine.isHidden = false
//        }
        
        
        let roundView = cell.contentView.viewWithTag(1001) as! UIView
        let lblCountNumber = cell.contentView.viewWithTag(1002) as! UILabel
        let lblTitle = cell.contentView.viewWithTag(1003) as! UILabel
        let lblAddress = cell.contentView.viewWithTag(1004) as! UILabel
   //     let lineView = cell.contentView.viewWithTag(1005) as! UIView
        
        let dicAll = self.objArrAllSearchBussiness!.object(at: indexPath.row) as! NSDictionary
        
        
        let btnCallClick = cell.contentView.viewWithTag(2000) as! UIButton
        let btnDirectionClick = cell.contentView.viewWithTag(2001) as! UIButton
        let btnWebsiteClick = cell.contentView.viewWithTag(2002) as! UIButton
        
        btnCallClick.addTarget(self, action: #selector(self.clickOnCallSearch(sender:)), for: UIControl.Event.touchUpInside)
        
        btnDirectionClick.addTarget(self, action: #selector(self.clickOnDirectionSearch(sender:)), for: UIControl.Event.touchUpInside)
        
        btnWebsiteClick.addTarget(self, action: #selector(self.clickOnWebsiteSearch(sender:)), for: UIControl.Event.touchUpInside)
        
        roundView.layer.cornerRadius = roundView.frame.height / 2
        roundView.clipsToBounds = true
        
        lblCountNumber.text = "\(indexPath.row + 1)"
        
        lblTitle.text = dicAll.value(forKey: "name") as? String
        
        let dicAddress = dicAll.value(forKey: "address") as? NSDictionary
        
        lblAddress.text = dicAddress?.value(forKey: "text") as? String
        
        cell.selectionStyle = .none
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dicAll = self.objArrAllSearchBussiness!.object(at: indexPath.row) as! NSDictionary
        
        let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
        browserVC.hidesBottomBarWhenPushed = true
        browserVC.strURL = dicAll.value(forKey: "detail_url") as! String
        self.navigationController?.pushViewController(browserVC, animated: true)
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt
        indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    @objc func clickOnCallSearch(sender:UIButton) {
        
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
        
        let dicAll = self.objArrAllSearchBussiness!.object(at: indexPath!.row) as! NSDictionary
        
        let phone = dicAll.value(forKey: "phone") as? String
        
        if let url = URL(string: "tel://\(phone ?? "")"),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // add error message here
        }
        
    }
    @objc func clickOnDirectionSearch(sender:UIButton) {
        
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
        
        
        let dicAll = self.objArrAllSearchBussiness!.object(at: indexPath!.row) as! NSDictionary
        
        let dicDirection = dicAll.value(forKey: "latlng") as? NSDictionary
        let lat = dicDirection?.value(forKey: "latitude") as? Double
        let long = dicDirection?.value(forKey: "longitude") as? Double
        
        
        var strLocation = String.init(format: "https://www.google.co.in/maps/dir/?saddr=\(lat ?? 0.0),\(long ?? 0.0)")
        strLocation = strLocation.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let url = URL.init(string: strLocation)
        
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        
    }
    @objc func clickOnWebsiteSearch(sender:UIButton) {
        
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
        
        let dicAll = self.objArrAllSearchBussiness!.object(at: indexPath!.row) as! NSDictionary
        
        let website = dicAll.value(forKey: "website") as? String
        
        if website != "" {
            let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
            browserVC.hidesBottomBarWhenPushed = true
            browserVC.strURL = website!
            self.navigationController?.pushViewController(browserVC, animated: true)
        }
        
    }

    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
