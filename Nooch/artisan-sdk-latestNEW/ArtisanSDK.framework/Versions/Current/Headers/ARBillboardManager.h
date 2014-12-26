//
//  ARBillboardManager.h
//  MarketingBillboardTest
//
//  Copyright (c) 2014 Artisan Mobile, Inc. All rights reserved.
//

/**
 * Manages the Artisan Billboards. This includes:
 *
 * - Registering Artisan Billboard bundles and billboards for those bundles so that they can be customized in Artisan Tools
 * - Checking to see if a billboard is available from Artisan for this device
 * - Getting UIView, UICollectionViewCell, and UITableViewCell instances of those billboards
 * - Getting the size of billboard instances
 *
 * Billboards are grouped into bundles, where each billboard in the bundle is sized to fit with a different device, layout, or orientation.
 *
 * When building a marketing campaign in Artisan Tools you will be able to provide content and assets for each of the billboards in the bundle.
 *
 * ARBillboardManager is a singleton that is automatically initialized when your app starts.
 */
@interface ARBillboardManager : NSObject

/**
 Register a billboard bundle with Artisan

 A billboard bundle represents a group of billboards. For example, in a universal app you might have one billboard bundle, but two billboards in the bundle: one for iPhones and one for iPads. Or, if your layout changes upon rotation you might have multiple billboards in the bundle, each sized to fit with a different device orientation.

 When building a marketing campaign in Artisan Tools you will be able to provide content and assets for each of the billboards in the bundle.

 This registration should occur in the `didFinishLaunchingWithOptions:` method of your main app delegate, *before* you start Artisan using the `[ARManager startWithAppId:version:]` method.

 Usage Example
 =============

 <code><pre>
 [ARBillboardManager registerBillboardBundleWithId:@"mainScreenBillboard"
                                      friendlyName:@"Billboard for the app main screen"
                                       description:@"This billboard will be shown prominently on the main screen for iPhones and iPads."];
 </pre></code>

 @param billboardBundleId unique identifier for this billboard bundle
 @param friendlyName a human-friendly name for this billboard bundle that will be displayed in Artisan Tools
 @param description a description for this billboard bundle, which will be visible to your business users in Artisan Tools. You may wish to include a description of the screens and layouts where this bundle is used in your app.
 */
+ (void)registerBillboardBundleWithId:(NSString *)billboardBundleId
                         friendlyName:(NSString *)friendlyName
                          description:(NSString *)description;

/**
 Register a billboard with Artisan

 A billboard is a view whose contents can be dynamically configured via Artisan Tools.

 This registration should occur in the `didFinishLaunchingWithOptions:` method of your main app delegate, *before* you start Artisan using the `[ARManager startWithAppId:version:]` method.

 Usage Example
 =============

 <code><pre>
 [ARBillboardManager registerBillboardWithId:@"mainScreeniPhone"
                        forBillboardBundleId:@"mainScreenBillboard"
                                friendlyName:@"Main Screen iPhone Billboard"
                                 description:@"This is visible on all iPhones"
                                        size:CGSizeMake(320, 133)
                                dynamicWidth:NO
                              dyanamicHeight:YES];
 </pre></code>

 @param billboardId a unique identifier for this billboard.
 @param billboardBundleId the bundle identifier for the bundle to which this billboard belongs.
 @param friendlyName a human-friendly name for this billboard that will be displayed in Artisan Tools
 @param description a description for this billboard, which will be visible to your business users in Artisan Tools. You may wish to describe the specific layouts and devices that this billboard is used for.
 @param size the size for this billboard. If dynamicWidth and dynamicHeight are both NO, then this will be the fixed height of the billboard.
 @param dynamicWidth whether this billboard should adjust its horizontal size to match the contents.
 @param dynamicHeight whether this billboard should adjust its vertical size to match the contents.
 */
+ (void)registerBillboardWithId:(NSString *)billboardId
           forBillboardBundleId:(NSString *)billboardBundleId
                   friendlyName:(NSString *)friendlyName
                    description:(NSString *)description
                           size:(CGSize)size
                   dynamicWidth:(BOOL)dynamicWidth
                 dyanamicHeight:(BOOL)dynamicHeight;

/**
 Check if a billboard is available.

 If you haven't configured any billboard content via Artisan Tools or if the current user is not elegible for the campaign then there may not be a billboard to show on this device. Therefore, you should always call billboardIsAvailableWithId before requesting a billboard view.

 Usage Example
 =============

 <code><pre>
 if ([ARBillboardManager billboardIsAvailableWithId:@"mainScreeniPhone" inBillboardBundleWithId:@"mainScreenBillboard"]) {
    UIView *billboardView = [ARBillboardManager getBillboardViewWithId:@"mainScreeniPhone" fromBillboardBundleWithId:@"mainScreenBillboard"];
    // add this billboard to your screen
    [myMainScreenView addSubview:billboardView];
 } else {
    // If the billboard is not available you should handle this in your app however it makes sense for your layout.
 }
 </pre></code>

 @param billboardId a unique identifier for this billboard.
 @param billboardBundleId the bundle identifier for the bundle to which this billboard belongs.
 */
