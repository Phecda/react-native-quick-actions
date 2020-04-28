import { NativeEventEmitter } from 'react-native';
export declare const QuickActionEmitter: NativeEventEmitter;
export declare const QuickActionEventName = 'quickActionShortcut';
export interface ShortcutItem {
  type: string;
  title: string;
  subtitle?: string;
  icon: string;
  userInfo: {
    url: string;
  };
}
/**
 * An initial action will be available if the app was cold-launched
 * from an action.
 *
 * The first caller of `popInitialAction` will get the initial
 * action object, or `null`. Subsequent invocations will return null.
 */
export declare function popInitialAction(): Promise<ShortcutItem | undefined>;
/**
 * Adds shortcut items to application
 */
export declare function setShortcutItems(items: ShortcutItem[]): void;
/**
 * Clears all previously set dynamic icons
 */
export declare function clearShortcutItems(): void;
/**
 * Check if quick actions are supported
 */
export declare function isSupported(
  callback: (error: Error | any, supported: boolean) => void
): void;
