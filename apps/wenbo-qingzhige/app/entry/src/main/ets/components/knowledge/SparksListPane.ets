import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { SparkItem } from '../../models/KnowledgeModels'
import { KnowledgeStore } from '../../services/KnowledgeStore'
import { KnowledgeNav } from '../../services/KnowledgeNav'
import { KnowledgeTime } from '../../services/CategorySuggest'

@Component
export struct SparksListPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('knowledgeRefresh') @Watch('onRefresh') refreshToken: number = 0
  @State items: SparkItem[] = []

  aboutToAppear(): void {
    this.items = KnowledgeStore.sparksAll()
  }

  onRefresh(): void {
    this.items = KnowledgeStore.sparksAll()
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { KnowledgeNav.closeSparks() })
        Text('灵感记录')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('写下')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { KnowledgeNav.openSpark('') })
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: 8 })

      if (this.items.length === 0) {
        AppEmpty({
          title: '把刚想到的事情，轻轻记下来。',
          description: '读书想法、一句值得记住的话，都可以放在这里。',
          actionLabel: '记录灵感',
          onAction: (): void => { KnowledgeNav.openSpark('') }
        })
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.items, (item: SparkItem) => {
            ListItem() {
              Column({ space: 6 }) {
                Text(item.title)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(item.body)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(3)
                Row() {
                  Text(item.tags)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .layoutWeight(1)
                  Text(KnowledgeTime.formatShort(item.createdAt))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
                .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
            }
          }, (item: SparkItem) => item.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
