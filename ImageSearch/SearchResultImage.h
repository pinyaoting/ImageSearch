//
//  SearchResultImage.h
//  ImageSearch
//
//  Created by Pythis Ting on 7/6/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@interface SearchResultImage : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSURL* imageURL;
@property (nonatomic, copy, readonly) NSURL* thumbnailURL;

+ (NSArray *)imagesWithDictionaries:(NSArray *)dictionaries;

@end
