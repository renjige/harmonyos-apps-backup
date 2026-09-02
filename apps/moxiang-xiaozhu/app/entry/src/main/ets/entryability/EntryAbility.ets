import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '墨香雅集');
    AppStorage.setOrCreate('appDisplayName', '墨香小筑');
    AppStorage.setOrCreate('appTagline', '读今日书摘，写下墨迹，在小筑与文友打卡。');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('detailRoute', '');
    AppStorage.setOrCreate('inkRefresh', 0);
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions', 'create_note,create_review,create_checkin,sync_records');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    SessionStore.init(this.context).then(() => {
      ThemeAppearance.applyStored(this.context);
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
