//
//  MessageCell.m
//  OpenVK Me
//
//  Created by miles on 25/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    if ([self.contentView subviews]) {
        for (UIView *subview in [self.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }
}


@end
