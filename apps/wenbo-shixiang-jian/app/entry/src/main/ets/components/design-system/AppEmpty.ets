import { Theme } from './Theme'
import { SketchStyle } from './SketchStyle'
import { AppButton } from './AppButton'
import { AppIcon } from './AppIcon'
import { SketchNote } from './SketchNote'

@Component
export struct AppEmpty {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '暂无内容'
  @Prop description: string = '当前还没有可展示的数据'
  @Prop actionLabel: string = ''
  onAction: () => void = () => {}

  build() {
    SketchNote({ noteIndex: 4, interactive: true }) {
      Column({ space: Theme.space.s3 }) {
        AppIcon({ name: 'empty', iconSize: Theme.icon.xl, color: SketchStyle.inkMuted() })
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(SketchStyle.titleWeight())
          .fontStyle(SketchStyle.titleStyle())
          .fontColor(SketchStyle.ink())
        Text(this.description)
          .fontSize(Theme.type.callout)
          .fontColor(SketchStyle.inkMuted())
          .textAlign(TextAlign.Center)
        if (this.actionLabel.length > 0) {
          AppButton({
            label: this.actionLabel,
            variant: 'primary',
            onTap: (): void => { this.onAction() }
          })
        }
      }
      .width('100%')
      .padding(Theme.space.s4)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }
}
