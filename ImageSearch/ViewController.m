//
//  ViewController.m
//  ImageSearch
//
//  Created by Pythis Ting on 7/6/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "ViewController.h"
#import "ImageCell.h"
#import "GoogleAPIClient.h"

const int NUM_OF_COLS = 3;
const int SEARCHBAR_HEIGHT = 44;
const int BULK_SIZE = 24;
const int BATCH_SIZE = 8;
const int ASPECT_RATIO = 1;

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) GoogleAPIClient *client;
@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, strong) NSMutableArray *images;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSearchBar];
    [self addSubviewTree];
    [self constrainViews];
    
    self.client = [GoogleAPIClient new];
    self.searchTerm = @"flowers";
    
    [self onRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup view hierachy

- (CGRect)mainViewFrame {
    return [[UIScreen mainScreen] bounds];
}

- (CGFloat)gridWidth {
    return [UIScreen mainScreen].bounds.size.width / NUM_OF_COLS - 12;
}

- (CGFloat)gridHeight {
    return self.gridWidth * ASPECT_RATIO;
}

- (UICollectionViewFlowLayout *)flowLayout {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(self.gridWidth, self.gridHeight)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    return flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.mainViewFrame collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [_collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"ImageCell"];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = NO;
    }
    return _collectionView;
}

- (void)setupSearchBar {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, SEARCHBAR_HEIGHT, [UIScreen mainScreen].bounds.size.width, SEARCHBAR_HEIGHT)];
    self.searchBar.placeholder = @"Search";
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
}

- (void)addSubviewTree {
    [self.view addSubview:self.collectionView];
}

- (void)constrainViews {
    NSDictionary *viewsDict = @{@"collectionView":self.collectionView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[collectionView]-8-|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[collectionView]-8-|" options:0 metrics:nil views:viewsDict]];
    
}

#pragma mark - Searchbar view methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.images = nil;
    self.searchTerm = searchBar.text;
    [self.searchBar endEditing:YES];
    [self onRefresh];
}

#pragma mark - Collection view methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    [cell setSearchResultImage:self.images[indexPath.row]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    // implement image detail view here
}

#pragma mark - private methods

- (NSMutableArray *)images {
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (void)onRefresh {
    [self nextBatch];
}

- (void)nextBatch {
    [self.client searchWithTerm:self.searchTerm options:@{@"start": [NSString stringWithFormat:@"%ld", self.images.count], @"rsz": [NSString stringWithFormat:@"%d", BATCH_SIZE]} completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *imagesArray = [responseDictionary valueForKeyPath:@"responseData.results"];

        // end of search result, no more images can be returned from API
        if (!imagesArray || imagesArray.count < BATCH_SIZE) {
            return;
        }
        
        NSArray *images = [SearchResultImage imagesWithDictionaries:imagesArray];
        [self.images addObjectsFromArray:images];
        [self.collectionView reloadData];
        
        if (self.images.count < BULK_SIZE) {
            [self nextBatch];
        }
    }];
}

@end
