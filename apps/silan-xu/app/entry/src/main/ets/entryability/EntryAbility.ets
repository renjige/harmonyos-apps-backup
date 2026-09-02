import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { SilanStore } from '../services/SilanStore'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AccessConfig } from '../config/AccessConfig'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('companyName', '思览文化')
    AppStorage.setOrCreate('appDisplayName', '思览叙')
    AppStorage.setOrCreate('appTagline', '整理阅读收获，沉淀个人思考档案')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('thoughtDetailId', '')
    AppStorage.setOrCreate('readingDetailId', '')
    AppStorage.setOrCreate('cardDetailId', '')
    AppStorage.setOrCreate('sparkDetailId', '')
    AppStorage.setOrCreate('themeDetailId', '')
    AppStorage.setOrCreate('editorOpen', false)
    AppStorage.setOrCreate('editorKind', '')
    AppStorage.setOrCreate('editorId', '')
    AppStorage.setOrCreate('searchOpen', false)
    AppStorage.setOrCreate('silanDataRev', 0)
    AccessConfig.applyLocalDefaults()
    Theme.applyBrandPrimary('#1E3A4C')
    AppContextService.setContext(this.context)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context)
    AppContextService.setContext(this.context)
    SessionStore.init(this.context).then(async () => {
      await SilanStore.init(this.context)
      const profile = await SilanStore.loadProfile()
      const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system'
      Theme.setColorMode(mode as 'light' | 'dark' | 'system')
      AppStorage.setOrCreate('colorMode', mode)
      if (mode === 'system') {
        Theme.setForcedDark(this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
      }
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(async () => {
      await SilanStore.init(this.context)
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
