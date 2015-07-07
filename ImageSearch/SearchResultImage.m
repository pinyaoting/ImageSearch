//
//  SearchResultImage.m
//  ImageSearch
//
//  Created by Pythis Ting on 7/6/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "SearchResultImage.h"

@interface SearchResultImage ()

@property (nonatomic, readwrite) NSURL* imageURL;
@property (nonatomic, readwrite) NSURL* thumbnailURL;

@end

@implementation SearchResultImage

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"imageURL": @"url",
             @"thumbnailURL": @"tbUrl",
             };
}

+ (NSValueTransformer *)imageURLJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *url, BOOL *success, NSError *__autoreleasing *error) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"%@", url]];
    }];
}

+ (NSValueTransformer *)thumbnailURLJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *url, BOOL *success, NSError *__autoreleasing *error) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"%@", url]];
    }];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error {
    self = [super initWithDictionary:dictionary error:error];
    if (self == nil) return nil;
    return self;
}

+ (NSArray *)imagesWithDictionaries:(NSArray *)dictionaries {
    NSMutableArray *images = [NSMutableArray array];
    
    for (NSDictionary *dictionary in dictionaries) {
        SearchResultImage *image = [MTLJSONAdapter modelOfClass:SearchResultImage.class fromJSONDictionary:dictionary error:nil];
        [images addObject:image];
    }
    
    return images;
}

@end
