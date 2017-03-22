//
//  IDCaptureSessionPipelineViewController.m
//  VideoCaptureDemo
//
//  Created by Adriaan Stellingwerff on 9/04/2015.
//  Copyright (c) 2015 Infoding. All rights reserved.
//

#import "IDCaptureSessionPipelineViewController.h"
#import "IDCaptureSessionAssetWriterCoordinator.h"
#import "IDCaptureSessionMovieFileOutputCoordinator.h"
#import "IDFileManager.h"
#import "IDPermissionsManager.h"

//TODO: add backgrounding stuff

@interface IDCaptureSessionPipelineViewController () <IDCaptureSessionCoordinatorDelegate>

@property (nonatomic, strong) IDCaptureSessionCoordinator *captureSessionCoordinator;
@property (nonatomic, weak) UIBarButtonItem *recordButton;

@property (nonatomic, assign) BOOL recording;
@property (nonatomic, assign) BOOL dismissing;


@end

@implementation IDCaptureSessionPipelineViewController


- (void)setupWithPipelineMode:(PipelineMode)mode
{
    //Let's check permissions for microphone and camera access before we get started
    [self checkPermissions];
    
    switch (mode) {
        case PipelineModeMovieFileOutput:
            _captureSessionCoordinator = [IDCaptureSessionMovieFileOutputCoordinator new];
            break;
        case PipelineModeAssetWriter:
            _captureSessionCoordinator = [IDCaptureSessionAssetWriterCoordinator new];
            break;
        default:
            break;
    }
    [_captureSessionCoordinator setDelegate:self callbackQueue:dispatch_get_main_queue()];
    [self configureInterface];
}


- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    
    
    CGSize size = self.view.frame.size;
    // 创建一个工具条，并设置它的大小和位置
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 20, size.width, 46)];
    // 设置工具条的style
    [toolbar setBarStyle:UIBarStyleDefault];
    
    // 创建使用文本标题的UIBarButtonItem
    UIBarButtonItem* leftItem = [[UIBarButtonItem alloc] initWithTitle:@"close" style:UIBarButtonItemStylePlain target:self action:@selector(closeCamera:)];
    [leftItem setTag:1];
    
    // 创建使用系统图标的UIBarButtonItem
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithTitle:@"record" style:UIBarButtonItemStylePlain target:self  action:@selector(toggleRecording:)];
    self.recordButton = rightItem;
    [rightItem setTag:3];
    // 为工具条设置工具按钮
    NSArray* barButtonItems = [NSArray arrayWithObjects:leftItem,rightItem, nil];
    
    [toolbar setItems:barButtonItems animated:YES];
    // 将工具条添加到当前应用的界面中
    [self.view addSubview:toolbar];
    
}

- (IBAction)toggleRecording:(id)sender
{
    if(_recording){
        [_captureSessionCoordinator stopRecording];
    } else {
        // Disable the idle timer while recording
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        self.recordButton.enabled = NO; // re-enabled once recording has finished starting
        self.recordButton.title = @"Stop";
        
        [self.captureSessionCoordinator startRecording];
        
        _recording = YES;
    }
}

- (IBAction)closeCamera:(id)sender
{
    //TODO: tear down pipeline
    if(_recording){
        _dismissing = YES;
        [_captureSessionCoordinator stopRecording];
    } else {
        [self stopPipelineAndDismiss];
    }
}

#pragma mark - Private methods

- (void)configureInterface
{
    AVCaptureVideoPreviewLayer *previewLayer = [_captureSessionCoordinator previewLayer];
    previewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    
    [_captureSessionCoordinator startRunning];
}

- (void)stopPipelineAndDismiss
{
    [_captureSessionCoordinator stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
    _dismissing = NO;
}

- (void)checkPermissions
{
    IDPermissionsManager *pm = [IDPermissionsManager new];
    [pm checkCameraAuthorizationStatusWithBlock:^(BOOL granted) {
        if(!granted){
            NSLog(@"we don't have permission to use the camera");
        }
    }];
    [pm checkMicrophonePermissionsWithBlock:^(BOOL granted) {
        if(!granted){
            NSLog(@"we don't have permission to use the microphone");
        }
    }];
}

#pragma mark = IDCaptureSessionCoordinatorDelegate methods

- (void)coordinatorDidBeginRecording:(IDCaptureSessionCoordinator *)coordinator
{
    _recordButton.enabled = YES;
}

- (void)coordinator:(IDCaptureSessionCoordinator *)coordinator didFinishRecordingToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    _recordButton.title = @"Record";
    _recording = NO;
    
    //Do something useful with the video file available at the outputFileURL
    IDFileManager *fm = [IDFileManager new];
    [fm copyFileToCameraRoll:outputFileURL];
    
    
    //Dismiss camera (when user taps cancel while camera is recording)
    if(_dismissing){
        [self stopPipelineAndDismiss];
    }
}

@end
