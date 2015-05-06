//
//  Config.h
//  NightCam
//
//  Created by marcel on 1/17/11.
//  Copyright 2011 ApfelCode.de (Marcel Erz). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ACGamma;
@class ConfigGeneral;

@interface Config : NSObject {
  ACGamma *screenGamma;
  ConfigGeneral *general;
}

@property(readwrite, retain) ACGamma *screenGamma;
@property(readwrite, retain) ConfigGeneral *general;

- (BOOL)loadFromDisk;
- (BOOL)saveToDisk;

@end
