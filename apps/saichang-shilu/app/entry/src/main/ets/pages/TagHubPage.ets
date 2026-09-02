import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CollectDetailPane } from '../components/sport/CollectDetailPane'
import { RecordCard } from '../components/sport/RecordCard'
import { SportRecordDetailPane } from '../components/sport/SportRecordDetailPane'
import { TagStat } from '../models/SportExtra'
import { CollectItem } from '../models/CollectModels'
import { SportRecord } from '../models/SportRecord'
import { MemoryStats } from '../services/MemoryStats'
import { RecordStore } from '../services/RecordStore'
import { CollectStore } from '../services/CollectStore'

@Component
export struct TagHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State tags: TagStat[] = []
  @State activeTag: string = ''
  @State matchHits: SportRecord[] = []
  @State collectHits: CollectItem[] = []
  @State detailMatch: SportRecord | undefined = undefined
  @State detailItem: CollectItem | undefined = undefined
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void MemoryStats.buildTagStats().then((t): void => { this.tags = t })
  }

  private async selectTag(tag: string): Promise<void> {
    this.activeTag = this.activeTag === tag ? '' : tag
    if (this.activeTag.length === 0) {
      this.matchHits = []
      this.collectHits = []
      return
    }
    const all = await RecordStore.loadAll()
    const mOut: SportRecord[] = []
    for (const m of all) {
      if (m.tagsPacked.indexOf(this.activeTag) >= 0) {
        mOut.push(m)
      }
    }
    this.matchHits = mOut
    const items = await CollectStore.loadAll()
    const cOut: CollectItem[] = []
    for (const it of items) {
      if (it.tags.indexOf(this.activeTag) >= 0) {
        cOut.push(it)
      }
    }
    this.collectHits = cOut
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('标签分析')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('汇总赛事与收藏的标签，点选查看关联内容。')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

            if (this.tags.length === 0) {
              AppEmpty({
                title: '还没有标签',
                description: '给赛事或瞬间加上「经典」「决赛」等标签后这里会出现统计',
                actionLabel: '',
                onAction: (): void => {}
              })
            } else {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.tags, (t: TagStat) => {
                  Text(`${t.tag} · ${t.count}`)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.activeTag === t.tag ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(this.activeTag === t.tag ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { void this.selectTag(t.tag) })
                }, (t: TagStat) => t.tag)
              }
              .width('100%')
            }

            if (this.activeTag.length > 0) {
              Text(`「${this.activeTag}」关联赛事 ${this.matchHits.length} · 收藏 ${this.collectHits.length}`)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

              ForEach(this.matchHits, (m: SportRecord) => {
                RecordCard({
                  record: m,
                  onTap: (): void => { this.detailMatch = m }
                })
              }, (m: SportRecord) => m.id)

              ForEach(this.collectHits, (it: CollectItem) => {
                Column({ space: 4 }) {
                  Text(it.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(it.body.length > 0 ? it.body : it.sub)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(2)
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick((): void => { this.detailItem = it })
              }, (it: CollectItem) => it.id)
            }
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.detailMatch !== undefined) {
        SportRecordDetailPane({
          record: this.detailMatch,
          onClose: (): void => { this.detailMatch = undefined },
          onDeleted: (): void => { this.detailMatch = undefined },
          onEdit: (): void => { this.detailMatch = undefined },
          onRecap: (): void => { this.detailMatch = undefined },
          onTimeline: (): void => { this.detailMatch = undefined },
          onWorkbench: (): void => { this.detailMatch = undefined }
        })
      }
      if (this.detailItem !== undefined) {
        CollectDetailPane({
          item: this.detailItem,
          onClose: (): void => { this.detailItem = undefined },
          onDeleted: (): void => { this.detailItem = undefined },
          onEdit: (): void => { this.detailItem = undefined }
        })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(70)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
