//
//  HeaderView.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 11/03/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit
import TTTAttributedLabel
class HeaderView: UIView {

    @IBOutlet var imgUserView : UIImageView!
    @IBOutlet var lblUserName : UILabel!
   
    @IBOutlet weak var lblComment: TTTAttributedLabel!
    
    @IBOutlet var lblReplayCount : UILabel!
    @IBOutlet var btnReplay : UIButton!
    @IBOutlet var bReplay : UIButton!
    @IBOutlet var btnLikeCount : UIButton!
    @IBOutlet var lblTime : UILabel!
    @IBOutlet var btnLike : UIButton!
    @IBOutlet var imgLike : UIImageView!

}
