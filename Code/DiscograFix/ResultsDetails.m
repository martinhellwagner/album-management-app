//
//  ResultsDetails.m
//  DiscograFix
//
//  Copyright (c) 2015 DiscograFix. All rights reserved.
//

#import "ResultsDetails.h"
#import "AppDelegate.h"

@implementation ResultsDetails

@synthesize albumsInternet = _albumsInternet;
@synthesize albumsInternetCopy = _albumsInternetCopy;
@synthesize albumsDevice = _albumsDevice;
@synthesize albumsDeviceCopy = _albumsDeviceCooy;
@synthesize yearsInternet = _yearsInternet;
@synthesize yearsInternetCopy = _yearsInternetCopy;
@synthesize yearsDevice = _yearsDevice;
@synthesize yearsDeviceCopy = _yearsDeviceCooy;

- (id)initWithStyle: (UITableViewStyle)style
{
    self = [super initWithStyle: style];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style: UIBarButtonItemStyleBordered
                                                                   target: self action: @selector(doneButtonClicked)];
    self.navigationItem.rightBarButtonItem = rightButton;
    if (self.allTypes == 0)
    {
        int heightStatusBar = [UIApplication sharedApplication].statusBarFrame.size.height;
        int heightNavigationBar = 44;
        self.tableView.contentInset = UIEdgeInsetsMake((float)(heightStatusBar + heightNavigationBar), 0.0f, 0.0f, 0.0f);
    } else if (self.allTypes == 1)
    {
        self.navigationItem.title = @"Missing albums";
    } else if (self.allTypes == 2)
    {
        self.navigationItem.title = @"Surplus albums";
    }
    if (self.allAges == 1)
    {
        [self filterYears];
    }
    [self createDifferences];
    [self sortDifferences];
    contentAlbums = [[NSMutableArray alloc] init];
    contentYears = [[NSMutableArray alloc] init];
    differencesAlbums = [[NSMutableArray alloc] init];
    differencesYears = [[NSMutableArray alloc] init];
    [self createTableContent];
}

- (void)viewDidUnload
{
    contentAlbums = nil;
    contentYears = nil;
    indices = nil;
    differencesAlbums = nil;
    differencesYears = nil;
    self.albumsInternet = nil;
    self.albumsInternetCopy = nil;
    self.albumsDevice = nil;
    self.albumsDeviceCopy = nil;
    self.yearsInternet = nil;
    self.yearsInternetCopy = nil;
    self.yearsDevice = nil;
    self.yearsDeviceCopy = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// displaying alert view
- (IBAction)doneButtonClicked
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"That's it."
                                              message: @"You'll be redirected to the first screen again for the next round."
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

// filter for recent years only
- (void)filterYears
{
    int thisYear = [[[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]] year];
    int lastYear = thisYear - 1;
    NSString *thisYearString = [NSString stringWithFormat: @"%d", thisYear];
    NSString *lastYearString = [NSString stringWithFormat: @"%d", lastYear];
    self.albumsInternetCopy = [[NSMutableArray alloc] initWithArray: self.albumsInternet];
    self.albumsDeviceCopy = [[NSMutableArray alloc] initWithArray: self.albumsDevice];
    self.yearsInternetCopy = [[NSMutableArray alloc] initWithArray: self.yearsInternet];
    self.yearsDeviceCopy = [[NSMutableArray alloc] initWithArray: self.yearsDevice];
    self.albumsInternet = [[NSMutableArray alloc] init];
    self.albumsDevice = [[NSMutableArray alloc] init];
    self.yearsInternet = [[NSMutableArray alloc] init];
    self.yearsDevice = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.yearsDeviceCopy.count; i++)
    {
        NSString *year = [NSString stringWithFormat: @"%@", [self.yearsDeviceCopy objectAtIndex: i]];
        if ([year isEqualToString: thisYearString] || [year isEqualToString: lastYearString])
        {
            [self.albumsDevice addObject: [self.albumsDeviceCopy objectAtIndex: i]];
            [self.yearsDevice addObject: [self.yearsDeviceCopy objectAtIndex: i]];
        }
    }
    for (int j = 0; j < self.yearsInternetCopy.count; j++)
    {
        NSString *year2 = [NSString stringWithFormat: @"%@", [self.yearsInternetCopy objectAtIndex: j]];
        if ([year2 isEqualToString: thisYearString] || [year2 isEqualToString: lastYearString])
        {
            [self.albumsInternet addObject: [self.albumsInternetCopy objectAtIndex: j]];
            [self.yearsInternet addObject: [self.yearsInternetCopy objectAtIndex: j]];
        }
    }
}

