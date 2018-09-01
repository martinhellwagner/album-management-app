//
//  AppDelegate.h
//  DiscograFix
//
//  Copyright (c) 2015 DiscograFix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIStoryboard *_initalStoryboard;
}

- (void)resetApp;

@property (strong, nonatomic) UIWindow *window;

@end
