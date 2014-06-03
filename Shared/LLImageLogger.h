//
//  LLImageLogger.h
//  ImageLogger
//
//  Created by Damien DeVille on 3/27/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

@import Foundation;

#define NEW_IMAGES_LOADED_NOTIFICATION @"⚠️🚥🚧"

@interface LLMachImage : NSObject
@property (readonly,copy) NSString *name, *path, *filetype, *extension;
@property (readonly) NSUInteger warningLevel, ncmds;
@property (readonly) id icon;
@end

@interface LLImageLogger : NSObject

+ (NSMutableArray*)images;

@end
