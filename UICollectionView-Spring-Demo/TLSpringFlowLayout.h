//
//  TLSpringFlowLayout.h
//  UICollectionView-Spring-Demo
//
//  Created by Ash Furrow on 2013-07-31.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kScrollResistanceFactorDefault 900.0f

@interface TLSpringFlowLayout : UICollectionViewFlowLayout

/// The scrolling resistance factor determines how much bounce / resistance the collection has. A higher number is less bouncy, a lower number is more bouncy. The default is 1200.0f.
@property (nonatomic, assign) CGFloat scrollResistanceFactor;

/// The dynamic animator used to animate the collection's bounce
@property (nonatomic, strong, readonly) UIDynamicAnimator *dynamicAnimator;

@end
