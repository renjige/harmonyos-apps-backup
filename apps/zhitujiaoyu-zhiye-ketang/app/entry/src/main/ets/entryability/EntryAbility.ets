import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { FavoriteService } from '../services/FavoriteService';
import { LearnProgressService } from '../services/LearnProgressService';
import { StudyStatsService } from '../services/StudyStatsService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { FavoriteService } from '../services/FavoriteService';
import { LearnProgressService } from '../services/LearnProgressService';
import { StudyStatsService } from '../services/StudyStatsService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '职途教育科技有限公司');
    AppStorage.setOrCreate('appDisplayName', '职业课堂');
    AppStorage.setOrCreate('appTagline',
      '面向职场人士的职业能力提升平台，提供免费职业课程与智慧学习工具');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('careerRoute', '');
    AppStorage.setOrCreate('careerTick', 0);
    AppStorage.setOrCreate('mainTab', 0);
    AppStorage.setOrCreate('learnFilterCategory', '');
    AppStorage.setOrCreate('learnFilterTeacher', '');
    AppStorage.setOrCreate('searchQuery', '');
    AppStorage.setOrCreate('favoriteTick', 0);
    AppStorage.setOrCreate('progressTick', 0);
    AppStorage.setOrCreate('learnChapterIndex', -1);
    Theme.applyBrandPrimary('#1A2A6C');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions', 'favorite,submit_enrollment,sync');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(() => {;
            return FavoriteService.init(this.context);
        }).then(() => {;
            return LearnProgressService.init(this.context);
        }).then(() => {;
            return StudyStatsService.init(this.context);
        }).then(() => {;
            windowStage.loadContent('pages/Index', (err) => {;
                if (err.code) {;
                    hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
                };
            });
        }).catch(() => {;
            windowStage.loadContent('pages/Index', (err) => {;
                if (err.code) {;
                    hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
                };
            });
        });
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }
}
