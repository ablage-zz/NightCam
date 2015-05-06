//
//  PreferencesController.m
//  NightCam
//
//  Created by marcel on 1/18/11.
//  Copyright 2011 ApfelCode.de (Marcel Erz). All rights reserved.
//

#import "PreferencesController.h"

#import "Config.h"
#import "ACGamma.h"

@implementation PreferencesController

- (void)setupModes {
  switch ([[config screenGamma] mode]) {
    case 1:   [screenModes selectCellAtRow:1 column:0]; break;
    case 2:   [screenModes selectCellAtRow:2 column:0]; break;
    case 3:   [screenModes selectCellAtRow:3 column:0]; break;
    default:  [screenModes selectCellAtRow:0 column:0]; break;
  }
}

- (void)awakeFromNib {
  [self setupModes];
}

- (void)windowWillClose:(NSNotification *)notification {
  [config saveToDisk];
}


- (IBAction)screenResetClick:(id)sender {
  [[config screenGamma] resetGammaTable];
  [self setupModes];
}

- (IBAction)screenModeClick:(id)sender {
  [[config screenGamma] setMode:[[sender selectedCell] tag]];
}

@end
