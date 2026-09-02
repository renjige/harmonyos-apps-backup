import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct DetailShell {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  onBack: () => void = () => {}

  build() {
    Column() {
      Row() {
        Row({ space: 4 }) {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
          Text('返回')
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
        .onClick(() => this.onBack())
        .constraintSize({ minHeight: 44 })
        Blank()
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Blank()
        AppIcon({ name: 'close', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
          .onClick(() => this.onBack())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })
    }
    .width('100%')
  }
}
