//
//  EventTap.h
//  DisableKey
//
//  Created by Yoshimasa Niwa on 2/26/18.
//  Copyright © 2017 Yoshimasa Niwa. All rights reserved.
//

@import AppKit;
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@class EventTap;

@protocol EventTapDelegate <NSObject>

@optional
- (CGEventRef)eventTap:(EventTap *)eventTap didTapEvent:(CGEventRef)event;
- (void)eventTapDisabled:(EventTap *)eventTap;

@end

@interface EventTap : NSObject

@property (nonatomic, weak, nullable) id<EventTapDelegate> delegate;
@property (nonatomic, readonly) CGEventMask eventMask;
@property (nonatomic, getter=isEnabled) BOOL enabled;

- (instancetype)initWithEventMask:(CGEventMask)eventMask NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
