//
//  TLSpringFlowLayout.m
//  UICollectionView-Spring-Demo
//
//  Created by Ash Furrow on 2013-07-31.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLSpringFlowLayout.h"

@interface TLSpringFlowLayout ()

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

@end

@implementation TLSpringFlowLayout

-(id)init {
    if (!(self = [super init])) return nil;
    
    self.minimumInteritemSpacing = 10;
    self.minimumLineSpacing = 10;
    self.itemSize = CGSizeMake(300, 44);
    self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    
    return self;
}

-(void)prepareLayout {
    [super prepareLayout];
    
    CGSize contentSize = self.collectionView.contentSize;
    NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0.0f, 0.0f, contentSize.width, contentSize.height)];
    
    if (items.count > 0 && self.dynamicAnimator.behaviors.count == 0) {
        
        [items enumerateObjectsUsingBlock:^(id<UIDynamicItem> obj, NSUInteger idx, BOOL *stop) {
            UIAttachmentBehavior *springBehaviour = [[UIAttachmentBehavior alloc] initWithItem:obj attachedToAnchor:[obj center]];
            
            springBehaviour.length = 0.0f;
            springBehaviour.damping = 0.8f;
            springBehaviour.frequency = 1.0f;
            
            [self.dynamicAnimator addBehavior:springBehaviour];
        }];
    }
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [self.dynamicAnimator itemsInRect:rect];
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    UIScrollView *scrollView = self.collectionView;
    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
        CGPoint anchorPoint = springBehaviour.anchorPoint;
        CGFloat distanceFromTouch = fabsf(touchLocation.y - anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / 1500.0f;
        
        UICollectionViewLayoutAttributes *item = [springBehaviour.items firstObject];
        CGPoint center = item.center;
        if (delta < 0) {
            center.y += MAX(delta, delta*scrollResistance);
        }
        else {
            center.y += MIN(delta, delta*scrollResistance);
        }
        item.center = center;
        
        [self.dynamicAnimator updateItemUsingCurrentState:item];
    }];
    
    return NO;
}

@end
