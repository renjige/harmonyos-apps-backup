import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { TuceStore } from '../services/TuceStore'
import { ProfileStore } from '../services/ProfileStore';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '蜕变影像');
    AppStorage.setOrCreate('appDisplayName', '运动图册');
    AppStorage.setOrCreate('appTagline', '收藏动作，记录训练，留下每一次进步');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('tuceRoute', '');
    AppStorage.setOrCreate('tuceRouteId', '');
    AppStorage.setOrCreate('tuceReload', 0);
    Theme.applyBrandPrimary('#FF6B35');
    Theme.setColorMode('light');
    AppStorage.setOrCreate('darkModeOn', false);
    AccessConfig.applyDefaults('open_optional');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    void (async (): Promise<void> => {
      await TuceStore.init(this.context);
      await ProfileStore.init(this.context);
      try {
        const dark = await ProfileStore.isDarkMode();
        ThemeAppearance.apply(dark ? 'dark' : 'light', this.context);
        AppStorage.setOrCreate('darkModeOn', dark);
      } catch {
        ThemeAppearance.apply('light', this.context);
        AppStorage.setOrCreate('darkModeOn', false);
      }
      try {
        await SessionStore.init(this.context);
      } catch {
      }
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    })();
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }
}
