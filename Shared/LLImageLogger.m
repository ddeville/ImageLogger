//
//  LLImageLogger.m
//  ImageLogger
//
//  Created by Damien DeVille on 3/27/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//


#import "LLImageLogger.h"

@import Darwin; @import MachO.dyld; @import MachO.loader;
#if TARGET_OS_IPHONE
#define NSImage UIImage
#else
@import AppKit;
#endif

@implementation LLMachImage @synthesize icon, extension;

- initWithDict:(NSDictionary*)d {

  return (d && (self = super.init)) ? [self setValuesForKeysWithDictionary:d], self : nil;
}

- (NSString*) extension { return extension = extension ?: ^{

  NSString *ext; if ((ext = self.path.pathExtension).length) return ext;
  NSString *pth = self.path.copy;

    for (int i = 0; i < 10 && pth.length > 1 && !ext.length; i++) {
      pth = pth.stringByDeletingLastPathComponent;
      ext = pth.pathExtension;
    }
    return ext;
  }();
}
- icon {   return icon = icon ?:  ^{ id img = nil, x, y, z;

#if !TARGET_OS_IPHONE
  img = self.extension ? [NSWorkspace.sharedWorkspace iconForFileType:extension]
                       : [NSImage imageNamed:NSImageNameCaution];
#endif
  return img = [self.extension isEqualToString:@"framework"] ? [NSImage imageNamed:@"framework"] : img ?:
       (( z = [NSBundle bundleWithPath:self.path])
    &&  ( x = [z objectForInfoDictionaryKey:@"CFBundleIconFile"])
    &&  ( y = [z pathForResource:x ofType:nil]))
    ?         [NSImage.alloc initWithContentsOfFile:y] : (id)nil;
 }();
}

- (NSString*) name { return _path ? _path.lastPathComponent : nil; }

- (NSUInteger) warningLevel { return

  [_path rangeOfString:@"Private"].location != NSNotFound ? 2 : ({

                    id arg0 = NSProcessInfo.processInfo.processName;

  [_path rangeOfString:arg0]      .location != NSNotFound ? 1 : 0; });
}


@end

#define MACH_HEADER_mh const struct mach_header *mh

typedef void (^VisitorBlock)(struct load_command *lc, bool *stop);

@implementation LLImageLogger  static NSMutableArray *loadedImages = nil;

+     (void)   load {  loadedImages = @[].mutableCopy;

	_dyld_register_func_for_add_image(&image_added);
	_dyld_register_func_for_remove_image(&image_removed);
}
+ (NSArray*) images { return loadedImages; }

#pragma mark - Callbacks

static void   image_added(MACH_HEADER_mh, intptr_t slide) {
	_print_image(mh, true);
}
static void image_removed(MACH_HEADER_mh, intptr_t slide) {
	_print_image(mh, false);
}

#pragma mark - Logger

static void      _print_image(MACH_HEADER_mh, bool added) {

	Dl_info image_info;
	int result = dladdr(mh, &image_info);

	if (!result) return (void)printf("Could not print info for mach_header: %p\n\n", mh);

	const char *image_name = image_info.dli_fname;


  id newimage = [LLMachImage.alloc initWithDict:@{
        @"path" : [NSString stringWithUTF8String:image_name],
    @"filetype" : _describe_filetype(mh),
       @"ncmds" : @(mh->ncmds)}];
       
  if(newimage) {
    [loadedImages addObject:newimage];
    [NSNotificationCenter.defaultCenter postNotificationName:NEW_IMAGES_LOADED_NOTIFICATION object:nil];
  }

	const intptr_t image_base_address = (intptr_t)image_info.dli_fbase;
	const uint64_t image_text_size = _image_text_segment_size(mh);
	
	char image_uuid[37];
	const uuid_t *image_uuid_bytes = _image_retrieve_uuid(mh);
	uuid_unparse(*image_uuid_bytes, image_uuid);
	
	const char *log = added ? "Added" : "Removed";
	printf("%s: 0x%02lx (0x%02llx) %s <%s>\n\n", log, image_base_address, image_text_size, image_name, image_uuid);
}
NSString *             _describe_filetype(MACH_HEADER_mh) {

  NSUInteger x = mh->filetype; return

  x == MH_OBJECT      ? @"relocatable object file" :
  x == MH_EXECUTE     ? @"demand paged executable file" :
  x == MH_FVMLIB      ? @"fixed VM shared library file" :
  x == MH_CORE        ? @"core file" :
  x == MH_PRELOAD     ? @"preloaded executable file" :
  x == MH_DYLIB       ? @"dynamically bound shared library" :
  x == MH_DYLINKER    ? @"dynamic link editor" :
  x == MH_BUNDLE      ? @"dynamically bound bundle file" :
  x == MH_DYLIB_STUB  ? @"shared library stub for static linking only, no section contents" :
  x == MH_DSYM        ? @"companion file with only debug sections" :
  x == MH_KEXT_BUNDLE ? @"x86_64 kexts" : @"Unknown";
}

#pragma mark - Private

