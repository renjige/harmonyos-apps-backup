import { Theme } from '../design-system/Theme'
import { ObserveTemplate } from '../../models/ObserveCatalog'

@Component
export struct TemplateStrip {
  onPick: (tpl: ObserveTemplate) => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('快捷记录模板')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(ObserveTemplate.all(), (tpl: ObserveTemplate) => {
            Column({ space: 4 }) {
              Text(tpl.title)
                .fontSize(Theme.type.bodyS)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(tpl.prompt)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .maxLines(2)
                .width(148)
            }
            .width(164)
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => this.onPick(tpl))
          }, (tpl: ObserveTemplate) => tpl.key)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .width('100%')
    }
    .width('100%')
  }
}
