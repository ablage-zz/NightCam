//
//  PreferencesController.h
//  NightCam
//
//  Created by marcel on 1/18/11.
//  Copyright 2011 ApfelCode.de (Marcel Erz). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Config;

@interface PreferencesController : NSWindowController {
  IBOutlet Config *config;
  
  IBOutlet NSMatrix *screenModes;
  IBOutlet NSButtonCell *screenModeNone;
  IBOutlet NSButtonCell *screenModeInverted;
  IBOutlet NSButtonCell *screenModeNightVision;
  IBOutlet NSButtonCell *screenModeNightVisionInverted;
}

- (IBAction)screenResetClick:(id)sender;
- (IBAction)screenModeClick:(id)sender;

@end