static uint32_t        _image_header_size(MACH_HEADER_mh) {
	bool is_header_64_bit = (mh->magic == MH_MAGIC_64 || mh->magic == MH_CIGAM_64);
	return (is_header_64_bit ? sizeof(struct mach_header_64) : sizeof(struct mach_header));
}
static uint64_t  _image_text_segment_size(MACH_HEADER_mh) {
	static const char *text_segment_name = "__TEXT";
	
	__block uint64_t text_size = 0;
	
	_image_visit_load_commands(mh, ^ (struct load_command *lc, bool *stop) {
		if (lc->cmdsize == 0) {
			return;
		}
		if (lc->cmd == LC_SEGMENT) {
			struct segment_command *seg_cmd = (struct segment_command *)lc;
			if (strcmp(seg_cmd->segname, text_segment_name) == 0) {
				text_size = seg_cmd->vmsize;
				*stop = true;
				return;
			}
		}
		if (lc->cmd == LC_SEGMENT_64) {
			struct segment_command_64 *seg_cmd = (struct segment_command_64 *)lc;
			if (strcmp(seg_cmd->segname, text_segment_name) == 0) {
				text_size = seg_cmd->vmsize;
				*stop = true;
				return;
			}
		}
	});
	
	return text_size;
}
static const uuid_t *_image_retrieve_uuid(MACH_HEADER_mh) {
	__block const struct uuid_command *uuid_cmd = NULL;
	
	_image_visit_load_commands(mh, ^ (struct load_command *lc, bool *stop) {
		if (lc->cmdsize == 0) {
			return;
		}
		if (lc->cmd == LC_UUID) {
			uuid_cmd = (const struct uuid_command *)lc;
			*stop = true;
		}
	});
	
	if (uuid_cmd == NULL) {
		return NULL;
	}
	
	return &uuid_cmd->uuid;
}
static void    _image_visit_load_commands(MACH_HEADER_mh,
                                    VisitorBlock visitor) {

	assert(visitor != NULL);
	
	uintptr_t lc_cursor = (uintptr_t)mh + _image_header_size(mh);
	
	for (uint32_t idx = 0; idx < mh->ncmds; idx++) {

		struct load_command *lc = (struct load_command *)lc_cursor;
		
		bool stop = false;	visitor(lc, &stop); if (stop) return;
		
		lc_cursor += lc->cmdsize;
	}
}

@end

/* Constants for the flags field of the mach_header
			x == MH_NOUNDEFS ? @"the object file has no undefined references" :
			x == MH_INCRLINK ? @"the object file is the output of an incremental link against a base file					   and can't be link edited again" :
			x == MH_DYLDLINK ? @"the object file is input for the  dynamic linker and can't be staticly link edited again" :
			x == MH_BINDATLOAD ? @"the object file's undefined references are bound by the dynamic linker when loaded." :
			x == MH_PREBOUND ? @"the file has its dynamic undefined references prebound." :
			x == MH_SPLIT_SEGS ? @"the file has its read-only and read-write segments split" :
			x == MH_LAZY_INIT ? @"the shared library init routine is to be run lazily via catching memory faults to its writeable segments (obsolete)" :
			x == MH_TWOLEVEL ? @"the image is using two-level name space bindings" :
			x == MH_FORCE_FLAT ? @"the executable is forcing all images to use flat name space bindings" :
			x == MH_NOMULTIDEFS ? @"this umbrella guarantees no multiple  defintions of symbols in its  sub-images so the two-level namespace hints can always be used." :
			x == MH_NOFIXPREBINDING ? @"do not have dyld notify the prebinding agent about this executable" :
			x == MH_PREBINDABLE ? @"the binary is not prebound but can   have its prebinding redone. only used when MH_PREBOUND is not set." :
			x == MH_ALLMODSBOUND ? @"indicates that this binary binds to all two-level namespace modules of its dependent libraries. only used when MH_PREBINDABLE and MH_TWOLEVEL are both set." :
			x == MH_SUBSECTIONS_VIA_SYMBOLS ? @"safe to divide up the sections into  sub-sections via symbols for dead code stripping" :
			x == MH_CANONICAL ? @"the binary has been canonicalized   via the unprebind operation" :
			x == MH_WEAK_DEFINES ? @"the final linked image contains external weak symbols" :
			x == MH_BINDS_TO_WEAK ? @"the final linked image uses weak symbols" :

			x == MH_ALLOW_STACK_EXECUTION ? @"When this bit is set, all stacks  in the task will be given stack execution privilege.  Only used in MH_EXECUTE filetypes." :
			x == MH_ROOT_SAFE ? @"When this bit is set, the binary   declares it is safe for use in  processes with uid zero" :
                                         
			x == MH_SETUID_SAFE ? @"When this bit is set, the binary   declares it is safe for use in  processes when issetugid() is true" :

			x == MH_NO_REEXPORTED_DYLIBS ? @"When this bit is set on a dylib,   the static linker does not need to  examine dependent dylibs to see  if any are re-exported" :
			x == MH_PIE ? @"When this bit is set, the OS will load the main executable at a random address.  Only used in MH_EXECUTE filetypes." :
			x == MH_DEAD_STRIPPABLE_DYLIB ? @"Only for use on dylibs.  When   linking against a dylib that   has this bit set, the static linker   will automatically not create a   LC_LOAD_DYLIB load command to the   dylib if no symbols are being   referenced from the dylib." :
			x == MH_HAS_TLV_DESCRIPTORS ? @"Contains a section of type   S_THREAD_LOCAL_VARIABLES" :

#define MH_NO_HEAP_EXECUTION 0x1000000	 When this bit is set, the OS will
*/
