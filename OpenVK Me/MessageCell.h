//
//  MessageCell.h
//  OpenVK Me
//
//  Created by miles on 25/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *bubble;

@end
