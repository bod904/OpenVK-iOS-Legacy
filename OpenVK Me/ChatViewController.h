//
//  ChatViewController.h
//  OpenVK Me
//
//  Created by miles on 25/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet UITextField *textMessage;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic) NSInteger peerId;

- (void)appendMessages;

@end
