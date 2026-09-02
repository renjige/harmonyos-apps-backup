import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { GewuStore } from '../services/GewuStore';
import { AppContextService } from '../services/AppContextService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('companyName', '格物文化');
    AppStorage.setOrCreate('appDisplayName', '格物集');
    AppStorage.setOrCreate('appTagline', '每日一物，格物致知——在碎片化时间完成有深度、有体系的知识探索与集册沉淀');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('openDetailId', '');
    AppStorage.setOrCreate('openRecordId', '');
    AppStorage.setOrCreate('recordEditorId', '');
    AppStorage.setOrCreate('detailRefreshToken', 0);
    AppStorage.setOrCreate('themeRevision', 0);
    AppStorage.setOrCreate('switchTabIndex', -1);
    AppStorage.setOrCreate('folioListMode', 'all');
    AppStorage.setOrCreate('folioAtlasFilter', 'all');
    AppStorage.setOrCreate('gewuLegalKind', '');
    AppStorage.setOrCreate('recordDateFilter', '');
    AppStorage.setOrCreate('traceSettingsOpen', false);
    AppStorage.setOrCreate('practiceSheet', '');
    AppStorage.setOrCreate('practiceFocusId', '')
    AppStorage.setOrCreate('homeRefreshTick', 0);
    Theme.applyBrandPrimary('#1A3A5C');
    AccessConfig.applyDefaults('open_optional', false);
    AppContextService.setContext(this.context);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppContextService.setContext(this.context);
    SessionStore.init(this.context).then(async () => {
      await GewuStore.init(this.context);
      const profile = await GewuStore.loadProfile();
      const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system';
      ThemeAppearance.apply(mode, this.context);
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    }).catch(async () => {
      await GewuStore.init(this.context);
      ThemeAppearance.apply('system', this.context);
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    });
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    ThemeAppearance.onSystemConfiguration(newConfig);
  }
}
