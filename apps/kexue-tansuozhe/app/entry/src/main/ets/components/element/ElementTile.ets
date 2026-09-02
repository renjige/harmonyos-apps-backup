import { Theme } from '../design-system/Theme'
import { ElementRecord } from '../../data/ElementCatalog'

@Component
export struct ElementTile {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop element: ElementRecord = new ElementRecord()
  @Prop explored: boolean = false
  onTap: () => void = () => {}

  private tintBg(): string {
    const hex = this.element.colorKey
    if (hex.length === 7) {
      return `${hex}22`
    }
    return Theme.colors().brandPrimaryContainer
  }

  build() {
    Column({ space: 2 }) {
      Text(`${this.element.atomicNumber}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Text(this.element.symbol)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(this.element.nameCn)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 8, bottom: 8 })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.tintBg())
    .borderRadius(Theme.radius.sm)
    .border({
      width: this.explored ? 2 : 1,
      color: this.explored ? Theme.colors().brandAccent : Theme.colors().strokeHairline
    })
    .onClick((): void => { this.onTap() })
  }
}
