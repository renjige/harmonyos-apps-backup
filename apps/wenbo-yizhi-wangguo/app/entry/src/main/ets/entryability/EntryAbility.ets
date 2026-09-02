import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { KingdomLocalStore } from '../services/KingdomLocalStore';
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
import { KingdomLocalStore } from '../services/KingdomLocalStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '益智王国');
    AppStorage.setOrCreate('appTagline', '面向3到12岁儿童的分级益智闯关，用形状色彩序列与推理培养观察力与逻辑，本机记录成长');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('kkDetailOpen', false);
    AppStorage.setOrCreate('kkDetailKind', 'level');
    AppStorage.setOrCreate('kkDetailId', '');
    AppStorage.setOrCreate('kkDetailCta', '开始闯关');
    AppStorage.setOrCreate('kkQuizOpen', false);
    AppStorage.setOrCreate('kkResultOpen', false);
    AppStorage.setOrCreate('kkDailyOpen', false);
    AppStorage.setOrCreate('kkCollectOpen', false);
    AppStorage.setOrCreate('kkSettingsOpen', false);
    AppStorage.setOrCreate('kkGateOpen', false);
    AppStorage.setOrCreate('kkDiagnoseOpen', false);
    Theme.applyBrandPrimary('#5B6ABF');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', '');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(() => {;
            return KingdomLocalStore.init(this.context);
        }).then(() => {;
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
