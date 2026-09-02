import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { ApiConfig } from '../config/ApiConfig'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { AppointmentLocalStore } from '../services/AppointmentLocalStore'
import { GrowthLocalStore } from '../services/GrowthLocalStore'
import { ThemeAppearance } from '../services/ThemeAppearance'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    hilog.info(0x0000, TAG, 'onCreate')
    ApiConfig.applyToAppStorage()
    AppStorage.setOrCreate('companyName', '魏文波')
    AppStorage.setOrCreate('appDisplayName', '约定提醒')
    AppStorage.setOrCreate('appTagline', '记录约定，智慧提醒，少遗漏')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('windowIsWide', false)
    AppStorage.setOrCreate('onboardingDone', false)
    AppStorage.setOrCreate('notifyEnabled', true)
    Theme.applyBrandPrimary('#1677FF')
    AccessConfig.applyDefaults('open_optional')
    AppStorage.setOrCreate('accessGuestWrite', true)
    AppStorage.setOrCreate('accessGateActions', 'sync')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context)
    SessionStore.init(this.context).then(() => {
      return AppointmentLocalStore.init(this.context)
    }).then(() => {
      return GrowthLocalStore.init(this.context)
    }).then(() => {
      windowStage.getMainWindow().then((win: window.Window) => {
        const size = win.getWindowProperties().windowRect
        AppStorage.setOrCreate('windowIsWide', size.width >= 840)
      }).catch(() => {
        AppStorage.setOrCreate('windowIsWide', false)
      })
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(() => {
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    })
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config)
  }
}
