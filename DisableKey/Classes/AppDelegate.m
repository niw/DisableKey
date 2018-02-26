//
//  AppDelegate.m
//  DisableKey
//
//  Created by Yoshimasa Niwa on 2/26/18.
//  Copyright © 2018 Yoshimasa Niwa. All rights reserved.
//

#import "AppDelegate.h"
#import "EventTap.h"

NS_ASSUME_NONNULL_BEGIN

static int64_t kInternalKeyboardType = 58;

@interface AppDelegate () <EventTapDelegate>

@property (nonatomic, nullable) NSStatusItem *statusItem;
@property (nonatomic, nullable) EventTap *eventTap;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSStatusBar * const statusBar = [NSStatusBar systemStatusBar];
    NSStatusItem * const statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    statusItem.highlightMode = YES;

    NSImage * const statusItemImage = [NSImage imageNamed:@"StatusItem"];
    statusItemImage.template = YES;
    statusItem.image = statusItemImage;

    NSMenu * const statusMenu = [[NSMenu alloc] init];

    NSMenuItem * const quitMenuItem = [[NSMenuItem alloc] init];
    quitMenuItem.title = @"Quit";
    quitMenuItem.keyEquivalent = @"q";
    quitMenuItem.keyEquivalentModifierMask = NSEventModifierFlagCommand;
    quitMenuItem.action = @selector(terminate:);
    [statusMenu addItem:quitMenuItem];

    statusItem.menu = statusMenu;

    self.statusItem = statusItem;

    CFDictionaryRef options = (__bridge CFDictionaryRef)@{(__bridge NSString *)kAXTrustedCheckOptionPrompt: @YES};
    if (AXIsProcessTrustedWithOptions(options)) {
        const CGEventMask eventMask = CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventKeyUp) | CGEventMaskBit(kCGEventFlagsChanged);
        EventTap * const eventTap = [[EventTap alloc] initWithEventMask:eventMask];
        eventTap.delegate = self;
        eventTap.enabled = YES;
        self.eventTap = eventTap;
    }
}

// MARK: - EventTapDelegate

- (CGEventRef)eventTap:(EventTap *)eventTap didTapEvent:(CGEventRef)event
{
    const int64_t keyboardType = CGEventGetIntegerValueField(event, kCGKeyboardEventKeyboardType);
    if (keyboardType == kInternalKeyboardType) {
        return NULL;
    } else {
        return event;
    }
}

@end

NS_ASSUME_NONNULL_END
