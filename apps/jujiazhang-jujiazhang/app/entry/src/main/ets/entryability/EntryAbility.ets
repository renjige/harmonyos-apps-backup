import { AbilityConstant, Configuration, UIAbility, Want, bundleManager } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { TaskLocalStore } from '../services/TaskLocalStore';
import { JujiaLocalStore } from '../services/JujiaLocalStore';
import { ThemeAppearance } from '../services/ThemeAppearance';
import { ReminderService } from '../services/ReminderService';
import { FeedbackService } from '../services/FeedbackService';
import { WelcomeSeedService } from '../services/WelcomeSeedService';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '居家章');
    AppStorage.setOrCreate('appDisplayName', '居家章');
    AppStorage.setOrCreate('appTagline', '家庭生活工作台 — 场景包、物品、备忘、成长统计一站协同');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('windowIsWide', false);
    AppStorage.setOrCreate('onboardingDone', false);
    AppStorage.setOrCreate('notifyEnabled', true);
    AppStorage.setOrCreate('appearance', 'system');
    AppStorage.setOrCreate('themeRevision', 0);
    AppStorage.setOrCreate('defaultReminder', 'none');
    Theme.applyBrandPrimary('#FF6B35');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', 'sync_records');
    AppStorage.setOrCreate('appVersionName', '1.7.0');
    AppStorage.setOrCreate('mainTabIndex', 0);
    AppStorage.setOrCreate('lifeHubSegment', 'memo');
    AppStorage.setOrCreate('dataRefreshEpoch', 0);
    void bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
      .then((info) => {
        AppStorage.setOrCreate('appVersionName', info.versionName);
        AppStorage.setOrCreate('appVersionCode', info.versionCode);
      }).catch(() => {
        AppStorage.setOrCreate('appVersionName', '1.7.0');
      });
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    SessionStore.init(this.context).then(() => {
      return TaskLocalStore.init(this.context);
    }).then(() => {
      return JujiaLocalStore.init(this.context);
    }).then(() => {
      return FeedbackService.init(this.context);
    }).then(() => {
      return WelcomeSeedService.init(this.context);
    }).then(() => {
      return WelcomeSeedService.seedGuideContentIfNeeded();
    }).then(() => {
      ThemeAppearance.applyStored(this.context);
      void ReminderService.syncAll(this.context);
      windowStage.getMainWindow().then((win: window.Window) => {
        const size = win.getWindowProperties().windowRect;
        AppStorage.setOrCreate('windowIsWide', size.width >= 840);
      }).catch(() => {
        AppStorage.setOrCreate('windowIsWide', false);
      });
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

  onForeground(): void {
    void ReminderService.deliverDueReminders(this.context);
    void ReminderService.syncAll(this.context);
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }
}
