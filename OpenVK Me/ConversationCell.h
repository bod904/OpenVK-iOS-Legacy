//
//  ConversationCell.h
//  OpenVK Me
//
//  Created by miles on 21/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *text;

@end
