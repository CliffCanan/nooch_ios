//
//  CollectionViewPreview.m
//  Playground
//
//  Created by Paul Colton on 11/28/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "CollectionViewPreview.h"
#import "CollectionViewController.h"
#import "CollectionViewCircleLayout.h"
#import "CollectionViewLineLayout.h"

@implementation CollectionViewPreview
{
    CollectionViewController *collectionViewController_;
}

- (void) initializeCustomController
{
    /* flow layout 
    collectionViewController_ = [[CollectionViewController alloc]
                                 initWithCollectionViewLayout:[[CollectionViewLineLayout alloc] init]];
     */
    
    collectionViewController_ = [[CollectionViewController alloc]
                                 initWithCollectionViewLayout:[[CollectionViewCircleLayout alloc] init]];
}

-(UIView *)previewView
{
    return collectionViewController_.collectionView;
}

@end

