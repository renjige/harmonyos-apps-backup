import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { pasteboard } from '@kit.BasicServicesKit'
import { ReviewService } from '../../services/ReviewService'

@Component
export struct ReviewPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State weekText: string = ''
  @State monthText: string = ''
  @State toastText: string = ''
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.weekText = await ReviewService.weekSummary()
    this.monthText = await ReviewService.monthSummary()
  }

  private async copyText(text: string): Promise<void> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      await pasteboard.getSystemPasteboard().setData(data)
      this.toastText = '回顾已复制到剪贴板'
    } catch {
      this.toastText = '复制失败'
    }
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  build() {
    Stack() {
      Column() {
        AppNavBar({ title: '学习回顾', onBack: (): void => { this.onClose() } })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Column({ space: 8 }) {
              Text('本周回顾')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(this.weekText)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              AppButton({
                label: '复制本周回顾',
                variant: 'secondary',
                onTap: (): void => { void this.copyText(this.weekText) }
              })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            Column({ space: 8 }) {
              Text('本月回顾')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(this.monthText)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              AppButton({
                label: '复制本月回顾',
                variant: 'secondary',
                onTap: (): void => { void this.copyText(this.monthText) }
              })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 16 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
