import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { WorkoutStore } from '../services/WorkoutStore';
import { ThemeAppearance } from '../services/ThemeAppearance';
import { FitDataNotify } from '../services/FitDataNotify';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('companyName', '体能图志科技');
    AppStorage.setOrCreate('appDisplayName', '体能图志');
    AppStorage.setOrCreate('appTagline', '用图表看见你的体能成长，智慧运动记录与可视化分析工具');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('fitDataEpoch', 0);
    AppStorage.setOrCreate('fitTotalWorkouts', 0);
    AppStorage.setOrCreate('fitStreakDays', 0);
    AppStorage.setOrCreate('fitChallengeDone', 0);
    AppStorage.setOrCreate('fitTotalMinutes', 0);
    AppStorage.setOrCreate('fitTodayMinutes', 0);
    Theme.applyBrandPrimary('#FF6B35');
    AccessConfig.applyDefaults('open_optional');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    void this.bootstrap(windowStage);
  }

  private async bootstrap(windowStage: window.WindowStage): Promise<void> {
    try {
      await SessionStore.init(this.context);
    } catch {
      hilog.error(0x0000, TAG, 'SessionStore.init failed');
    }
    try {
      await WorkoutStore.init(this.context);
      await FitDataNotify.syncStats();
    } catch {
      hilog.error(0x0000, TAG, 'WorkoutStore.init failed');
    }
    try {
      ThemeAppearance.applyStored(this.context);
      const profile = await WorkoutStore.loadProfile();
      const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system';
      Theme.setColorMode(mode as 'light' | 'dark' | 'system');
      AppStorage.setOrCreate('colorMode', mode);
      if (mode === 'system') {
        Theme.setForcedDark(this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      }
    } catch {
      hilog.error(0x0000, TAG, 'theme bootstrap failed');
    }
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
      }
    });
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }
}
