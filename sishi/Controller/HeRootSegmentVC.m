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
#import "HeSearchInfoVC.h"

@interface HeRootSegmentVC ()<UISearchBarDelegate>
@property(strong,nonatomic)UISearchBar *searchBar;


@end

@implementation HeRootSegmentVC
@synthesize searchBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self setUpAllViewController];
    [self initView];
}

- (void)initializaiton
{
    [super initializaiton];
}

- (void)initView
{
    [super initView];
    CGFloat searchX = 10;
    CGFloat searchY = 15;
    CGFloat searchW = SCREENWIDTH - 2 * searchX;
    CGFloat searchH = 64 - 2 * searchY;
    
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(searchX, searchY, searchW, searchH)];
    searchView.layer.masksToBounds = YES;
    searchView.layer.cornerRadius = 3.0;
    searchView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:searchView.bounds];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"          搜索话题、用户";
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:15.0];
    [searchView addSubview:titleLabel];
    
    CGFloat iconW = 20;
    CGFloat iconH = 20;
    CGFloat iconX = 10;
    CGFloat iconY = (searchH - iconH) / 2.0;
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, iconY, iconW, iconH)];
    searchIcon.image = [UIImage imageNamed:@"icon_search"];
    [searchView addSubview:searchIcon];
    
    searchView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchInfo:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [searchView addGestureRecognizer:tap];
    
//    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(searchX, searchY, searchW, searchH)];
//    searchBar.tintColor = [UIColor blueColor];
//    searchBar.delegate = self;
//    searchBar.barStyle = UIBarStyleDefault;
//    searchBar.placeholder = @"请输入关键字";
    self.navigationItem.titleView = searchView;
    
    self.norColor = [UIColor whiteColor];
    self.selColor = [UIColor whiteColor];
    self.titleFont = [UIFont systemFontOfSize:20.0];
    self.isShowUnderLine = YES;
    self.underLineColor = [UIColor whiteColor];
    self.underLineH = 3.0;
    self.underLineW = SCREENWIDTH / 5.0;
    
    NSArray *titleViewArray = @[@"main_meet_select",@"main_message_select",@"main_mine_select"];
    
    [self setSelectedTitleViewArrayWith:titleViewArray size:CGSizeMake(SCREENWIDTH / 3.0, 50)];
}

- (void)searchInfo:(id)sender
{
    HeSearchInfoVC *searchInfoVC = [[HeSearchInfoVC alloc] init];
    searchInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchInfoVC animated:YES];
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
