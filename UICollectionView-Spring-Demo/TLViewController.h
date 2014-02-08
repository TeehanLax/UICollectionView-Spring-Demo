//
//  TLViewController.h
//  UICollectionView-Spring-Demo
//
//  Created by Ash Furrow on 2013-07-31.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

@import UIKit;

@interface TLViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
