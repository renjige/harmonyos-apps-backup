import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { BowenStore } from '../services/BowenStore'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AccessConfig } from '../config/AccessConfig'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('companyName', '博闻文化')
    AppStorage.setOrCreate('appDisplayName', '博闻阁')
    AppStorage.setOrCreate('appTagline', '广泛收集，深度沉淀——个人知识档案与学习整理空间')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('thoughtDetailId', '')
    AppStorage.setOrCreate('readingDetailId', '')
    AppStorage.setOrCreate('cardDetailId', '')
    AppStorage.setOrCreate('sparkDetailId', '')
    AppStorage.setOrCreate('themeDetailId', '')
    AppStorage.setOrCreate('studyDetailId', '')
    AppStorage.setOrCreate('editorOpen', false)
    AppStorage.setOrCreate('editorKind', '')
    AppStorage.setOrCreate('editorId', '')
    AppStorage.setOrCreate('searchOpen', false)
    AppStorage.setOrCreate('bowenDataRev', 0)
    AccessConfig.applyLocalDefaults()
    Theme.applyBrandPrimary('#1A3347')
    AppContextService.setContext(this.context)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context)
    AppContextService.setContext(this.context)
    SessionStore.init(this.context).then(async () => {
      await BowenStore.init(this.context)
      const profile = await BowenStore.loadProfile()
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
      await BowenStore.init(this.context)
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
