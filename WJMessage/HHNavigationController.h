//
//  HHNavigationController.h
//  WJMessage
//
//  Created by apple on 16/7/26.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHNavigationController : UINavigationController

@end

@interface UIViewController (HHNavigationController)
//YES 用系统自带 NO 自定义      defualt YES
- (BOOL)navigationShouldPop;
@end