import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { ReminderService } from '../services/ReminderService';
import { BrowseHistoryService } from '../services/BrowseHistoryService';
import { ScoutNoteService } from '../services/ScoutNoteService';
import { WatchPlanService } from '../services/WatchPlanService';
import { StreakService } from '../services/StreakService';
import { QuizRecordService } from '../services/QuizRecordService';
import { CompareSetService } from '../services/CompareSetService';
import { WatchReviewService } from '../services/WatchReviewService';
import { AchievementService } from '../services/AchievementService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '魏文波');
    AppStorage.setOrCreate('appDisplayName', '球星风采');
    AppStorage.setOrCreate('appTagline', '体育人物工具：观赛计划、球探笔记、双星对比、知识挑战与赛事提醒');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('detailRoute', '');
    AppStorage.setOrCreate('detailToken', 0);
    AppStorage.setOrCreate('growthTick', 0);
    AppStorage.setOrCreate('notifyEnabled', true);
    AppStorage.setOrCreate('themeColorMode', 'system');
    Theme.applyBrandPrimary('#0EA5E9');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions',
      'follow_athlete,sync_favorites,share_card');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context);
    SessionStore.init(this.context).then(() => {
      return ReminderService.init(this.context);
    }).then(() => {
      return BrowseHistoryService.init(this.context);
    }).then(() => {
      return ScoutNoteService.init(this.context);
    }).then(() => {
      return WatchPlanService.init(this.context);
    }).then(() => {
      return StreakService.init(this.context);
    }).then(() => {
      return QuizRecordService.init(this.context);
    }).then(() => {
      return CompareSetService.init(this.context);
    }).then(() => {
      return WatchReviewService.init(this.context);
    }).then(() => {
      return AchievementService.init(this.context);
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

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }
}
