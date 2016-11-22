//
//  HeDistributeView.m
//  huobao
//
//  Created by HeDongMing on 14-7-4.
//  Copyright (c) 2014年 何 栋明. All rights reserved.
//

#import "HeComplaintUserVC.h"
#import "ScanPictureView.h"
#import "AppDelegate.h"
#import "UIButton+Bootstrap.h"
#import "TKAddressBook.h"
#import "UMFeedback.h"

@interface HeComplaintUserVC ()
@property(strong,nonatomic)NSMutableArray *dataSource;

@end

@implementation HeComplaintUserVC
@synthesize distributeTable;
@synthesize distributeTF;
@synthesize headerBGView;
@synthesize addPictureButton;
@synthesize pictureArray;
@synthesize loadSucceedFlag;
@synthesize buttonArray;
@synthesize dataSource;
@synthesize fzid;
@synthesize userNick;

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
        label.text = @"投诉用户";
        [label sizeToFit];
        self.navigationItem.titleView = label;
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataSource = [[NSMutableArray alloc] initWithObjects:@"色情",@"欺诈骗钱",@"色情",@"广告骚扰",@"敏感信息",@"侵权",nil];
    [self initializaiton];
    [self initView];
    
}

-(void)initializaiton
{
    [super initializaiton];
    buttonArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < 5; i++) {
        TKAddressBook *book = [[TKAddressBook alloc] init];
        book.rowSelected = NO;
        if (i == 0) {
            book.rowSelected = YES;
        }
        [buttonArray addObject:book];
    }
    
    pictureArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    addPictureButton = [[UIButton alloc] init];
    [addPictureButton setBackgroundImage:[UIImage imageNamed:@"加图片图标.png"] forState:UIControlStateNormal];
    [addPictureButton setBackgroundImage:[UIImage imageNamed:@"加图片图标高亮.png"] forState:UIControlStateHighlighted];
    addPictureButton.tag = -1;
    addPictureButton.frame = CGRectMake(10, 5, 70, 70);
    [addPictureButton addTarget:self action:@selector(addPictureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *distributeItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(distributeNews:)];
    distributeItem.tintColor = [UIColor whiteColor];
    if (!ISIOS7) {
        distributeItem.tintColor = [UIColor redColor];
    }
    distributeItem.target = self;
    distributeItem.action = @selector(distributeNews:);
    self.navigationItem.rightBarButtonItem = distributeItem;
    
    
    
}

-(void)backTolastView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)finish:(id)sender
{
    
}

-(void)deleteImageAtIndex:(int)index
{
    [pictureArray removeAllObjects];
    addPictureButton.tag = -1;
    [addPictureButton setImage:[UIImage imageNamed:@"icon_add_pho"] forState:UIControlStateNormal];
    
}