// creating difference lists for missing and surplus albums
- (void)createDifferences
{
    self.albumsInternetCopy = [[NSMutableArray alloc] initWithArray: self.albumsInternet];
    self.albumsDeviceCopy = [[NSMutableArray alloc] initWithArray: self.albumsDevice];
    self.yearsInternetCopy = [[NSMutableArray alloc] initWithArray: self.yearsInternet];
    self.yearsDeviceCopy = [[NSMutableArray alloc] initWithArray: self.yearsDevice];
    for (NSString *internet in self.albumsInternetCopy)
    {
        for (NSString *device in self.albumsDeviceCopy)
        {
            if ([internet caseInsensitiveCompare: device] == NSOrderedSame)
            {
                int i = [self.albumsInternet indexOfObject: internet];
                if (i >= 0 && i < self.albumsInternet.count)
                {
                    [self.albumsInternet removeObjectAtIndex: i];
                    [self.yearsInternet removeObjectAtIndex: i];
                }
            }
        }
    }
    for (NSString *device in self.albumsDeviceCopy)
    {
        for (NSString *internet in self.albumsInternetCopy)
        {
            if ([device caseInsensitiveCompare: internet] == NSOrderedSame)
            {
                int j = [self.albumsDevice indexOfObject: device];
                if (j >= 0 && j < self.albumsDevice.count)
                {
                    [self.albumsDevice removeObjectAtIndex: j];
                    [self.yearsDevice removeObjectAtIndex: j];
                }
            }
        }
    }
}

// sorting difference lists for missing and surplus albums
- (void)sortDifferences
{
    if (self.albumsDevice.count != 0 && self.yearsDevice.count != 0)
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects: self.yearsDevice forKeys: self.albumsDevice];
        NSArray *albumsDeviceSorted = [[dictionary allKeys] sortedArrayUsingSelector: @selector(compare:)];
        NSArray *yearsDeviceSorted = [dictionary objectsForKeys: albumsDeviceSorted notFoundMarker: [NSNull null]];
        self.albumsDevice = [[NSMutableArray alloc] initWithArray: albumsDeviceSorted];
        self.yearsDevice = [[NSMutableArray alloc] initWithArray: yearsDeviceSorted];
    }
    if (self.albumsInternet.count != 0 && self.yearsInternet.count != 0)
    {
        NSDictionary *dictionary2 = [NSDictionary dictionaryWithObjects: self.yearsInternet forKeys: self.albumsInternet];
        NSArray *albumsInternetSorted = [[dictionary2 allKeys] sortedArrayUsingSelector: @selector(compare:)];
        NSArray *yearsInternetSorted = [dictionary2 objectsForKeys: albumsInternetSorted notFoundMarker: [NSNull null]];
        self.albumsInternet = [[NSMutableArray alloc] initWithArray: albumsInternetSorted];
        self.yearsInternet = [[NSMutableArray alloc] initWithArray: yearsInternetSorted];
    }
}

// creating content for indexed table view
- (void)createTableContent
{
    NSMutableArray *letters = [[NSMutableArray alloc] init];
    [letters addObject: @"A"]; [letters addObject: @"B"]; [letters addObject: @"C"]; [letters addObject: @"D"]; [letters addObject: @"E"];
    [letters addObject: @"F"]; [letters addObject: @"G"]; [letters addObject: @"H"]; [letters addObject: @"I"]; [letters addObject: @"J"];
    [letters addObject: @"K"]; [letters addObject: @"L"]; [letters addObject: @"M"]; [letters addObject: @"N"]; [letters addObject: @"O"];
    [letters addObject: @"P"]; [letters addObject: @"Q"]; [letters addObject: @"R"]; [letters addObject: @"S"]; [letters addObject: @"T"];
    [letters addObject: @"U"]; [letters addObject: @"V"]; [letters addObject: @"W"]; [letters addObject: @"X"]; [letters addObject: @"Y"];
    [letters addObject: @"Z"];
    indices = [[NSMutableArray alloc] initWithArray: letters];
    [letters addObject: @"#"];
    for (NSString *string in letters)
    {
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        [temp addObject: string];
        NSMutableArray *temp2 = [[NSMutableArray alloc] init];
        [temp2 addObject: string];
        [contentAlbums addObject: temp];
        [contentYears addObject: temp2];
    }
    if (self.allTypes == 1 || (self.allTypes == 0 && self.index == 0))
    {
        for (int i = 0; i < self.albumsInternet.count; i++)
        {
            [differencesAlbums addObject: [self.albumsInternet objectAtIndex: i]];
            [differencesYears addObject: [self.yearsInternet objectAtIndex: i]];
        }
    } else
    {
        for (int j = 0; j < self.albumsDevice.count; j++)
        {
            [differencesAlbums addObject: [self.albumsDevice objectAtIndex: j]];
            [differencesYears addObject: [self.yearsDevice objectAtIndex: j]];
        }
    }
    for (int i = 0; i < differencesAlbums.count; i++)
    {
        NSString *firstLetter = [NSString stringWithFormat: @"%c", toupper([[differencesAlbums objectAtIndex: i] characterAtIndex: 0])];
        if (![indices containsObject: firstLetter])
        {
            firstLetter = @"#";
        }
        for (int j = 0; j < contentAlbums.count; j++)
        {
            NSMutableArray *temp = [contentAlbums objectAtIndex: j];
            NSMutableArray *temp2 = [contentYears objectAtIndex: j];
            if ([temp containsObject: firstLetter] && [temp2 containsObject: firstLetter])
            {
                int index = [temp indexOfObject: firstLetter];
                if (index < 0)
                {
                    index = 0;
                }
                [temp insertObject: [differencesAlbums objectAtIndex: i] atIndex: index];
                [temp2 insertObject: [differencesYears objectAtIndex: i] atIndex: index];
                break;
            }
        }
    }
    NSMutableArray *contentAlbumsCopy = [[NSMutableArray alloc] initWithArray: contentAlbums];
    NSMutableArray *contentYearsCopy = [[NSMutableArray alloc] initWithArray: contentYears];
    contentAlbums = [[NSMutableArray alloc] init];
    contentYears = [[NSMutableArray alloc] init];
    for (NSMutableArray *temp in contentAlbumsCopy)
    {
        if (temp.count > 1)
        {
            [contentAlbums addObject: temp];
        }
    }
    for (NSMutableArray *temp2 in contentYearsCopy)
    {
        if (temp2.count > 1)
        {
            [contentYears addObject: temp2];
        }
    }
    [indices addObject: @"#"];
}

