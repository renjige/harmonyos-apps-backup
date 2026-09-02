import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { PortfolioStore } from '../services/PortfolioStore';
import { ProfileStore } from '../services/ProfileStore';
import { VisitStatsService } from '../services/VisitStatsService';
import { SettingsService } from '../services/SettingsService';
import { PrivacyService } from '../services/PrivacyService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { PortfolioStore } from '../services/PortfolioStore';
import { ProfileStore } from '../services/ProfileStore';
import { VisitStatsService } from '../services/VisitStatsService';
import { SettingsService } from '../services/SettingsService';
import { PrivacyService } from '../services/PrivacyService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('companyName', '墨展工作室');
    AppStorage.setOrCreate('appDisplayName', '展格创作集');
    AppStorage.setOrCreate('appTagline', '个人创作者的数字化作品展厅，专业优雅呈现创作成果');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('openSettingsTab', false);
    AccessConfig.applyDefaults('open_optional');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(async () => {;
            await PortfolioStore.init(this.context);
            await ProfileStore.init(this.context);
            await VisitStatsService.init(this.context);
            await SettingsService.init(this.context);
            if (PrivacyService.isAccepted()) {;
                await VisitStatsService.recordVisit();
            };
            const theme = await SettingsService.getThemeMode();
            if (theme === 'dark') {;
                Theme.setColorMode('dark');
                AppStorage.setOrCreate('colorMode', 'dark');
            };
            else if (theme === 'light') {;
                Theme.setColorMode('light');
                AppStorage.setOrCreate('colorMode', 'light');
            };
            else {;
                Theme.setColorMode('system');
            };
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
