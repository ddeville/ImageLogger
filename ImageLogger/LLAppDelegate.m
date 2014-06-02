#import "LLAppDelegate.h"
#import "LLImageLogger.h"

@interface CautionRow : NSTableRowView @end
@implementation CautionRow
- (void) drawBackgroundInRect:(NSRect)d { [super drawBackgroundInRect:d]; [NSColor.redColor set]; NSRectFill(d);  }
@end
//
//  LLAppDelegate.m
//  ImageLogger
//
//  Created by Damien DeVille on 3/27/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//


@implementation LLAppDelegate

- (IBAction) loadSomething:(id)x  {

  NSBundle *b = [NSBundle bundleWithPath:@"~/Library/Frameworks/AtoZ.framework"];
  NSError *e;
  BOOL ok = [b preflightAndReturnError:&e];
  if(ok && !e) [b load];
  else NSLog(@"Error:%@", e);

}
- (void)awakeFromNib {

  [_table setDelegate:self];
  [_images setContent:NSMutableArray.new];
  [LLImageLogger.images enumerateObjectsUsingBlock:^(NSMutableDictionary*d, NSUInteger idx, BOOL *stop) {
    NSMutableDictionary *m = d.mutableCopy; NSBundle *b = nil;
    id ext; NSString *eFind = d[@"path"];
    while (eFind.length > 1 && !ext)
      if (!(ext = eFind.pathExtension.length ? eFind.pathExtension : nil))
        eFind = eFind.stringByDeletingLastPathComponent;
    m[@"icon"] = !!ext ? [NSWorkspace.sharedWorkspace iconForFileType:ext]
                       : [NSImage.alloc initByReferencingFile:[b = [NSBundle bundleWithPath:d[@"path"]] pathForImageResource:[b objectForInfoDictionaryKey:@"CFBundleIconFile"]]]
                      ?: [NSImage imageNamed:NSImageNameCaution];
  [_images addObject:m];
  }];
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
