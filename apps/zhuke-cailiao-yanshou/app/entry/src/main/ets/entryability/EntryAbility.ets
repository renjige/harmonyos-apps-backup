import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { InspectLocalStore } from '../services/InspectLocalStore';
import { BrandIdentity } from '../config/BrandIdentity';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('themeEpoch', 0);
    AppStorage.setOrCreate('companyName', BrandIdentity.company());
    AppStorage.setOrCreate('appDisplayName', BrandIdentity.appName());
    AppStorage.setOrCreate('appTagline', BrandIdentity.tagline());
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('inspectNavMode', '');
    AppStorage.setOrCreate('inspectNavId', '');
    AppStorage.setOrCreate('inspectExtraMode', '');
    AppStorage.setOrCreate('inspectExtraKey', '');
    AppStorage.setOrCreate('inspectBoardFilter', '');
    AppStorage.setOrCreate('inspectTick', 0);
    AppStorage.setOrCreate('homeTodayTotal', 0);
    AppStorage.setOrCreate('homeTodayDone', 0);
    AppStorage.setOrCreate('homeTodayPending', 0);
    AppStorage.setOrCreate('homeFollowCount', 0);
    AppStorage.setOrCreate('colorModeTick', 0);
    AppStorage.setOrCreate('systemIsDark', false);
    AccessConfig.applyDefaults('open_optional');
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context);
    const dark = this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    AppStorage.setOrCreate('systemIsDark', dark);
    Theme.setForcedDark(dark);
    SessionStore.init(this.context).then(() => {
      return InspectLocalStore.init(this.context);
    }).then(() => {
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
}
