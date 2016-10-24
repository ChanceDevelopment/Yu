//
//  HeFeedbackVC.m
//  carTune
//
//  Created by Tony on 16/7/21.
//  Copyright © 2016年 Jitsun. All rights reserved.
//

#import "HeFeedbackVC.h"
#import "SAMTextView.h"
#import "UIButton+Bootstrap.h"
#import "UMFeedback.h"

@interface HeFeedbackVC ()<UITextFieldDelegate,UITextViewDelegate>
@property(strong,nonatomic)IBOutlet SAMTextView *contentTextView;
@property(strong,nonatomic)IBOutlet UIButton *commitButton;

@end

@implementation HeFeedbackVC
@synthesize contentTextView;
@synthesize commitButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        label.text = @"功能反馈";
        [label sizeToFit];
        self.title = @"功能反馈";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

- (void)initializaiton
{
    [super initializaiton];
}

- (void)initView
{
    [super initView];
    
    [commitButton defaultStyle];
    commitButton.layer.borderWidth = 1.0;
    commitButton.layer.borderColor = APPDEFAULTORANGE.CGColor;
    commitButton.layer.masksToBounds = YES;
    commitButton.layer.cornerRadius = 2.0;
    [commitButton setTitleColor:APPDEFAULTORANGE forState:UIControlStateNormal];
    
    contentTextView.placeholder = @"请献上您的宝贵意见";
    contentTextView.layer.borderWidth = 1.0;
    contentTextView.layer.borderColor = [UIColor grayColor].CGColor;
    contentTextView.layer.cornerRadius = 4.0;
    contentTextView.layer.masksToBounds = YES;
}

- (IBAction)commitAdvice:(id)sender
{
    NSString *content = contentTextView.text;
    
    if (content == nil || [content isEqualToString:@""]) {
        [self showHint:@"请写上你的宝贵意见"];
        return;
    }
    [self showHudInView:self.view hint:@"提交中..."];
    NSDictionary *feedDict = @{@"content":content};
    UMFeedback *feedback = [[UMFeedback alloc] init];
    [feedback post:feedDict completion:^(NSError *error){
        [self hideHud];
        if (error) {
            [self showHint:error.localizedDescription];
            return;
        }
        else{
            [self showHint:@"提交成功"];
            [self performSelector:@selector(backToLastView) withObject:nil afterDelay:0.3];
        }
        
    }];
    
}

- (void)backToLastView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