// specifying number of sections
- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView
{
    if (contentAlbums.count != 0 && contentYears.count != 0)
    {
        return contentAlbums.count;
    }
    return 1;
}

// specifying number of rows
- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    if (contentAlbums.count != 0 && contentYears.count != 0)
    {
        NSMutableArray *temp = [contentAlbums objectAtIndex: section];
        return temp.count - 1;
    }
    return 1;
}

// specifying section titles
- (NSString *)tableView: (UITableView *)tableView titleForHeaderInSection: (NSInteger)section
{
    if (contentAlbums.count != 0 && contentYears.count != 0)
    {
        NSMutableArray *temp = [contentAlbums objectAtIndex: section];
        return [temp objectAtIndex: temp.count - 1];
    }
    return nil;
}

// populating table view
- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.numberOfLines = 1;
    if ((self.allTypes == 1 || (self.allTypes == 0 && self.index == 0)) && self.albumsInternet.count == 0 && self.yearsInternet.count == 0)
    {
        cell.textLabel.font = [UIFont italicSystemFontOfSize: 17.0];
        cell.textLabel.text = @"No missing albums found.";
    } else if ((self.allTypes == 2 || (self.allTypes == 0 && self.index == 1)) && self.albumsDevice.count == 0 && self.yearsDevice.count == 0)
    {
        cell.textLabel.font = [UIFont italicSystemFontOfSize: 17.0];
        cell.textLabel.text = @"No surplus albums found.";
    } else
    {
        cell.textLabel.font = [UIFont systemFontOfSize: 17.0];
        cell.textLabel.text = [[contentAlbums objectAtIndex: indexPath.section] objectAtIndex: indexPath.row];
        NSString *subtitle = [[contentYears objectAtIndex: indexPath.section] objectAtIndex: indexPath.row];
        cell.detailTextLabel.font = [UIFont italicSystemFontOfSize: 12.0];
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%@", subtitle];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

// connecting to the iTunes Store
- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    NSString *searchTerm = [tableView cellForRowAtIndexPath: indexPath].textLabel.text;
    NSString *string;
    if (![searchTerm isEqualToString: @"No missing albums found."] && ![searchTerm isEqualToString: @"No surplus albums found."])
    {
        searchTerm = [[searchTerm componentsSeparatedByString: @" - "] objectAtIndex: 0];
        if ([searchTerm caseInsensitiveCompare: @"Queens of the Stone Age"] == NSOrderedSame)
        {
            string = @"itms://itunes.apple.com/artist/queens-of-the-stone-age/id857919";
        }
        else if ([searchTerm caseInsensitiveCompare: @"Paul Smith"] == NSOrderedSame)
        {
            string = @"itms://itunes.apple.com/artist/paul-smith/id56899380";
        }
        else
        {
            searchTerm = [searchTerm stringByReplacingOccurrencesOfString: @" " withString: @""];
            string = [@"itms://itunes.com/" stringByAppendingString: searchTerm];
        }
        NSData *data = [string dataUsingEncoding: NSASCIIStringEncoding allowLossyConversion: YES];
        NSString *stringEncoding = [[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding];
        NSURL *url = [NSURL URLWithString: stringEncoding];
        NSLog(@"%@", url);
        [[UIApplication sharedApplication] openURL: url];
    }
}

@end