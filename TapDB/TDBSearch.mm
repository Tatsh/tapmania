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

@implementation TDBSearchController
@synthesize searchBar, searchDisplayController;

- (void) awakeFromNib {
	currentSearchResults = [[NSMutableArray alloc] initWithCapacity:10];
}

- (void) dealloc {
	[currentSearchResults release];
	[super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	
	TMLog(@"Requesting cell count...");
    return [currentSearchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	TMLog(@"Requesting cell...");
	
	static NSString *kCellID = @"cellID";
		
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	TDBSimfile* sim = [currentSearchResults objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@ by %@", sim.title, sim.artist];
	return cell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[[TapDBService sharedInstance] searchByTitle:curSearchStr forTotalItems:10 startingAt:0 
									withCallback:@selector(byTitle:) delegate:self];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	curSearchStr = [searchString copy];
	return NO;
}



- (void) byTitle:(NSArray*)items {
	TMLog(@"Got data!? %d", [items count]);
	[currentSearchResults removeAllObjects];
	
	NSUInteger i, count = [items count];
	for (i = 0; i < count; i++) {
		NSDictionary* obj = [items objectAtIndex:i];
		NSDictionary* item = [obj objectForKey:@"tapdbs"];
		
		TDBSimfile* sim = [[TDBSimfile alloc] init];
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

- (void)dealloc {
	[artist release];
	artist = nil;
	[md5 release];
	md5 = nil;
	[title release];
	title = nil;
	[type release];
	type = nil;
	[url release];
	url = nil;
	
	[super dealloc];
}

@end