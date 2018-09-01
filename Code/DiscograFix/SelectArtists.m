//
//  SelectArtists.m
//  DiscograFix
//
//  Copyright (c) 2015 DiscograFix. All rights reserved.
//

#import "SelectArtists.h"
#import "SpecifyOptions.h"
#import "Reachability.h"
#import "MediaPlayer/MPMediaQuery.h"

@implementation SelectArtists

@synthesize artistsDevice = _artistsDevice;
@synthesize artistsDeviceCopy = _artistsDeviceCopy;
@synthesize selectedIndexPath = _selectedIndexPath;

- (id)initWithNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    internetWorking = 1;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString: @"Pull to Refresh"];
    [refreshControl addTarget: self action: @selector(refreshTableContent) forControlEvents: UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle: @"Next" style: UIBarButtonItemStyleBordered
                                                            target: self action: @selector(nextButtonClicked)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.artistsDevice = [[NSMutableArray alloc] init];
    self.artistsDeviceCopy = [[NSMutableArray alloc] init];
    self.selectedIndexPath = [[NSMutableArray alloc] init];
    [self testInternetConnection];
    [self fetchArtists];
    content = [[NSMutableArray alloc] init];
    [self createTableContent];
}

- (void)viewDidUnload
{
    content = nil;
    indices = nil;
    self.artists = nil;
    self.artistsDevice = nil;
    self.artistsDeviceCopy = nil;
    self.selectedIndexPath = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// pushing data to next screen
- (void)prepareForSegue: (UIStoryboardSegue *)segue sender: (id)sender
{
    if ([segue.identifier isEqualToString: @"firstSegue"])
    {
        SpecifyOptions *controller = (SpecifyOptions *)segue.destinationViewController;
        controller.artistsDevice = self.artistsDevice;
    }
}

// refreshing table content
- (IBAction)refreshTableContent
{
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

// saving artist list and performing segue
- (IBAction)nextButtonClicked
{
    [self.artistsDeviceCopy sortUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
    self.artistsDevice = [[NSMutableArray alloc] initWithArray: self.artistsDeviceCopy];
    [self performSegueWithIdentifier: @"firstSegue" sender: nil];
}

// testing Internet connection
- (void)testInternetConnection
{
    @autoreleasepool
    {
        Reachability *internetReachability = [Reachability reachabilityWithHostname: @"www.google.com"];
        internetReachability.reachableBlock = ^(Reachability*reach)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                internetWorking = 1;
                if (self.selectedIndexPath.count > 0)
                {
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                }
            });
        };
        internetReachability.unreachableBlock = ^(Reachability*reach)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                internetWorking = 0;
                self.navigationItem.rightBarButtonItem.enabled = NO;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Four-oh-four."
                                                          message: @"It seems that you're currently offline.\nMake sure you have a working Internet connection and try again."
                                                          delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
                [alert show];
            });
        };
        [internetReachability startNotifier];
    }
}

// fetching artists from music library
- (void)fetchArtists
{
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    query = [MPMediaQuery artistsQuery];
    NSArray *collections = [query collections];
    for (MPMediaItemCollection *collection in collections)
    {
        NSString *artistName = [[collection representativeItem] valueForProperty: MPMediaItemPropertyArtist];
        if (![self.artistsDevice containsObject: artistName])
        {
            [self.artistsDevice addObject: artistName];
        }
    }
    query = [[MPMediaQuery alloc] init];
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
    for (NSString *letter in letters)
    {
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        [temp addObject: letter];
        [content addObject: temp];
    }
    for (NSString *artistName in self.artistsDevice)
    {
        NSString *firstLetter;
        NSString *substring;
        if (artistName.length >= 4)
        {
            substring = [artistName substringToIndex: 4];
        }
        if ([substring isEqualToString: @"The "] && artistName.length >= 4)
        {
            firstLetter = [NSString stringWithFormat: @"%c", toupper([artistName characterAtIndex: 4])];
        } else
        {
            firstLetter = [NSString stringWithFormat: @"%c", toupper([artistName characterAtIndex: 0])];
        }
        if ([firstLetter isEqualToString: @"Ä"] || [firstLetter isEqualToString: @"Á"] ||
            [firstLetter isEqualToString: @"Â"] || [firstLetter isEqualToString: @"Å"])
        {
            firstLetter = @"A";
        } else if ([firstLetter isEqualToString: @"Ö"])
        {
            firstLetter = @"O";
        } else if ([firstLetter isEqualToString: @"Ü"])
        {
            firstLetter = @"U";
        }
        if (![indices containsObject: firstLetter])
        {
            firstLetter = @"#";
        }
        for (NSMutableArray *temp in content)
        {
            if ([temp containsObject: firstLetter])
            {
                [temp insertObject: artistName atIndex: [temp indexOfObject: firstLetter]];
            }
        }
    }
    NSMutableArray *contentCopy = [[NSMutableArray alloc] initWithArray: content];
    content = [[NSMutableArray alloc] init];
    for (NSMutableArray *temp in contentCopy)
    {
        if (temp.count > 1)
        {
            [content addObject: temp];
        }
    }
    [indices addObject: @"#"];
}

// specifying number of sections
- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView
{
    if (content.count != 0)
    {
        return content.count;
    }
    return 1;
}

// specifying number of rows
- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    if (content.count != 0)
    {
        NSMutableArray *temp = [content objectAtIndex: section];
        return temp.count - 1;
    }
    return 1;
}

// specifying section titles
- (NSString *)tableView: (UITableView *)tableView titleForHeaderInSection: (NSInteger)section
{
    if (content.count != 0)
    {
        NSMutableArray *temp = [content objectAtIndex: section];
        return [temp objectAtIndex: temp.count - 1];
    }
    return nil;
}

// specifying index titles
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return indices;
}

// specifying indexed locations
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle: (NSString *)title atIndex: (NSInteger)index
{
    for (NSMutableArray *temp in indices)
    {
        if ([indices containsObject: title])
        {
            return [indices indexOfObject: title];
        }
    }
    return 0;
}

// populating table view
- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.numberOfLines = 1;
    if (self.artistsDevice.count == 0)
    {
        cell.textLabel.font = [UIFont italicSystemFontOfSize: 17.0];
        cell.textLabel.text = @"No artists found.";
    } else
    {
        cell.textLabel.font = [UIFont systemFontOfSize: 17.0];
        cell.textLabel.text = [[content objectAtIndex: indexPath.section] objectAtIndex: indexPath.row];
    }
    if ([self.selectedIndexPath containsObject: indexPath] && self.artistsDevice.count != 0)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

// adding checkmark when selecting cells
- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    if (self.artistsDevice.count != 0)
    {
        [tableView deselectRowAtIndexPath: indexPath animated: YES];
        if ([self.selectedIndexPath containsObject: indexPath])
        {
            [self.selectedIndexPath removeObject: indexPath];
            [self.artistsDeviceCopy removeObject: [tableView cellForRowAtIndexPath: indexPath].textLabel.text];
            if (self.selectedIndexPath.count == 0)
            {
                self.navigationItem.rightBarButtonItem.enabled = NO;
            }
        } else
        {
            if (self.selectedIndexPath.count < 5)
            {
                [self.selectedIndexPath addObject: indexPath];
                [self.artistsDeviceCopy addObject: [tableView cellForRowAtIndexPath: indexPath].textLabel.text];
                if (self.selectedIndexPath.count > 0 && internetWorking == 1)
                {
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"High five."
                                                          message: @"Please don't select more than five artists at a time. Scan the current selection first and then redo the process."
                                                          delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
                [alert show];
            }
        }
        [tableView reloadData];
    }
}

@end