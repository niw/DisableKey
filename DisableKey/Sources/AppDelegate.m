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

static int64_t kInternalKeyboardTypes[] = {
    58,
    91  // MacBook Pro (M1, 2021)
};

@interface AppDelegate () <EventTapDelegate>

@property (nonatomic, nullable) NSStatusItem *statusItem;
@property (nonatomic, nullable) EventTap *eventTap;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSStatusBar * const statusBar = [NSStatusBar systemStatusBar];
    NSStatusItem * const statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    // NOTE: This `highlightsBy` that is alternative to the deprecated
    // `statusItem.highlightMode = YES` may be not necessary anymore.
    NSButtonCell * const statusItemButtonCell = (NSButtonCell *)statusItem.button.cell;
    statusItemButtonCell.highlightsBy = NSContentsCellMask | NSChangeBackgroundCellMask;

    NSImage * const statusItemImage = [NSImage imageNamed:@"StatusItem"];
    statusItemImage.template = YES;
    statusItem.button.image = statusItemImage;

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
        const CGEventMask eventMask = CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventKeyUp) | CGEventMaskBit(kCGEventFlagsChanged) | CGEventMaskBit(NX_SYSDEFINED);
        EventTap * const eventTap = [[EventTap alloc] initWithEventMask:eventMask];
        eventTap.delegate = self;
        eventTap.enabled = YES;
        self.eventTap = eventTap;
    }
}

// MARK: - EventTapDelegate

- (CGEventRef)eventTap:(EventTap *)eventTap didTapEvent:(CGEventRef)event
{
    NSEvent * const nsEvent = [NSEvent eventWithCGEvent:event];
    if (nsEvent.type == NSEventTypeSystemDefined && nsEvent.subtype == NX_SUBTYPE_AUX_CONTROL_BUTTONS) {
        return NULL;
    }

    const int64_t keyboardType = CGEventGetIntegerValueField(event, kCGKeyboardEventKeyboardType);
    const size_t internalKeyboardTypesCount = sizeof(kInternalKeyboardTypes) / sizeof(int64_t);
    for (size_t index = 0; index < internalKeyboardTypesCount; index++) {
        if (keyboardType == kInternalKeyboardTypes[index]) {
            return NULL;
        }
    }
    return event;
}

@end

NS_ASSUME_NONNULL_END
