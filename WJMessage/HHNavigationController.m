//
//  HHNavigationController.m
//  WJMessage
//
//  Created by apple on 16/7/26.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

#import "HHNavigationController.h"

@interface UINavigationController (HHNavigationController)<UINavigationBarDelegate>

@end

@implementation UIViewController (HHNavigationController)

- (BOOL)navigationShouldPop {
    return YES;
}

@end

@implementation HHNavigationController
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (!self.topViewController.navigationShouldPop) {
        return NO;
    }
    return [super navigationBar:navigationBar shouldPopItem:item];
}
@end
