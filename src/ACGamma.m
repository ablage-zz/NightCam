//
//  ACGamma.m
//  NightCam
//
//  Created by marcel on 1/17/11.
//  Copyright 2011 ApfelCode.de (Marcel Erz). All rights reserved.
//

#import "ACGamma.h"

@implementation ACGamma

+ (int)mainDisplayId {
  return (int)CGMainDisplayID();
}

+ (ACGammaTable)getGammaTable:(int)displayId {
  CGDisplayErr cgErr;
  ACGammaTable table;
  
  cgErr = CGGetDisplayTransferByTable(displayId, 256, table.red, table.green, table.blue, &table.count);
  
  if (cgErr != kCGErrorSuccess) {
    NSLog(@"Error during CGGetDisplayTransferByTable.");
    table.valid = NO;
  } else {
    table.valid = YES;    
  }
  
  return table;
}
+ (BOOL)setGammaTable:(int)displayId withTable:(ACGammaTable)table {
  
  if (table.valid == NO) {
    NSLog(@"Invalid default gamma table.");
    return NO;
    
  } else {
    CGDisplayErr cgErr = CGSetDisplayTransferByTable(displayId, table.count, table.red, table.green, table.blue);
    
    if (cgErr != kCGErrorSuccess) {
      NSLog(@"Error during CGGetDisplayTransferByTable.");
      return NO;
    } else {
      return YES;
    }
  }
}

@synthesize defaultGammaTable;
@synthesize active;
@synthesize gain;
@synthesize mode;
@synthesize displayId;

- (id)initWithCoder:(NSCoder *)coder {
	self = [self init];
	if (self != nil) {
		int version = [coder decodeIntForKey:@"version"];
    
    if (version >= 1) {
      active = [coder decodeBoolForKey:@"active"];
      gain = [coder decodeIntForKey:@"gain"];
      mode = [coder decodeIntForKey:@"mode"];
    }
    
    [self update];
	}
	return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:1 forKey:@"version"];
	[coder encodeBool:[self active] forKey:@"active"];
	[coder encodeInt:[self gain] forKey:@"gain"];
	[coder encodeInt:[self mode] forKey:@"mode"];
}


- (id)init {
  return [self initWithDisplayId:[ACGamma mainDisplayId]];
}
- (id)initWithDisplayId:(int)displayId {
	if(self = [super init]) {
		defaultGammaTable = [ACGamma getGammaTable:[ACGamma mainDisplayId]];
    if (defaultGammaTable.valid == NO) {
      NSLog(@"Could not get default gamma table.");
    }
    gain = 50;
    active = false;
    mode = 3;
	}
	return self;
}


- (void)dealloc {
  [self resetGammaTable];
  
	[super dealloc];
}


- (void)setActive:(BOOL)value {
  active = value;
  [self update];
}
- (void)setGain:(int)value {
  gain = value;
  [self update];
}
- (void)setMode:(int)value {
  mode = value;
  [self update];
}



- (ACGammaTable)applyPropertiesOnTable:(ACGammaTable)table {
  
  if (!active) {
    return defaultGammaTable;
    
  } else {
    ACGammaTable copyTable;
    
    int paletteShift = defaultGammaTable.count * ((float)gain / 100);
    int paletteSize = ((int)(defaultGammaTable.count / 2) - abs(paletteShift - (int)(defaultGammaTable.count / 2))) * 2;
    
    float step = (float)paletteSize/table.count;
    int start = paletteShift-(int)(paletteSize/2);
    
    for(int i = 0; i < table.count; i++) {
      copyTable.red[i] = table.red[start + (int)(step * i)];
      copyTable.green[i] = table.green[start + (int)(step * i)];
      copyTable.blue[i] = table.blue[start + (int)(step * i)];
    }
    copyTable.count = table.count;
    copyTable.valid = table.valid;
    
    return copyTable;
  }
}



- (BOOL)resetGammaTable {
  [self willChangeValueForKey:@"gain"];
  gain = 50;
  [self didChangeValueForKey:@"gain"];
  
  return [self normal];
}



- (BOOL)normal {
  [self willChangeValueForKey:@"mode"];
  mode = 0;  
  [self didChangeValueForKey:@"mode"];

  return [ACGamma setGammaTable:displayId withTable:[self applyPropertiesOnTable:defaultGammaTable]];
}

- (BOOL)inverted {
  ACGammaTable table;
  
  for(int i = 0; i < defaultGammaTable.count; i++) {
    table.red[i] = defaultGammaTable.red[defaultGammaTable.count - i - 1];
    table.green[i] = defaultGammaTable.green[defaultGammaTable.count - i - 1];
    table.blue[i] = defaultGammaTable.blue[defaultGammaTable.count - i - 1];
  }
  
  table.count = defaultGammaTable.count;
  table.valid = defaultGammaTable.valid;
  
  [self willChangeValueForKey:@"mode"];
  mode = 1;
  [self didChangeValueForKey:@"mode"];

  return [ACGamma setGammaTable:displayId withTable:[self applyPropertiesOnTable:table]];
}

- (BOOL)nightVision {
  ACGammaTable table;
  
  for(int i = 0; i < defaultGammaTable.count; i++) {
    table.red[i] = defaultGammaTable.red[i];
    table.green[i] = 0;
    table.blue[i] = 0;
  }
  
  table.count = defaultGammaTable.count;
  table.valid = defaultGammaTable.valid;
  
  [self willChangeValueForKey:@"mode"];
  mode = 2;
  [self didChangeValueForKey:@"mode"];

  return [ACGamma setGammaTable:displayId withTable:[self applyPropertiesOnTable:table]];
}

- (BOOL)nightVisionInverted {
  ACGammaTable table;
  
  for(int i = 0; i < defaultGammaTable.count; i++) {
    table.red[i] = defaultGammaTable.red[defaultGammaTable.count - i - 1];
    table.green[i] = 0;
    table.blue[i] = 0;
  }
  
  table.count = defaultGammaTable.count;
  table.valid = defaultGammaTable.valid;
  
  [self willChangeValueForKey:@"mode"];
  mode = 3;
  [self didChangeValueForKey:@"mode"];
  
  return [ACGamma setGammaTable:displayId withTable:[self applyPropertiesOnTable:table]];
}


- (BOOL)update {
  if (mode == 1) {
    return [self inverted];
    
  } else if (mode == 2) {
    return [self nightVision];
    
  } else if (mode == 3) {
    return [self nightVisionInverted];
    
  } else {
    return [self normal];
  }
}

@end
