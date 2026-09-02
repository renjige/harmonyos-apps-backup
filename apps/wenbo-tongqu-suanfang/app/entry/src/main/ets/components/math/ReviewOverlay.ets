import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { pasteboard } from '@kit.BasicServicesKit'
import { MathBizService } from '../../services/MathBizService'

@Component
export struct ReviewOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State period: string = 'week'
  @State body: string = ''
  @State copied: boolean = false
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.body = MathBizService.periodReport(this.period)
  }

  private setPeriod(p: string): void {
    this.period = p
    this.reload()
  }

  private copy(): void {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.body)
      pasteboard.getSystemPasteboard().setData(data)
      this.copied = true
      setTimeout(() => { this.copied = false }, 2000)
    } catch {
    }
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44).height(44).justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text('学习回顾')
          .fontSize(Theme.type.title3).fontWeight(FontWeight.Medium)
          .layoutWeight(1).textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%').padding({ left: Theme.space.s2, top: Theme.space.s2 })

      Row({ space: Theme.space.s3 }) {
        this.chip('今日', 'today')
        this.chip('本周', 'week')
        this.chip('本月', 'month')
      }
      .padding({ left: Theme.space.s6, right: Theme.space.s6, bottom: Theme.space.s3 })
      .width('100%')

      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Text(this.body)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          AppButton({
            label: this.copied ? '已复制' : '复制给家长',
            onTap: () => this.copy()
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  chip(label: string, id: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.period === id ? '#FFFFFF' : Theme.colors().textPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.period === id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => this.setPeriod(id))
  }
}
