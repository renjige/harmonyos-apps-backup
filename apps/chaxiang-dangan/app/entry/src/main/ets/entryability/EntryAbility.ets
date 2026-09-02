import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { SessionStore } from '../services/SessionStore'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { TeaStore } from '../services/TeaStore'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('companyName', '茶香印记')
    AppStorage.setOrCreate('appDisplayName', '茶香档案')
    AppStorage.setOrCreate('appTagline', '记下每一款茶的香气与故事')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('teaDetailId', '')
    AppStorage.setOrCreate('tastingDetailId', '')
    AppStorage.setOrCreate('teaEditorOpen', false)
    AppStorage.setOrCreate('teaEditorId', '')
    AppStorage.setOrCreate('tastingEditorOpen', false)
    AppStorage.setOrCreate('tastingEditorTeaId', '')
    AppStorage.setOrCreate('tastingEditorId', '')
    AppStorage.setOrCreate('searchOpen', false)
    AppStorage.setOrCreate('listSheetOpen', false)
    AppStorage.setOrCreate('albumSheetOpen', false)
    AppStorage.setOrCreate('planSheetOpen', false)
    AppStorage.setOrCreate('organizeOpen', false)
    AppStorage.setOrCreate('tagSheetOpen', false)
    AppStorage.setOrCreate('teaRev', 0)
    AccessConfig.applyLocalArchiveDefaults()
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context)
    SessionStore.init(this.context).then(() => {
      return TeaStore.init(this.context)
    }).then(() => {
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
