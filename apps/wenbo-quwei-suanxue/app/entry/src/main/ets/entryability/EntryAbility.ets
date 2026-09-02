import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { MathLocalStore } from '../services/MathLocalStore';
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
import { MathLocalStore } from '../services/MathLocalStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '承德锐泓科技信息有限公司');
    AppStorage.setOrCreate('appDisplayName', '趣味算学');
    AppStorage.setOrCreate('appTagline', '面向6-12岁小学生的游戏化口算闯关，智慧挑战与成长徽章激励');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('windowIsWide', false);
    AppStorage.setOrCreate('onboardingDone', false);
    AppStorage.setOrCreate('mathDetailOpen', false);
    AppStorage.setOrCreate('mathDetailKind', 'mode');
    AppStorage.setOrCreate('mathDetailId', '');
    Theme.applyBrandPrimary('#4A90D9');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', '');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(() => {;
            return MathLocalStore.init(this.context);
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
