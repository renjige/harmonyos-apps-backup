import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { TrackStore } from '../services/TrackStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { TrackStore } from '../services/TrackStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.apply();
    AppStorage.setOrCreate('companyName', '轨迹工坊');
    AppStorage.setOrCreate('appDisplayName', '个人轨迹');
    AppStorage.setOrCreate('appTagline',
      '手动记录每一段人生足迹，写下地点与回忆，数据默认仅存本地设备');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('trackDetailId', '');
    Theme.applyBrandPrimary('#FF6B35');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions', 'export_gpx,sync_account');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(async () => {;
            await TrackStore.init(this.context);
            windowStage.loadContent('pages/Index', (err) => {;
                if (err.code) {;
                    hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
                };
            });
        }).catch(() => {;
            windowStage.loadContent('pages/Index', (err) => {;
                if (err.code) {;
                    hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
                };
            });
        });
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }
}
