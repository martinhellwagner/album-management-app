//
//  SpecifyOptions.h
//  DiscograFix
//
//  Copyright (c) 2015 DiscograFix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <iAd/iAd.h>

@class MBProgressHUD;
@interface SpecifyOptions : UIViewController <NSXMLParserDelegate>
{
    MBProgressHUD *activityIndicator;
    int artistIDFound;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *type;
@property (weak, nonatomic) IBOutlet UISegmentedControl *age;

@property (nonatomic) int allTypes;
@property (nonatomic) int allAges;
@property (strong, nonatomic) NSString *artistID;
@property (strong, nonatomic) NSString *albumType;
@property (strong, nonatomic) NSMutableString *currentValueName;
@property (strong, nonatomic) NSString *expectedValueName;
@property (strong, nonatomic) NSMutableString *currentValueYear;
@property (strong, nonatomic) NSString *expectedValueYear;
@property (strong, nonatomic) NSMutableArray *artistsDevice;
@property (strong, nonatomic) NSMutableArray *albumsDuplicates;
@property (strong, nonatomic) NSMutableArray *yearsDuplicates;
@property (strong, nonatomic) NSMutableArray *albumsInternet;
@property (strong, nonatomic) NSMutableArray *albumsDevice;
@property (strong, nonatomic) NSMutableArray *yearsInternet;
@property (strong, nonatomic) NSMutableArray *yearsDevice;

@end