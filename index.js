import { NativeModules, NativeEventEmitter, Platform } from 'react-native';
const { RNQuickActionManager, ReactAppShortcuts } = NativeModules;
let _initialAction = RNQuickActionManager && RNQuickActionManager.initialAction;
const NativeQuickActionModule = Platform.select({
  ios: RNQuickActionManager,
  android: ReactAppShortcuts,
});
export const QuickActionEmitter = new NativeEventEmitter(
  NativeQuickActionModule
);
export const QuickActionEventName = 'quickActionShortcut';
/**
 * An initial action will be available if the app was cold-launched
 * from an action.
 *
 * The first caller of `popInitialAction` will get the initial
 * action object, or `null`. Subsequent invocations will return null.
 */
export async function popInitialAction() {
  if (Platform.OS === 'ios') {
    let initialAction = _initialAction;
    _initialAction = undefined;
    return initialAction;
  } else if (Platform.OS === 'android') {
    return ReactAppShortcuts.popInitialAction();
  }
}
/**
 * Adds shortcut items to application
 */
export function setShortcutItems(items) {
  NativeQuickActionModule.setShortcutItems(items);
}
/**
 * Clears all previously set dynamic icons
 */
export function clearShortcutItems() {
  NativeQuickActionModule.clearShortcutItems();
}
/**
 * Check if quick actions are supported
 */
export function isSupported(callback) {
  NativeQuickActionModule.isSupported(callback);
}
