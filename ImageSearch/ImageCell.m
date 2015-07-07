//
//  ImageCell.m
//  ImageSearch
//
//  Created by Pythis Ting on 7/6/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "ImageCell.h"
#import "UIImageView+AFNetworking.h"

@interface ImageCell ()

@property (nonatomic, readwrite) UIImageView *resultImageView;

@end

@implementation ImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.frame = frame;
        [self addSubviewTree];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

#pragma mark - setup view hierachy

- (UIImageView*)resultImageView {
    if (!_resultImageView) {
        _resultImageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
        _resultImageView.contentMode = UIViewContentModeScaleToFill;
        _resultImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _resultImageView;
}

- (void)addSubviewTree {
    [self.contentView addSubview:self.resultImageView];
}

- (void)updateConstraints {
    [super updateConstraints];
    NSMutableDictionary *viewsDictionary = [NSMutableDictionary new];
    [viewsDictionary setObject:self.resultImageView forKey:@"resultImageView"];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[resultImageView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[resultImageView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
}

- (void)setSearchResultImage:(SearchResultImage *)searchResultImage {
    _searchResultImage = searchResultImage;
    
    // load thumbnail
    [self displayImage:self.searchResultImage.thumbnailURL completionHandler:^(BOOL finished) {
        // load hi-res image
        [self displayImage:self.searchResultImage.imageURL completionHandler:nil];
    }];
}

- (void)displayImage:(NSURL *)imageURL completionHandler:(void (^)(BOOL finished))completionHandler {
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5.0f];
    __weak ImageCell *this = self;
    [self.resultImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        ImageCell *that = this;
        // fade-in
        [UIView transitionWithView:that.resultImageView duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            that.resultImageView.image = image;
        } completion:completionHandler];
    } failure:nil];
}

@end
