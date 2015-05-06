//
//  NightCamController.h
//  NightCam
//
//  Created by marcel on 1/17/11.
//  Copyright 2011 ApfelCode.de (Marcel Erz). All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

@class UVCCameraControl;
@class Config;

@interface NightCamController : NSWindowController {
	UVCCameraControl *cameraControl;
  
	QTCaptureSession *session;

	QTCaptureDeviceInput *videoDeviceInput;
  QTCaptureMovieFileOutput *movieFileOutput;
  
  QTCaptureDevice *videoDevice;
	
  NSArray *videoDevices;
  
  IBOutlet Config *config;
  
	IBOutlet QTCaptureView *captureView;
	
	IBOutlet NSButton *autoExposureCheckBox;
	IBOutlet NSButton *autoWhiteBalanceCheckBox;
  
	IBOutlet NSSlider *exposureSlider;
	IBOutlet NSSlider *gainSlider;
	IBOutlet NSSlider *brightnessSlider;
	IBOutlet NSSlider *contrastSlider;
	IBOutlet NSSlider *saturationSlider;
	IBOutlet NSSlider *sharpnessSlider;
	IBOutlet NSSlider *whiteBalanceSlider;
}

- (NSArray *)videoDevices;

- (QTCaptureDevice *)selectedVideoDevice;
- (void)setSelectedVideoDevice:(QTCaptureDevice *)selectedVideoDevice;

- (void)refreshDevices;

// Capture and recording
- (QTCaptureSession *)session;

- (BOOL)hasRecordingDevice;
- (BOOL)isRecording;
- (void)setRecording:(BOOL)recording;

// Media format summary
- (NSString *)mediaFormatSummary;

// Device controls
- (QTCaptureDevice *)controllableDevice;
- (BOOL)isDevicePlaying;
- (void)setDevicePlaying:(BOOL)playing;
- (IBAction)stopDevice:(id)sender;
- (BOOL)isDeviceRewinding;
- (void)setDeviceRewinding:(BOOL)rewinding;
- (BOOL)isDeviceFastforwarding;
- (void)setDeviceFastforwarding:(BOOL)fastforwarding;

// Camera settings
- (IBAction)sliderMoved:(id)sender;
- (IBAction)checkBoxChanged:(id)sender;

@end
