import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SymbolCover } from '../design-system/SymbolVisual'
import { MemoryRecord } from '../../models/MemoryModels'
import { MemoryStore } from '../../services/MemoryStore'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct MemoryListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: MemoryRecord = new MemoryRecord()
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      SymbolCover({ category: this.item.primaryTag(), tileSize: 64 })
      Column({ space: 6 }) {
        Row({ space: 6 }) {
          if (this.item.pinned) {
            Text('置顶')
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().brandOnPrimary)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
          }
          if (this.item.favorite) {
            Text('收藏')
              .fontSize(Theme.type.overline)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
          }
          Text(this.item.previewLine())
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('100%')
        Row({ space: 6 }) {
          ForEach(this.chipTags(), (t: string) => {
            Text(CategoryEmojiUtil.chipLabel(t))
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
          }, (t: string) => t)
          Blank()
          Text(MemoryStore.timeLabel(this.item.createTime))
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
      }
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .shadow({
      radius: 10,
      color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(26,109,245,0.08)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick((): void => { this.onOpen() })
  }

  private chipTags(): string[] {
    if (this.item.tags.length === 0) {
      return ['未分类']
    }
    const out: string[] = []
    let i = 0
    for (const t of this.item.tags) {
      if (i < 3) {
        out.push(t)
      }
      i++
    }
    return out
  }
}
