//
//  HeRootSegmentVC.m
//  yu
//
//  Created by Tony on 16/8/29.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeRootSegmentVC.h"
#import "HeUserVC.h"
#import "HeDiscoverVC.h"
#import "HeNewsVC.h"
#import "HeChatVC.h"

@interface HeRootSegmentVC ()<UISearchBarDelegate>
@property(strong,nonatomic)UISearchBar *searchBar;

@end

@implementation HeRootSegmentVC
@synthesize searchBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    [self setUpAllViewController];
}

- (void)initializaiton
{
    [super initializaiton];
}

- (void)initView
{
    [super initView];
    CGFloat searchX = 30;
    CGFloat searchY = 5;
    CGFloat searchW = SCREENWIDTH - 2 * searchX;
    CGFloat searchH = SCREENHEIGH - 2 * searchY;
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(searchX, searchY, searchW, searchH)];
    searchBar.tintColor = [UIColor blueColor];
    searchBar.delegate = self;
    searchBar.barStyle = UIBarStyleDefault;
    searchBar.placeholder = @"请输入关键字";
    self.navigationItem.titleView = searchBar;
}

- (void)setUpAllViewController
{
    HeDiscoverVC *discoverVC = [[HeDiscoverVC alloc] init];
    [self addChildViewController:discoverVC];
    
    HeChatVC *newsVC = [[HeChatVC alloc] init];
    [self addChildViewController:newsVC];
    
    
    HeUserVC *userVC = [[HeUserVC alloc] init];
    [self addChildViewController:userVC];
}



- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
    NSString *searchKey = searchBar.text;
    if (searchKey == nil || [searchKey isEqualToString:@""]) {
        [self showHint:@"请输入搜索关键字"];
        return;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
