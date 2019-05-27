//
//  UIView+Layout.h
//  Project
//
//  Created by Aaron on 2018/5/9.
//  Copyright © 2018年 ChenYalun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (YAAutoLayout)
// 宽度和高度
- (NSLayoutConstraint *)ya_constraintHeight:(CGFloat)height;

- (NSLayoutConstraint *)ya_constraintWidth:(CGFloat)width;

- (NSArray *)ya_constraintsSize:(CGSize)size;

// 和some view的关系
- (NSLayoutConstraint *)ya_constraintCenterXEqualToView:(UIView *)view;

- (NSLayoutConstraint *)ya_constraintCenterYEqualToView:(UIView *)view;

- (NSLayoutConstraint *)ya_constraintCenterXOffset:(CGFloat)offset ToView:(UIView *)view;

- (NSLayoutConstraint *)ya_constraintCenterYOffset:(CGFloat)offset ToView:(UIView *)view;

- (NSArray *)ya_constraintsCenterEqualToView:(UIView *)view;

- (NSLayoutConstraint *)ya_constraintHeightEqualToView:(UIView *)view;

- (NSLayoutConstraint *)ya_constraintWidthEqualToView:(UIView *)view;

- (NSArray *)ya_constraintsSizeEqualToView:(UIView *)view;

- (NSLayoutConstraint *)ya_constraintTopGapToBottomOfView:(UIView *)view;

- (NSLayoutConstraint *)ya_constraintBottomGapToTopOfView:(UIView *)view;

- (NSLayoutConstraint *)ya_constraintLeftGapToRightOfView:(UIView *)view;

- (NSLayoutConstraint *)ya_constraintRightGapToLeftOfView:(UIView *)view;

- (NSLayoutConstraint *)ya_constraintTopGap:(CGFloat)top toBottomOfView:(UIView *)toView;

- (NSLayoutConstraint *)ya_constraintBottomGap:(CGFloat)bottom toTopOfView:(UIView *)toView;

- (NSLayoutConstraint *)ya_constraintLeftGap:(CGFloat)left toRightOfView:(UIView *)toView;

- (NSLayoutConstraint *)ya_constraintRightGap:(CGFloat)right toLeftOfView:(UIView *)toView;

// 和superview的关系
- (NSArray *)ya_constraintsTopEqualToSuperView;

- (NSArray *)ya_constraintsBottomEqualToSuperView;

- (NSArray *)ya_constraintsLeftEqualToSuperView;

- (NSArray *)ya_constraintsRightEqualToSuperView;

- (NSArray *)ya_constraintsTopInSuperView:(CGFloat)top;

- (NSArray *)ya_constraintsBottomInSuperView:(CGFloat)bottom;

- (NSArray *)ya_constraintsLeftInSuperView:(CGFloat)left;

- (NSArray *)ya_constraintsRightInSuperView:(CGFloat)right;

- (NSArray *)ya_constraintsFillWidthInSuperView;

- (NSArray *)ya_constraintsFillHeightInSuperView;

- (NSArray *)ya_constraintsFillSizeInSuperView ;


@end
