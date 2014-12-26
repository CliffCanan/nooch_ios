//
//  UITableViewCell+ArtisanPublic.h
//
//  Copyright (c) 2014 Artisan Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (ArtisanPublic)

/**
 * Holds the row value originally set by the UITableView for the cell.
 *
 * If row number was modified using the Artisan reordering API artisanOriginalRow will contain the original value before the ordering.  If the Artisan reordering API was not used this value will equal the row number.
 */
@property (assign,nonatomic) long artisanOriginalRow;

@end
