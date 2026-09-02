import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { YouyuStore } from '../services/YouyuStore';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '悠隅生活');
    AppStorage.setOrCreate('appDisplayName', '悠隅纪');
    AppStorage.setOrCreate('appTagline', '静谧一隅，温柔记录生活美好瞬间的私密智慧空间');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('youyuShowCompose', false);
    AppStorage.setOrCreate('youyuShowDetail', false);
    AppStorage.setOrCreate('youyuShowTags', false);
    AppStorage.setOrCreate('youyuComposeId', '');
    AppStorage.setOrCreate('youyuDetailId', '');
    AppStorage.setOrCreate('youyuRev', 0);
    AppStorage.setOrCreate('youyuHomeFilter', '');
    AppStorage.setOrCreate('youyuOpenMineSettings', false);
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', 'sync_account');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    SessionStore.init(this.context).then(async () => {
      ThemeAppearance.applyStored(this.context);
      await YouyuStore.init(this.context);
      const dark = AppStorage.get<boolean>('darkModeOn') === true;
      Theme.setColorMode(dark ? 'dark' : 'light');
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
