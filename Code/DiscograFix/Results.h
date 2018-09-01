//
//  ResultsSummary.h
//  DiscograFix
//
//  Copyright (c) 2015 DiscograFix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface Results : UIViewController <UIPageViewControllerDataSource>
{
    UIPageControl *pageControl;
}
@property (nonatomic) int allTypes;
@property (nonatomic) int allAges;
@property (nonatomic) UIColor *barTintColor;
@property (strong, nonatomic) NSMutableArray *albumsInternet;
@property (strong, nonatomic) NSMutableArray *albumsDevice;
@property (strong, nonatomic) NSMutableArray *yearsInternet;
@property (strong, nonatomic) NSMutableArray *yearsDevice;
@property (strong, nonatomic) UIPageViewController *pageController;

@end