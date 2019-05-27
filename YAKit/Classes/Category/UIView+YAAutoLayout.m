//
//  UIView+Layout.m
//  Project
//
//  Created by Aaron on 2018/5/9.
//  Copyright © 2018年 ChenYalun. All rights reserved.
//

#import "UIView+YAAutoLayout.h"

@implementation UIView (YAAutoLayout)
#pragma mark - 宽度和高度

- (NSLayoutConstraint *)ya_constraintHeight:(CGFloat)height {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0f constant:height];
}

- (NSLayoutConstraint *)ya_constraintWidth:(CGFloat)width {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:width];
}

- (NSArray *)ya_constraintsSize:(CGSize)size {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return @[[self ya_constraintHeight:size.height], [self ya_constraintWidth:size.width]];
}

#pragma mark - 和some view的关系

- (NSLayoutConstraint *)ya_constraintCenterXEqualToView:(UIView *)view {
    return [self ya_constraintCenterXOffset:0 ToView:view];
}

- (NSLayoutConstraint *)ya_constraintCenterYEqualToView:(UIView *)view {
    return [self ya_constraintCenterYOffset:0 ToView:view];
}

- (NSLayoutConstraint *)ya_constraintCenterXOffset:(CGFloat)offset ToView:(UIView *)view {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:offset];
}

- (NSLayoutConstraint *)ya_constraintCenterYOffset:(CGFloat)offset ToView:(UIView *)view {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:offset];
}

- (NSArray *)ya_constraintsCenterEqualToView:(UIView *)view {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return @[[self ya_constraintCenterXEqualToView:view], [self ya_constraintCenterYEqualToView:view]];
}

- (NSLayoutConstraint *)ya_constraintHeightEqualToView:(UIView *)view {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
}

- (NSLayoutConstraint *)ya_constraintWidthEqualToView:(UIView *)view {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
}

- (NSArray *)ya_constraintsSizeEqualToView:(UIView *)view {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return @[[self ya_constraintHeightEqualToView:view], [self ya_constraintWidthEqualToView:view]];
}

- (NSLayoutConstraint *)ya_constraintTopGapToBottomOfView:(UIView *)view {
    return [self ya_constraintTopGap:0 toBottomOfView:view];
}

- (NSLayoutConstraint *)ya_constraintBottomGapToTopOfView:(UIView *)view {
    return [self ya_constraintBottomGap:0 toTopOfView:view];
}

- (NSLayoutConstraint *)ya_constraintLeftGapToRightOfView:(UIView *)view {
    return [self ya_constraintLeftGap:0 toRightOfView:view];
}

- (NSLayoutConstraint *)ya_constraintRightGapToLeftOfView:(UIView *)view {
    return [self ya_constraintRightGap:0 toLeftOfView:view];
}

- (NSLayoutConstraint *)ya_constraintTopGap:(CGFloat)top toBottomOfView:(UIView *)toView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:toView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:top];
}

- (NSLayoutConstraint *)ya_constraintBottomGap:(CGFloat)bottom toTopOfView:(UIView *)toView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:toView attribute:NSLayoutAttributeTop multiplier:1.0f constant:-bottom];
}

- (NSLayoutConstraint *)ya_constraintLeftGap:(CGFloat)left toRightOfView:(UIView *)toView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:toView attribute:NSLayoutAttributeRight multiplier:1.0f constant:-left];
}

- (NSLayoutConstraint *)ya_constraintRightGap:(CGFloat)right toLeftOfView:(UIView *)toView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:toView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:right];
}

#pragma mark - 和superview的关系

- (NSArray *)ya_constraintsTopEqualToSuperView {
    return [self ya_constraintsTopInSuperView:0];
}

- (NSArray *)ya_constraintsBottomEqualToSuperView {
    return [self ya_constraintsBottomInSuperView:0];
}

- (NSArray *)ya_constraintsLeftEqualToSuperView {
    return [self ya_constraintsLeftInSuperView:0];
}

- (NSArray *)ya_constraintsRightEqualToSuperView {
    return [self ya_constraintsRightInSuperView:0];
}

- (NSArray *)ya_constraintsTopInSuperView:(CGFloat)top {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *selfView = self;
    return [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[selfView]" options:0 metrics:@{@"top":@(top)} views:NSDictionaryOfVariableBindings(selfView)];
}

- (NSArray *)ya_constraintsBottomInSuperView:(CGFloat)bottom {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *selfView = self;
    return [NSLayoutConstraint constraintsWithVisualFormat:@"V:[selfView]-(bottom)-|" options:0 metrics:@{@"bottom":@(bottom)} views:NSDictionaryOfVariableBindings(selfView)];
}

- (NSArray *)ya_constraintsLeftInSuperView:(CGFloat)left {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *selfView = self;
    return [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[selfView]" options:0 metrics:@{@"left":@(left)} views:NSDictionaryOfVariableBindings(selfView)];
}

- (NSArray *)ya_constraintsRightInSuperView:(CGFloat)right {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *selfView = self;
    return [NSLayoutConstraint constraintsWithVisualFormat:@"H:[selfView]-(right)-|" options:0 metrics:@{@"right":@(right)} views:NSDictionaryOfVariableBindings(selfView)];
}

- (NSArray *)ya_constraintsFillWidthInSuperView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *selfView = self;
    return [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[selfView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(selfView)];
}

- (NSArray *)ya_constraintsFillHeightInSuperView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *selfView = self;
    return [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[selfView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(selfView)];
}

- (NSArray *)ya_constraintsFillSizeInSuperView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray *resultConstraints = [[NSMutableArray alloc] init];
    [resultConstraints addObjectsFromArray:[self ya_constraintsFillWidthInSuperView]];
    [resultConstraints addObjectsFromArray:[self ya_constraintsFillHeightInSuperView]];
    return resultConstraints;
}

@end
