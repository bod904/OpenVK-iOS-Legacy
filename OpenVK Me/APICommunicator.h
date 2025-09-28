//
//  APICommunicator.h
//  OpenVK Me
//
//  Created by miles on 15/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APICommunicator : NSObject
+ (NSString *) getServerVersion;
+ (NSDictionary *) callMethod:(NSString *)method params:(NSArray *)params;
+ (NSString *) getToken:(NSString *)login password:(NSString *)password twofaCode:(NSString *)twofaCode;
+ (NSDictionary *) getBadges;
+ (NSDictionary *) getConversationInfo:(NSInteger)peerId;
+ (NSDictionary *) getCurrentUserInfo;
+ (NSDictionary *) getNewsfeed:(NSString *)next;
@end
