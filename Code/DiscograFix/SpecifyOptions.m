//
//  SpecifyOptions.m
//  DiscograFix
//
//  Copyright (c) 2015 DiscograFix. All rights reserved.
//

#import "SpecifyOptions.h"
#import "Results.h"
#import "ResultsDetails.h"
#import "MBProgressHUD.h"

@implementation SpecifyOptions

@synthesize artistID = _artistID;
@synthesize albumType = _albumType;
@synthesize currentValueName = _currentValueName;
@synthesize expectedValueName = _expectedValueName;
@synthesize currentValueYear = _currentValueYear;
@synthesize expectedValueYear = _expectedValueYear;
@synthesize artistsDevice = _artistsDevice;
@synthesize albumsDuplicates = _albumsDuplicates;
@synthesize yearsDuplicates = _yearsDuplicates;
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
    self.allTypes = 0;
    self.allAges = 0;
    self.albumType = @"Album";
    self.albumsDuplicates = [[NSMutableArray alloc] init];
    self.yearsDuplicates = [[NSMutableArray alloc] init];
    self.albumsDevice = [[NSMutableArray alloc] init];
    self.albumsInternet = [[NSMutableArray alloc] init];
    self.yearsDevice = [[NSMutableArray alloc] init];
    self.yearsInternet = [[NSMutableArray alloc] init];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle: @"Scan" style: UIBarButtonItemStyleBordered
                                                            target: self action: @selector(scanButtonClicked)];
    self.navigationItem.rightBarButtonItem = rightButton;
    ADBannerView *banner = [[ADBannerView alloc] initWithFrame:CGRectZero];
    [self.view addSubview: banner];
}

- (void)viewDidUnload
{
    self.age = nil;
    self.type = nil;
    self.artistID = nil;
    self.albumType = nil;
    self.currentValueName = nil;
    self.currentValueYear = nil;
    self.expectedValueName = nil;
    self.expectedValueYear = nil;
    self.artistsDevice = nil;
    self.albumsDuplicates = nil;
    self.yearsInternet = nil;
    self.albumsInternet = nil;
    self.albumsDevice = nil;
    self.yearsInternet = nil;
    self.yearsDevice = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// preparing segmented data
- (IBAction)type: (UISegmentedControl *)sender
{
    self.allTypes = [sender selectedSegmentIndex];
}

// preparing segmented data
- (IBAction)age: (UISegmentedControl *)sender
{
    self.allAges = [sender selectedSegmentIndex];
}

// pushing data to next screen
- (void)prepareForSegue: (UIStoryboardSegue *)segue sender: (id)sender
{
    if ([segue.identifier isEqualToString: @"secondSegue"])
    {
        Results *controller = (Results *)segue.destinationViewController;
        controller.allTypes = self.allTypes;
        controller.allAges = self.allAges;
        controller.albumsInternet = self.albumsInternet;
        controller.albumsDevice = self.albumsDevice;
        controller.yearsInternet = self.yearsInternet;
        controller.yearsDevice = self.yearsDevice;
    } else if ([segue.identifier isEqualToString: @"thirdSegue"])
    {
        ResultsDetails *controller = (ResultsDetails *)segue.destinationViewController;
        controller.allTypes = self.allTypes;
        controller.allAges = self.allAges;
        controller.albumsInternet = self.albumsInternet;
        controller.albumsDevice = self.albumsDevice;
        controller.yearsInternet = self.yearsInternet;
        controller.yearsDevice = self.yearsDevice;
    }
}

// activating activity indicator and performing segue
- (IBAction)scanButtonClicked
{
    @autoreleasepool
    {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        activityIndicator = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
        activityIndicator.labelText = @"Scanning...";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            for (NSString *artistName in self.artistsDevice)
            {
                /* DEBUG */ NSLog(@"%@", artistName);
                [self startParsing: artistName];
            }
            [self fetchAlbums];
            [self handleExceptionsAdd];
            /* DEBUG */ NSLog(@"Internet albums: %@", self.albumsInternet);
            /* DEBUG */ NSLog(@"Internet years: %@", self.yearsInternet);
            /* DEBUG */ NSLog(@"Device albums: %@", self.albumsDevice);
            /* DEBUG */ NSLog(@"Device years: %@", self.yearsDevice);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                if (self.allTypes == 0)
                {
                    [self performSegueWithIdentifier: @"secondSegue" sender: nil];
                } else
                {
                    [self performSegueWithIdentifier: @"thirdSegue" sender: nil];
                }
            });
        });
    }
}

