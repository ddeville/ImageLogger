
//  LLAppDelegate.m  ImageLogger
//  Created by Damien DeVille on 3/27/14.  Copyright (c) 2014 Damien DeVille. All rights reserved.

#import "LLAppDelegate.h"
#import "LLImageLogger.h"

@implementation LLAppDelegate

- (void) loadMore:(id)x {  NSOpenPanel * p = NSOpenPanel.openPanel;

  [_table unbind:NSContentBinding]; // dunno why this is necessary..  idiotic.
  [p beginSheetModalForWindow:_window
            completionHandler:^(NSInteger r) { NSError *e; NSURL *u; NSBundle *b;

    if (r != NSFileHandlingPanelOKButton || !p.URLs.count) return;

    NSLog (@"Loading %@", u = [p.URLs[0]filePathURL]);

    if (!(b = [NSBundle bundleWithURL:u])) return;

    [b preflightAndReturnError:&e] && !e ? [b load], NSLog(@"Bundle:%@", b) : NSLog(@"Error:%@", e);

    [_table bind:NSContentBinding toObject:_arrayController withKeyPath:@"arrangedObjects" options:nil];
  }];
}

- (NSArrayController*) arrayController { return _arrayController = _arrayController ?: ({

  [_arrayController = NSArrayController.new bind:NSContentArrayBinding toObject:LLImageLogger.logger withKeyPath:@"images" options:nil]; _arrayController; });
}

- (void) applicationDidFinishLaunching:(NSNotification*)n {

  [_table            bind:NSContentBinding toObject:self.arrayController withKeyPath:@"arrangedObjects"           options:nil];
  [_loadedImages     bind:NSValueBinding   toObject:_arrayController     withKeyPath:@"arrangedObjects.@count"    options:nil];
  [_numberOfCommands bind:NSValueBinding   toObject:_arrayController    withKeyPath:@"arrangedObjects.@sum.ncmds" options:nil];
  //  [_table bind:NSToolTipBinding toObject:self.arrayController withKeyPath:[NSSelectedObjectBinding stringByAppendingString:@".flags"] options:nil];
}
-(void) tableViewSelectionDidChange:(NSNotification *)n {

  NSTableView* tv = n.object;
  NSLog(@"%@",[[self.arrayController.arrangedObjects objectAtIndex:tv.selectedRow] valueForKey:@"flags"]);

}
@end

int main(int argc, const char **argv) { return NSApplicationMain(argc, argv); }
