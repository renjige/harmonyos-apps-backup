import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { Theme } from '../components/design-system/Theme'
import { SessionStore } from '../services/SessionStore'
import { SaituLocalStore } from '../services/SaituLocalStore'
import { SaituTrackStore } from '../services/SaituTrackStore'
import { SaituSportStore } from '../services/SaituSportStore'
import { SaituCheckInStore } from '../services/SaituCheckInStore'
import { SaituPlanStore } from '../services/SaituPlanStore'
import { SaituAchievementStore } from '../services/SaituAchievementStore'
import { AppContextService } from '../services/AppContextService'
import { PrivacyService } from '../services/PrivacyService'
import { ThemeAppearance } from '../services/ThemeAppearance'

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  private mainWin: window.Window | null = null

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate')
    AppStorage.setOrCreate('companyName', '赛途记')
    AppStorage.setOrCreate('appDisplayName', '赛途札记')
    AppStorage.setOrCreate('appTagline', '个人赛事档案与旅途成长记录，不是资讯流')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('themeEpoch', 0)
    AppStorage.setOrCreate('accessGuestWrite', true)
    AppStorage.setOrCreate('accessGuestBrowse', true)
    AppStorage.setOrCreate('accessMode', 'open_optional')
    AppStorage.setOrCreate('saituDetailOpen', false)
    AppStorage.setOrCreate('saituDetailRecordId', '')
    AppStorage.setOrCreate('saituEditorOpen', false)
    AppStorage.setOrCreate('saituEditorRecordId', '')
    AppStorage.setOrCreate('saituJourneyManageOpen', false)
    AppStorage.setOrCreate('saituMilestoneOpen', false)
    AppStorage.setOrCreate('saituMilestoneEditorOpen', false)
    AppStorage.setOrCreate('saituInsightDetailOpen', false)
    AppStorage.setOrCreate('saituSportDetailOpen', false)
    AppStorage.setOrCreate('saituSportEditorOpen', false)
    AppStorage.setOrCreate('saituAlbumDetailOpen', false)
    AppStorage.setOrCreate('saituAlbumEditorOpen', false)
    AppStorage.setOrCreate('saituFollowOpen', false)
    AppStorage.setOrCreate('saituEditorSession', 0)
    AppStorage.setOrCreate('saituSportEditorSession', 0)
    AppStorage.setOrCreate('saituMainTab', -1)
    Theme.applyBrandPrimary('#007AFF')
    AppContextService.setContext(this.context)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ThemeAppearance.applyStored(this.context)
    AppContextService.setContext(this.context)
    windowStage.getMainWindow().then((win: window.Window) => {
      this.mainWin = win
      ThemeAppearance.systemBarRefresh = (): void => {
        if (this.mainWin !== null) {
          this.applySystemBars(this.mainWin)
        }
      }
      try {
        win.setWindowLayoutFullScreen(false)
      } catch {
      }
      this.applySystemBars(win)
    })
    SessionStore.init(this.context).then(async () => {
      await SaituLocalStore.init(this.context)
      await SaituTrackStore.init(this.context)
      await SaituSportStore.init(this.context)
      await SaituCheckInStore.init(this.context)
      await SaituPlanStore.init(this.context)
      await SaituAchievementStore.init(this.context)
      const profile = await SaituLocalStore.loadProfile()
      const mode = profile.themeMode.length > 0 ? profile.themeMode : 'system'
      ThemeAppearance.apply(mode, this.context)
      AppStorage.setOrCreate('colorMode', mode)
      if (PrivacyService.isAccepted()) {
        AppStorage.setOrCreate('privacyAccepted', true)
      }
      if (this.mainWin !== null) {
        this.applySystemBars(this.mainWin)
      }
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    }).catch(async () => {
      await SaituLocalStore.init(this.context)
      await SaituTrackStore.init(this.context)
      await SaituSportStore.init(this.context)
      await SaituCheckInStore.init(this.context)
      await SaituPlanStore.init(this.context)
      await SaituAchievementStore.init(this.context)
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'loadContent failed: %{public}s', JSON.stringify(err))
        }
      })
    })
  }

  private applySystemBars(win: window.Window): void {
    const dark = Theme.isDark()
    const bg = dark ? '#0F172A' : '#F2F4F7'
    const fg = dark ? '#F8FAFC' : '#0F172A'
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
