import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { SessionStore } from '../services/SessionStore';
import { MomentStore } from '../services/MomentStore';
import { AppContextService } from '../services/AppContextService';
import { AccessConfig } from '../config/AccessConfig';
import { ThemeAppearance } from '../services/ThemeAppearance';
import { Theme } from '../components/design-system/Theme';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    AppStorage.setOrCreate('momentDataEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('companyName', '承德锐泓科技有限公司');
    AppStorage.setOrCreate('appDisplayName', '小事记');
    AppStorage.setOrCreate('appTagline', '30秒捕捉生活里的小确幸、灵感碎片与待办点滴，让记录简单而美好');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('momentNavKind', 'none');
    AppStorage.setOrCreate('momentNavId', '');
    AppStorage.setOrCreate('momentNavToken', 0);
    AppStorage.setOrCreate('noteDraftSeed', '');
    AppStorage.setOrCreate('noteDraftTag', '');
    Theme.applyBrandPrimary('#C44A22');
    AppContextService.setContext(this.context);
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    const sysDark = this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    AppStorage.setOrCreate('systemColorDark', sysDark);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppContextService.setContext(this.context);
    SessionStore.init(this.context).then(async () => {
      await MomentStore.init(this.context);
      await MomentStore.ensureFirstUse();
      const profile = await MomentStore.loadProfile();
      const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system';
      ThemeAppearance.apply(mode, this.context);
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    }).catch(async () => {
      await MomentStore.init(this.context);
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
