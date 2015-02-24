//
//  LSQRCodeScannerController.m
//  LayerSample
//
//  Created by Kevin Coleman on 2/14/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "ATLMQRScannerController.h"
#import <AVFoundation/AVFoundation.h>
#import "ATLMOverlayView.h"
#import "ATLMRegistrationViewController.h"
#import "ATLMLayerClient.h"
#import "ATLMUtilities.h"

@interface ATLMQRScannerController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) NSString *applicationID;

@end

@implementation ATLMQRScannerController

NSString *const ATLMDidReceiveLayerAppID = @"ATLMDidRecieveLayerAppID";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isReading = NO;
    
    [self setupCaptureSession];
    [self setupOverlay];
    [self toggleQRCapture];
}

- (void)setupOverlay
{
    ATLMOverlayView *overlayView = [[ATLMOverlayView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:overlayView];
}

- (void)setupCaptureSession
{
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        ATLMAlertWithError(error);
        return;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("appID-capture-queue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame:self.view.layer.bounds];
    [self.view.layer addSublayer:self.videoPreviewLayer];
}

- (void)toggleQRCapture
{
    if (!_isReading) {
        [self startReading];
    } else {
        [self stopReading];
    }
    _isReading = !_isReading;
}

- (void)startReading
{
    [self.captureSession startRunning];
}

-(void)stopReading
{
    [self.captureSession stopRunning];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSLog(@"Received Layer App ID: %@", metadataObj.stringValue);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self toggleQRCapture];
                if (!self.applicationID) {
                    self.applicationID = metadataObj.stringValue;
                    [self setupLayerWithAppID:self.applicationID];
                }
            });
            _isReading = NO;
        }
    }
}

- (void)setupLayerWithAppID:(NSString *)appID
{
    NSUUID *applicationID = [[NSUUID alloc] initWithUUIDString:appID];
    if (applicationID) {
        [[NSUserDefaults standardUserDefaults] setValue:appID forKey:ATLMLayerApplicationID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:ATLMDidReceiveLayerAppID object:appID];
        [self presentRegistrationViewController];
    } else {
        NSError *error = [[NSError alloc] initWithDomain:ATLMErrorDomain code:ATLMInvalidAppIDString userInfo:@{NSLocalizedDescriptionKey : @"There was an error scanning the QR code. Please try again"}];
        UIAlertView *alertView = ATLMAlertWithError(error);
        alertView.delegate = self;
    }
}

- (void)presentRegistrationViewController
{
    ATLMRegistrationViewController *controller = [[ATLMRegistrationViewController alloc] init];
    controller.applicationController = self.applicationController;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self toggleQRCapture];
}

@end
