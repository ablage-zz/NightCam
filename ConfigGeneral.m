//
//  ConfigGamma.m
//  NightCam
//
//  Created by marcel on 1/17/11.
//  Copyright 2011 ApfelCode.de (Marcel Erz). All rights reserved.
//

#import "ConfigGeneral.h"


@implementation ConfigGeneral

@synthesize openSavedMovie;

- (id)init {
	self = [super init];
	if (self != nil) {
		openSavedMovie = YES;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [self init];
	if (self != nil) {
		int version = [coder decodeIntForKey:@"version"];
    
    if (version >= 1) {
      [self setOpenSavedMovie:[coder decodeBoolForKey:@"openSavedMovie"]];
    }
	}
	return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:1 forKey:@"version"];
	[coder encodeBool:[self openSavedMovie] forKey:@"openSavedMovie"];
}

@end
