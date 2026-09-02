import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { ObservationStore } from '../services/ObservationStore';
import { AppContextService } from '../services/AppContextService';
import { ReminderService } from '../services/ReminderService';
import { PrivacyService } from '../services/PrivacyService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { Theme } from '../components/design-system/Theme';
import { SessionStore } from '../services/SessionStore';
import { ObservationStore } from '../services/ObservationStore';
import { AppContextService } from '../services/AppContextService';
import { ReminderService } from '../services/ReminderService';
import { PrivacyService } from '../services/PrivacyService';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('companyName', '溪漫生活');
    AppStorage.setOrCreate('appDisplayName', '溪漫观');
    AppStorage.setOrCreate('appTagline', '让每一天的碎片生活，被智慧地看见');
    AppStorage.setOrCreate('tabBarHidden', false);
    Theme.applyBrandPrimary('#5B8C8C');
    AppContextService.setContext(this.context);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        AppContextService.setContext(this.context);
        SessionStore.init(this.context).then(async () => {;
            await ObservationStore.init(this.context);
            const profile = await ObservationStore.loadProfile();
            const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system';
            Theme.setColorMode(mode as 'light' | 'dark' | 'system');
            AppStorage.setOrCreate('colorMode', mode);
            if (mode === 'system') {;
                Theme.setForcedDark(this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
            };
            if (PrivacyService.isAccepted()) {;
                await ReminderService.syncFromProfile(this.context);
            };
            windowStage.loadContent('pages/Index', (err) => {;
                if (err.code) {;
                    hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
                };
            });
        }).catch(async () => {;
            await ObservationStore.init(this.context);
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
