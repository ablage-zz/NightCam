//
//  NightCamController.m
//  NightCamvideoDeviceInput
//
//  Created by marcel on 1/17/11.
//  Copyright 2011 ApfelCode.de (Marcel Erz). All rights reserved.
//

#import "NightCamController.h"

#import "UVCCameraControl.h"
#import "Config.h"
#import "ConfigGeneral.h"

@implementation NightCamController

+ (NSSet *)keyPathsForValuesAffectingHasRecordingDevice {
	return [NSSet setWithObjects:@"selectedVideoDevice", nil];
}

+ (NSSet *)keyPathsForValuesAffectingControllableDevice {
	return [NSSet setWithObjects:@"selectedVideoDevice", nil];
}

+ (NSSet *)keyPathsForValuesAffectingMediaFormatSummary {
	return [NSSet setWithObjects:@"selectedVideoDevice", nil];
}


- (void)windowWillClose:(NSNotification *)notification {
  [config saveToDisk];
}


- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];

	[session stopRunning];
	[session release];

	[videoDeviceInput release];
	[movieFileOutput release];

	[videoDevices release];

  [cameraControl release];
  
	[super dealloc];
}

- (void)awakeFromNib {
    
	// Create a capture session
	session = [[QTCaptureSession alloc] init];
	
	// Setup capture view
	[captureView setCaptureSession:session];
  [captureView setDelegate:self];
  
	// Attach outputs to session
	movieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
	[movieFileOutput setDelegate:self];
  [session addOutput:movieFileOutput error:nil];
	
	// Select devices if any exist
	NSArray *myVideoDevices = [self videoDevices];
	if ([myVideoDevices count] > 0) {
		[self setSelectedVideoDevice:[myVideoDevices objectAtIndex:0]];
	}
  
  // Set session
	[session startRunning];
  
	// Register for notifications
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(devicesDidChange:) name:QTCaptureDeviceWasConnectedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(devicesDidChange:) name:QTCaptureDeviceWasDisconnectedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFormatWillChange:) name:QTCaptureConnectionFormatDescriptionWillChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFormatDidChange:) name:QTCaptureConnectionFormatDescriptionDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAttributeWillChange:) name:QTCaptureDeviceAttributeWillChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAttributeDidChange:) name:QTCaptureDeviceAttributeDidChangeNotification object:nil];

  [self showWindow:nil];
}


- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	// Do nothing
}

- (void)devicesDidChange:(NSNotification *)notification {
	[self refreshDevices];
}

- (void)refreshDevices {
	[self willChangeValueForKey:@"videoDevices"];
	[videoDevices release];
	videoDevices = [[[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo] arrayByAddingObjectsFromArray:[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeMuxed]] retain];
	[self didChangeValueForKey:@"videoDevices"];
	
	if (![videoDevices containsObject:[self selectedVideoDevice]]) {
		[self setSelectedVideoDevice:nil];
	}
}

- (NSArray *)videoDevices {
	if (!videoDevices) [self refreshDevices];
	return videoDevices;
}

- (QTCaptureDevice *)selectedVideoDevice {
	return [videoDeviceInput device];
}

