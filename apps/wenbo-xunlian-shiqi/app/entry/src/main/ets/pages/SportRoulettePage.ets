import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { SolidButton } from '../components/design-system/SolidButton'
import { PlayPick } from '../models/PlayModels'
import { SportRouletteService } from '../services/SportRouletteService'

@Component
export struct SportRoulettePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: PlayPick = new PlayPick()
  @State spinning: boolean = false
  @State spinTick: number = 0
  onClose: () => void = () => {}
  onAction: (action: string) => void = () => {}

  aboutToAppear(): void {
    this.current = SportRouletteService.spin()
  }

  private spin(): void {
    if (this.spinning) {
      return
    }
    this.spinning = true
    this.spinTick = 0
    this.runSpinStep()
  }

  private runSpinStep(): void {
    this.current = SportRouletteService.spin()
    this.spinTick += 1
    if (this.spinTick < 12) {
      setTimeout((): void => { this.runSpinStep() }, 90 + this.spinTick * 8)
      return
    }
    this.spinning = false
  }

  build() {
    Column() {
      Row() {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.onClose() })
        Text('今天玩什么')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Column({ space: Theme.space.s5 }) {
        Text('随机抽一种运动玩法')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
        Column({ space: Theme.space.s3 }) {
          Text(this.current.title.length > 0 ? this.current.title : '点下方开始抽取')
            .fontSize(Theme.type.title1)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
            .textAlign(TextAlign.Center)
          Text(this.current.hint)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .textAlign(TextAlign.Center)
            .lineHeight(22)
            .padding({ left: Theme.space.s4, right: Theme.space.s4 })
        }
        .width('100%')
        .padding(Theme.space.s6)
        .backgroundColor(Theme.cardBg(this.themeEpoch))
        .borderRadius(Theme.radius.xl)
        .border({ width: 1, color: Theme.colors().strokeHairline })

        SolidButton({
          label: this.spinning ? '抽取中…' : '再抽一次',
          tone: 'secondary',
          onTap: (): void => { this.spin() }
        })
        SolidButton({
          label: '就去玩这个',
          tone: 'primary',
          onTap: (): void => {
            if (this.current.action.length > 0) {
              this.onAction(this.current.action)
            }
          }
        })

        Text('覆盖跟练、呼吸、图鉴、挑战、笔记、目标、清单、复盘等场景，不是只写计划。')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .lineHeight(18)
          .width('100%')
      }
      .layoutWeight(1)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.pageBg(this.themeEpoch))
    .zIndex(26)
  }
}
