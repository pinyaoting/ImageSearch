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

const int NUM_OF_ROWS = 3;
const int STATUSBAR_HEIGHT = 63;
const int SEARCHBAR_HEIGHT = 44;
@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, assign) CGRect mainViewFrame;
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) GoogleAPIClient *client;
@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, strong) NSArray *images;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view = [self mainView];
    [self addSubviewTree];
    [self constrainViews];
    
    self.client = [GoogleAPIClient new];
    self.searchTerm = @"fuzzy monkey";
    
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

- (CGFloat)rowHeight {
    return ([UIScreen mainScreen].bounds.size.height - SEARCHBAR_HEIGHT) / NUM_OF_ROWS;
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

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.mainViewFrame];
        _tableView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin |
                                      UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin);
        [_tableView registerClass:[ImageCell class] forCellReuseIdentifier:@"ImageCell"];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = self.rowHeight;

    }
    return _tableView;
}

- (void)addSubviewTree {
    [self.view addSubview:self.tableView];
}

- (void)constrainViews {
    NSDictionary *viewsDict = @{@"tableView":self.tableView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|" options:0 metrics:nil views:viewsDict]];
    
}

#pragma mark - Searchbar view methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchTerm = searchBar.text;
    [self.searchBar endEditing:YES];
    [self onRefresh];
}

#pragma mark - Table view methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NUM_OF_ROWS;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
    [cell setSearchResultImage:self.images[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // implement image detail view here
}

#pragma mark - private methods

- (void)onRefresh {
    [self.client searchWithTerm:self.searchTerm completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *imagesArray = [responseDictionary valueForKeyPath:@"responseData.results"];
        self.images = [SearchResultImage imagesWithDictionaries:imagesArray];
        [self.tableView reloadData];
    }];
}

@end
