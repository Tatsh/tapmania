//
//	$Id$
//  TDBSearch.mm
//	TapMania
//
//  Created by Alex Kremer on 8/18/10.
//  Copyright 2010 Godexsoft. All rights reserved.
//

#import "TDBSearch.h"
#import "TapDBService.h"
#import "TDBSimFileCell.h"

@implementation TDBSearchController
@synthesize searchBar, tableView, totalLabel;

- (void)awakeFromNib
{
    currentSearchResults = [[NSMutableArray alloc] initWithCapacity:10];
}

- (void)dealloc
{
    [currentSearchResults release];
    [super dealloc];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section
{
    TMLog(@"Requesting cell count...");
    return [currentSearchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tblView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TMLog(@"Requesting cell...");

    static NSString *kCellID = @"cellID";

    TDBSimFileCell *cell = (TDBSimFileCell *) [tblView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil)
    {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"TDBSimFile" owner:nil options:nil];
        cell = [arr objectAtIndex:0];
    }

    TDBSimfile *sim = [currentSearchResults objectAtIndex:indexPath.row];
    cell.title.text = sim.title;
    cell.artist.text = sim.artist;

    return cell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)bar
{
    curSearchStr = [bar text];
    [searchBar resignFirstResponder];

    [[TapDBService sharedInstance] searchByTitle:curSearchStr forTotalItems:10 startingAt:0
                                    withCallback:@selector(byTitle:) delegate:self];

    [totalLabel setText:@"10/1034"];
}


- (void)byTitle:(NSArray *)items
{
    TMLog(@"Got data!? %d", [items count]);
    [currentSearchResults removeAllObjects];

    NSUInteger i, count = [items count];
    for (i = 0; i < count; i++)
    {
        NSDictionary *obj = [items objectAtIndex:i];
        NSDictionary *item = [obj objectForKey:@"tapdbs"];

        TDBSimfile *sim = [[TDBSimfile alloc] init];
        sim.artist = [item objectForKey:@"artist"];
        sim.md5 = [item objectForKey:@"md5"];
        sim.Id = [[item objectForKey:@"id"] intValue];
        sim.title = [item objectForKey:@"title"];
        sim.url = [item objectForKey:@"url"];

        [currentSearchResults addObject:sim];
    }

    [self.tableView reloadData];
}

@end


@implementation TDBSimfile

@synthesize artist;
@synthesize Id;
@synthesize md5;
@synthesize title;
@synthesize type;
@synthesize url;

- (void)dealloc
{
    [artist release];
    artist = nil;
    [md5 release];
    md5 = nil;
    [title release];
    title = nil;
    [url release];
    url = nil;

    [super dealloc];
}

@end