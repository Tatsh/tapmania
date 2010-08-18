//
//	$Id$
//  TDBSearch.h
//	TapMania
//
//  Created by Alex Kremer on 8/18/10.
//  Copyright 2010 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TDBSearchController : UITableViewController <UITableViewDataSource, UITableViewDelegate,
														UISearchBarDelegate, UISearchDisplayDelegate> 
{
	UISearchDisplayController*	searchDiplayController;
	UISearchBar*				searchBar;
	
	NSMutableArray* currentSearchResults;
	NSString*		curSearchStr;
}

@property (retain, nonatomic) IBOutlet UISearchDisplayController* searchDisplayController;
@property (retain, nonatomic) IBOutlet UISearchBar* searchBar;

@end


@interface TDBSimfile : NSObject 
{
	NSString* artist;
	NSUInteger Id;
	NSString* md5;
	NSString* title;
	NSUInteger type;
	NSString* url;
}

@property (nonatomic, copy) NSString *artist;
@property (nonatomic, assign) NSUInteger Id;
@property (nonatomic, copy) NSString *md5;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, copy) NSString *url;

@end