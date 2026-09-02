import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessConfig } from '../config/AccessConfig';
import { SessionStore } from '../services/SessionStore';
import { XuLocalStore } from '../services/XuLocalStore';
import { ApiConfig } from '../config/ApiConfig';
import { Theme } from '../components/design-system/Theme';
import { ThemeAppearance } from '../services/ThemeAppearance';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0);
    hilog.info(0x0000, TAG, 'onCreate');
    AppStorage.setOrCreate('apiBaseUrl', ApiConfig.baseUrl());
    AppStorage.setOrCreate('allowDevHttp', false);
    AppStorage.setOrCreate('tenantId', ApiConfig.TENANT_ID);
    AppStorage.setOrCreate('companyName', '明序阁');
    AppStorage.setOrCreate('appDisplayName', '明序阁');
    AppStorage.setOrCreate('appTagline', '明以洞察，序以行远');
    AppStorage.setOrCreate('tabBarHidden', false);
    AppStorage.setOrCreate('xuAgendaId', '');
    AppStorage.setOrCreate('xuHabitId', '');
    AppStorage.setOrCreate('xuNoteId', '');
    AppStorage.setOrCreate('xuTipId', '');
    AppStorage.setOrCreate('xuAgendaEditOpen', false);
    AppStorage.setOrCreate('xuAgendaEditId', '');
    AppStorage.setOrCreate('xuAgendaEditDate', '');
    AppStorage.setOrCreate('xuAgendaFocusDate', '');
    AppStorage.setOrCreate('xuLocalStoreReady', 0);
    AppStorage.setOrCreate('xuDataEpoch', 0);
    AppStorage.setOrCreate('xuAgendaCount', 0);
    AppStorage.setOrCreate('xuHabitCount', 0);
    AppStorage.setOrCreate('xuNoteCount', 0);
    AppStorage.setOrCreate('xuHomeAgendaDone', 0);
    AppStorage.setOrCreate('xuHomeAgendaTotal', 0);
    AppStorage.setOrCreate('xuHomeAgendaHint', '去日程页添加');
    AppStorage.setOrCreate('xuHomeHabitDone', 0);
    AppStorage.setOrCreate('xuHomeHabitTotal', 0);
    AppStorage.setOrCreate('xuHomeHabitHint', '点我添加习惯');
    AppStorage.setOrCreate('xuHabitEditOpen', false);
    AppStorage.setOrCreate('xuNoteEditOpen', false);
    AppStorage.setOrCreate('xuDiagnoseOpen', false);
    AppStorage.setOrCreate('xuMessagesOpen', false);
    AccessConfig.applyDefaults('open_optional');
    AppStorage.setOrCreate('accessGuestWrite', true);
    AppStorage.setOrCreate('accessGateActions', 'sync_records');
    Theme.applyBrandPrimary('#1A2A3A');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context);
    void (async () => {
      try {
        await SessionStore.init(this.context);
      } catch {
        // SessionStore 内部已兜底
      }
      await XuLocalStore.init(this.context);
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        }
      });
    })();
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config);
  }
}
