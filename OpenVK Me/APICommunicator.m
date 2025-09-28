//
//  APICommunicator.m
//  OpenVK Me
//
//  Created by miles on 15/08/22.
//  Copyright (c) 2022 Miles Prower. All rights reserved.
//

#import "APICommunicator.h"

@implementation APICommunicator

+ (NSDictionary *) callMethod:(NSString *)method params:(NSArray *)params {
    NSString *URL = @"";
    
    NSInteger selectedInstance = [NSUserDefaults.standardUserDefaults integerForKey:@"selectedInstance"];
    NSArray *instances = [NSUserDefaults.standardUserDefaults arrayForKey:@"instances"];
    
    NSString *instanceURL = [instances[selectedInstance] valueForKey:@"serverURL"];
    NSInteger isHTTPS = [[instances[selectedInstance] valueForKey:@"isHTTPS"] integerValue];
    
    if(isHTTPS == 1) {
        URL = [URL stringByAppendingString:@"https://"];
    } else {
        URL = [URL stringByAppendingString:@"http://"];
    }
    
    URL = [URL stringByAppendingString:instanceURL];
    URL = [URL stringByAppendingString:@"/method/"];
    URL = [URL stringByAppendingString:method];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setURL:[NSURL URLWithString:URL]];
    
    NSString *httpparams = @"";
    
    for (id param in params) {
        httpparams = [httpparams stringByAppendingFormat:@"%@=%@&", param[0], param[1]];
    }
    
    httpparams = [httpparams stringByAppendingFormat:@"%@=%@&", @"access_token", [NSUserDefaults.standardUserDefaults stringForKey:@"token"]];
    NSLog(@"%@", httpparams);
    
    NSData *postData = [httpparams dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [request setHTTPBody:postData];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if (error == nil) {
        NSError *errorJSON = nil;
        id object = [NSJSONSerialization
                     JSONObjectWithData:oResponseData options:0 error:&errorJSON];
    
        if (!errorJSON && [object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = object;
            if ([responseCode statusCode] == 200) {
                return [response objectForKey:@"response"];
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

+ (NSString *) getToken:(NSString *)login password:(NSString *)password twofaCode:(NSString *)twofaCode{
    NSString *URL = @"";
    
    NSInteger selectedInstance = [NSUserDefaults.standardUserDefaults integerForKey:@"selectedInstance"];
    NSArray *instances = [NSUserDefaults.standardUserDefaults arrayForKey:@"instances"];
    
    NSString *instanceURL = [instances[selectedInstance] valueForKey:@"serverURL"];
    NSInteger isHTTPS = [[instances[selectedInstance] valueForKey:@"isHTTPS"] integerValue];
    
    if(isHTTPS == 1) {
        URL = [URL stringByAppendingString:@"https://"];
    } else {
        URL = [URL stringByAppendingString:@"http://"];
    }
    
    URL = [URL stringByAppendingString:instanceURL];
    URL = [URL stringByAppendingString:@"/token?2fa_supported=1&client_name=openvk_legacy_ios&grant_type=password&username=&1&password=&2"];
    URL = [URL stringByReplacingOccurrencesOfString:@"&1" withString:login];
    URL = [URL stringByReplacingOccurrencesOfString:@"&2" withString:password];
    if (twofaCode != nil) {
        URL = [URL stringByAppendingString:@"&code=&3"];
        URL = [URL stringByReplacingOccurrencesOfString:@"&3" withString:twofaCode];
    }
    
    NSMutableURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if (error == nil || error.code == -1012) {
        NSError *errorJSON = nil;
        id object = [NSJSONSerialization
                     JSONObjectWithData:oResponseData options:0 error:&errorJSON];
    
        if (!errorJSON && [object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = object;
            if ([responseCode statusCode] == 200) {
                [NSUserDefaults.standardUserDefaults setValue:[response objectForKey:@"access_token"] forKey:@"token"];
                [NSUserDefaults.standardUserDefaults setValue:[response objectForKey:@"user_id"] forKey:@"userID"];
                return [response objectForKey:@"access_token"];
            } else if ([[response objectForKey:@"error"] isEqual: @"need_validation"]) {
                return [response objectForKey:@"error"];
            } else {
                return @"invalid_password";
            }
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}


+ (NSString *) getServerVersion{
    NSString *version = [[self callMethod:@"ovk.version" params:nil] objectForKey:@"response"];
    return version;
}

+ (NSDictionary *) getBadges{
    NSDictionary *response = [APICommunicator callMethod:@"Account.getCounters" params:NULL];
    return response;
}

+ (NSDictionary *) getConversationInfo:(NSInteger)peerId {
    NSDictionary *response = [APICommunicator callMethod:@"Messages.getConversationsById" params:@[@[@"peer_ids", @(peerId)], @[@"extended", @(1)], @[@"fields", @"photo_50"]]];
    return response;
}

+ (NSDictionary *) getCurrentUserInfo {
    NSDictionary *users = [APICommunicator callMethod:@"Users.get" params:@[@[@"user_ids", @([NSUserDefaults.standardUserDefaults integerForKey:@"userID"])], @[@"fields", @"photo_100"]]];
    if ([users isKindOfClass:[NSArray class]]) {
        NSArray *response = (NSArray*)users;
        NSLog(@"%@", response);
        
        return [response objectAtIndex:0];
    } else {
        return 0;
    }
}

+ (NSDictionary *) getNewsfeed:(id)next {
    NSMutableArray *params = [NSMutableArray array];
    [params addObject:@[@"extended", @"1"]];
    [params addObject:@[@"count", @"15"]];
    
    if (next != nil) {
        NSString *nextStr = [NSString stringWithFormat:@"%@", next]; // convert NSNumber or NSString
        [params addObject:@[@"start_from", nextStr]];
    }
    
    return [APICommunicator callMethod:@"Newsfeed.get" params:params];
}



@end