// fetching albums from music library
- (void)fetchAlbums
{
    for (NSString *artistName in self.artistsDevice)
    {
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue: artistName forProperty: MPMediaItemPropertyArtist];
        MPMediaQuery *albumsQuery = [MPMediaQuery albumsQuery];
        [albumsQuery addFilterPredicate: predicate];
        for (MPMediaItemCollection *collection in [albumsQuery collections])
        {
            NSString *artistNameNew = [artistName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *albumName = [[collection representativeItem] valueForProperty: MPMediaItemPropertyAlbumTitle];
            if ([albumName isEqualToString: @""])
            {
                albumName = @"Unknown album";
            }
            albumName = [albumName stringByReplacingOccurrencesOfString: @"..." withString: @"…"];
            NSString *entry = [NSString stringWithFormat: @"%@%s%@", artistNameNew, " - ", albumName];
            NSString *albumYear = [[collection representativeItem] valueForProperty: @"year"];
            if (![self.albumsDevice containsObject: entry])
            {
                [self.albumsDevice addObject: entry];
                if (albumYear && [albumYear isKindOfClass: [NSNumber class]])
                {
                    [self.yearsDevice addObject: albumYear];
                } else
                {
                    [self.yearsDevice addObject: @"Unknown year"];
                }
            }
        }
    }
}

// parsing start element
- (void)startParsing: (NSString*)artistName;
{
    artistName = [artistName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self handleDeviatingArtists: artistName];
    if ([self.artistID isEqualToString: @"no match"])
    {
        NSString *artistNameNew = [artistName stringByReplacingOccurrencesOfString: @"&" withString: @"and"];
        NSString *string = @"http://www.musicbrainz.org/ws/2/artist?query=artist:";
        string = [string stringByAppendingString: artistNameNew];
        NSString *stringEncoding = [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString: stringEncoding];
        artistIDFound = 0;
        self.artistID = nil;
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL: url];
        [parser setDelegate: self];
        [parser setShouldResolveExternalEntities: YES];
        [parser parse];
    }
    if (self.artistID && self.artistID != nil && self.artistID != NULL)
    {
        NSString *string = @"http://www.musicbrainz.org/ws/2/release-group?artist=";
        string = [string stringByAppendingString: self.artistID];
        string = [string stringByAppendingString: @"&type=album"];
        NSString *stringEncoding = [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString: stringEncoding];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL: url];
        [parser setDelegate: self];
        [parser setShouldResolveExternalEntities: YES];
        [parser parse];
        for (int i = 0; i < self.albumsDuplicates.count; i++)
        {
            NSString *albumNameNew = [[self.albumsDuplicates objectAtIndex: i] stringByReplacingOccurrencesOfString: @"’" withString: @"'"];
            NSString *entry = [artistName stringByAppendingString: @" - "];
            entry = [entry stringByAppendingString: albumNameNew];
            [self.albumsInternet addObject: entry];
            [self.yearsInternet addObject: [self.yearsDuplicates objectAtIndex: i]];
        }
        self.albumsDuplicates = [[NSMutableArray alloc] init];
        self.yearsDuplicates = [[NSMutableArray alloc] init];
        [self handleExceptionsRemoveUpdate];
    }
}

// parsing beginning element
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString: @"artist"] && artistIDFound == 0)
    {
        NSString *score = [attributeDict objectForKey: @"ext:score"];
        if ([score isEqualToString: @"100"])
        {
            self.artistID = [attributeDict objectForKey: @"id"];
            artistIDFound = 1;
        }
    }
    if ([elementName isEqualToString: @"release-group"])
    {
        self.albumType = [attributeDict objectForKey: @"type"];
    }
}

// parsing middle element
- (void)parser: (NSXMLParser *)parser foundCharacters: (NSString *)string
{
    if (!self.currentValueName)
    {
        self.currentValueName = [[NSMutableString alloc] init];
    }
    [self.currentValueName appendString: string];
    if (!self.currentValueYear)
    {
        self.currentValueYear = [[NSMutableString alloc] init];
    }
    [self.currentValueYear appendString: string];
}

