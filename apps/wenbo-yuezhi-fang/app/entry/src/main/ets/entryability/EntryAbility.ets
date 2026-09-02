import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { AtelierProgress } from '../services/AtelierProgress';
import { AtelierShelf } from '../services/AtelierShelf';
import { AtelierPractice } from '../services/AtelierPractice';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '悦知坊');
    AppStorage.setOrCreate('appTagline', '悦读片刻，智识日常');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('detailRoute', '');
    AppStorage.setOrCreate('detailToken', 0);
    AppStorage.setOrCreate('showMineSettings', false);
    AppStorage.setOrCreate('atelierRefresh', 0);
    AppStorage.setOrCreate('mainTabIndex', 0);
    AppStorage.setOrCreate('gateLogin', false);
    AppStorage.setOrCreate('workCardId', '');
    AppStorage.setOrCreate('appToastText', '');
    Theme.applyBrandPrimary('#1A2A6C');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions', 'favorite');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    SessionStore.init(this.context).then(async () => {
      await AtelierProgress.init(this.context);
      await AtelierShelf.init(this.context);
      await AtelierPractice.init(this.context);
      const manualDark = await AtelierProgress.readDarkPref();
      if (manualDark === null) {
        ThemeAppearance.apply('system', this.context);
      } else {
        ThemeAppearance.apply(manualDark ? 'dark' : 'light', this.context);
      }
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    }).catch(() => {
      ThemeAppearance.apply('system', this.context);
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
