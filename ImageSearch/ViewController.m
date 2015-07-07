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
const int BULK_SIZE = 16;
const int BATCH_SIZE = 8;

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>
@property (nonatomic, assign) CGRect mainViewFrame;
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) GoogleAPIClient *client;
@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, retain) NSMutableArray *images;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view = [self mainView];
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
    return [UIScreen mainScreen].bounds.size.width / NUM_OF_COLS - 8;
}

- (CGFloat)gridHeight {
    return self.gridWidth * 1;
}

- (UIView *)mainView {
    UIView *mainView = [[UIView alloc] initWithFrame: self.mainViewFrame];
    mainView.backgroundColor = [UIColor clearColor];
    mainView.translatesAutoresizingMaskIntoConstraints = NO;

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, SEARCHBAR_HEIGHT, [UIScreen mainScreen].bounds.size.width, SEARCHBAR_HEIGHT)];
    self.searchBar.placeholder = @"Search";
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    
    return mainView;
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
        [_collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"ImageCell"];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = NO;
    }
    return _collectionView;
}

- (void)addSubviewTree {
    [self.view addSubview:self.collectionView];
}

- (void)constrainViews {
    NSDictionary *viewsDict = @{@"collectionView":self.collectionView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:0 metrics:nil views:viewsDict]];
    
}

#pragma mark - Searchbar view methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchTerm = searchBar.text;
    [self.searchBar endEditing:YES];
    [self onRefresh];
}

#pragma mark - UICollectionViewDelegate methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    [cell setSearchResultImage:self.images[indexPath.row]];
    [cell setNeedsUpdateConstraints];
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
    self.images = nil;
    [self nextBatch];
}

- (void)nextBatch {
    [self.client searchWithTerm:self.searchTerm options:@{@"start": [NSString stringWithFormat:@"%ld", self.images.count], @"rsz": [NSString stringWithFormat:@"%d", BATCH_SIZE]} completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *imagesArray = [responseDictionary valueForKeyPath:@"responseData.results"];
        NSArray *images = [SearchResultImage imagesWithDictionaries:imagesArray];
        [self.images addObjectsFromArray:images];
        if (images.count == BATCH_SIZE && self.images.count < BULK_SIZE) {
            [self nextBatch];
            return;
        }
        [self.collectionView reloadData];
    }];
}

@end
