import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { HuntProgressStore } from '../services/HuntProgressStore';
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
import { HuntProgressStore } from '../services/HuntProgressStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '诗词寻宝');
    AppStorage.setOrCreate('appTagline', '以闯关寻宝与诗地点亮学习鉴赏古典诗词，告别枯燥名篇罗列');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('windowIsWide', false);
    AppStorage.setOrCreate('poetryRoute', '');
    AppStorage.setOrCreate('mainTab', 0);
    AppStorage.setOrCreate('poetryTick', 0);
    AppStorage.setOrCreate('huntCoins', 0);
    AppStorage.setOrCreate('huntCleared', 0);
    AppStorage.setOrCreate('huntPlaces', 0);
    AppStorage.setOrCreate('huntFavs', 0);
    AppStorage.setOrCreate('huntFontScale', 100);
    AppStorage.setOrCreate('huntColorMode', 'system');
    AppStorage.setOrCreate('huntHidden', false);
    Theme.applyBrandPrimary('#1A1A2E');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', 'sync_records');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(() => {;
            return HuntProgressStore.init(this.context);
        }).then(() => {;
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
