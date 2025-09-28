//
//  FriendCell.h
//  OpenVK Me
//
//  Created by miles on 18/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"

@interface FriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end
