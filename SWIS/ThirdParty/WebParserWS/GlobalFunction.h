//
//  GlobalFunction.h
//  sactomofo
//
//  Created by Dipak Kasodariya on 18/03/14.
//  Copyright (c) 2014 Dipak Kasodariya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface GlobalFunction : NSObject



+ (BOOL)ISinternetConnection;
+ (NSMutableDictionary *)GetDictionary_JsonString:(NSString *)JsonString;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (NSString *)getApplicationName;
+ (void)showAlertMessage:(NSString *)alertMesasge;

+(void)SaveValue :(NSString*) Value key :(NSString *) key;
+(NSString *)GetValueForkey :(NSString*) key;
+(int)getLength:(NSString *)mobileNumber;
+(NSString *)formatNumber:(NSString *)mobileNumber;
+(CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center inView:(UIScrollView *)scrlView;
+(NSMutableDictionary *)checkString:(NSString *)key dic:(NSMutableDictionary *)dic;
+(void)setDeleteButtonHeight:(UITableView *)tblView;
+ (UILabel *)adjust:(UILabel *)label withString:(NSString*)string withMaximumSize:(CGSize)maxSixe;
@end
