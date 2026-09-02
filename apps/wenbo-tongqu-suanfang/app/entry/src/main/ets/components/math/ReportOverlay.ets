import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct ReportOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop body: string = ''
  @State copied: boolean = false
  onClose: () => void = () => {}

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
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text('给家长的周报')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%')
      .padding({ left: Theme.space.s2, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Text(this.body)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('可复制发给家人。这是陪伴记录，不排名。')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          AppButton({
            label: this.copied ? '已复制' : '复制周报',
            onTap: () => this.copy()
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
