//
//  EventTap.m
//  DisableKey
//
//  Created by Yoshimasa Niwa on 12/13/17.
//  Copyright © 2017 Yoshimasa Niwa. All rights reserved.
//

#import "EventTap.h"

@import os.log;

NS_ASSUME_NONNULL_BEGIN

static CGEventRef EventTapCallback(CGEventTapProxy proxy, CGEventType type,  CGEventRef event, void * _Nullable userInfo)
{
    @autoreleasepool {
        EventTap * const eventTap = (__bridge EventTap *)userInfo;

        switch (type) {
            case kCGEventTapDisabledByTimeout:
            case kCGEventTapDisabledByUserInput: {
                eventTap.enabled = NO;

                os_log_error(OS_LOG_DEFAULT, "Event tap disabled by type: %d", type);

                id<EventTapDelegate> const delegate = eventTap.delegate;
                if ([delegate respondsToSelector:@selector(eventTapDisabled:)]) {
                    [delegate eventTapDisabled:eventTap];
                }
                break;
            }
            default: {
                id<EventTapDelegate> const delegate = eventTap.delegate;
                if ([delegate respondsToSelector:@selector(eventTap:didTapEvent:)]) {
                    return [delegate eventTap:eventTap didTapEvent:event];
                }
                break;
            }
        }

        return event;
    }
}

@implementation EventTap
{
    CFMachPortRef _eventTap;
    CFRunLoopSourceRef _runLoopSource;
}

- (instancetype)init
{
    return [self initWithEventMask:kCGEventMaskForAllEvents];
}

- (instancetype)initWithEventMask:(CGEventMask)eventMask
{
    if (self = [super init]) {
        _eventMask = eventMask;
    }
    return self;
}

- (void)dealloc
{
    [self _main_disable];
}

- (void)setEnabled:(BOOL)enabled
{
    if (_enabled != enabled) {
        if (enabled) {
            [self _main_enable];
        } else {
            [self _main_disable];
        }
    }
}

- (void)_main_enable
{
    if (_eventTap) {
        return;
    }
    if (_runLoopSource) {
        return;
    }

    _eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0, self.eventMask, EventTapCallback, (__bridge void *)self);
    if (_eventTap) {
        _runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, _eventTap, 0);
        if (_runLoopSource) {
            CFRunLoopAddSource(CFRunLoopGetMain(), _runLoopSource, kCFRunLoopCommonModes);
            CGEventTapEnable(_eventTap, true);

            os_log_info(OS_LOG_DEFAULT, "Event tap enabled: %p", _eventTap);

            _enabled = YES;
        } else {
            CFRelease(_eventTap);
            _eventTap = NULL;
        }
    }
}

- (void)_main_disable
{
    if (_runLoopSource) {
        CFRunLoopRemoveSource(CFRunLoopGetMain(), _runLoopSource, kCFRunLoopCommonModes);
        CFRelease(_runLoopSource);
        _runLoopSource = NULL;
    }
    if (_eventTap) {
        CGEventTapEnable(_eventTap, false);

        os_log_info(OS_LOG_DEFAULT, "Event tap disabled: %p", _eventTap);

        CFRelease(_eventTap);
        _eventTap = NULL;
    }

    _enabled = NO;
}

@end

NS_ASSUME_NONNULL_END