- (void)setSelectedVideoDevice:(QTCaptureDevice *)selectedVideoDevice {
  // Remove the old device input from the session and close the device
	if (videoDeviceInput) {
		[session removeInput:videoDeviceInput];
		[[videoDeviceInput device] close];
		[videoDeviceInput release];
		videoDeviceInput = nil;
	}
	
	if (selectedVideoDevice) {
		NSError *error = nil;
		BOOL success;
		
		// Try to open the new device
		success = [selectedVideoDevice open:&error];
		if (!success) {
			[[NSAlert alertWithError:error] beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
			return;
		}
		
		// Create a device input for the device and add it to the session
		videoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:selectedVideoDevice];
		
		success = [session addInput:videoDeviceInput error:&error];
		if (!success) {
			[[NSAlert alertWithError:error] beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
			[videoDeviceInput release];
			videoDeviceInput = nil;
    } else {
      // Setup camera-control
      UInt32 locationID = 0;
      sscanf([[selectedVideoDevice uniqueID] UTF8String], "0x%8x", &locationID);
      
      cameraControl = [[UVCCameraControl alloc] initWithLocationID:locationID];
      [cameraControl setAutoExposure:YES];
      [cameraControl setAutoWhiteBalance:YES];
      
			//[selectedVideoDevice close];
		}
	}
}

- (QTCaptureSession *)session {
	return session;
}

- (BOOL)hasRecordingDevice {
	return (videoDeviceInput != nil);
}

- (BOOL)isRecording {
  return ([movieFileOutput outputFileURL] != nil);
}

- (void)setRecording:(BOOL)recording {
  if (recording != [self isRecording]) {
    if (recording) {
			// Record to a temporary file, which the user will relocate when recording is finished
			char *tempNameBytes = tempnam([NSTemporaryDirectory() fileSystemRepresentation], "QTRecorder_");
			NSString *tempName = [[[NSString alloc] initWithBytesNoCopy:tempNameBytes length:strlen(tempNameBytes) encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
      
			[movieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:[tempName stringByAppendingPathExtension:@"mov"]]];
    } else {
      [movieFileOutput recordToOutputFileURL:nil];
    }
  }
}


- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didOutputSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection {
  
}

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput willStartRecordingToOutputFileAtURL:(NSURL *)fileURL forConnections:(NSArray *)connections {
	NSLog(@"Will start recording to %@", [fileURL description]);
}

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL forConnections:(NSArray *)connections {
	NSLog(@"Did start recording to %@", [fileURL description]);
}

- (BOOL)captureOutput:(QTCaptureFileOutput *)captureOutput shouldChangeOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error {
	NSLog(@"Should change file due to error %@", [error description]);
	
	return NO;
}

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput mustChangeOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error {
	NSLog(@"Must change file due to error %@", [error description]);
}

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput willFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error {
	NSLog(@"Will finish recording to %@ due to error %@", [outputFileURL description], [error description]);
	
	// This delegate method may not be called on the main thread, so do all UI updates using performSelectorOnMainThread:
	[self performSelectorOnMainThread:@selector(willFinishRecording) withObject:nil waitUntilDone:NO];
}


- (void)willFinishRecording {
	[self willChangeValueForKey:@"recording"];
}

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error {
	NSLog(@"Recorded:\n%llu Bytes\n%@ Duration", [captureOutput recordedFileSize], QTStringFromTime([captureOutput recordedDuration]));
  
	[self didChangeValueForKey:@"recording"];
	
	if (error && ![[[error userInfo] objectForKey:QTErrorRecordingSuccesfullyFinishedKey] boolValue]) {
		[[NSAlert alertWithError:error] beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
		return;
	}
	
  // Move the recorded temporary file to a user-specified location
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  
  [savePanel setRequiredFileType:@"mov"];
  [savePanel setCanSelectHiddenExtension:YES];
  [savePanel beginSheetForDirectory:nil file:nil modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo:[outputFileURL retain]]; // The output URL will be released by the delegate method
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	NSURL *outputFileURL = [(NSURL *)contextInfo autorelease];	// Was retained when the sheet was opened
	
  if (returnCode == NSOKButton) {
		NSString *filename = [sheet filename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
      [[NSFileManager defaultManager] removeItemAtPath:filename error:nil];
    }
		[[NSFileManager defaultManager] moveItemAtPath:[outputFileURL path] toPath:filename error:nil];
    
    if ([config.general openSavedMovie]) {
      [[NSWorkspace sharedWorkspace] openFile:filename];
    }
  } else {
		[[NSFileManager defaultManager] removeItemAtPath:[outputFileURL path] error:nil];
	}
}


- (NSString *)mediaFormatSummary {
	if (!videoDeviceInput)
		return nil;
	
	NSMutableString *mediaFormatSummary = [NSMutableString stringWithCapacity:0];
	
	NSEnumerator *videoConnectionEnumerator = [[videoDeviceInput connections] objectEnumerator];
	QTCaptureConnection *videoConnection;
	while ((videoConnection = [videoConnectionEnumerator nextObject])) {
		[mediaFormatSummary appendString:[[videoConnection formatDescription] localizedFormatSummary]];
		[mediaFormatSummary appendString:@"\n"];
	}
	
	return mediaFormatSummary;
}


- (void)connectionFormatWillChange:(NSNotification *)notification {
	id owner = [[notification object] owner];
	if (owner == videoDeviceInput) {
		[self willChangeValueForKey:@"mediaFormatSummary"];
	}
}

- (void)connectionFormatDidChange:(NSNotification *)notification {
	id owner = [[notification object] owner];
	if (owner == videoDeviceInput) {
		[self didChangeValueForKey:@"mediaFormatSummary"];
	}
}


- (QTCaptureDevice *)controllableDevice {
  QTCaptureDevice *selectedVideoDevice = [self selectedVideoDevice];
	
  if (selectedVideoDevice) {
    // Make sure that the the device has AVC transport controls
    if (![selectedVideoDevice attributeForKey:QTCaptureDeviceAVCTransportControlsAttribute] || [selectedVideoDevice attributeIsReadOnly:QTCaptureDeviceAVCTransportControlsAttribute]) {
      selectedVideoDevice = nil;
    }
  }
  
  return selectedVideoDevice;
}

- (BOOL)isDevicePlaying {
	NSDictionary *transportControls = [[self controllableDevice] attributeForKey:QTCaptureDeviceAVCTransportControlsAttribute];
	
	if (transportControls) {
		QTCaptureDeviceAVCTransportControlsSpeed speed = [[transportControls objectForKey:QTCaptureDeviceAVCTransportControlsSpeedKey] longValue];
		QTCaptureDeviceAVCTransportControlsPlaybackMode playbackMode = [[transportControls objectForKey:QTCaptureDeviceAVCTransportControlsPlaybackModeKey] unsignedLongValue];
		
		return ((speed == QTCaptureDeviceAVCTransportControlsNormalForwardSpeed) && (playbackMode == QTCaptureDeviceAVCTransportControlsPlayingMode));
	}
	
	return NO;
}

- (void)setDevicePlaying:(BOOL)playing {
	QTCaptureDevice *device = [self controllableDevice];
	
	if (device != nil) {
		QTCaptureDeviceAVCTransportControlsSpeed speed = playing ? QTCaptureDeviceAVCTransportControlsNormalForwardSpeed : QTCaptureDeviceAVCTransportControlsStoppedSpeed;
		
		NSDictionary *attr = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithLong:speed], QTCaptureDeviceAVCTransportControlsSpeedKey,
                          [NSNumber numberWithUnsignedLong:QTCaptureDeviceAVCTransportControlsPlayingMode], QTCaptureDeviceAVCTransportControlsPlaybackModeKey,
                          nil];
		
		[device setAttribute:attr forKey:QTCaptureDeviceAVCTransportControlsAttribute];
	}
}

- (IBAction)stopDevice:(id)sender {
	QTCaptureDevice* device = [self controllableDevice];
	
	if (device != nil) {
		NSDictionary *attr = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithLong:QTCaptureDeviceAVCTransportControlsStoppedSpeed], QTCaptureDeviceAVCTransportControlsSpeedKey,
                          [NSNumber numberWithUnsignedLong:QTCaptureDeviceAVCTransportControlsNotPlayingMode], QTCaptureDeviceAVCTransportControlsPlaybackModeKey,
                          nil];
		
		[device setAttribute:attr forKey:QTCaptureDeviceAVCTransportControlsAttribute];
	}
}

