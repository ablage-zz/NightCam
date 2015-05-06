//
//  AppController.m
//  NightCam
//
//  Created by marcel on 1/18/11.
//  Copyright 2011 ApfelCode.de (Marcel Erz). All rights reserved.
//

#import "AppController.h"

#import "Config.h"

@implementation AppController

- (IBAction)preferencesClick:(id)sender {
  [preferencesController showWindow:self];
}

- (IBAction)nightCamClick:(id)sender {
  [nightCamController showWindow:self];
}

- (IBAction)showHelp:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.apfelcode.de"]];
}

@end
