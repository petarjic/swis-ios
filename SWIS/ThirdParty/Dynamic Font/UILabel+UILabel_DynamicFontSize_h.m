//
//  UILabel+UILabel_DynamicFontSize_h.m
//  SWIS
//
//  Created by Dharmesh Sonani on 14/03/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

#import "UILabel+UILabel_DynamicFontSize_h.h"

@implementation UILabel (UILabel_DynamicFontSize_h)
@dynamic adjustFontSize;

-(void)setAdjustFontSize:(BOOL)adjustFontSize{
    if (adjustFontSize)
    {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        self.font = [self.font fontWithSize:self.font.pointSize*(screenBounds.size.width/320)]; // 320 for iPhone 5(320x568) storyboard design
        // if you design with iphone 6(375x667) in storyboard, use 375 instead of 320 and iphone 6 plus(414x736), use 414
    }
}

@end
