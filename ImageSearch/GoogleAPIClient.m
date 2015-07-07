//
//  GoogleAPIClient.m
//  ImageSearch
//
//  Created by Pythis Ting on 7/6/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "GoogleAPIClient.h"

@implementation GoogleAPIClient

- (void)searchWithTerm:(NSString *)term completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))completionHandler {
    
    // assmble request url
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = @"https";
    components.host = @"ajax.googleapis.com";
    components.path = @"/ajax/services/search/images";
    // url encode search term
    components.query = [NSString stringWithFormat:@"v=1.0&q=%@", [term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = components.URL;

    // create request
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    // send async request
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:completionHandler];
    
}

@end

