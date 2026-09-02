import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct DetailShell {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop bodyKey: number = 0
  onClose: () => void = () => {}
  @BuilderParam body: () => void
  @BuilderParam footer: () => void

  build() {
    Column() {
      Row({ space: Theme.space.s3 }) {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .rotate({ angle: 180 })
        .onClick(() => {
          this.onClose()
        })

        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)

        Blank().width(40)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          ForEach([this.bodyKey], (rev: number) => {
            Column({ space: Theme.space.s4 }) {
              this.body()
            }
            .width('100%')
          }, (rev: number) => `detail_body_${rev}_${this.title}`)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)

      Column({ space: Theme.space.s3 }) {
        this.footer()
      }
      .width('100%')
      .padding(Theme.space.pageX)
      .padding({ bottom: Theme.space.s4 })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
