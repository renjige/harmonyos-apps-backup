import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { SymbolHero } from '../design-system/SymbolVisual'
import { DetailShell } from './DetailShell'
import { BreathModeItem } from '../../models/CoolPlanModels'
import { CoolPlanBizService } from '../../services/CoolPlanBizService'
import { CoolPlanNav } from '../../services/CoolPlanNav'

@Component
export struct BreathModeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onModeIdChange') modeId: string = ''
  @Prop @Watch('onModeIdChange') refreshToken: number = 0
  @State item: BreathModeItem | undefined = undefined
  @State loading: boolean = true
  onStart: (modeId: string) => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onModeIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await CoolPlanBizService.findBreathMode(this.modeId)
    this.loading = false
  }

  build() {
    if (this.loading) {
      Column() { AppLoading({ label: '打开呼吸模式' }) }
        .width('100%').height('100%').justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    } else if (this.item === undefined) {
      DetailShell({ title: '呼吸模式', onClose: (): void => CoolPlanNav.close() }) {
        AppEmpty({ title: '模式不存在', iconName: 'heart', emojiMark: '🧘' })
      }
    } else {
      DetailShell({
        title: this.item.title,
        contentKey: this.modeId,
        onClose: (): void => CoolPlanNav.close()
      }) {
        Column({ space: Theme.space.s4 }) {
          SymbolHero({
            category: this.item.title,
            coverKey: this.item.coverKey.length > 0 ? this.item.coverKey : 'hero_breath_calm',
            overline: '🌿 智慧呼吸',
            title: this.item.title,
            bannerHeight: 200
          })

          Column({ space: 8 }) {
            Text(`节奏 ${this.item.rhythmLabel} · ${this.item.rounds} 轮 · 约 ${Math.ceil(this.item.totalSeconds() / 60)} 分钟`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
            Text(this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.item.body)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text('呼吸练习仅供放松参考，不替代医疗建议。感到不适请立即停止。')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Column({ space: Theme.space.s3 }) {
            AppButton({
              label: '开始练习',
              onTap: (): void => {
                if (this.item !== undefined) {
                  this.onStart(this.item.id)
                }
              }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .width('100%')
      }
    }
  }
}
