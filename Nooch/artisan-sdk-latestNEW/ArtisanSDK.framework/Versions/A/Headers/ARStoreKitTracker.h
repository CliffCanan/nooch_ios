//
//  ARStoreKitTracker.h
//
//  Copyright (c) 2014 Artisan Mobile. All rights reserved.
//

#import <StoreKit/StoreKit.h>


/**
 * Enables tracking Store Kit transactions.
 */
@interface ARStoreKitTracker : NSObject

/** Initialize the automatic tracking of Store Kit transactions.
 
  This should be called in the ProductRequest:didReceiveResponse: method that gets called after you
  start your SKProductsRequest. You pass in the products that are contained in the response (response.products).
  This will automatically generate analytics events for purchases and whether they succeeded or failed.
  You can call this method more than once depending on how you've implemented Store Kit in your app.  If you
  send a product a second time the new version of the product will be used for analytics reporting.
 
  This is an example of what this will look like in your app:
 
      - (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
      {
           [ARStoreKitTracker initWithSKProducts:response.products];
     
            <The rest of your handling for the product request...>
      }
 
  @param products An NSArray of SKProduct objects that were returned from the Store Kit
 */
+(void)initWithSKProducts:(NSArray *)products;

@end
