//
//  HeDistributeTopicVC.m
//  yu
//
//  Created by HeDongMing on 2016/10/21.
//  Copyright © 2016年 Channce. All rights reserved.
//

#import "HeDistributeTopicVC.h"
#import "SAMTextView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TZImagePickerController.h"
#import <Photos/Photos.h>
#import "TZImageManager.h"

#define MAXUPLOADIMAGE 1
#define MAXINPUTTEXTLENGTH 64

@interface HeDistributeTopicVC ()<UITextViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,TZImagePickerControllerDelegate>
@property(strong,nonatomic)SAMTextView *recommendTextView;
@property(strong,nonatomic)IBOutlet UIButton *addPictureButton;
@property(strong,nonatomic)NSMutableArray *pictureArray;

@property(strong,nonatomic)NSMutableArray *selectedAssets;
@property(strong,nonatomic)NSMutableArray *selectedPhotos;

@property(strong,nonatomic)NSMutableArray *takePhotoArray;
@property(strong,nonatomic)IBOutlet UILabel *inputTextLengthLabel;

@end

@implementation HeDistributeTopicVC
@synthesize recommendTextView;
@synthesize addPictureButton;
@synthesize takePhotoArray;
@synthesize pictureArray;
@synthesize locationDict;
@synthesize inputTextLengthLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = APPDEFAULTTITLETEXTFONT;
        label.textColor = APPDEFAULTTITLECOLOR;
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        label.text = @"发布话题";
        [label sizeToFit];
        
        self.title = @"发布话题";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    CGFloat textViewX = 20;
    CGFloat textViewY = 20;
    CGFloat textViewW = SCREENWIDTH - 2 * textViewX;
    CGFloat textViewH = 100;
    recommendTextView = [[SAMTextView alloc] initWithFrame:CGRectMake(textViewX, textViewY, textViewW, textViewH)];
    recommendTextView.layer.borderWidth = 1.0;
    recommendTextView.layer.borderColor = APPDEFAULTORANGE.CGColor;
    recommendTextView.font = [UIFont systemFontOfSize:15.0];
    recommendTextView.textColor = [UIColor blackColor];
    recommendTextView.placeholder = @"请输入你要发布的话题";
    recommendTextView.layer.cornerRadius = 5.0;
    recommendTextView.layer.masksToBounds = YES;
    recommendTextView.delegate = self;
    [self.view addSubview:recommendTextView];
    
    UIImage *buttonIcon = [UIImage imageNamed:@"icon_put"];
    CGFloat buttonX = 0;
    CGFloat buttonY = 0;
    CGFloat buttonH = 25.0;
    CGFloat buttonW = buttonH;
    if (buttonIcon) {
        buttonW = buttonIcon.size.width * buttonH / buttonIcon.size.height;
    }
    UIButton *distributeButton = [[UIButton alloc] init];
    [distributeButton setBackgroundImage:[UIImage imageNamed:@"icon_put"] forState:UIControlStateNormal];
    [distributeButton addTarget:self action:@selector(distributeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    distributeButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
    UIBarButtonItem *distributeItem = [[UIBarButtonItem alloc] initWithCustomView:distributeButton];
    distributeItem.target = self;
    self.navigationItem.rightBarButtonItem = distributeItem;
    
    if (!_selectedPhotos) {
        _selectedPhotos = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (!_selectedAssets) {
        _selectedAssets = [[NSMutableArray alloc] initWithCapacity:0];
    }
    takePhotoArray = [[NSMutableArray alloc] initWithCapacity:0];
    pictureArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    inputTextLengthLabel.backgroundColor = [UIColor clearColor];
    inputTextLengthLabel.textColor = [UIColor grayColor];
}

- (void)distributeButtonClick:(id)sender
{
    NSLog(@"distributeButtonClick");
    NSString *content = recommendTextView.text;
    if (content == nil || [content isEqualToString:@""]) {
        [self showHint:@"请输入话题内容"];
        return;
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *latitude = [locationDict objectForKey:@"latitude"];
    if (latitude == nil) {
        latitude = @"";
    }
    NSString *longitude = [locationDict objectForKey:@"longitude"];
    if (longitude == nil) {
        longitude = @"";
    }
    AsynImageView *imageview = nil;
    UIImage *imageData = nil;
    if ([pictureArray count] > 0) {
        imageview = pictureArray[0];
        imageData = imageview.image;
        
    }
    NSString *zoneCover = @"";
    if (imageData) {
        NSData *data = UIImageJPEGRepresentation(imageData,0.2);
        NSData *base64Data = [GTMBase64 encodeData:data];
        zoneCover = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    }
    NSDictionary *commentDict = @{@"userId":userId,@"img":zoneCover,@"content":content,@"longitude":longitude,@"latitude":latitude};
    NSString *replyUrl = [NSString stringWithFormat:@"%@/topic/Releasetopic.action",BASEURL];
    [self showHudInView:self.view hint:@"发布中..."];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:replyUrl params:commentDict success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"distributeTopicSucceed" object:nil];
            [self showHint:@"发布成功"];
            [self performSelector:@selector(backToLastView) withObject:nil afterDelay:0.3];
            
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
        
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)backToLastView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addPhotoButtonClick:(id)sender
{
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
            [self mutiplepickPhotoSelect];
        }];
        
        // Add the actions.
        [alertController addAction:cameraAction];
        [alertController addAction:libAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"来自相册",@"来自拍照", nil];
        sheet.tag = 1;
        [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 1:
            {
                if (ISIOS7) {
                    NSString *mediaType = AVMediaTypeVideo;
                    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
                    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此应用没有权限访问您的照片或摄像机，请在: 隐私设置 中启用访问" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                        [alert show];
                    }else{
                        [self pickerCamer];
                    }
                }
                else{
                    [self pickerCamer];
                }
                
                
                break;
            }
            case 0:
            {
                if (ISIOS7) {
                    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
                    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
                        //无权限
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此应用没有权限访问您的照片或摄像机，请在: 隐私设置 中启用访问" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    else{
                        [self mutiplepickPhotoSelect];
                    }
                }
                else{
                    [self mutiplepickPhotoSelect];
                }
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

- (void)handleSelectPhoto
{
    for (AsynImageView *imageview in pictureArray) {
        if (imageview.imageTag != -1) {
            [pictureArray removeObject:imageview];
        }
    }
    
    for (UIImage *image in _selectedPhotos) {
        AsynImageView *asyncImage = [[AsynImageView alloc] init];
        [asyncImage setImage:image];
        asyncImage.bigImageURL = nil;
        [pictureArray addObject:asyncImage];
        
    }
    [self updateImageBG];
}

- (void)updateImageBG
{
    AsynImageView *imageView = pictureArray[0];
    [addPictureButton setImage:imageView.image forState:UIControlStateNormal];
}

- (void)mutiplepickPhotoSelect{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:MAXUPLOADIMAGE delegate:self];
    imagePickerVc.selectedAssets = _selectedAssets; // optional, 可选的
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    // Set the appearance
    // 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    
    // Set allow picking video & photo & originalPhoto or not
    // 设置是否可以选择视频/图片/原图
    // imagePickerVc.allowPickingVideo = NO;
    // imagePickerVc.allowPickingImage = NO;
    // imagePickerVc.allowPickingOriginalPhoto = NO;
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark TZImagePickerControllerDelegate



/// User finish picking photo，if assets are not empty, user picking original photo.
/// 用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    [self dismissViewControllerAnimated:YES completion:^{
        [self handleSelectPhoto];
    }];
}

