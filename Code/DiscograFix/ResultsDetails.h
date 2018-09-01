//
//  ResultsDetails.h
//  DiscograFix
//
//  Copyright (c) 2015 DiscograFix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ResultsDetails : UITableViewController
{
    NSMutableArray *contentAlbums;
    NSMutableArray *contentYears;
    NSMutableArray *indices;
    NSMutableArray *differencesAlbums;
    NSMutableArray *differencesYears;
}

@property (nonatomic) int allTypes;
@property (nonatomic) int allAges;
@property (strong, nonatomic) NSMutableArray *albumsInternet;
@property (strong, nonatomic) NSMutableArray *albumsInternetCopy;
@property (strong, nonatomic) NSMutableArray *albumsDevice;
@property (strong, nonatomic) NSMutableArray *albumsDeviceCopy;
@property (strong, nonatomic) NSMutableArray *yearsInternet;
@property (strong, nonatomic) NSMutableArray *yearsInternetCopy;
@property (strong, nonatomic) NSMutableArray *yearsDevice;
@property (strong, nonatomic) NSMutableArray *yearsDeviceCopy;
@property (assign, nonatomic) NSInteger index;

@end