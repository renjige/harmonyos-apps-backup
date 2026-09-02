import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { WorkshopStore } from '../services/WorkshopStore';
import { CraftLocalStore } from '../services/CraftLocalStore';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('apiBaseUrl', ApiConfig.baseUrl());
    AppStorage.setOrCreate('tenantId', ApiConfig.tenantId());
    AppStorage.setOrCreate('allowDevHttp', false);
    AppStorage.setOrCreate('companyName', '心笺生活美学');
    AppStorage.setOrCreate('appDisplayName', '手作心笺');
    AppStorage.setOrCreate('appTagline', '手作记录与生活美学工具，温暖记录每一次创作灵感');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('craftDetailWorkId', '');
    AppStorage.setOrCreate('craftDetailToken', 0);
    Theme.applyBrandPrimary('#D4A5A5');
    AccessConfig.applyDefaults('open_optional');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context);
    SessionStore.init(this.context).then(async () => {
      await WorkshopStore.init(this.context);
      await CraftLocalStore.init(this.context);
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    }).catch(async () => {
      await WorkshopStore.init(this.context);
      await CraftLocalStore.init(this.context);
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
