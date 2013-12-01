//
//  AppDelegate.m
//  THGNS
//
//  Created by Connor Montgomery on 7/13/13.
//  Copyright (c) 2013 Connor Montgomery. All rights reserved.
//

#import "AppDelegate.h"

static NSString * const TITLE_KEY = @"title";
static NSString * const STATUS_KEY = @"status";
static NSString * const COMPLETED_SIGNATURE = @"tdio";

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
    [self resetStatusTitleTimer];
    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(fetchAndSetThings) userInfo:nil repeats:YES];
}

- (void)resetStatusTitleTimer {
    if (self.statusTitleTimer != nil) {
        [self.statusTitleTimer invalidate];
    }
    self.statusTitleTimer = [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(setRandomStatusTitle) userInfo:nil repeats:YES];
}

- (void)setRandomStatusTitle{
    NSUInteger randomIndex = arc4random() % [things count];
    NSDictionary *thing = [things objectAtIndex:randomIndex];
    NSString *title = [self reasonablySizedVersionOfString:[thing objectForKey:TITLE_KEY]];
    [self setStatusItemTitle:title];
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
    
    for (NSInteger x = 1; x < numberOfItems + 1; x += 3) {
        NSString *title = [[returnDescriptor descriptorAtIndex:x] stringValue];
        NSString *status = [[returnDescriptor descriptorAtIndex:x + 1] stringValue];
        NSString *id = [[returnDescriptor descriptorAtIndex:x + 2] stringValue];
        
        NSDictionary *localThing = @{TITLE_KEY: title, STATUS_KEY: status, @"id": id};
        [things addObject:localThing];
        
    }
    
    NSArray* reversedThings = [[things reverseObjectEnumerator] allObjects];
    
    for (int i = 0; i < [reversedThings count]; i++) {
        [self addItemToMenu:[reversedThings objectAtIndex:i]];
    }
    
    NSMenuItem *separatorItem = [NSMenuItem separatorItem];
    [statusItemMenu insertItem:separatorItem atIndex:[things count]];
    [statusItemMenu insertItemWithTitle:@"Quit" action:@selector(onQuitClick:) keyEquivalent:@"q" atIndex:[things count] + 1];
}

- (void)onQuitClick:(id)sender{
    [[NSApplication sharedApplication] terminate:self];
}

- (void)addItemToMenu:(NSDictionary*) thing{
    NSString *title = [thing objectForKey:TITLE_KEY];
    NSString *status = [thing objectForKey:STATUS_KEY];
 
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[self reasonablySizedVersionOfString:title] action:@selector(onStatusMenuItemClick:) keyEquivalent:@""];

    [statusItemMenu setAutoenablesItems:NO];
    
    if (![status isEqual: COMPLETED_SIGNATURE]) {
        [menuItem setEnabled:NO];
        [menuItem setState:1];
    }
    
    [statusItemMenu insertItem:menuItem atIndex:0];

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
    NSString *title = [sender title];
    [self setStatusItemTitle:title];
    [self resetStatusTitleTimer];
}

@end
