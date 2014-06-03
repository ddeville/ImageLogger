//
//  LLAppDelegate.m
//  ImageLogger
//
//  Created by Damien DeVille on 3/27/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import "LLAppDelegate.h"
#import "LLImageLogger.h"

@implementation LLAppDelegate

- (void) loadMore:(id)x {

  NSOpenPanel * p = NSOpenPanel.openPanel;
  [p beginSheetModalForWindow:_window
            completionHandler:^(NSInteger r) {
    if (r != NSFileHandlingPanelOKButton || !p.URLs.count) return;

    NSURL *u = p.URLs[0];
    NSLog (@"Loading %@", u.filePathURL);
    //[_path.animator setHidden:NO]; _path.URL = r
    NSError *e;
    NSBundle *b = [NSBundle bundleWithURL:u.filePathURL]; //:url.path?:@"~/Library/Frameworks/AtoZ.framework"];
      if (!b) return;
    [b preflightAndReturnError:&e] && !e ? [b load] : NSLog(@"Error:%@", e);
  }];
}

- (void) applicationDidFinishLaunching:(NSNotification *)n {

  [NSNotificationCenter.defaultCenter addObserverForName:NEW_IMAGES_LOADED_NOTIFICATION object:nil queue:NSOperationQueue.mainQueue
                                              usingBlock:^(NSNotification *n) {
//    [self willChangeValueForKey:@"images"];
//    [self didChangeValueForKey:@"images"];
//    NSBeep();
     [_table reloadData];
  }];

}
- (void)awakeFromNib {


  [self bind:@"images" toObject:LLImageLogger.class withKeyPath:@"images" options:nil];
//  [_table setDelegate:self];

//  [LLImageLogger.images enumerateObjectsUsingBlock:^(NSMutableDictionary*d, NSUInteger idx, BOOL *stop) {

////  [_images setContent:NSMutableArray.new];
}
//- (NSTableRowView*) tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
//
//    static NSString* const kRowIdentifier = @"Normal", *const kRowCaution = @"ci";
//
//    BOOL ok = [[_images.arrangedObjects[row]objectForKey:@"path"] rangeOfString:@"Private"].location == NSNotFound;
//
//    id rowView = [tableView makeViewWithIdentifier:ok ? kRowIdentifier:kRowCaution owner:tableView];
//    if (!rowView) {
//        // Size doesn't matter, the table will set it
////        Class k = 
//        rowView = [(ok ? NSTableRowView.class : CautionRow.class).alloc initWithFrame:NSZeroRect];
//
//        // This seemingly magical line enables your view to be found
//        // next time "makeViewWithIdentifier" is called.
//        [rowView setIdentifier: ok ? kRowIdentifier : kRowCaution];
//    }
//
//  // 'backgroundColor' isn't going to work at this point since the table
//    // Can customize properties here. Note that customizing
//    // will reset it later. Use 'didAddRow' to customize if desired.
//
//    return rowView;
//
////  return [tableView makeViewWithIdentifier:nil owner:nil];//NSTableRowView.new;//!x ? [.alloc  init] : CautionRow.new;
//}


/*      NSString *path = m[@"path"]; NSBundle *b = nil; id iconInfo = nil;
      while (path.length > 1 && !b)
        if (!(b = )) path = [path
        else m[@"archs"] = b.executableArchitectures ?: @[];
    b ? (iconInfo = )
      ?
      : <#(NSString *)#>:m[@"bundlePath"] = [b.bundlePath stringByAppendingPathComponent:d[@"name"]]]
; });
   setContent:LLImageLogger.images];
  [_logger setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"ncmds" ascending:NO]]];
- (instancetype)init {

//return self = super.init ? _logger = LLImageLogger.new, self : nil;
//}
*/
@end

int main(int argc, const char **argv)
{
	return NSApplicationMain(argc, argv);
}
