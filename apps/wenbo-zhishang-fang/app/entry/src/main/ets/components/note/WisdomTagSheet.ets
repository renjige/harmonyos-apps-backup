import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { WisdomTagService } from '../../services/WisdomTagService'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct WisdomTagSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop selected: string[] = []
  onToggle: (name: string) => void = (_n: string) => {}
  onDone: () => void = () => {}

  private isOn(name: string): boolean {
    for (const t of this.selected) {
      if (t === name) {
        return true
      }
    }
    return false
  }

  build() {
    Column() {
      Blank()
        .layoutWeight(1)
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onDone() })
      Column({ space: Theme.space.s3 }) {
        Text('选择分类，可多选或改写')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(WisdomTagService.catalog(), (t: string) => {
            Text(CategoryEmojiUtil.chipLabel(t))
              .fontSize(Theme.type.caption)
              .fontColor(this.isOn(t) ? '#FFFFFF' : Theme.colors().textPrimary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.isOn(t) ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .border({
                width: this.isOn(t) ? 0 : 1,
                color: Theme.colors().strokeStrong
              })
              .onClick((): void => { this.onToggle(t) })
          }, (t: string) => t)
        }
        .width('100%')
        AppButton({
          label: '完成',
          onTap: (): void => { this.onDone() }
        })
      }
      .width('100%')
      .padding(Theme.space.s5)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius({ topLeft: 20, topRight: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().overlayScrim)
  }
}
