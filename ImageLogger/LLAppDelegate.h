//
//  LLAppDelegate.h
//  ImageLogger
//
//  Created by Damien DeVille on 3/27/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//@class LLImageLogger;
@interface LLAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTableView *table;
@property (assign) IBOutlet NSTextField *numberOfCommands, *loadedImages;
@property (nonatomic) NSArrayController *arrayController;
@property NSPopover *pop;
- (IBAction) loadMore:(id)x;

@end

//@property (assign) IBOutlet NSPathControl *path;
