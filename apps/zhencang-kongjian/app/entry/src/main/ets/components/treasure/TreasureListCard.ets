import { Theme } from '../design-system/Theme'
import { TreasureItem } from '../../models/TreasureModels'
import { CompletenessUtil } from '../../services/CompletenessUtil'
import { ImagePathUtil } from '../../services/ImagePathUtil'
import { TreasureStore } from '../../services/TreasureStore'

@Component
export struct TreasureListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: TreasureItem = new TreasureItem()
  onTap: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        if (this.item.imagePath.length > 0) {
          Image(ImagePathUtil.displayUri(this.item.imagePath))
            .width('100%')
            .height(140)
            .borderRadius(Theme.radius.lg)
            .objectFit(ImageFit.Cover)
        } else {
          Column() {
            Image($r('app.media.empty_vault'))
              .width(56)
              .height(56)
              .opacity(0.85)
          }
          .width('100%')
          .height(140)
          .borderRadius(Theme.radius.lg)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .justifyContent(FlexAlign.Center)
        }
        Row() {
          Text(`${CompletenessUtil.percent(this.item)}%`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding(Theme.space.s2)
      }
      Text(this.item.name.length > 0 ? this.item.name : '未命名藏品')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(`${TreasureStore.categoryName(this.item.categoryId)} · ${this.item.acquiredAt}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .maxLines(1)
      if (this.item.archiveStatus === '重点珍藏') {
        Text('重点珍藏')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
      }
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .shadow({ radius: 12, color: 'rgba(23,23,23,0.06)', offsetY: 4 })
    .onClick(() => this.onTap())
  }
}
