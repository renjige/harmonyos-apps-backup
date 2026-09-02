import { Theme } from './Theme'

@Component
export struct AppNavBar {
  @Prop title: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  onBack: () => void = () => {}

  build() {
    Column() {
      Row({ space: Theme.space.s1 }) {
        Row({ space: Theme.space.s1 }) {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(Theme.icon.md)
            .fontColor([Theme.palette(this.darkModeOn).brandPrimary])
            .renderingStrategy(SymbolRenderingStrategy.SINGLE)
          Text('返回')
            .fontSize(Theme.type.callout)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.palette(this.darkModeOn).brandPrimary)
        }
        .padding({ right: Theme.space.s3, top: Theme.space.s2, bottom: Theme.space.s2 })
        .onClick(() => this.onBack())

        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.palette(this.darkModeOn).textPrimary)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s3
      })
      .alignItems(VerticalAlign.Center)

      Divider()
        .color(Theme.palette(this.darkModeOn).strokeHairline)
        .strokeWidth(1)
    }
    .width('100%')
    .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)
  }
}
