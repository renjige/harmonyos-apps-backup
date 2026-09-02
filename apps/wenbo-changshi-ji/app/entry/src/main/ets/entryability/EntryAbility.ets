import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { CommonSenseStore } from '../services/CommonSenseStore';
import { CommonSenseFactsCache } from '../services/CommonSenseFactsCache';
import { CommonSenseLocalService } from '../services/CommonSenseLocalService';
import { LearningHubService } from '../services/LearningHubService';
import { ThemeAppearance } from '../services/ThemeAppearance';
import { Theme } from '../components/design-system/Theme';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '常识集');
    AppStorage.setOrCreate('appTagline', '每日一条精选常识，按日历积累、分类检索、收藏笔记，让生活智慧触手可及。');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('detailRoute', '');
    AppStorage.setOrCreate('detailToken', 0);
    AppStorage.setOrCreate('showMineSettings', false);
    AppStorage.setOrCreate('csRefresh', 0);
    AppStorage.setOrCreate('mainTabIndex', 0);
    AppStorage.setOrCreate('fontScale', 1.0);
    AppStorage.setOrCreate('factsLoadSource', 'pending');
    AppStorage.setOrCreate('factsLoadHint', '');
    Theme.applyBrandPrimary('#007AFF');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', 'sync_favorites');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context);
    SessionStore.init(this.context).then(async () => {
      await CommonSenseStore.init(this.context);
      await CommonSenseLocalService.init(this.context);
      await LearningHubService.init(this.context);
      await CommonSenseFactsCache.init(this.context);
      const dark = AppStorage.get<boolean>('darkModeOn') === true;
      ThemeAppearance.apply(dark ? 'dark' : 'light', this.context);
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
