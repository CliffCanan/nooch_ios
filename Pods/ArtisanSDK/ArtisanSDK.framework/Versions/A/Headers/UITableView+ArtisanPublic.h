//
//  UITableView+ArtisanPublic.h
//
//  Copyright (c) 2014 Artisan Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (ArtisanPublic)

/**
 * Marking a table as static internally sets each table view section as static.
 *
 * Each cell in a table view section that is marked as static is treated as unique when reverse engineered by Artisan.
 *
 * @param value Sets the table as static.
 */
-(void) artisanSetTableStatic:(BOOL)value;

/**
 * Is the current table marked as static?
 *
 * Each cell in a table view section that is marked as static is treated as unique when reverse engineered by Artisan.
 */
-(BOOL) artisanTableStatic;

/**
 * Mark an individual table section as static.
 *
 * Each cell in a table view section that is marked as static is treated as unique when reverse engineered by Artisan.
 *
 * @param value Mark section as static with boolean.
 * @param section Identify the section to mark as static.
 */
-(void) artisanSetTableSectionStatic:(BOOL)value forSection:(int)section;

/**
 * Is the section marked as static?
 *
 * Each cell in a table view section that is marked as static is treated as unique when reverse engineered by Artisan.
 *
 * @param section Identify the section to check for the static boolean.
 */
-(BOOL) artisanTableSectionStaticForSection:(int)section;

/**
 * Set the sort ordering for rows in the indentified section.
 *
 * To reorder cells with in a section the table section must be set as static with artisanSetTableStatic: or artisanSetTableSectionStatic:.  The next step is to pass in an array of NSNumber objects (i.e. [table artisanSetTableSectionOrder:@[@6,@5,@4,@3,@2,@1,@0] forSection:0]) to be used as the new sort order.
 *
 * @param array The array of row indexes in the new sort order.
 * @param section Identify the section to use the new ordering.
 */
-(void) artisanSetTableSectionOrder:(NSArray *)array forSection:(int)section;

/**
 * Return the array used for ordering rows in the section identified.
 *
 * Returns an array of NSNumber objects for the sort ordering of the section indentified.
 *
 * @param section Identify the section to use the new ordering.
 */
-(NSArray *) artisanTableSectionOrderForSection:(int)section;

@end
