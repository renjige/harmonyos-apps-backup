import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { EntryListCard } from '../components/journal/EntryListCard'
import { CornerEntry, CornerTag, DateGroup } from '../models/YouyuModels'
import { YouyuMedia } from '../services/YouyuMedia'
import { YouyuNav } from '../services/YouyuNav'
import { YouyuStore } from '../services/YouyuStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('youyuRev') @Watch('onStoreRev') storeRev: number = 0
  @StorageLink('youyuShowCompose') @Watch('onComposeClosed') showCompose: boolean = false
  @StorageLink('youyuHomeFilter') @Watch('onFilterSync') homeFilter: string = ''
  @Prop appName: string = '悠隅纪'
  @Prop tagline: string = ''
  @State groups: DateGroup[] = []
  @State filterId: string = ''
  @State tags: CornerTag[] = []
  @State listEpoch: number = 0

  aboutToAppear(): void {
    this.filterId = this.homeFilter
    this.reload()
  }

  onStoreRev(): void {
    this.reload()
  }

  onComposeClosed(): void {
    if (!this.showCompose) {
      this.reload()
    }
  }

  onFilterSync(): void {
    this.filterId = this.homeFilter
    this.reload()
  }

  private copyEntry(item: CornerEntry): CornerEntry {
    const e = new CornerEntry()
    e.id = item.id
    e.body = item.body
    e.mood = item.mood
    e.tagCsv = item.tagCsv
    e.photoPath = item.photoPath
    e.entryDate = item.entryDate
    e.createdAt = item.createdAt
    e.updatedAt = item.updatedAt
    return e
  }

  private groupKey(g: DateGroup): string {
    let key = g.date
    for (const item of g.items) {
      key = `${key}|${item.id}:${item.updatedAt}`
    }
    return key
  }

  private reload(): void {
    this.tags = YouyuStore.tags()
    const raw = YouyuStore.groupedTimeline(this.filterId)
    const next: DateGroup[] = []
    for (const g of raw) {
      const row = new DateGroup()
      row.date = g.date
      row.label = g.label
      row.items = []
      for (const item of g.items) {
        row.items.push(this.copyEntry(item))
      }
      next.push(row)
    }
    this.groups = next
    this.listEpoch += 1
  }

  private tagsLine(item: CornerEntry): string {
    const names: string[] = []
    for (const id of item.tagList()) {
      for (const t of this.tags) {
        if (t.id === id) {
          names.push(t.name)
        }
      }
    }
    return names.join(' · ')
  }

  private summaryOf(item: CornerEntry): string {
    if (item.body.length <= 72) {
      return item.body
    }
    return `${item.body.substring(0, 72)}…`
  }

  private setFilter(id: string): void {
    if (this.filterId === id) {
      this.filterId = ''
    } else {
      this.filterId = id
    }
    AppStorage.setOrCreate('youyuHomeFilter', this.filterId)
    this.reload()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text(this.appName)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Column() {
            AppIcon({ name: 'gear', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            AppStorage.setOrCreate('youyuOpenMineSettings', true)
            AppStorage.setOrCreate('tabBarHidden', true)
          })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s2
        })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack() {
              Image(YouyuMedia.heroWindow())
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(200)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(61,43,31,0.12)', 0], ['rgba(61,43,31,0.78)', 1]]
                })
              Column({ space: 6 }) {
                Text(YouyuStore.greeting())
                  .fontSize(Theme.type.subhead)
                  .fontColor('#F9F6F0')
                  .width('100%')
                Text(this.tagline)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F9F6F0')
                  .width('100%')
              }
              .width('100%')
              .padding({ left: 16, right: 16, bottom: 16 })
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .height(200)
            .borderRadius(Theme.radius.md)
            .clip(true)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Image(YouyuMedia.bannerTea())
              .width('100%')
              .height(92)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
              .clip(true)

            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(this.tags, (t: CornerTag) => {
                  Text(t.name)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.filterId === t.id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .constraintSize({ minHeight: 32 })
                    .backgroundColor(this.filterId === t.id ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => this.setFilter(t.id))
                }, (t: CornerTag) => t.id)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            if (this.groups.length === 0) {
              Column({ space: Theme.space.s3 }) {
                Image(YouyuMedia.emptyCorner())
                  .width('100%')
                  .height(140)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
                AppEmpty({
                  title: '这一隅还空着',
                  description: '写下今天的心情与一件小事。',
                  actionLabel: '写下此刻',
                  onAction: (): void => YouyuNav.openCompose('')
                })
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            } else {
              Column({ space: Theme.space.s4 }) {
                ForEach(this.groups, (g: DateGroup) => {
                  Column({ space: Theme.space.s3 }) {
                    Text(g.label)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .width('100%')
                    ForEach(g.items, (item: CornerEntry) => {
                      EntryListCard({
                        itemId: item.id,
                        mood: item.mood,
                        summary: this.summaryOf(item),
                        timeLabel: item.entryDate,
                        tagsLine: this.tagsLine(item),
                        photoPath: item.photoPath,
                        onTap: (): void => YouyuNav.openDetail(item.id)
                      })
                    }, (item: CornerEntry) => `${item.id}_${item.updatedAt}`)
                  }
                  .width('100%')
                  .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
                }, (g: DateGroup) => this.groupKey(g))
              }
              .width('100%')
              .key(`timeline_${this.listEpoch}_${this.storeRev}`)
            }
            Blank().height(88)
          }
          .padding({ bottom: Theme.space.s6 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')

      Column() {
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .shadow({ radius: 12, color: 'rgba(61,43,31,0.18)', offsetX: 0, offsetY: 4 })
        .onClick(() => YouyuNav.openCompose(''))
      }
      .width('100%')
      .alignItems(HorizontalAlign.End)
      .padding({ right: Theme.space.pageX, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
