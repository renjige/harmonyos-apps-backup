import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { TripStore } from '../services/TripStore';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { TripStore } from '../services/TripStore';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '行程备忘');
    AppStorage.setOrCreate('appTagline', '用清晰时间线记录旅行、出行与日常安排，一眼看见什么时候做什么');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('showTripForm', false);
    AppStorage.setOrCreate('showItemForm', false);
    AppStorage.setOrCreate('showTemplates', false);
    AppStorage.setOrCreate('showCalendar', false);
    AppStorage.setOrCreate('showSearch', false);
    AppStorage.setOrCreate('detailTripId', '');
    AppStorage.setOrCreate('tripFormId', '');
    AppStorage.setOrCreate('itemFormId', '');
    AppStorage.setOrCreate('itemFormTripId', '');
    AppStorage.setOrCreate('tripRefresh', 0);
    AppStorage.setOrCreate('minePanelOpen', false);
    AppStorage.setOrCreate('mainTabIndex', 0);
    AppStorage.setOrCreate('homeDateIso', '');
    AppStorage.setOrCreate('toastText', '');
    AppStorage.setOrCreate('homeHasItems', false);
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', 'sync_trips');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(async () => {;
            await TripStore.init(this.context);
            const dark = AppStorage.get<boolean>('darkModeOn') === true;
            Theme.applyDark(dark);
            try {;
                this.context.getApplicationContext().setColorMode(dark ?;
                    ConfigurationConstant.ColorMode.COLOR_MODE_DARK :;
                    ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
            };
            catch {;
            };
            const font = AppStorage.get<number>('fontLevel');
            Theme.setFontLevel(typeof font === 'number' ? font : 1);
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
