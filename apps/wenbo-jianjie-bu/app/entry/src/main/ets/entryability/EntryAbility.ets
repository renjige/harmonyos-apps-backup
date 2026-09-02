import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AccessConfig } from '../config/AccessConfig'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { InsightStore } from '../services/InsightStore'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  private mainWin: window.Window | null = null

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('themeEpoch', 0)
    AppStorage.setOrCreate('companyName', '承德锐泓科技信息有限公司')
    AppStorage.setOrCreate('appDisplayName', '见解簿')
    AppStorage.setOrCreate('appTagline', '智慧记录，沉淀洞见')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('themeRevision', 0)
    AppStorage.setOrCreate('appearance', 'system')
    AppStorage.setOrCreate('entryStamp', 0)
    AppStorage.setOrCreate('lastAchievementUnlock', '')
    AppStorage.setOrCreate('achievementToastAt', 0)
    Theme.applyBrandPrimary('#6C5CE7')
    AccessConfig.applyDefaults('open_optional')
    AppStorage.setOrCreate('accessGuestWrite', true)
    AppContextService.setContext(this.context)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context)
    AppContextService.setContext(this.context)
    void this.bootstrap(windowStage)
  }

  private async bootstrap(windowStage: window.WindowStage): Promise<void> {
    try {
      await SessionStore.init(this.context)
    } catch {
    }
    try {
      await InsightStore.init(this.context)
      const profile = await InsightStore.loadProfile()
      const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system'
      ThemeAppearance.apply(mode, this.context)
    } catch {
      await InsightStore.init(this.context)
    }
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
      }
    })
    windowStage.getMainWindow().then((win: window.Window) => {
      this.mainWin = win
      try {
        win.setWindowLayoutFullScreen(false)
      } catch {
      }
      this.applySystemBars(win)
    })
  }

  private applySystemBars(win: window.Window): void {
    const dark = Theme.isDark()
    const bg = dark ? '#1A1A1A' : '#F8F6F3'
    const fg = dark ? '#F5F3EE' : '#1A1A1A'
    const props: window.SystemBarProperties = {
      statusBarColor: bg,
      statusBarContentColor: fg,
      navigationBarColor: bg,
      navigationBarContentColor: fg
    }
    win.setWindowSystemBarProperties(props).catch(() => {
    })
  }

  onConfigurationUpdate(config: Configuration): void {
    ThemeAppearance.onSystemConfiguration(config)
    if (this.mainWin !== null) {
      this.applySystemBars(this.mainWin)
    }
  }
}
