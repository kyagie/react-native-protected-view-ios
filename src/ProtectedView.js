// ProtectedView.js

import { requireNativeComponent, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-protected-view' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n';

const ComponentName = 'RNProtectedViewIos';

const ProtectedView = Platform.select({
  ios: requireNativeComponent(ComponentName),
  default: () => {
    throw new Error(LINKING_ERROR);
  },
});

export const ProtectionOptions = {
  SCREENSHOTS: 1,
  SCREEN_SHARING: 2,
  INACTIVITY: 4,
  ALL: 7, // 1 | 2 | 4
};

export default ProtectedView;