import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { WorkoutStore } from '../services/WorkoutStore';
import { HabitStore } from '../services/HabitStore';
import { DataBus } from '../services/DataBus';
import { AppContextService } from '../services/AppContextService';
import { ThemeAppearance } from '../services/ThemeAppearance';
import { StatsService } from '../services/StatsService';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('companyName', '留痕科技');
    AppStorage.setOrCreate('appDisplayName', '运动留痕');
    AppStorage.setOrCreate('appTagline', '轻量级运动记录与可视化，每一次运动都留下痕迹');
    AppStorage.setOrCreate('tabBarHidden', false);
    DataBus.init();
    StatsService.initHomeStatsStorage();
    Theme.applyBrandPrimary('#F97316');
    AppContextService.setContext(this.context);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppContextService.setContext(this.context);
    SessionStore.init(this.context).then(async () => {
      ThemeAppearance.applyStored(this.context);
      await WorkoutStore.init(this.context);
      await HabitStore.init(this.context);
      await StatsService.publishHomeStats();
      const settings = await WorkoutStore.loadSettings();
      const mode = settings.themeMode.length > 0 ? settings.themeMode : 'system';
      Theme.setColorMode(mode as 'light' | 'dark' | 'system');
      AppStorage.setOrCreate('colorMode', mode);
      if (mode === 'system') {
        Theme.setForcedDark(this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      }
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    }).catch(() => {
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    });
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }
}
