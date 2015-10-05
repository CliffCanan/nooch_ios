//
//  UIView+ArtisanEventTags.h
//
//  Copyright (c) 2014 Artisan Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtisanEventTags.h"

/**
 Category that adds the artisanEventTags property to UIViews.
 */
@interface UIView (ArtisanEventTags)

/**
 Use this property to add ArtisanEventTags to your UIViews (e.g. UIButton, UITableViewCell).

 ArtisanEventTags are a collection of key/values that can be attached to a UIView so that any automatically-collected analytics events, like button tap events, will be tagged or categorized with the appropriate values.

 <h3>Usage Example</h3>

 Here I am adding a tag for the button title which will perform the currentTitle selector to get the current title of the button at the time that any automatically-collected analytics event is recorded. This could be useful if the title on my button changes while it is on the screen and I want to know what it said when the user tapped on it. In this example self is my UIViewController.

 <code><pre>
 ArtisanEventTags *extraButtonInfo = [ArtisanEventTags artisanEventTags];
 [extraButtonInfo setSelector:@selector(currentTitle) forKey:@"buttonTitle"];
 self.addToCartButton.artisanEventTags = extraButtonInfo;
 </pre></code>
 */
@property (nonatomic, retain) ArtisanEventTags *artisanEventTags;

@end
