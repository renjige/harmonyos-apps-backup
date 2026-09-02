import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { SearchHit } from '../models/CollectModels'
import { SportRecord } from '../models/SportRecord'
import { CollectItem } from '../models/CollectModels'
import { MemoryStats } from '../services/MemoryStats'
import { RecordStore } from '../services/RecordStore'
import { CollectStore } from '../services/CollectStore'
import { SportRecordDetailPane } from '../components/sport/SportRecordDetailPane'
import { CollectDetailPane } from '../components/sport/CollectDetailPane'

@Component
export struct GlobalSearchPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State query: string = ''
  @State hits: SearchHit[] = []
  @State detailMatch: SportRecord | undefined = undefined
  @State detailItem: CollectItem | undefined = undefined
  onClose: () => void = () => {}

  private async search(): Promise<void> {
    this.hits = await MemoryStats.unifiedSearch(this.query)
  }

  private openHit(h: SearchHit): void {
    if (h.kind === 'match') {
      void RecordStore.findById(h.refId).then((m): void => {
        if (m !== undefined) {
          this.detailMatch = m
        }
      })
      return
    }
    void CollectStore.find(h.refId).then((it): void => {
      if (it !== undefined) {
        this.detailItem = it
      }
    })
  }

  private kindLabel(kind: string): string {
    if (kind === 'match') {
      return '赛事'
    }
    if (kind === 'moment') {
      return '瞬间'
    }
    if (kind === 'note') {
      return '笔记'
    }
    if (kind === 'team') {
      return '球队'
    }
    if (kind === 'player') {
      return '球员'
    }
    return '收藏'
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
          Text('全局搜索')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        TextInput({ text: this.query, placeholder: '搜赛事 / 球队 / 球员 / 标签 / 笔记' })
          .onChange((v: string) => {
            this.query = v
            void this.search()
          })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .padding(Theme.space.s3)

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.query.length > 0 && this.hits.length === 0) {
              Text('没有匹配内容，换个关键词试试。')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            ForEach(this.hits, (h: SearchHit) => {
              Column({ space: 4 }) {
                Text(this.kindLabel(h.kind))
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                Text(h.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(h.sub)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(2)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => { this.openHit(h) })
            }, (h: SearchHit) => h.id)
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
          onDeleted: (): void => { this.detailMatch = undefined; void this.search() },
          onEdit: (): void => { this.detailMatch = undefined },
          onRecap: (): void => { this.detailMatch = undefined },
          onTimeline: (): void => { this.detailMatch = undefined }
        })
      }
      if (this.detailItem !== undefined) {
        CollectDetailPane({
          item: this.detailItem,
          onClose: (): void => { this.detailItem = undefined },
          onDeleted: (): void => { this.detailItem = undefined; void this.search() },
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
