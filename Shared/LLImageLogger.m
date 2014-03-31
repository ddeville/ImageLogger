//
//  LLImageLogger.m
//  ImageLogger
//
//  Created by Damien DeVille on 3/27/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import "LLImageLogger.h"

#import <dlfcn.h>
#import <mach-o/loader.h>
#import <mach-o/dyld.h>

@implementation LLImageLogger

+ (void)load
{
	_dyld_register_func_for_add_image(&image_added);
	_dyld_register_func_for_remove_image(&image_removed);
}

#pragma mark - Callbacks

static void image_added(const struct mach_header *mh, intptr_t slide)
{
	_print_image(mh, true);
}

static void image_removed(const struct mach_header *mh, intptr_t slide)
{
	_print_image(mh, false);
}

#pragma mark - Logger

static void _print_image(const struct mach_header *mh, bool added)
{
	Dl_info image_info;
	int result = dladdr(mh, &image_info);
	
	if (result == 0) {
		printf("Could not print info for mach_header: %p\n\n", mh);
		return;
	}
	
	const char *image_name = image_info.dli_fname;
	
	const intptr_t image_base_address = (intptr_t)image_info.dli_fbase;
	const uint64_t image_text_size = _image_text_segment_size(mh);
	
	char image_uuid[37];
	const uuid_t *image_uuid_bytes = _image_retrieve_uuid(mh);
	uuid_unparse(*image_uuid_bytes, image_uuid);
	
	const char *log = added ? "Added" : "Removed";
	printf("%s: 0x%02lx (0x%02llx) %s <%s>\n\n", log, image_base_address, image_text_size, image_name, image_uuid);
}

#pragma mark - Private

static uint32_t _image_header_size(const struct mach_header *mh)
{
	bool is_header_64_bit = (mh->magic == MH_MAGIC_64 || mh->magic == MH_CIGAM_64);
	return (is_header_64_bit ? sizeof(struct mach_header_64) : sizeof(struct mach_header));
}

static void _image_visit_load_commands(const struct mach_header *mh, void (^visitor)(struct load_command *lc, bool *stop))
{
	assert(visitor != NULL);
	
	uintptr_t lc_cursor = (uintptr_t)mh + _image_header_size(mh);
	
	for (uint32_t idx = 0; idx < mh->ncmds; idx++) {
		struct load_command *lc = (struct load_command *)lc_cursor;
		
		bool stop = false;
		visitor(lc, &stop);
		
		if (stop) {
			return;
		}
		
		lc_cursor += lc->cmdsize;
	}
}

static uint64_t _image_text_segment_size(const struct mach_header *mh)
{
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

static const uuid_t *_image_retrieve_uuid(const struct mach_header *mh)
{
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

@end
