//
//  GoogleAPIClient.h
//  ImageSearch
//
//  Created by Pythis Ting on 7/6/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleAPIClient : NSObject

- (void)searchWithTerm:(NSString *)term options:(NSDictionary *)options completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))success;

@end