/// User finish picking video,
/// 用户选择好了视频
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    [_selectedPhotos addObjectsFromArray:@[coverImage]];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self handleSelectPhoto];
    }];
    
    /*
     // open this code to send video / 打开这段代码发送视频
     [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
     NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
     // Export completed, send video here, send by outputPath or NSData
     // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
     
     }];
     */
    
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
        //        imagePicker.allowsEditing = YES;
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
    //    photoAlbumPicker.allowsEditing = YES;
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
    
    //    [self initButtonWithImage:image];
    
    AsynImageView *asyncImage = [[AsynImageView alloc] init];
    
    UIImageJPEGRepresentation(image, 0.6);
    [asyncImage setImage:image];
    
    asyncImage.bigImageURL = nil;
    asyncImage.imageTag = -1; //表明是调用系统相机、相册的
    //先删除原来旧的数据
    [pictureArray removeAllObjects];
    [pictureArray addObject:asyncImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self updateImageBG];
    }];
    
}


//相应取消动作
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(float)getSize:(CGSize)size
{
    float a = size.width / 480.0;
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

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView isFirstResponder]) {
        [textView resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@""] && range.length > 0) {
        //删除字符肯定是安全的
        return YES;
    }
    else {
        if (textView.text.length - range.length + text.length > MAXINPUTTEXTLENGTH) {
            
            return NO;
        }
        else {
            return YES;
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger currentLength = textView.text.length;
    inputTextLengthLabel.text = [NSString stringWithFormat:@"%ld/%d",currentLength,MAXINPUTTEXTLENGTH];
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
