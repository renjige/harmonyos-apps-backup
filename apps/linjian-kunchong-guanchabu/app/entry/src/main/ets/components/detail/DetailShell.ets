import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct DetailShell {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop showFavorite: boolean = false
  @Prop favorite: boolean = false
  onBack: () => void = () => {}
  onFavorite: () => void = () => {}
  @BuilderParam content: () => void

  build() {
    Column() {
      Row() {
        Row({ space: Theme.space.s1 }) {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(Theme.icon.md)
            .fontColor([Theme.colors().brandPrimary])
            .renderingStrategy(SymbolRenderingStrategy.SINGLE)
          Text('返回')
            .fontSize(Theme.type.callout)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
        .padding({ right: Theme.space.s3, top: Theme.space.s2, bottom: Theme.space.s2 })
        .onClick((): void => this.onBack())

        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.showFavorite) {
          AppIcon({
            name: 'heart',
            iconSize: Theme.icon.md,
            color: this.favorite ? Theme.colors().brandAccent : Theme.colors().textSecondary
          })
            .onClick((): void => this.onFavorite())
        }
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s3
      })

      Column() {
        this.content()
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
