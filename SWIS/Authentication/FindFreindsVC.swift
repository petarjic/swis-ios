//
//  FindFreindsVC.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 07/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class FindFreindsVC: UIViewController {

    @IBOutlet var btnSkip : UIButton!
    @IBOutlet var btnFindFriends : UIButton!
    @IBOutlet var lbl1 : UILabel!
    @IBOutlet var lbl2 : UILabel!
    @IBOutlet var lbl3 : UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        btnFindFriends.layer.cornerRadius = btnFindFriends.frame.size.height/2
        
        btnSkip.layer.borderWidth = 1
        btnSkip.layer.borderColor = UIColor.white.cgColor
        btnSkip.layer.cornerRadius = btnSkip.frame.size.height/2
        
        lbl1.attributedText = NSAttributedString.init(string: lbl1.text!, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.kern:2.0])
        
        lbl2.attributedText = NSAttributedString.init(string: lbl2.text!, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.kern:2.0])
        
        lbl3.attributedText = NSAttributedString.init(string: lbl3.text!, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.kern:2.0])
        
    }
    
  
    @IBAction func clickOnSkip(sender:UIButton)
    {
        appDelegate.setupTabbarcontroller(selectedIndex: 3)
    }

    @IBAction func clickOnInviteFriend(sender:UIButton)
    {
        let shareProfileVC = objMainSB.instantiateViewController(withIdentifier: "ShareProfileViewController") as! ShareProfileViewController
        
        self.navigationController?.pushViewController(shareProfileVC, animated: true)
    }

}
