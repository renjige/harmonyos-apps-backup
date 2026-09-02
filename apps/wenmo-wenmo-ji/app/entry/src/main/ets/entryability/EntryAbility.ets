import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { FavoriteLocalService } from '../services/FavoriteLocalService';
import { ReadTodayService } from '../services/ReadTodayService';
import { CheckinService } from '../services/CheckinService';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { FavoriteLocalService } from '../services/FavoriteLocalService';
import { ReadTodayService } from '../services/ReadTodayService';
import { CheckinService } from '../services/CheckinService';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '承德锐泓科技信息有限公司');
    AppStorage.setOrCreate('appDisplayName', '文墨集');
    AppStorage.setOrCreate('appTagline', '传统文化智慧阅读与个人知识库，每日文摘、智慧笔记、节气日历与学习打卡闭环');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('detailRoute', '');
    AppStorage.setOrCreate('whRefresh', 0);
    AppStorage.setOrCreate('minePanelOpen', false);
    AppStorage.setOrCreate('mainTabIndex', 0);
    AppStorage.setOrCreate('darkModeOn', false);
    AppStorage.setOrCreate('libraryCategoryFilter', '');
    AppStorage.setOrCreate('libraryAuthorFilter', '');
    AppStorage.setOrCreate('showQuoteSearch', false);
    AppStorage.setOrCreate('showThoughtSearch', false);
    AppStorage.setOrCreate('showFavorites', false);
    AppStorage.setOrCreate('showAuthorList', false);
    AppStorage.setOrCreate('showMessages', false);
    AppStorage.setOrCreate('showWriteThought', false);
    AppStorage.setOrCreate('writeThoughtId', '');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions', 'create_thought,sync_thoughts,add_favorite');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(async () => {;
            await FavoriteLocalService.init(this.context);
            await ReadTodayService.init(this.context);
            await CheckinService.init(this.context);
            const dark = AppStorage.get<boolean>('darkModeOn') === true;
            Theme.setColorMode(dark ? 'dark' : 'light');
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
