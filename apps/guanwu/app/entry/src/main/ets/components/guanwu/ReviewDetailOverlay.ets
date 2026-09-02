import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

@Component
export struct ReviewDetailOverlay {
  @Prop title: string = '回顾'
  @Prop lines: string[] = []
  onClose: () => void = () => {}

  build() {
    Column() {
      Row() {
        Text(this.title)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        AppButton({ label: '关闭', variant: 'ghost', onTap: (): void => this.onClose() })
      }
      .width('100%')
      .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.lines, (line: string, idx: number) => {
            Text(line)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .lineHeight(24)
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
          }, (line: string, idx: number) => `rev-${idx}`)
        }
        .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s8 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
