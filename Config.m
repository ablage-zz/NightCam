//
//  Config.m
//  NightCam
//
//  Created by marcel on 1/17/11.
//  Copyright 2011 ApfelCode.de (Marcel Erz). All rights reserved.
//

#import "Config.h"

#import "ACGamma.h"
#import "ConfigGeneral.h"

@implementation Config

@synthesize screenGamma;
@synthesize general;

+ (Config *)config {
	return [[[Config alloc] init] autorelease];
}


- (id)init {
	self = [super init];
	if (self != nil) {
    [self loadFromDisk];
	}
	return self;
}
- (void)dealloc {
  [self saveToDisk];
  
  [screenGamma release];
  [general release];
  
	[super dealloc];
}


- (BOOL)loadFromDisk {
	NSDictionary * rootObject;
	NSFileManager *fm = [NSFileManager defaultManager];
	
	NSString *path = [NSString stringWithFormat:@"%@/Config.plist", [[NSBundle mainBundle] resourcePath]];
	if ([fm fileExistsAtPath:path]) {
		rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
		if (rootObject == nil) {
			NSLog(@"Could not load config from bundle.");
      [self setScreenGamma:[[[ACGamma alloc] init] autorelease]];
      [self setGeneral:[[[ConfigGeneral alloc] init] autorelease]];
			return NO;
      
		} else {
      [self setScreenGamma:[rootObject valueForKey:@"screenGamma"]];
      [self setGeneral:[rootObject valueForKey:@"general"]];
		}
	} else {
		NSLog(@"Could not find config in bundle.");
    [self setScreenGamma:[[[ACGamma alloc] init] autorelease]];
    [self setGeneral:[[[ConfigGeneral alloc] init] autorelease]];
		return NO;
	}
	
	return YES;
}
- (BOOL)saveToDisk {
	NSMutableDictionary *rootObject;
	NSString *path = [NSString stringWithFormat:@"%@/Config.plist", [[NSBundle mainBundle] resourcePath]];
  
	rootObject = [NSMutableDictionary dictionary];
  
	[rootObject setValue:[self screenGamma] forKey:@"screenGamma"];
	[rootObject setValue:[self general] forKey:@"general"];
  
	if (![NSKeyedArchiver archiveRootObject:rootObject toFile:path]) {
		NSLog(@"Could not save config to bundle.");
		return NO;
    
	} else {
    return YES;
  }
}

@end
