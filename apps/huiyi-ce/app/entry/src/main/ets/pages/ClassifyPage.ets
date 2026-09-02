import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { MemoryListCard } from '../components/memory/MemoryListCard'
import { BookletCard } from '../components/memory/BookletCard'
import { ClassifyHint, MemoryBooklet, MemoryRecord, TagCloudItem } from '../models/MemoryModels'
import { MemoryStatsService } from '../services/MemoryStatsService'
import { MemoryStore } from '../services/MemoryStore'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct ClassifyPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @State cloud: TagCloudItem[] = []
  @State hints: ClassifyHint[] = []
  @State filterTag: string = ''
  @State filtered: MemoryRecord[] = []
  @State books: MemoryBooklet[] = []
  onOpenDetail: (id: string) => void = (_id: string) => {}
  onChanged: () => void = () => {}
  onOpenBooklet: (id: string) => void = (_id: string) => {}
  onCreateBooklet: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.cloud = await MemoryStatsService.tagCloud()
    this.hints = await MemoryStatsService.hints()
    this.books = await MemoryStore.loadBooklets()
    if (this.filterTag.length > 0) {
      this.filtered = await MemoryStore.byTag(this.filterTag)
    }
  }

  private async openTag(name: string): Promise<void> {
    this.filterTag = name
    this.filtered = await MemoryStore.byTag(name)
  }

  private async adopt(hint: ClassifyHint): Promise<void> {
    await MemoryStatsService.applyHint(hint.recordId, hint.suggested)
    await this.load()
    this.onChanged()
  }

  build() {
    Column() {
      Text('智慧归类')
        .fontSize(Theme.type.titleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s2
        })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.classify_tabs'))
              .width('100%')
              .height(132)
              .objectFit(ImageFit.Cover)
            Column() {
              Blank()
              Text('收成册子，按标签找回每一条')
                .fontSize(Theme.type.bodyS)
                .fontColor('#FFFFFF')
                .width('100%')
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(11,42,92,0.78)', 1]]
                })
            }
            .width('100%')
            .height(132)
          }
          .width('100%')
          .height(132)
          .borderRadius(Theme.radius.md)
          .clip(true)

          Row() {
            Text('记忆册')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            Text('新建册')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .constraintSize({ minHeight: 40 })
              .onClick((): void => { this.onCreateBooklet() })
          }
          .width('100%')

          if (this.books.length === 0) {
            Text('把出差、项目、旅行等主题收成一本册，整本回顾')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          } else {
            Scroll() {
              Row({ space: Theme.space.s3 }) {
                ForEach(this.books, (b: MemoryBooklet) => {
                  BookletCard({
                    item: b,
                    onOpen: (): void => { this.onOpenBooklet(b.id) }
                  })
                }, (b: MemoryBooklet) => b.id)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }

          Text('标签云')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          if (this.cloud.length === 0) {
            AppEmpty({
              title: '还没有标签',
              description: '保存记忆并确认标签后，这里会形成标签云'
            })
          } else {
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
              ForEach(this.cloud, (t: TagCloudItem) => {
                Text(`${CategoryEmojiUtil.markFor(t.name)} ${t.name}`)
                  .fontSize(t.fontSize)
                  .fontWeight(t.count > 2 ? FontWeight.Medium : FontWeight.Normal)
                  .fontColor(this.filterTag === t.name ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .margin({ left: 4, right: 4, bottom: 8 })
                  .constraintSize({ minHeight: 40 })
                  .backgroundColor(this.filterTag === t.name ?
                    Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { void this.openTag(t.name) })
              }, (t: TagCloudItem) => t.name)
            }
            .width('100%')
          }

          if (this.filterTag.length > 0) {
            Row() {
              Text(`${this.filterTag} · ${this.filtered.length} 条`)
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Blank()
              Text('清除筛选')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .onClick((): void => {
                  this.filterTag = ''
                  this.filtered = []
                })
            }
            .width('100%')
            ForEach(this.filtered, (it: MemoryRecord) => {
              MemoryListCard({
                item: it,
                onOpen: (): void => { this.onOpenDetail(it.id) }
              })
            }, (it: MemoryRecord) => it.id)
          }

          Text('智能归类建议')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          if (this.hints.length === 0) {
            Text('暂无待归类记忆，新写下的内容会自动出现在这里')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          } else {
            Scroll() {
              Row({ space: Theme.space.s3 }) {
                ForEach(this.hints, (h: ClassifyHint) => {
                  Column({ space: Theme.space.s3 }) {
                    Text(h.preview)
                      .fontSize(Theme.type.bodyS)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .maxLines(3)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')
                    Text(`建议：${CategoryEmojiUtil.chipLabel(h.suggested)}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                      .width('100%')
                    AppButton({
                      label: '采纳',
                      onTap: (): void => { void this.adopt(h) }
                    })
                  }
                  .width(220)
                  .padding(Theme.space.s4)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.md)
                }, (h: ClassifyHint) => h.recordId)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
