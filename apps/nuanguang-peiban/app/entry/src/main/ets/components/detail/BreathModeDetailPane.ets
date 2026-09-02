import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { WarmMediaHero } from '../warm/WarmMediaHero'
import { DetailShell } from './DetailShell'
import { BreathModeItem } from '../../models/WarmCompanionModels'
import { WarmCompanionBizService } from '../../services/WarmCompanionBizService'
import { WarmCompanionNav } from '../../services/WarmCompanionNav'

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
    this.item = await WarmCompanionBizService.findBreathMode(this.modeId)
    this.loading = false
  }

  build() {
    if (this.loading) {
      Column() { AppLoading({ label: '打开呼吸模式' }) }
        .width('100%').height('100%').justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    } else if (this.item === undefined) {
      DetailShell({ title: '呼吸引导', onClose: (): void => WarmCompanionNav.close() }) {
        AppEmpty({ title: '模式不存在', iconName: 'heart', emojiMark: '🧘' })
      }
    } else {
      DetailShell({
        title: this.item.title,
        contentKey: this.modeId,
        onClose: (): void => WarmCompanionNav.close()
      }) {
        Column({ space: Theme.space.s4 }) {
          WarmMediaHero({
            coverKey: this.item.coverKey.length > 0 ? this.item.coverKey : 'cover_breath_soft',
            overline: '🧘 呼吸引导',
            title: this.item.title,
            bannerHeight: 180
          })

          Column({ space: 8 }) {
            Text(`${this.item.rhythmLabel} · ${this.item.rounds} 轮 · 约 ${Math.floor(this.item.totalSeconds() / 60)} 分钟`)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
            Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Column({ space: Theme.space.s3 }) {
            AppButton({
              label: '开始引导',
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