- (BOOL)isDeviceRewinding {
	NSDictionary *transportControls = [[self controllableDevice] attributeForKey:QTCaptureDeviceAVCTransportControlsAttribute];
	
	if (transportControls) {
		QTCaptureDeviceAVCTransportControlsSpeed speed = [[transportControls objectForKey:QTCaptureDeviceAVCTransportControlsSpeedKey] longValue];
		
		switch (speed) {
      case QTCaptureDeviceAVCTransportControlsSlowestReverseSpeed:
      case QTCaptureDeviceAVCTransportControlsVerySlowReverseSpeed:
      case QTCaptureDeviceAVCTransportControlsSlowReverseSpeed:
      case QTCaptureDeviceAVCTransportControlsNormalReverseSpeed:
      case QTCaptureDeviceAVCTransportControlsFastReverseSpeed:
      case QTCaptureDeviceAVCTransportControlsVeryFastReverseSpeed:
      case QTCaptureDeviceAVCTransportControlsFastestReverseSpeed:
        return YES;
      default:
        return NO;
		}
	}
	
	return NO;
}

- (void)setDeviceRewinding:(BOOL)rewinding {
	QTCaptureDevice* device = [self controllableDevice];
	
	if (device != nil) {
		QTCaptureDeviceAVCTransportControlsSpeed speed = rewinding ? QTCaptureDeviceAVCTransportControlsFastReverseSpeed : QTCaptureDeviceAVCTransportControlsStoppedSpeed;
    
		// Preserve the playback mode already set for the device
		NSDictionary *originalAttr = [device attributeForKey:QTCaptureDeviceAVCTransportControlsAttribute];
		NSNumber *playbackMode = [originalAttr objectForKey:QTCaptureDeviceAVCTransportControlsPlaybackModeKey];
		
		NSDictionary *attr = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithLong:speed], QTCaptureDeviceAVCTransportControlsSpeedKey,
                          playbackMode, QTCaptureDeviceAVCTransportControlsPlaybackModeKey,
                          nil];
		
		[device setAttribute:attr forKey:QTCaptureDeviceAVCTransportControlsAttribute];
	}
}

