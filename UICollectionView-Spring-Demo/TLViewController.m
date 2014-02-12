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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.headerView.layer.shadowOpacity = 0.5;
    self.headerView.layer.shadowRadius = 3.8;
    self.headerView.layer.shadowOffset = CGSizeMake(0.6, 0.6);
    self.headerView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
}

#pragma mark - UICollectionView Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *otherCell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    return otherCell;
}

@end