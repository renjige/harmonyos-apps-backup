import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { ThemeAppearance } from '../services/ThemeAppearance';
import { Theme } from '../components/design-system/Theme';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    Theme.applyBrandPrimary('#3D5A80');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '事项笺');
    AppStorage.setOrCreate('appTagline', '每天 3 件承诺 · 时段工位 · 专注计时后收工');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('detailRoute', '');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions',
      'create_task,edit_task,create_habit,habit_checkin,sync_records');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context);
    SessionStore.init(this.context).then(() => {
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