- (BOOL)isDeviceFastforwarding {
	NSDictionary *transportControls = [[self controllableDevice] attributeForKey:QTCaptureDeviceAVCTransportControlsAttribute];
	
	if (transportControls) {
		QTCaptureDeviceAVCTransportControlsSpeed speed = [[transportControls objectForKey:QTCaptureDeviceAVCTransportControlsSpeedKey] longValue];
		
		switch (speed) {
      case QTCaptureDeviceAVCTransportControlsSlowestForwardSpeed:
      case QTCaptureDeviceAVCTransportControlsVerySlowForwardSpeed:
      case QTCaptureDeviceAVCTransportControlsSlowForwardSpeed:
      case QTCaptureDeviceAVCTransportControlsFastForwardSpeed:
      case QTCaptureDeviceAVCTransportControlsVeryFastForwardSpeed:
      case QTCaptureDeviceAVCTransportControlsFastestForwardSpeed:
        return YES;
      default:
        return NO;
		}
	}
	
	return NO;
}

- (void)setDeviceFastforwarding:(BOOL)fastforwarding {
	QTCaptureDevice* device = [self controllableDevice];
	
	if (device != nil) {
		QTCaptureDeviceAVCTransportControlsSpeed speed = fastforwarding ? QTCaptureDeviceAVCTransportControlsFastForwardSpeed : QTCaptureDeviceAVCTransportControlsStoppedSpeed;
		
		// Preserve the playback mode already set for the device
		NSDictionary *originalAttr = [device attributeForKey:QTCaptureDeviceAVCTransportControlsAttribute];
		NSNumber *playbackMode = [originalAttr objectForKey:QTCaptureDeviceAVCTransportControlsPlaybackModeKey];
		
		NSDictionary *attr = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithLong:speed], QTCaptureDeviceAVCTransportControlsSpeedKey,
                          playbackMode, QTCaptureDeviceAVCTransportControlsPlaybackModeKey,
                          nil];
		
		[device setAttribute:attr forKey:QTCaptureDeviceAVCTransportControlsAttribute];
	}
}


- (void)deviceAttributeWillChange:(NSNotification *)notification {
	if (([notification object] == [self controllableDevice]) && [[[notification userInfo] objectForKey:QTCaptureDeviceChangedAttributeKey] isEqualToString:QTCaptureDeviceAVCTransportControlsAttribute]) {
		[self willChangeValueForKey:@"devicePlaying"];
		[self willChangeValueForKey:@"deviceFastforwarding"];
		[self willChangeValueForKey:@"deviceRewinding"];
	}
}

- (void)deviceAttributeDidChange:(NSNotification *)notification {
	if (([notification object] == [self controllableDevice]) && [[[notification userInfo] objectForKey:QTCaptureDeviceChangedAttributeKey] isEqualToString:QTCaptureDeviceAVCTransportControlsAttribute]) {
		[self didChangeValueForKey:@"devicePlaying"];
		[self didChangeValueForKey:@"deviceFastforwarding"];
		[self didChangeValueForKey:@"deviceRewinding"];
	}
}


- (IBAction)sliderMoved:(id)sender {
  if([sender isEqualTo:exposureSlider]) {		
		[cameraControl setExposure:exposureSlider.floatValue];
    
	} else if([sender isEqualTo:gainSlider]) {
		[cameraControl setGain:gainSlider.floatValue];
    
	} else if([sender isEqualTo:brightnessSlider]) {
		[cameraControl setBrightness:brightnessSlider.floatValue];
    
	} else if([sender isEqualTo:contrastSlider]) {
		[cameraControl setContrast:contrastSlider.floatValue];
    
	} else if([sender isEqualTo:saturationSlider]) {
		[cameraControl setSaturation:saturationSlider.floatValue];
    
	} else if([sender isEqualTo:sharpnessSlider]) {
		[cameraControl setSharpness:sharpnessSlider.floatValue];
    
	} else if([sender isEqualTo:whiteBalanceSlider]) {
		[cameraControl setWhiteBalance:whiteBalanceSlider.floatValue];
  }
}

- (IBAction)checkBoxChanged:(id)sender {
	
	// Auto Exposure
	if([sender isEqualTo:autoExposureCheckBox]) {
		if(autoExposureCheckBox.state == NSOnState) {
			[cameraControl setAutoExposure:YES];
			[exposureSlider setEnabled:NO];

		} else {
			[cameraControl setAutoExposure:NO];
			[exposureSlider setEnabled:YES];
			[cameraControl setExposure:exposureSlider.floatValue];
		}
	
	// Auto White Balance
  } else if([sender isEqualTo:autoWhiteBalanceCheckBox]) {
		if(autoWhiteBalanceCheckBox.state == NSOnState) {
			[cameraControl setAutoWhiteBalance:YES];
			[whiteBalanceSlider setEnabled:NO];

		} else {
			[cameraControl setAutoWhiteBalance:NO];
			[whiteBalanceSlider setEnabled:YES];
			[cameraControl setWhiteBalance:whiteBalanceSlider.floatValue];
		}
	}
}


@end
