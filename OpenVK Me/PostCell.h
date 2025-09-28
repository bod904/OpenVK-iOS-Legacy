//
//  PostCell.h
//  OpenVK
//
//  Created by miles on 03/03/23.
//  Copyright (c) 2023 Miles Prower. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UITextView *text;

@property (weak, nonatomic) IBOutlet UIImageView *header;

@end
