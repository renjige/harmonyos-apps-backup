import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { SessionStore } from '../services/SessionStore'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { TreasureStore } from '../services/TreasureStore'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('themeEpoch', 0)
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('companyName', '珍藏空间')
    AppStorage.setOrCreate('appDisplayName', '珍藏空间')
    AppStorage.setOrCreate('appTagline', '为每一件值得留下的物品建立专属珍藏档案')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('treasureShowEditor', false)
    AppStorage.setOrCreate('treasureShowDetail', false)
    AppStorage.setOrCreate('treasureEditId', '')
    AppStorage.setOrCreate('treasureDetailId', '')
    AppStorage.setOrCreate('treasureSubPage', '')
    AppStorage.setOrCreate('treasureRev', 0)
    AppStorage.setOrCreate('treasureTabIndex', -1)
    AppStorage.setOrCreate('treasurePlanId', '')
    AppStorage.setOrCreate('treasureNoteId', '')
    AppStorage.setOrCreate('treasureAlbumId', '')
    AppStorage.setOrCreate('treasureDomainKey', '')
    AppStorage.setOrCreate('treasureCompareFirst', '')
    AppStorage.setOrCreate('treasureCompareSecond', '')
    AppStorage.setOrCreate('exploreFilterKind', '')
    AppStorage.setOrCreate('exploreFilterValue', '')
    AccessConfig.applyDefaults('open_optional')
    AppStorage.setOrCreate('accessGuestWrite', true)
    AppStorage.setOrCreate('accessAllowRegister', false)
    AppStorage.setOrCreate('accessGateActions', '')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context)
    SessionStore.init(this.context).then(() => {
      return TreasureStore.init(this.context)
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
