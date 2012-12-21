//
//	$Id$
//  TDBSimFileCell.h
//	TapMania
//
//  Created by Alex Kremer on 8/18/10.
//  Copyright 2010 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDBSimFileCell : UITableViewCell
{
    UILabel *title;
    UILabel *artist;
}

@property(nonatomic, retain) IBOutlet UILabel *title;
@property(nonatomic, retain) IBOutlet UILabel *artist;

@end
