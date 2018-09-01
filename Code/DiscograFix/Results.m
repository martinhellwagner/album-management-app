//
//  Results.m
//  DiscograFix
//
//  Copyright (c) 2015 DiscograFix. All rights reserved.
//

#import "Results.h"
#import "ResultsDetails.h"
#import "AppDelegate.h"

@implementation Results

@synthesize albumsInternet = _albumsInternet;
@synthesize albumsDevice = _albumsDevice;

- (id)initWithNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Missing albums";
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style: UIBarButtonItemStyleBordered
                                                            target: self action: @selector(doneButtonClicked)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle: UIPageViewControllerTransitionStyleScroll
                                                        navigationOrientation: UIPageViewControllerNavigationOrientationHorizontal options: nil];
    self.pageController.dataSource = self;    
    self.pageController.view.frame = self.view.bounds;
    ResultsDetails *initialViewController = [self viewControllerAtIndex: 0];
    NSArray *viewControllers = [NSArray arrayWithObject: initialViewController];
    [self.pageController setViewControllers: viewControllers direction: UIPageViewControllerNavigationDirectionForward animated: NO completion: nil];
    [self addChildViewController: self.pageController];
    [[self view] addSubview: [self.pageController view]];
    [self.pageController didMoveToParentViewController: self];
    pageControl = [UIPageControl appearanceWhenContainedIn: [self.pageController class], nil];
    pageControl.pageIndicatorTintColor = [UIColor blackColor];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed: 0.0 green: 122.0/255.0 blue: 1.0 alpha: 1.0];
    pageControl.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidUnload
{
    pageControl = nil;
    self.albumsInternet = nil;
    self.albumsDevice = nil;
    self.yearsInternet = nil;
    self.yearsDevice = nil;
    self.pageController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// displaying alert view
- (IBAction)doneButtonClicked
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"That's it."
                                                    message: @"You'll now be redirected to the initial screen again for the next round."
                                                   delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
    [alert show];
}

// checking if alert view button was clicked
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate resetApp];
    }
}

// initializing page controllers
- (ResultsDetails *)viewControllerAtIndex: (NSUInteger)index
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: [NSBundle mainBundle]];
    ResultsDetails *controller = [storyboard instantiateViewControllerWithIdentifier: @"ResultsDetails"];
    controller.index = index;
    controller.allTypes = self.allTypes;
    controller.allAges = self.allAges;
    controller.albumsInternet = self.albumsInternet;
    controller.albumsDevice = self.albumsDevice;
    controller.yearsInternet = self.yearsInternet;
    controller.yearsDevice = self.yearsDevice;
    return controller;
}

// specifying transition when reaching bottom page controller
- (UIViewController *)pageViewController: (UIPageViewController *)pageViewController viewControllerBeforeViewController: (UIViewController *)viewController
{
    if ([(ResultsDetails *)viewController index] == 0)
    {
        self.navigationItem.title = @"Missing albums";
        pageControl.currentPage = 0;
        return [self viewControllerAtIndex: 1];
    } else
    {
        self.navigationItem.title = @"Surplus albums";
        pageControl.currentPage = 1;
        return [self viewControllerAtIndex: 0];
    }
}

// specifying transition when reaching top page controller
- (UIViewController *)pageViewController: (UIPageViewController *)pageViewController viewControllerAfterViewController: (UIViewController *)viewController
{
    if ([(ResultsDetails *)viewController index] == 1)
    {
        self.navigationItem.title = @"Surplus albums";
        pageControl.currentPage = 1;
        return [self viewControllerAtIndex: 0];
    } else
    {
        self.navigationItem.title = @"Missing albums";
        pageControl.currentPage = 0;
        return [self viewControllerAtIndex: 1];
    }
}

// specifying number of items in page indicator
- (NSInteger)presentationCountForPageViewController: (UIPageViewController *)pageViewController
{
    return 2;
}

// specifying selected item in page indicator
- (NSInteger)presentationIndexForPageViewController: (UIPageViewController *)pageViewController
{
    return 0;
}

@end