import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { XdStore } from '../services/XdStore'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AccessConfig } from '../config/AccessConfig'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('companyName', '小岛生活')
    AppStorage.setOrCreate('appDisplayName', '小岛慢记')
    AppStorage.setOrCreate('appTagline', '在忙碌世界里保留一座慢生活数字小岛')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('XdEntryId', '')
    AppStorage.setOrCreate('XdClipId', '')
    AppStorage.setOrCreate('XdThemeId', '')
    AppStorage.setOrCreate('XdEntryEditId', '')
    AppStorage.setOrCreate('XdEntryTemplate', 'blank')
    AppStorage.setOrCreate('XdEntryEditorOpen', false)
    AppStorage.setOrCreate('XdClipEditId', '')
    AppStorage.setOrCreate('XdClipEditorOpen', false)
    AppStorage.setOrCreate('XdThemeEditId', '')
    AppStorage.setOrCreate('XdThemeEditorOpen', false)
    AppStorage.setOrCreate('xdSearchOpen', false)
    AppStorage.setOrCreate('xdYearOpen', false)
    AppStorage.setOrCreate('xdDataRev', 0)
    AppStorage.setOrCreate('xdJumpJournalInbox', false)
    AppStorage.setOrCreate('xdActiveTab', 0)
    AccessConfig.applyLocalDefaults()
    Theme.applyBrandPrimary('#6B8FA3')
    AppContextService.setContext(this.context)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context)
    AppContextService.setContext(this.context)
    SessionStore.init(this.context).then(async () => {
      await XdStore.init(this.context)
      const profile = await XdStore.loadProfile()
      const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system'
      ThemeAppearance.apply(mode, this.context)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(async () => {
      await XdStore.init(this.context)
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
