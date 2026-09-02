import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { SlipStore } from '../services/SlipStore';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { SlipStore } from '../services/SlipStore';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '梦隅文化');
    AppStorage.setOrCreate('appDisplayName', '梦隅札');
    AppStorage.setOrCreate('appTagline', '记录梦境 · 洞察自我');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('showWriteNote', false);
    AppStorage.setOrCreate('detailRoute', '');
    AppStorage.setOrCreate('noteRefresh', 0);
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', 'sync_notes');
    Theme.applyBrandPrimary('#C9A87C');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(async () => {;
            await SlipStore.init(this.context);
            const darkStored = AppStorage.get<boolean>('darkModeOn');
            const dark = darkStored === undefined ? true : darkStored === true;
            AppStorage.setOrCreate('darkModeOn', dark);
            Theme.setColorMode(dark ? 'dark' : 'light');
            const font = AppStorage.get<number>('fontLevel') ?? 1;
            Theme.applyFontLevel(typeof font === 'number' ? font : 1);
            windowStage.loadContent('pages/Index', (err) => {;
                if (err.code) {;
                    hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
                };
            });
        }).catch(() => {;
            Theme.setColorMode('dark');
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
