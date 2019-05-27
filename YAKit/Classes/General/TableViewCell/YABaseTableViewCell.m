//
//  YABaseTableViewCell.m
//  YAArrayDataSource
//
//  Created by Aaron on 2018/5/7.
//  Copyright © 2018年 ChenYalun. All rights reserved.
//

#import "YABaseTableViewCell.h"

@implementation YABaseTableViewCell
#pragma mark - Life cycle
+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

#pragma mark - Private methods
- (void)setup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
@end
