//
//  ShareProfileVCViewController.swift
//  SWIS
//
//  Created by Rp on 18/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class ShareProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
 //   @IBOutlet var txtBio : UITextField!
    @IBOutlet var btnShareProfile : UIButton!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblUsername : UILabel!
    @IBOutlet var imgUser : UIImageView!
    @IBOutlet var topView : UIView!
    @IBOutlet var informationView : UIView!
    @IBOutlet var lblLine : UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet var lblBottomLine : UILabel!
    @IBOutlet var lblHeight : NSLayoutConstraint!
    @IBOutlet var socialView : UIView!
    @IBOutlet var topY : NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        self.lblName.text = appDelegate.dicLoginDetail.value(forKey: "name") as? String
        self.lblUsername.text = "@\(appDelegate.dicLoginDetail.value(forKey: "username") as! String)"
        
        var strUserImg = appDelegate.dicLoginDetail.value(forKey: "avatar") as? String
        strUserImg = strUserImg?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        self.imgUser.sd_setImage(with: URL.init(string: strUserImg!), placeholderImage: nil, options: .continueInBackground, completed: nil)
        
        self.lblBio.isUserInteractionEnabled  = false
        
        self.lblBio.numberOfLines = 0
        self.lblBio.text = appDelegate.dicLoginDetail.value(forKey: "bio") as? String
        self.lblBio.sizeToFit()
        
        self.lblHeight.constant = self.lblBio.frame.size.height
        
        
        var frame = CGRect()
        frame = lblBottomLine.frame
        frame.origin.y = self.lblBio.frame.origin.y + self.lblBio.frame.size.height
        lblBottomLine.frame = frame
        
     //   self.setupTextField(textField: txtBio)
        self.setupLine()
        
        btnShareProfile.layer.cornerRadius = btnShareProfile.frame.size.height/2
        btnShareProfile.layer.masksToBounds = true
    }
    
    func setupLine()
    {
        var frame = CGRect()
        frame = self.lblLine.frame
        frame.origin.x = 6
        frame.size.width = 55
        self.lblLine.frame = frame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
//    func setupTextField(textField:UITextField)
//    {
//        textField.attributedPlaceholder = NSAttributedString.init(string: textField.placeholder!, attributes: [NSAttributedString.Key.font:UIFont.init(name: "HelveticaNeue-Italic", size: 13),NSAttributedString.Key.foregroundColor:UIColor.white])
//
//        let layer = CALayer()
//        layer.frame = CGRect.init(x: 0, y: textField.frame.size.height-1, width: textField.frame.size.width, height: 1)
//        layer.borderWidth = 1
//        layer.borderColor = UIColor.white.cgColor
//        textField.layer.addSublayer(layer)
//    }
    
    @IBAction func clickOnShareProfile(){
        
        let image = informationView.asImage()
        
        let activityController = UIActivityViewController.init(activityItems: [image], applicationActivities: nil)
        
        self.present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func clickOnSMS(sender:UIButton)
    {
        let inviteVC = objMainSB.instantiateViewController(withIdentifier: "InviteViewController") as! InviteViewController
        inviteVC.isFromSMS = true
        self.navigationController?.pushViewController(inviteVC, animated: false)
    }
    
    @IBAction func clickonEmail(sender:UIButton)
    {
        let inviteVC = objMainSB.instantiateViewController(withIdentifier: "InviteViewController") as! InviteViewController
        inviteVC.isFromSMS = false
        self.navigationController?.pushViewController(inviteVC, animated: false)
    }
    
    @IBAction func clickOnBack(sender:UIButton)
    {
        self.navigationController?.popViewController(animated: false)
    }

}

extension UIView {
    
    func asImage() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
            defer { UIGraphicsEndImageContext() }
            guard let currentContext = UIGraphicsGetCurrentContext() else {
                return nil
            }
            self.layer.render(in: currentContext)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
}
