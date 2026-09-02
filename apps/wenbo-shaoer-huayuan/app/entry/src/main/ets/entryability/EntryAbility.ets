import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate')
    ApiConfig.applyToAppStorage()
    AppStorage.setOrCreate('companyName', '魏文波')
    AppStorage.setOrCreate('appDisplayName', '少儿画苑')
    AppStorage.setOrCreate('appTagline', '把孩子的画作收进时间线与主题画册，办一场只属于你们的数字画展')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('windowIsWide', false)
    AppStorage.setOrCreate('kagRoute', '')
    AppStorage.setOrCreate('kagTick', 0)
    AppStorage.setOrCreate('kagChildId', '')
    AppStorage.setOrCreate('mainTab', 0)
    Theme.applyBrandPrimary('#FF8A65')
    AccessConfig.applyDefaults('open_optional')
    AppStorage.setOrCreate('accessGateActions', 'upload_artwork,create_album,create_child,share_exhibition,mark_milestone')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(() => {;
            windowStage.getMainWindow().then((win: window.Window) => {;
                const size = win.getWindowProperties().windowRect;
                AppStorage.setOrCreate('windowIsWide', size.width >= 840);
            }).catch(() => {;
                AppStorage.setOrCreate('windowIsWide', false);
            });
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
