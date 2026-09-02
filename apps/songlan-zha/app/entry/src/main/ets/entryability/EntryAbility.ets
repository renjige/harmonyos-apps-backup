import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { SessionStore } from '../services/SessionStore';
import { ZhaLocalStore } from '../services/ZhaLocalStore';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { SessionStore } from '../services/SessionStore';
import { ZhaLocalStore } from '../services/ZhaLocalStore';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('companyName', '松岚札');
    AppStorage.setOrCreate('appDisplayName', '松岚札');
    AppStorage.setOrCreate('appTagline', '智慧生活记录与轻量笔记工具，帮助用户优雅记录灵感、管理待办、沉淀思考');
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', '');
    AppStorage.setOrCreate('zhaNoteDetailId', '');
    AppStorage.setOrCreate('zhaNoteEditorId', '');
    AppStorage.setOrCreate('zhaNoteEditorOpen', false);
    AppStorage.setOrCreate('zhaJournalCalendarOpen', false);
    AppStorage.setOrCreate('zhaJournalDetailKey', '');
    AppStorage.setOrCreate('zhaTodoEditId', '');
    AppStorage.setOrCreate('zhaThemeTick', 0);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      ThemeAppearance.applyStored(this.context);

        SessionStore.init(this.context).then(async () => {;
            await ZhaLocalStore.init(this.context);
            const dark = await ZhaLocalStore.isDarkMode();
            Theme.applyDark(dark);
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
