
#import "GlobalFunction.h"
//#import "CheckInternetReachability.h"
#import "Reachability.h"

@implementation GlobalFunction

UIWindow *window;

+(BOOL)ISinternetConnection{
    Reachability* reachability;
    reachability = [Reachability reachabilityWithHostName:@"www.google.com"]; //change URL to application server
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    [reachability startNotifier];
    switch (netStatus){
            
        case NotReachable:{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkFail" object:self];
            return NO;
            break;
        }
            
        case ReachableViaWWAN:{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkPass" object:self];
            return YES;
            break;
        }
        case ReachableViaWiFi:{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkPass" object:self];
            return YES;
            break;
        }
    }
}


+ (void)showAlertMessage:(NSString *)alertMesasge{
    
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:[GlobalFunction getApplicationName] message:alertMesasge delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    
}

+ (NSString *)getApplicationName{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+(NSMutableDictionary *)GetDictionary_JsonString:(NSString *)JsonString{
    
    NSError *jsonError;
    NSData *objectData = [JsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    return [NSJSONSerialization JSONObjectWithData:objectData
                                           options:NSJSONReadingMutableContainers
                                             error:&jsonError] ;
    
}

+ (UIImage *)imageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+(void)SaveValue :(NSString*) Value key :(NSString *) key{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:Value forKey:key];
        [standardUserDefaults synchronize];
    }
}

+(NSString *)GetValueForkey :(NSString*) key{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = @"";
    if ([standardUserDefaults objectForKey:key]!= nil) {
        value =  [[standardUserDefaults objectForKey:key] mutableCopy];
        [standardUserDefaults synchronize];
    }
    return value;
}

+(int)getLength:(NSString *)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    
    return length;
}

+(NSString *)formatNumber:(NSString *)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSLog(@"%@", mobileNumber);
    
    int length = (int)[mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        NSLog(@"%@", mobileNumber);
        
    }
    
    return mobileNumber;
}

+(CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center inView:(UIScrollView *)scrlView {
    CGRect zoomRect;
    zoomRect.size.height = [scrlView frame].size.height / scale;
    zoomRect.size.width  = [scrlView frame].size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

+(NSMutableDictionary *)checkString:(NSString *)key dic:(NSMutableDictionary *)dic
{
    if ([[dic valueForKey:key]isKindOfClass:[NSNull class]]) {
        
         return dic;
    }
    else
    {
        return nil;
    }
    
}


+(void)setDeleteButtonHeight:(UITableView *)tblView
{
    for (UIView *subview in tblView.subviews) {
        //iterate through subviews until you find the right one...
        for(UIView *subview2 in subview.subviews){
            if ([NSStringFromClass([subview2 class]) isEqualToString:@"UITableViewCellDeleteConfirmationView"]) {
                //your color
                ((UIView*)[subview2.subviews firstObject]).backgroundColor=[UIColor blueColor];
            }
        }
    }
}

+(UILabel *)adjust:(UILabel *)label withString:(NSString*)string withMaximumSize:(CGSize)maxSixe{
    
    CGRect expectedLabelRect = [string boundingRectWithSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName: label.font}
                                                    context:nil];
    expectedLabelRect.size.height = ceilf(expectedLabelRect.size.height);
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.origin.y += (newFrame.size.height - expectedLabelRect.size.height) * 0.5;
    newFrame.size.height = expectedLabelRect.size.height;
    
    label.numberOfLines = ceilf(newFrame.size.height/label.font.lineHeight);
    label.frame = newFrame;
    
    return label;
}


@end
