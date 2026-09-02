import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { Configuration } from '@kit.AbilityKit';
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
    AppStorage.setOrCreate('appDisplayName', '行旅笺');
    AppStorage.setOrCreate('appTagline', '纸上的旅途，从容记录每一段出行');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('showTripForm', false);
    AppStorage.setOrCreate('showItemForm', false);
    AppStorage.setOrCreate('showJournalForm', false);
    AppStorage.setOrCreate('showInspireForm', false);
    AppStorage.setOrCreate('showTemplates', false);
    AppStorage.setOrCreate('showSearch', false);
    AppStorage.setOrCreate('detailTripId', '');
    AppStorage.setOrCreate('detailJournalId', '');
    AppStorage.setOrCreate('detailInspireId', '');
    AppStorage.setOrCreate('tripFormId', '');
    AppStorage.setOrCreate('journalFormId', '');
    AppStorage.setOrCreate('inspireFormId', '');
    AppStorage.setOrCreate('itemFormId', '');
    AppStorage.setOrCreate('itemFormTripId', '');
    AppStorage.setOrCreate('tripRefresh', 0);
    AppStorage.setOrCreate('minePanelOpen', false);
    AppStorage.setOrCreate('mainTabIndex', 0);
    AppStorage.setOrCreate('toastText', '');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', '');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context);
    SessionStore.init(this.context).then(async () => {
      await TripStore.init(this.context);
      const dark = AppStorage.get<boolean>('darkModeOn') === true;
      Theme.applyDark(dark);
      try {
        this.context.getApplicationContext().setColorMode(dark ?
          ConfigurationConstant.ColorMode.COLOR_MODE_DARK :
          ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
      } catch {
      }
      const font = AppStorage.get<number>('fontLevel');
      Theme.setFontLevel(typeof font === 'number' ? font : 1);
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
