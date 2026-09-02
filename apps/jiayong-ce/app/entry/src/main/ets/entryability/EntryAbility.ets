import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { SessionStore } from '../services/SessionStore'
import { AlbumStore } from '../services/AlbumStore'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('themeEpoch', 0)
    AppStorage.setOrCreate('companyName', '温馨家记')
    AppStorage.setOrCreate('appDisplayName', '家用册')
    AppStorage.setOrCreate('appTagline', '一家人的记忆，一本就够了')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('albumShowUpload', false)
    AppStorage.setOrCreate('albumShowDetail', false)
    AppStorage.setOrCreate('albumShowFilter', false)
    AppStorage.setOrCreate('albumShowRecap', false)
    AppStorage.setOrCreate('albumShowSearch', false)
    AppStorage.setOrCreate('albumDetailId', '')
    AppStorage.setOrCreate('albumFilterKind', 'all')
    AppStorage.setOrCreate('albumFilterValue', '')
    AppStorage.setOrCreate('albumRev', 0)
    AccessConfig.applyDefaults('open_optional')
    AppStorage.setOrCreate('accessGuestWrite', true)
    AppStorage.setOrCreate('accessAllowRegister', false)
    AppStorage.setOrCreate('accessGateActions', '')
    Theme.setColorMode('system')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context)
    SessionStore.init(this.context).then(() => {
      return AlbumStore.init(this.context)
    }).then(() => {
      const settings = AlbumStore.settings()
      ThemeAppearance.apply(settings.colorMode, this.context)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed')
        }
      })
    }).catch(() => {
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed')
        }
      })
    })
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config)
  }
}
