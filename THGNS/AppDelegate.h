//
//  AppDelegate.h
//  THGNS
//
//  Created by Connor Montgomery on 7/13/13.
//  Copyright (c) 2013 Connor Montgomery. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) NSMutableArray *things;
@property (nonatomic) IBOutlet NSMenu *statusItemMenu;

@end