-(void)addPictureButtonClick:(id)sender
{
    if ([distributeTF isFirstResponder]) {
        [distributeTF resignFirstResponder];
    }
    
    if (addPictureButton.tag == 1) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (AsynImageView *asyImage in pictureArray) {
            if (asyImage.highlightedImage == nil) {
                [array addObject:asyImage];
            }
        }
        int index = 1;
        
        ScanPictureView *scanPictureView = [[ScanPictureView alloc] initWithArray:array selectButtonIndex:index];
        scanPictureView.deleteDelegate = self;
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
        [backButton setTintColor:[UIColor colorWithRed:65.0f/255.0f green:164.0f/255.0f blue:220.0f/255.0f alpha:1.0f]];
        self.navigationItem.backBarButtonItem = backButton;
        scanPictureView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:scanPictureView animated:YES];
        return;
    }
    if (ISIOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        // Create the actions.
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            //取消
        }];
        
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"打开照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self pickerCamer];
        }];
        
        UIAlertAction *libAction = [UIAlertAction actionWithTitle:@"从手机相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self pickerPhotoLibrary];
        }];
        
        // Add the actions.
        [alertController addAction:cameraAction];
        [alertController addAction:libAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
    sheet.tag = 1;
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 0:
            {
                [self pickerCamer];
                break;
            }
            case 1:
            {
                [self pickerPhotoLibrary];
                break;
            }
            case 2:
            {
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark ImagePicker method
//从相册中打开照片选择画面(图片库)：UIImagePickerControllerSourceTypePhotoLibrary
//启动摄像头打开照片摄影画面(照相机)：UIImagePickerControllerSourceTypeCamera

//按下相机触发事件
-(void)pickerCamer
{
    //照相机类型
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    //判断属性值是否可用
    if([UIImagePickerController isSourceTypeAvailable:sourceType]){
        //UIImagePickerController是UINavigationController的子类
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        //设置可以编辑
        imagePicker.allowsEditing = YES;
        //设置类型为照相机
        imagePicker.sourceType = sourceType;
        //进入照相机画面
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

//当按下相册按钮时触发事件
-(void)pickerPhotoLibrary
{
    //图片库类型
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *photoAlbumPicker = [[UIImagePickerController alloc] init];
    photoAlbumPicker.delegate = self;
    photoAlbumPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    //设置可以编辑
    photoAlbumPicker.allowsEditing = YES;
    //设置类型
    photoAlbumPicker.sourceType = sourceType;
    //进入图片库画面
    [self presentViewController:photoAlbumPicker animated:YES completion:nil];
}


#pragma mark -
#pragma mark imagePickerController method
//当拍完照或者选取好照片之后所要执行的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CGSize sizeImage = image.size;
    float a = [self getSize:sizeImage];
    if (a>0) {
        CGSize size = CGSizeMake(sizeImage.width/a, sizeImage.height/a);
        image = [self scaleToSize:image size:size];
    }
    
    [self initButtonWithImage:image];
    
    AsynImageView *asyncImage = [[AsynImageView alloc] init];
    
    UIImageJPEGRepresentation(image, 0.8);
    [asyncImage setImage:image];
    asyncImage.bigImageURL = nil;
    [pictureArray addObject:asyncImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


//相应取消动作
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initButtonWithImage:(UIImage *)image
{
    
    CGSize sizeImage = image.size;
    CGFloat width = sizeImage.width;
    CGFloat hight = sizeImage.height;
    CGFloat standarW = width;
    CGRect frame = CGRectMake(0, hight - width, standarW, standarW);
    
    if (width > hight) {
        standarW = hight;
        
        frame = CGRectMake(0, 0, standarW, standarW);
    }
    //截取图片
    UIImage *jiequImage = [self imageFromImage:image inRect:frame];
    //    CGSize jiequSize = jiequImage.size;
    
    
    addPictureButton.tag = 1;
    [addPictureButton setImage:jiequImage forState:UIControlStateNormal];
}

- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}

-(float)getSize:(CGSize)size
{
    float a = size.width/480;
    if (a > 1) {
        return a;
    }
    else
        return -1;
    
    
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

-(void)initView
{
    [super initView];
    headerBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 60)];
    headerBGView.backgroundColor = [UIColor whiteColor];
    
    distributeTable.tableHeaderView = headerBGView;
    [Tool setExtraCellLineHidden:distributeTable];
    
    CGFloat distributeX = 10;
    CGFloat distributeY = 5;
    CGFloat distributeW = SCREENWIDTH - 2 * distributeX;
    CGFloat distributeH = 50 - 2 * distributeY;
    
    distributeTF = [[UITextField alloc] initWithFrame:CGRectMake(distributeX, distributeY, distributeW, distributeH)];
    distributeTF.font = [UIFont systemFontOfSize:16.0];
    distributeTF.textColor = [UIColor blackColor];
    distributeTF.placeholder = @"请输入投诉详情";
    [headerBGView addSubview:distributeTF];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

-(void)distributeNews:(id)sender
{
    NSString *content = distributeTF.text;
    if ([content isEqualToString:@""] || content == nil) {
        [self showHint:@"请输入投诉内容"];
        return;
    }
    if ([buttonArray count] == 0) {
        [self showHint:@"请选择图片作为投诉凭证"];
    }
    [self showHudInView:self.distributeTable hint:@"提交中..."];
    NSDictionary *feedDict = @{@"content":content};
    
    UMFeedback *feedback = [[UMFeedback alloc] init];
    __block HeComplaintUserVC *weakSelf = self;
    [feedback post:feedDict completion:^(NSError *error){
        [self hideHud];
        if (error) {
            [weakSelf showHint:error.localizedDescription];
            return;
        }
        else{
            [weakSelf distributePicture:nil];
        }
        
    }];
//    [self performSelector:@selector(distributePicture:) withObject:nil afterDelay:0.8];
    
}

-(void)distributePicture:(id)sender
{
    [self showHint:@"提交成功，我们会安排客服第一时间处理"];
    [self performSelector:@selector(backTolastView) withObject:nil afterDelay:0.8];
}

- (void)backTolastView
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)distributeText:(NSDictionary *)dic
{
    
}

-(void)requestSucceedWithDic:(NSDictionary *)receiveDic
{
    self.loadSucceedFlag = 1;
    NSString *stateStr = [receiveDic objectForKey:@"state"];
    if (stateStr == nil || [stateStr isMemberOfClass:[NSNull class]]) {
        stateStr = @"-1";
    }
    int stateid = [stateStr intValue];
    if (stateid != 1) {
        NSString *msg = [receiveDic objectForKey:@"msg"];
        if ([msg isMemberOfClass:[NSNull class]] || msg == nil) {
            msg = @"投诉出错，请重试";
        }
        [self showHint:msg];
        //        [self showTipLabelWith:msg];
        return;
    }
    if (uploadType == 1) {
        NSDictionary *dic = [receiveDic objectForKey:@"result"];
        [self distributeText:dic];
        return;
    }
    if (uploadType == 2) {
        [self showHint:@"你的投诉我们会24小时内处理"];
        //        [self showTipLabelWith:@"你的投诉我们会24小时内处理"];
        [self performSelector:@selector(backTolastView:) withObject:nil afterDelay:1.0];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 5;
    }
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [[NSString alloc] initWithFormat:@"被投诉人：%@，请选择投诉原因",userNick];
//        @"请选择投诉原因";
    }
    return @"请选择上传图片";
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"Cell";
    UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        
        //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    switch (section) {
        case 0:
        {
            TKAddressBook *book = [buttonArray objectAtIndex:row];
            if (book.rowSelected) {
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkBox.png"]];
                
            }
            else{
                cell.accessoryView = nil;
            }
            switch (row) {
                case 0:
                {
                    
                    cell.textLabel.text = @"色情";
                    break;
                }
                case 1:
                {
                    cell.textLabel.text = @"欺诈骗钱";
                    break;
                }
                case 2:
                {
                    cell.textLabel.text = @"广告骚扰";
                    break;
                }
                case 3:
                {
                    cell.textLabel.text = @"敏感信息";
                    break;
                }
                case 4:
                {
                    cell.textLabel.text = @"侵权";
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1:
        {
            [cell.contentView addSubview:addPictureButton];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    switch (section) {
        case 0:
        {
            return 50;
            break;
        }
        case 1:
        {
            return 100;
            break;
        }
        default:
            break;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch (section) {
        case 0:
        {
            TKAddressBook *book = [buttonArray objectAtIndex:row];
            book.rowSelected = !book.rowSelected;
            if (book.rowSelected) {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkBox.png"]];
                book.name = [self.dataSource objectAtIndex:row];
            }
            else{
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.accessoryView = nil;
                book.name = nil;
            }
            break;
        }
        default:
            break;
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
