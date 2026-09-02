import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { ApiConfig } from '../config/ApiConfig';
import { SessionStore } from '../services/SessionStore';
import { FavoriteLocalService } from '../services/FavoriteLocalService';
import { ReadTodayService } from '../services/ReadTodayService';
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
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    ApiConfig.applyToAppStorage();
    AppStorage.setOrCreate('companyName', '承德锐泓科技信息有限公司');
    AppStorage.setOrCreate('appDisplayName', '知语集');
    AppStorage.setOrCreate('appTagline', '轻量级智慧语录应用，每日精选金句浏览收藏分享，留白中的知性阅读体验');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('detailRoute', '');
    AppStorage.setOrCreate('whRefresh', 0);
    AppStorage.setOrCreate('minePanelOpen', false);
    AppStorage.setOrCreate('mainTabIndex', 0);
    AppStorage.setOrCreate('darkModeOn', false);
    AppStorage.setOrCreate('libraryCategoryFilter', '');
    AppStorage.setOrCreate('libraryAuthorFilter', '');
    AppStorage.setOrCreate('showQuoteSearch', false);
    AppStorage.setOrCreate('showFavorites', false);
    AppStorage.setOrCreate('showAuthorList', false);
    AppStorage.setOrCreate('showMessages', false);
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGateActions', 'add_favorite,sync_favorites');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(async () => {;
            await FavoriteLocalService.init(this.context);
            await ReadTodayService.init(this.context);
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
