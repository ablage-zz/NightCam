//
//  ACGamma.h
//  NightCam
//
//  Created by marcel on 1/17/11.
//  Copyright 2011 ApfelCode.de (Marcel Erz). All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

typedef struct {
  BOOL valid;
  CGGammaValue red[256];
  CGGammaValue green[256];
  CGGammaValue blue[256];
  CGTableCount count;
} ACGammaTable;

@interface ACGamma : NSObject {
  ACGammaTable defaultGammaTable;
  
  BOOL active;
  int gain;
  int mode;
  int displayId;
}

+ (int)mainDisplayId;

+ (ACGammaTable)getGammaTable:(int)displayId;
+ (BOOL)setGammaTable:(int)displayId withTable:(ACGammaTable)table;  

@property(readonly) ACGammaTable defaultGammaTable;
@property(readwrite, assign) BOOL active;
@property(readwrite, assign) int gain;
@property(readwrite, assign) int mode;
@property(readwrite, assign) int displayId;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

- (id)initWithDisplayId:(int)displayId;

- (BOOL)resetGammaTable;

- (BOOL)normal;
- (BOOL)inverted;
- (BOOL)nightVision;
- (BOOL)nightVisionInverted;

- (BOOL)update;

@end
