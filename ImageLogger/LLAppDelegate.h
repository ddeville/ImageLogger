//
//  LLAppDelegate.h
//  ImageLogger
//
//  Created by Damien DeVille on 3/27/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LLAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate>


@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSPathControl *path;
@property (assign) IBOutlet NSTableView *table;

@property (readonly) NSArray *images;

- (IBAction) loadMore:(id)x;

@end
