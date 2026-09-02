import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
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
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '思见堂');
    AppStorage.setOrCreate('appTagline', '智慧思想交流平台，每日慧语启发、思录沉淀与轻量思友互动，东方美学静谧阅读体验');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('showWriteThought', false);
    AppStorage.setOrCreate('writeThoughtId', '');
    AppStorage.setOrCreate('writePrefillTitle', '');
    AppStorage.setOrCreate('writePrefillBody', '');
    AppStorage.setOrCreate('showMessages', false);
    AppStorage.setOrCreate('showThoughtSearch', false);
    AppStorage.setOrCreate('showFavorites', false);
    AppStorage.setOrCreate('showHistory', false);
    AppStorage.setOrCreate('detailRoute', '');
    AppStorage.setOrCreate('whRefresh', 0);
    AppStorage.setOrCreate('minePanelOpen', false);
    AppStorage.setOrCreate('mainTabIndex', 0);
    AppStorage.setOrCreate('darkModeOn', false);
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions', 'create_thought,add_favorite,like_featured,sync_records');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(() => {;
            const dark = AppStorage.get<boolean>('darkModeOn') === true;
            Theme.setColorMode(dark ? 'dark' : 'light');
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
