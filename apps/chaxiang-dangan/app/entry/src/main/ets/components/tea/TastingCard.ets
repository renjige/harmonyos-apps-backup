import { Theme } from '../design-system/Theme'
import { TastingRecord } from '../../models/TeaModels'
import { TeaMedia } from '../../services/TeaMedia'
import { TeaStore } from '../../services/TeaStore'

@Component
export struct TastingCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop rec: TastingRecord = new TastingRecord()
  onOpen: () => void = () => {}

  private teaName(): string {
    const tea = TeaStore.findTea(this.rec.teaId)
    return tea !== null ? tea.name : '已删除的茶'
  }

  private starText(): string {
    const n = this.rec.stars()
    if (n <= 0) {
      return '未评分'
    }
    return `${n} 星`
  }

  private feelLine(): string {
    if (this.rec.aromaFeel.length > 0) {
      return this.rec.aromaFeel
    }
    if (this.rec.tasteFeel.length > 0) {
      return this.rec.tasteFeel
    }
    if (this.rec.note.length > 0) {
      return this.rec.note
    }
    return '还没有写下感受'
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(TeaMedia.tasting())
        .width(84)
        .height(84)
        .borderRadius(Theme.radius.md)
        .objectFit(ImageFit.Cover)
        .flexShrink(0)

      Column({ space: 4 }) {
        Text(this.teaName())
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(`${this.rec.dateKey} · ${this.rec.period} · ${this.rec.mood}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(this.feelLine())
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(this.starText())
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(VerticalAlign.Center)
    .onClick((): void => { this.onOpen() })
  }
}
