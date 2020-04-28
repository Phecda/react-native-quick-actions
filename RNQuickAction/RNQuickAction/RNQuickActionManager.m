//
//  RNQuickAction.m
//  RNQuickAction
//
//  Created by Jordan Byron on 9/26/15.
//  Copyright © 2015 react-native. All rights reserved.
//

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTUtils.h>
#import "RNQuickActionManager.h"

NSString *const RCTShortcutItemClicked = @"ShortcutItemClicked";

NSDictionary *RNQuickAction(UIApplicationShortcutItem *item) {
    if (!item) return nil;
    return @{
        @"type": item.type,
        @"title": item.localizedTitle,
        @"userInfo": item.userInfo ?: @{}
    };
}

@implementation RNQuickActionManager
{
    UIApplicationShortcutItem *_initialAction;
}

RCT_EXPORT_MODULE();

- (void)startObserving
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleQuickActionPress:)
                                                 name:RCTShortcutItemClicked
                                               object:nil];
}

- (void)stopObserving
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (void)setBridge:(RCTBridge *)bridge
{
    [super setBridge:bridge];
    _initialAction = [bridge.launchOptions[UIApplicationLaunchOptionsShortcutItemKey] copy];
}

// Map user passed array of UIApplicationShortcutItem
- (NSArray*)dynamicShortcutItemsForPassedArray:(NSArray*)passedArray {
    // FIXME: Dynamically map icons from UIApplicationShortcutIconType to / from their string counterparts
    // so we don't have to update this list every time Apple adds new system icons.
    NSMutableDictionary *icons = @{
        @"Compose": @(UIApplicationShortcutIconTypeCompose),
        @"Play": @(UIApplicationShortcutIconTypePlay),
        @"Pause": @(UIApplicationShortcutIconTypePause),
        @"Add": @(UIApplicationShortcutIconTypeAdd),
        @"Location": @(UIApplicationShortcutIconTypeLocation),
        @"Search": @(UIApplicationShortcutIconTypeSearch),
        @"Share": @(UIApplicationShortcutIconTypeShare),
    }.mutableCopy;
    if (@available(iOS 9.1, *)) {
        [icons addEntriesFromDictionary: @{
            @"Prohibit": @(UIApplicationShortcutIconTypeProhibit),
            @"Contact": @(UIApplicationShortcutIconTypeContact),
            @"Home": @(UIApplicationShortcutIconTypeHome),
            @"MarkLocation": @(UIApplicationShortcutIconTypeMarkLocation),
            @"Favorite": @(UIApplicationShortcutIconTypeFavorite),
            @"Love": @(UIApplicationShortcutIconTypeLove),
            @"Cloud": @(UIApplicationShortcutIconTypeCloud),
            @"Invitation": @(UIApplicationShortcutIconTypeInvitation),
            @"Confirmation": @(UIApplicationShortcutIconTypeConfirmation),
            @"Mail": @(UIApplicationShortcutIconTypeMail),
            @"Message": @(UIApplicationShortcutIconTypeMessage),
            @"Date": @(UIApplicationShortcutIconTypeDate),
            @"Time": @(UIApplicationShortcutIconTypeTime),
            @"CapturePhoto": @(UIApplicationShortcutIconTypeCapturePhoto),
            @"CaptureVideo": @(UIApplicationShortcutIconTypeCaptureVideo),
            @"Task": @(UIApplicationShortcutIconTypeTask),
            @"TaskCompleted": @(UIApplicationShortcutIconTypeTaskCompleted),
            @"Alarm": @(UIApplicationShortcutIconTypeAlarm),
            @"Bookmark": @(UIApplicationShortcutIconTypeBookmark),
            @"Shuffle": @(UIApplicationShortcutIconTypeShuffle),
            @"Audio": @(UIApplicationShortcutIconTypeAudio),
            @"Update": @(UIApplicationShortcutIconTypeUpdate)
        }];
    }

    NSMutableArray *shortcutItems = [NSMutableArray new];

    [passedArray enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        NSString *iconName = item[@"icon"];

        // If passed iconName is enum, use system icon
        // Otherwise, load from bundle
        UIApplicationShortcutIcon *shortcutIcon;
        NSNumber *iconType = icons[iconName];

        if (iconType) {
            shortcutIcon = [UIApplicationShortcutIcon iconWithType:[iconType intValue]];
        } else if (iconName) {
            shortcutIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:iconName];
        }

        [shortcutItems addObject:[[UIApplicationShortcutItem alloc] initWithType:item[@"type"]
                                                                  localizedTitle:item[@"title"] ?: item[@"type"]
                                                               localizedSubtitle:item[@"subtitle"]
                                                                            icon:shortcutIcon
                                                                        userInfo:item[@"userInfo"]]];
    }];

    return shortcutItems;
}

RCT_EXPORT_METHOD(setShortcutItems:(NSArray *) shortcutItems)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    NSArray *dynamicShortcuts = [self dynamicShortcutItemsForPassedArray:shortcutItems];
    [UIApplication sharedApplication].shortcutItems = dynamicShortcuts;
  });
}

RCT_EXPORT_METHOD(isSupported:(RCTResponseSenderBlock)callback)
{
    BOOL supported = [[UIApplication sharedApplication].delegate.window.rootViewController.traitCollection forceTouchCapability] == UIForceTouchCapabilityAvailable;

    callback(@[[NSNull null], [NSNumber numberWithBool:supported]]);
}

RCT_EXPORT_METHOD(clearShortcutItems)
{
    [UIApplication sharedApplication].shortcutItems = nil;
}

+ (void)onQuickActionPress:(UIApplicationShortcutItem *) shortcutItem completionHandler:(void (^)(BOOL succeeded)) completionHandler
{
    RCTLogInfo(@"[RNQuickAction] Quick action shortcut item pressed: %@", [shortcutItem type]);

    [[NSNotificationCenter defaultCenter] postNotificationName:RCTShortcutItemClicked
                                                        object:self
                                                      userInfo:RNQuickAction(shortcutItem)];

    completionHandler(YES);
}

- (void)handleQuickActionPress:(NSNotification *) notification
{
    [self sendEventWithName:@"quickActionShortcut" body:notification.userInfo];
}

- (NSDictionary *)constantsToExport
{
    return @{
      @"initialAction": RCTNullIfNil(RNQuickAction(_initialAction))
    };
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"quickActionShortcut"];
}

@end