+ (BOOL)billboardIsAvailableWithId:(NSString *)billboardId inBillboardBundleWithId:(NSString *)billboardBundleId;

/**
 Get a billboard view to display.

 Usage Example
 =============

 <code><pre>
 if ([ARBillboardManager billboardIsAvailableWithId:@"mainScreeniPhone" inBillboardBundleWithId:@"mainScreenBillboard"]) {
    UIView *billboardView = [ARBillboardManager getBillboardViewWithId:@"mainScreeniPhone" fromBillboardBundleWithId:@"mainScreenBillboard"];
    // add this billboard to your screen
    [myMainScreenView addSubview:billboardView];
 } else {
    // If the billboard is not available you should handle this in your app however it makes sense for your layout.
 }
 </pre></code>
 
 @warning Always check billboardIsAvailableWithId before calling this method so that you are guaranteed to get a billboard back. If the billboard is not available and you call getBillboardViewWithId we will return an empty view and log an error to the console.

 @param billboardId a unique identifier for this billboard.
 @param billboardBundleId the bundle identifier for the bundle to which this billboard belongs.
 */
+ (UIView *)getBillboardViewWithId:(NSString *)billboardId fromBillboardBundleWithId:(NSString *)billboardBundleId;

/**
 Get a billboard to display as a table view cell

 Usage Example
 =============

 <code><pre>
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == billboardIndex) { // only add the billboard to a specific section and row
        if ([ARBillboardManager billboardIsAvailableWithId:@"mainScreeniPhone" inBillboardBundleWithId:@"mainScreenBillboard"]) {
            return [ARBillboardManager getBillboardTableViewCellWithId:@"mainScreeniPhone" fromBillboardBundleWithId:@"mainScreenBillboard" forTableView:tableView];
        } else {
            // If the billboard is not available you should handle this in your app however it makes sense for your layout.
        }
    }
    // ...
 }
 </pre></code>

 @warning Always check billboardIsAvailableWithId before calling this method so that you are guaranteed to get a billboard back. If the billboard is not available and you call getBillboardTableViewCellWithId we will return a non-null but empty cell and log an error to the console.

 @param billboardId a unique identifier for this billboard.
 @param billboardBundleId the bundle identifier for the bundle to which this billboard belongs.
 @param tableView the tableview to add the billboard cell to.
 */
+ (UITableViewCell *)getBillboardTableViewCellWithId:(NSString *)billboardId fromBillboardBundleWithId:(NSString *)billboardBundleId forTableView:(UITableView *)tableView;

/**
 Get a billboard to display as a collection view cell

 Usage Example
 =============

 <code><pre>
 -(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (((indexPath.row == 4) || (indexPath.row == 9) || (indexPath.row == 13) ) && ([ARBillboardManager billboardIsAvailableWithId:@"mainScreeniPhone" inBillboardBundleWithId:@"mainScreenBillboard"]) ) {
        return [ARBillboardManager getBillboardCollectionViewCellWithId:@"mainScreeniPhone" fromBillboardBundleWithId:@"mainScreenBillboard" forCollectionView:collectionView atIndexPath:indexPath];
    } else {
        // ...
    }
 }
 </pre></code>

 @warning Always check billboardIsAvailableWithId before calling this method so that you are guaranteed to get a billboard back. If the billboard is not available and you call getBillboardCollectionViewCellWithId we will return a non-null but empty cell and log an error to the console.


 @param billboardId a unique identifier for this billboard.
 @param billboardBundleId the bundle identifier for the bundle to which this billboard belongs.
 @param collectionView the collectionView to add the billboard cell to.
 @param indexPath the indexPath to add the cell to in the collection view
 */
+ (UICollectionViewCell *)getBillboardCollectionViewCellWithId:(NSString *)billboardId fromBillboardBundleWithId:(NSString *)billboardBundleId forCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;

/**
 Get the size of a billboard.

 Typically a billboard will be the size that you registered it with, but if you have dynamicWidth or dynamicHeight turned on then the size may vary depending on the contents that were configured in Artisan Tools.

 Usage Example
 =============

 <code><pre>
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 3) {
        return [ARBillboardManager getSizeOfBillboardWithId:@"mainScreeniPhone" fromBillboardBundleWithId:@"mainScreenBillboard"].height;
    } else {
        return 150.0;
    }
 }
 </pre></code>

 @param billboardId a unique identifier for this billboard.
 @param billboardBundleId the bundle identifier for the bundle to which this billboard belongs.
 */
+ (CGSize)getSizeOfBillboardWithId:(NSString *)billboardId fromBillboardBundleWithId:(NSString *)billboardBundleId;
@end
