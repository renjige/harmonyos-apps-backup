import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { YunLocalStore } from '../services/YunLocalStore'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('companyName', '云水间')
    AppStorage.setOrCreate('appDisplayName', '云水间')
    AppStorage.setOrCreate('appTagline', '记录生活，也收藏片刻。')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('yunNoteDetailId', '')
    AppStorage.setOrCreate('yunNoteEditorId', '')
    AppStorage.setOrCreate('yunNoteEditorOpen', false)
    AppStorage.setOrCreate('yunTodoEditId', '')
    AppStorage.setOrCreate('yunSearchOpen', false)
    AppStorage.setOrCreate('yunCraftDetailId', '')
    AppStorage.setOrCreate('lifeCraftEditorId', '')
    AppStorage.setOrCreate('lifeCraftEditorKind', 'tip')
    AppStorage.setOrCreate('yunCraftEditorOpen', false)
    AppStorage.setOrCreate('lifeEditorTemplate', '')
    AppStorage.setOrCreate('lifeEditorCategory', '')
    AppStorage.setOrCreate('yunThemeTick', 0)
    AppStorage.setOrCreate('yunActiveTab', 0)
    Theme.applyBrandPrimary('#3D5A5C')
    AppContextService.setContext(this.context)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.lockSystemLight(this.context)
    ThemeAppearance.applyStored(this.context)
    AppContextService.setContext(this.context)
    SessionStore.init(this.context).then(async () => {
      await YunLocalStore.init(this.context)
      const dark = await YunLocalStore.isDarkMode()
      Theme.applyDark(dark)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(async () => {
      await YunLocalStore.init(this.context)
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

  onForeground(): void {
    AppContextService.setContext(this.context)
  }
}
