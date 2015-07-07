//
//  GoogleAPIClient.m
//  ImageSearch
//
//  Created by Pythis Ting on 7/6/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "GoogleAPIClient.h"

@implementation GoogleAPIClient

- (void)searchWithTerm:(NSString *)term options:(NSDictionary *)options completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))completionHandler {
    
    // assmble request url
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = @"https";
    components.host = @"ajax.googleapis.com";
    components.path = @"/ajax/services/search/images";

    // url encode search term
    NSMutableArray *params = [[NSMutableArray alloc] initWithArray:@[[[NSURLQueryItem alloc] initWithName:@"v" value:@"1.0"],
                                                                     [[NSURLQueryItem alloc] initWithName:@"q" value:[term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]],
                                                                      ]];
    [options enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        // TODO: whitelist allowed params
        [params addObject:[[NSURLQueryItem alloc] initWithName:key value:[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }];
    components.queryItems = params;
    NSURL *url = components.URL;

    // create request
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    // send async request
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:completionHandler];
    
}

@end

