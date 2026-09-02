import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { SessionStore } from '../services/SessionStore'
import { ZhixingStore } from '../services/ZhixingStore'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('apiBaseUrl', 'https://saas16.qianqi.online/api/v1')
    AppStorage.setOrCreate('tenantId', 'wenbo-zhixing-ye')
    AppStorage.setOrCreate('allowDevHttp', false)
    AppStorage.setOrCreate('companyName', '承德锐泓科技信息有限公司')
    AppStorage.setOrCreate('appDisplayName', '知行页')
    AppStorage.setOrCreate('appTagline', '把知识沉淀为卡片与图谱，再转化为计划、习惯与行动日志的知行合一学习工具')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('dataEpoch', 0)
    AppStorage.setOrCreate('themeEpoch', 0)
    AccessConfig.applyDefaults('open_optional')
    AppStorage.setOrCreate('accessGuestWrite', true)
    Theme.applyBrandPrimary('#2D3B66')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context)
    SessionStore.init(this.context).then(async () => {
      await ZhixingStore.init(this.context)
      const dark = await ZhixingStore.loadDark()
      ThemeAppearance.apply(dark ? 'dark' : 'light', this.context)
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
