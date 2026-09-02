import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { ReminderLocalStore } from '../services/ReminderLocalStore';
import { FollowWidgetStore } from '../services/FollowWidgetStore';
import { TeamNoteStore } from '../services/TeamNoteStore'
import { ResearchStore } from '../services/ResearchStore';
import { SportsBizService } from '../services/SportsBizService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '球队研判');
    AppStorage.setOrCreate('appTagline', '球队数据研究与球迷分析：状态、对比、交锋、图表与关注跟踪');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('detailRoute', '');
    AppStorage.setOrCreate('detailStack', '');
    AppStorage.setOrCreate('notifyEnabled', true);
    AppStorage.setOrCreate('defaultRemindMinutes', 30);
    Theme.applyBrandPrimary('#1677FF');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions', 'follow_team,follow_match,set_reminder,share_card,sync_favorites');
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    SessionStore.init(this.context).then(() => {
      ThemeAppearance.applyStored(this.context);
      return FollowWidgetStore.init(this.context);
    }).then(() => {
      return TeamNoteStore.init(this.context);
    }).then(() => {
      return ResearchStore.init(this.context);
    }).then(() => {
      return ReminderLocalStore.init(this.context);
    }).then(() => {
      void SportsBizService.syncFollowWidget();
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        } else {
          ThemeAppearance.applyStored(this.context);
        }
      });
    }).catch(() => {
      ThemeAppearance.applyStored(this.context);
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        } else {
          ThemeAppearance.applyStored(this.context);
        }
      });
    });
  }
}
