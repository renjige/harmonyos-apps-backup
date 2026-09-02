import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { SessionStore } from '../services/SessionStore';
import { ThoughtStore } from '../services/ThoughtStore';
import { ThinkStore } from '../services/ThinkStore';
import { AppContextService } from '../services/AppContextService';
import { ThemeAppearance } from '../services/ThemeAppearance';
import { GrowthStatHub } from '../services/GrowthStatHub';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('apiBaseUrl', 'https://saas16.qianqi.online/api/v1');
    AppStorage.setOrCreate('allowDevHttp', false);
    AppStorage.setOrCreate('tenantId', 'siwei-xia');
    AppStorage.setOrCreate('companyName', '思维匣');
    AppStorage.setOrCreate('appDisplayName', '思维匣');
    AppStorage.setOrCreate('appTagline', '把碎片想法收进匣子，用标签层级展开成思维导图');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('tbReload', 0);
    GrowthStatHub.initDefaults();
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', 'sync_notes');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context);
    AppContextService.setContext(this.context);
    void (async (): Promise<void> => {
      try {
        await SessionStore.init(this.context);
      } catch {
      }
      await ThoughtStore.init(this.context);
      await ThinkStore.init(this.context);
      await ThinkStore.syncGrowthToAppStorage();
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    })();
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }
}
