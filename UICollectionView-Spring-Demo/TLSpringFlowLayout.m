//
//  TLSpringFlowLayout.m
//  UICollectionView-Spring-Demo
//
//  Created by Ash Furrow on 2013-07-31.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLSpringFlowLayout.h"

@interface TLSpringFlowLayout ()

/// The dynamic animator used to animate the collection's bounce
@property (nonatomic, strong, readwrite) UIDynamicAnimator *dynamicAnimator;

// Needed for tiling
@property (nonatomic, strong) NSMutableSet *visibleIndexPathsSet;
@property (nonatomic, strong) NSMutableSet *visibleHeaderAndFooterSet;
@property (nonatomic, assign) CGFloat latestDelta;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

@end

@implementation TLSpringFlowLayout

- (instancetype)init {
    self = [super init];
    if (self){
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setup];
    }
    return self;
}

- (void)setup {
    _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    _visibleIndexPathsSet = [NSMutableSet set];
    _visibleHeaderAndFooterSet = [[NSMutableSet alloc] init];
}

- (void)prepareLayout {
    [super prepareLayout];
    
    if ([[UIApplication sharedApplication] statusBarOrientation] != self.interfaceOrientation) {
        [self.dynamicAnimator removeAllBehaviors];
        self.visibleIndexPathsSet = [NSMutableSet set];
    }
    
    self.interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // Need to overflow our actual visible rect slightly to avoid flickering.
    CGRect visibleRect = CGRectInset((CGRect){.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size}, -100, -100);
    
    NSArray *itemsInVisibleRectArray = [super layoutAttributesForElementsInRect:visibleRect];
    
    NSSet *itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:@"indexPath"]];
    
    // Step 1: Remove any behaviours that are no longer visible.
    NSArray *noLongerVisibleBehaviours = [self.dynamicAnimator.behaviors filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behaviour, NSDictionary *bindings) {
        return [itemsIndexPathsInVisibleRectSet containsObject:[[[behaviour items] firstObject] indexPath]] == NO;
    }]];
    
    [noLongerVisibleBehaviours enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        [self.dynamicAnimator removeBehavior:obj];
        [self.visibleIndexPathsSet removeObject:[[[obj items] firstObject] indexPath]];
        [self.visibleHeaderAndFooterSet removeObject:[[[obj items] firstObject] indexPath]];
    }];
    
    // Step 2: Add any newly visible behaviours.
    // A "newly visible" item is one that is in the itemsInVisibleRect(Set|Array) but not in the visibleIndexPathsSet
    NSArray *newlyVisibleItems = [itemsInVisibleRectArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        return (item.representedElementCategory == UICollectionElementCategoryCell ?
                [self.visibleIndexPathsSet containsObject:item.indexPath] : [self.visibleHeaderAndFooterSet containsObject:item.indexPath]) == NO;
    }]];
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger idx, BOOL *stop) {
        CGPoint center = item.center;
        UIAttachmentBehavior *springBehaviour = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:center];
        
        springBehaviour.length = 1.0f;
        springBehaviour.damping = 0.8f;
        springBehaviour.frequency = 1.0f;
        
        // If our touchLocation is not (0,0), we'll need to adjust our item's center "in flight"
        if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
            if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                CGFloat distanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
                
                CGFloat scrollResistance;
                if (self.scrollResistanceFactor) scrollResistance = distanceFromTouch / self.scrollResistanceFactor;
                else scrollResistance = distanceFromTouch / kScrollResistanceFactorDefault;
                
                if (self.latestDelta < 0) center.y += MAX(self.latestDelta, self.latestDelta*scrollResistance);
                else center.y += MIN(self.latestDelta, self.latestDelta*scrollResistance);
                
                item.center = center;
                
            } else {
                CGFloat distanceFromTouch = fabsf(touchLocation.x - springBehaviour.anchorPoint.x);
                
                CGFloat scrollResistance;
                if (self.scrollResistanceFactor) scrollResistance = distanceFromTouch / self.scrollResistanceFactor;
                else scrollResistance = distanceFromTouch / kScrollResistanceFactorDefault;
                
                if (self.latestDelta < 0) center.x += MAX(self.latestDelta, self.latestDelta*scrollResistance);
                else center.x += MIN(self.latestDelta, self.latestDelta*scrollResistance);
                
                item.center = center;
            }
        }
        
        [self.dynamicAnimator addBehavior:springBehaviour];
        if(item.representedElementCategory == UICollectionElementCategoryCell)
        {
            [self.visibleIndexPathsSet addObject:item.indexPath];
        }
        else
        {
            [self.visibleHeaderAndFooterSet addObject:item.indexPath];
        }
    }];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [self.dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *dynamicLayoutAttributes = [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
    // Check if dynamic animator has layout attributes for a layout, otherwise use the flow layouts properties. This will prevent crashing when you add items later in a performBatchUpdates block (e.g. triggered by NSFetchedResultsController update)
    return (dynamicLayoutAttributes)?dynamicLayoutAttributes:[super layoutAttributesForItemAtIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    UIScrollView *scrollView = self.collectionView;
    
    CGFloat delta;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) delta = newBounds.origin.y - scrollView.bounds.origin.y;
    else delta = newBounds.origin.x - scrollView.bounds.origin.x;
    
    self.latestDelta = delta;
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            CGFloat distanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
            
            CGFloat scrollResistance;
            if (self.scrollResistanceFactor) scrollResistance = distanceFromTouch / self.scrollResistanceFactor;
            else scrollResistance = distanceFromTouch / kScrollResistanceFactorDefault;
            
            UICollectionViewLayoutAttributes *item = [springBehaviour.items firstObject];
            CGPoint center = item.center;
            if (delta < 0) center.y += MAX(delta, delta*scrollResistance);
            else center.y += MIN(delta, delta*scrollResistance);
            
            item.center = center;
            
            [self.dynamicAnimator updateItemUsingCurrentState:item];
        } else {
            CGFloat distanceFromTouch = fabsf(touchLocation.x - springBehaviour.anchorPoint.x);
            
            CGFloat scrollResistance;
            if (self.scrollResistanceFactor) scrollResistance = distanceFromTouch / self.scrollResistanceFactor;
            else scrollResistance = distanceFromTouch / kScrollResistanceFactorDefault;
            
            UICollectionViewLayoutAttributes *item = [springBehaviour.items firstObject];
            CGPoint center = item.center;
            if (delta < 0) center.x += MAX(delta, delta*scrollResistance);
            else center.x += MIN(delta, delta*scrollResistance);
            
            item.center = center;
            
            [self.dynamicAnimator updateItemUsingCurrentState:item];
        }
    }];
    
    return NO;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger idx, BOOL *stop) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            if([self.dynamicAnimator layoutAttributesForCellAtIndexPath:updateItem.indexPathAfterUpdate])
            {
                return;
            }
            
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:updateItem.indexPathAfterUpdate];
            
            //attributes.frame = CGRectMake(10, updateItem.indexPathAfterUpdate.item * 310, 300, 44); // or some other initial frame
            
            UIAttachmentBehavior *springBehaviour = [[UIAttachmentBehavior alloc] initWithItem:attributes attachedToAnchor:attributes.center];
            
            springBehaviour.length = 1.0f;
            springBehaviour.damping = 0.8f;
            springBehaviour.frequency = 1.0f;
            [self.dynamicAnimator addBehavior:springBehaviour];
        }
    }];
}

@end
