//
//  AppDelegate.m
//  THGNS
//
//  Created by Connor Montgomery on 7/13/13.
//  Copyright (c) 2013 Connor Montgomery. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize statusItemMenu;
@synthesize things;
@synthesize statusItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    things = [[NSMutableArray alloc] init];
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	statusItem.menu = self.statusItemMenu;
	statusItem.highlightMode = YES;
    [self fetchAndSetThings];
    [self setRandomStatusTitle];
    [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(setRandomStatusTitle) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(fetchAndSetThings) userInfo:nil repeats:YES];
}

- (void)setRandomStatusTitle{
    NSUInteger randomIndex = arc4random() % [things count];
    NSString *newStatusTitle = [things objectAtIndex:randomIndex];
    [self setStatusItemTitle:newStatusTitle];
}

- (void)reset {
    [things removeAllObjects];
    [self removeAllItemsFromMenu];
}

- (void)removeAllItemsFromMenu {
    [statusItemMenu removeAllItems];
}

- (void)fetchAndSetThings{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"thingsToday" ofType:@"scpt"];
    NSURL* url = [NSURL fileURLWithPath:path];NSDictionary* errors = [NSDictionary dictionary];
    NSAppleScript* appleScript = [[NSAppleScript alloc] initWithContentsOfURL:url error:&errors];
    NSAppleEventDescriptor *returnDescriptor = [appleScript executeAndReturnError:nil];
   
    NSInteger numberOfItems = [returnDescriptor numberOfItems];
  
    [self reset];
    
    for (NSInteger x = 1; x < numberOfItems + 1; x++) {
        NSString *itemTitle = [[returnDescriptor descriptorAtIndex:x] stringValue];
        [things addObject:[self reasonablySizedVersionOfString:itemTitle]];
    }

    for (int i = 0; i < [things count]; i++) {
        [self addItemToMenu:[things objectAtIndex:i]];
    }
}

- (void)checkItemAtIndex: (NSInteger*) index{
    [[statusItemMenu itemAtIndex:*index] setState:YES];
    [[statusItemMenu itemAtIndex:*index] setEnabled:NO];
}

- (void)addItemToMenu:(NSString*) title{
    [statusItemMenu insertItemWithTitle:[self reasonablySizedVersionOfString:title] action:@selector(onStatusMenuItemClick:) keyEquivalent:@"" atIndex:0];
}

- (NSString *)reasonablySizedVersionOfString:(NSString *)originalString {
	NSInteger stringLength = [originalString length];
    NSInteger stringMaxLength = 30;
	if (stringLength > stringMaxLength) {
		return [NSString stringWithFormat:@"%@…%@",
                [originalString substringWithRange:NSMakeRange(0, stringMaxLength)],
                [originalString substringWithRange:NSMakeRange(stringLength - stringMaxLength, 0)]];
	}
	return [NSString stringWithString:originalString];
    
}

- (void)setStatusItemTitle:(NSString *)title{
    self.statusItem.title = title;
}

- (void)onStatusMenuItemClick: sender{
    
}

@end
