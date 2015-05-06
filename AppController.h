//
//  AppController.h
//  NightCam
//
//  Created by marcel on 1/18/11.
//  Copyright 2011 ApfelCode.de (Marcel Erz). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Config;

@interface AppController : NSObject {
  IBOutlet Config *config;
  
  IBOutlet NSWindowController *preferencesController;
  IBOutlet NSWindowController *nightCamController;
}

- (IBAction)preferencesClick:(id)sender;
- (IBAction)nightCamClick:(id)sender;
- (IBAction)showHelp:(id)sender;

@end
