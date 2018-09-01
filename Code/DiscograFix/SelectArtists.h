//
//  SelectArtists.h
//  DiscograFix
//
//  Copyright (c) 2015 DiscograFix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectArtists : UITableViewController
{
    int internetWorking;
    NSMutableArray *content;
    NSMutableArray *indices;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *artists;
@property (strong, nonatomic) IBOutlet UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSMutableArray *artistsDevice;
@property (strong, nonatomic) NSMutableArray *artistsDeviceCopy;
@property (nonatomic, retain) NSMutableArray *selectedIndexPath;

@end