// parsing end element
- (void)parser: (NSXMLParser *)parser didEndElement: (NSString *)elementName namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qName
{
    NSString *temp = [self.currentValueName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *temp2 = [self.currentValueYear stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.currentValueName = nil;
    self.currentValueYear = nil;
    if ([elementName isEqualToString: @"title"] && [self.albumType isEqualToString: @"Album"])
    {
        self.expectedValueName = temp;
    }
    if ([elementName isEqualToString: @"first-release-date"] && [self.albumType isEqualToString: @"Album"])
    {
        if (!temp2 || temp2 == nil || temp2 == NULL)
        {
            self.expectedValueYear = @"Unknown year";
        } else
        {
            temp2 = [[temp2 componentsSeparatedByString: @"-"] objectAtIndex: 0];
            self.expectedValueYear = temp2;
        }
        if (![self.albumsDuplicates containsObject: self.expectedValueName])
        {
            [self.albumsDuplicates addObject: self.expectedValueName];
            [self.yearsDuplicates addObject: self.expectedValueYear];
        }
    }
}

// handling deviating artists
- (void)handleDeviatingArtists: (NSString*)artistName
{
    if ([artistName isEqualToString: @"AaRON"])
    {
        self.artistID = @"f897e098-941b-4fa4-b966-4870c1e5614c";
    } else if ([artistName isEqualToString: @"Bastille"])
    {
        self.artistID = @"7808accb-6395-4b25-858c-678bbb73896b";
    } else if ([artistName isEqualToString: @"Boy"])
    {
        self.artistID = @"2e76bad0-edf3-4a6c-ad79-db87bb5a0d35";
    } else if ([artistName isEqualToString: @"DJ Fresh"])
    {
        self.artistID = @"77049387-0580-4a3a-a05f-d12b5d6b5042";
    } else if ([artistName isEqualToString: @"Everything Everything"])
    {
        self.artistID = @"251e10fb-4ed1-4a79-8655-7f22d461a689";
    } else if ([artistName isEqualToString: @"Haim"])
    {
        self.artistID = @"aef06569-098f-4218-a577-b413944d9493";
    } else if ([artistName isEqualToString: @"Indiana"])
    {
        self.artistID = @"5be8db78-fb0c-4427-9e25-547b64da79f9";
    } else if ([artistName isEqualToString: @"Loadstar"])
    {
        self.artistID = @"d7d3e885-15a1-4d53-943c-0ffca6628cbe";
    } else if ([artistName isEqualToString: @"Lorde"])
    {
        self.artistID = @"8e494408-8620-4c6a-82c2-c2ca4a1e4f12";
    } else if ([artistName isEqualToString: @"Nero"])
    {
        self.artistID = @"bd057a0c-a7b6-47bf-8dc3-45e0efac1798";
    } else if ([artistName isEqualToString: @"Paul Smith"])
    {
        self.artistID = @"2f727018-1e83-4797-8433-32c8b99dd057";
    } else if ([artistName isEqualToString: @"Pendulum"])
    {
        self.artistID = @"beff21d3-88c7-4ee0-8b7a-40b6db22c6d7";
    } else if ([artistName isEqualToString: @"Phoenix"])
    {
        self.artistID = @"8d455809-96b3-4bb6-8829-ea4beb580d35";
    } else if ([artistName isEqualToString: @"Rodriguez"] || [artistName isEqualToString: @"Sixto Rodriguez"])
    {
        self.artistID = @"8898cd01-b0c5-41bd-9699-0845fc73efc1";
    } else if ([artistName isEqualToString: @"Skream"])
    {
        self.artistID = @"fb5ee67e-e31a-40cf-8b06-5f1a0f53529a";
    } else
    {
        self.artistID = @"no match";
    }
}

// handling exceptions of adding nature
- (void)handleExceptionsAdd
{
    [self addEntry: @"Ásgeir - In the Silence" : @"2013"];
    [self addEntry: @"Bauchklang - Akusmatik" : @"2013"];
    [self addEntry: @"Charity Children - The Autumn Came" : @"2013"];
    [self addEntry: @"Farin Urlaub - Die Wahrheit übers Lügen" : @"2008"];
    [self addEntry: @"Farin Urlaub - Faszination Weltraum" : @"2014"];
    [self addEntry: @"Keeno - Life Cycle" : @"2014"];
    [self addEntry: @"Los Yukas - Mas hambre que talento" : @"2012"];
    [self addEntry: @"Nu:Logic - What I've Always Waited For" : @"2013"];
    [self addEntry: @"S.P.Y - What the Future Holds" : @"2012"];
    [self addEntry: @"S.P.Y - Back to Basics Chapter One" : @"2014"];
    [self addEntry: @"S.P.Y - Back to Basics Chapter Two" : @"2014"];
    [self addEntry: @"SpectraSoul - The Mistress" : @"2015"];
    [self addEntry: @"The Swell Season - Once Soundtrack" : @"2007"];
    [self addEntry: @"The Swell Season - The Swell Season" : @"2006"];
    [self addEntry: @"Tenacious D - The Pick of Destiny" : @"2006"];
}

// handling exceptions of updating and removing nature
- (void)handleExceptionsRemoveUpdate
{
    [self removeEntry: @"Ásgeir - Asgeir, Sjefen over alle sjefer"];
    [self removeEntry: @"Die Ärzte - 5, 6, 7, 8 - Bullenstaat!"];
    [self removeEntry: @"Bastille - Remixed"];
    [self removeEntry: @"Bastille - VS. (Other People's Heartache, Part III)"];
    [self removeEntry: @"Bauchklang - Klangeins"];
    [self removeEntry: @"Björk - Gling-Gló"];
    [self removeEntry: @"Camo & Krooked - Between the Lines"];
    [self removeEntry: @"Charity Children - Impedimenta"];
    [self removeEntry: @"Charlie Winston - Passport"];
    [self removeEntry: @"Damon Albarn - Democrazy"];
    [self removeEntry: @"Damon Albarn - Dr Dee"];
    [self removeEntry: @"Damon Albarn - Mali Music"];
    [self removeEntry: @"Dave Matthews Band - The Lillywhite Sessions"];
    [self removeEntry: @"Dave Matthews Band - The Rutabega Demos (1/5/92)"];
    [self removeEntry: @"Dave Matthews Band - Warehouse 5, Volume 11"];
    [self removeEntry: @"Dave Matthews Band - Warehouse 5 Volume 6"];
    [self removeEntry: @"Death Cab for Cutie - Transatlanticism Demos"];
    [self removeEntry: @"Death Cab for Cutie - You Can Play These Songs With Chords"];
    [self removeEntry: @"Disclosure - FACT Mix 327: Disclosure"];
    [self removeEntry: @"DJ Fresh - Gold Dust (Shy FX Re-Edit)"];
    [self removeEntry: @"Ellie Goulding - Halcyon Days"];
    [self removeEntry: @"Exit Clov - Cover Boy"];
    [self removeEntry: @"Family of the Year - Our Songbook"];
    [self removeEntry: @"Franz Ferdinand - FFS"];
    [self removeEntry: @"Glen Hansard - The Swell Season"];
    [self removeEntry: @"Imagine Dragons - Smoke+Mirrors Special Edition"];
    [self removeEntry: @"Infected Mushroom - Friends on Mushrooms (Deluxe Edition)"];
    [self removeEntry: @"James Blake - James Drake Mixtape"];
    [self removeEntry: @"Jamiroquai - Live At Montreux 2003 - CD 1"];
    [self removeEntry: @"Jason Mraz - Homemade"];
    [self removeEntry: @"Jason Mraz - Sold Out (In Stereo)"];
    [self removeEntry: @"Jeff Buckley - Grace / Mystery White Boy"];
    [self removeEntry: @"Jeff Buckley - Sketches for My Sweetheart the Drunk"];
    [self removeEntry: @"Jeff Buckley - Grace Outtakes"];
    [self removeEntry: @"Jeff Buckley - Songs to No One 1991-1992"];
    [self removeEntry: @"Jeff Buckley - Eternal Life"];
    [self removeEntry: @"Kaiser Chiefs - Start the Revolution Without Me"];
    [self removeEntry: @"Keane - The Best of Keane"];
    [self removeEntry: @"Major Lazer - LazerProof"];
    [self removeEntry: @"Major Lazer - Start A Fire"];
    [self removeEntry: @"Mando Diao - The Braley Geshmore'"];
    [self removeEntry: @"Metronomy - The English Riviera (Unreleased Remixes)"];
    [self removeEntry: @"Mumford & Sons - Babel (Gentlemen of the Road Edition)"];
    [self removeEntry: @"Muse - Greatest Hits"];
    [self removeEntry: @"Nada Surf - If I Had a Hi-Fi"];
    [self removeEntry: @"Nirvana - Verse Chorus Verse"];
    [self removeEntry: @"Noisia - Motorstorm Apocalypse"];
    [self removeEntry: @"The Offspring - Anti-Depressivum"];
    [self removeEntry: @"Paper Diamond - Paragon"];
    [self removeEntry: @"Parov Stelar - Klangwolke"];
    [self removeEntry: @"Pendulum - Greatest Hits"];
    [self removeEntry: @"The Prodigy - The Dirtchamber Sessions, Volume One"];
    [self removeEntry: @"The Prototypes - Don't Let Me Go"];
    [self removeEntry: @"Queens of the Stone Age - Rated R + Songs for the Deaf"];
    [self removeEntry: @"Radiohead - No Surprises / Running From Demons"];
    [self removeEntry: @"Radiohead - Oxford Angels: The Rarities"];
    [self removeEntry: @"Radiohead - Sail to Montreux"];
    [self removeEntry: @"Reso - Tangram"];
    [self removeEntry: @"Rudimental - Speeding (Remixes)"];
    [self removeEntry: @"Seeed - New Dubby Conquerors / Music Monks"];
    [self removeEntry: @"Selah Sue - Rarities"];
    [self removeEntry: @"Serj Tankian - California Nightmare"];
    [self removeEntry: @"Serj Tankian - Jazz-Iz Christ"];
    [self removeEntry: @"Serj Tankian - Selected Music Scores"];
    [self removeEntry: @"Sigur Rós - Heima"];
    [self removeEntry: @"Skream - The Freeizm Album"];
    [self removeEntry: @"Skream - 100K Freeizm"];
    [self removeEntry: @"Skream - Freeizm History"];
    [self removeEntry: @"Slut - Corpus Delicti"];
    [self removeEntry: @"Sub Focus - Mixmag Presents: The Road to Creamfields"];
    [self removeEntry: @"System of a Down - Toxicity II"];
    [self removeEntry: @"Technimatic - Night Vision"];
    [self removeEntry: @"Texta - Geschwiegen"];
    [self removeEntry: @"Vampire Weekend - Weeemix"];
    [self removeEntry: @"The White Stripes - Candy Stripes"];
    [self removeEntry: @"The Wombats - Girls, Boys & Marsupials"];
    [self removeEntry: @"Young Rebel Set - Young Rebel Set"];

    [self updateEntry: @"Beatsteaks - Smacksmash" : @"Beatsteaks - Smack Smash"];
    [self updateEntry: @"Brookes Brothers - The Brookes Brothers" : @"Brookes Brothers - Brookes Brothers"];
    [self updateEntry: @"Die Ärzte - Das ist nicht die ganze Wahrheit …" : @"Die Ärzte - Das ist nicht die ganze Wahrheit…"];
    [self updateEntry: @"Incubus - A Crow Left of the Murder..." : @"Incubus - A Crow Left of the Murder…"];
    [self updateEntry: @"Infected Mushroom - B.P.Empire" : @"Infected Mushroom - B.P. Empire"];
    [self updateEntry: @"Major Lazer - Guns Don't Kill People... Lazers Do" : @"Major Lazer - Guns Don't Kill People… Lazers Do"];
    [self updateEntry: @"Paul Smith - Frozen by Sight" : @"Paul Smith - Frozen By Sight"];
    [self updateEntry: @"Queens of the Stone Age - R" : @"Queens of the Stone Age - Rated R"];
    [self updateEntry: @"Serj Tankian - ORCA" : @"Serj Tankian - Orca Symphony No. 1"];
    [self updateEntry: @"Texta - Gediegen..." : @"Texta - Gediegen"];
}

// adding exception entries
- (void)addEntry: (NSString *)stringName : (NSString *)stringYear
{
    if ([self.albumsDevice containsObject: stringName] && ![self.albumsInternet containsObject: stringName])
    {
        [self.albumsInternet addObject: stringName];
        [self.yearsInternet addObject: stringYear];
    }
}

// removing exception entries
- (void)removeEntry: (NSString *)string
{
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray: self.albumsInternet];
    for (NSString *internet in temp)
    {
        if ([internet caseInsensitiveCompare: string] == NSOrderedSame)
        {
            int i = [self.albumsInternet indexOfObject: string];
            if (i >= 0 && i < self.albumsInternet.count)
            {
                [self.albumsInternet removeObjectAtIndex: i];
                [self.yearsInternet removeObjectAtIndex: i];
            }
        }
    }
}

// updating exception entries
- (void)updateEntry: (NSString *)stringOld : (NSString *)stringNew
{
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray: self.albumsInternet];
    for (NSString *internet in temp)
    {
        if ([internet caseInsensitiveCompare: stringOld] == NSOrderedSame)
        {
            int j = [self.albumsInternet indexOfObject: stringOld];
            if (j >= 0 && j < self.albumsInternet.count)
            {
                [self.albumsInternet removeObjectAtIndex: j];
                [self.albumsInternet insertObject: stringNew atIndex: j];
            }
        }
    }
}

@end