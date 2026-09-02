import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { VitalityStore } from '../services/VitalityStore';
import { AppContextService } from '../services/AppContextService';
import { ReminderService } from '../services/ReminderService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    AppStorage.setOrCreate('vitalityEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('companyName', '活力旅程科技');
    AppStorage.setOrCreate('appDisplayName', '活力纪行');
    AppStorage.setOrCreate('appTagline', '轻量级每日活力记录与回顾，3秒看见成长轨迹');
    AppStorage.setOrCreate('tabBarHidden', false);
    Theme.applyBrandPrimary('#FF6B35');
    AppContextService.setContext(this.context);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppContextService.setContext(this.context);
    SessionStore.init(this.context).then(async () => {
      ThemeAppearance.applyStored(this.context);
      await VitalityStore.init(this.context);
      const profile = await VitalityStore.loadProfile();
      const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system';
      Theme.setColorMode(mode as 'light' | 'dark' | 'system');
      AppStorage.setOrCreate('colorMode', mode);
      if (mode === 'system') {
        Theme.setForcedDark(this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      }
      await ReminderService.syncFromProfile(this.context);
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    }).catch(async () => {
      try {
        await VitalityStore.init(this.context)
      } catch {
        // ignore
      }
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
