//
//  TLViewController.m
//  UICollectionView-Spring-Demo
//
//  Created by Ash Furrow on 2013-07-31.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLViewController.h"
#import "TLSpringFlowLayout.h"

@implementation TLViewController

static NSString * CellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UICollectionView Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell) return cell;
    else {
        UICollectionViewCell *otherCell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
        UIColor *tlBlue = [UIColor colorWithHue:0.5472f saturation:0.6f brightness:0.53f alpha:1.0f];
        otherCell.backgroundColor = tlBlue;
    
        return otherCell;
    }
}

@end
