//
//  ConfigGamma.h
//  NightCam
//
//  Created by marcel on 1/17/11.
//  Copyright 2011 ApfelCode.de (Marcel Erz). All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ConfigGeneral : NSObject {
  BOOL openSavedMovie;
}

@property(readwrite, assign) BOOL openSavedMovie;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

@end
