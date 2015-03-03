//
//  UIViewController+ArtisanEventTags.h
//
//  Copyright (c) 2014 Artisan Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtisanEventTags.h"

/**
 Category that adds the artisanEventTags property to UIViewControllers.
 */
@interface UIViewController (ArtisanEventTags)

/**
 ArtisanEventTags are a collection of key/values that can be attached to a UIView so that any automatically-collected analytics events, like screen view events, will be tagged or categorized with the appropriate values.

 <h3>Usage Example</h3>

 In this example self is my UIViewController.

 <code><pre>
 - (void)viewWillAppear:(BOOL)animated
 {
  [super viewWillAppear:animated];

  ArtisanEventTags *extraInfoForScreen = [ArtisanEventTags artisanEventTags];
  [extraInfoForScreen setValue:@"HOLIDAY" forKey:@"Shopping Season"];
  self.artisanEventTags = extraInfoForScreen;
 }
 </pre></code>
 */
@property (nonatomic, retain) ArtisanEventTags *artisanEventTags;

@end
