import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { SymbolCover } from '../components/design-system/SymbolVisual'
import { TagChips } from '../components/wisdom/TagChips'
import { ThoughtListCard } from '../components/wisdom/ThoughtListCard'
import { WisdomItem } from '../models/WisdomHallModels'
import { WisdomHallBizService } from '../services/WisdomHallBizService'
import { WisdomHallNav } from '../services/WisdomHallNav'
import { AuthService } from '../services/AuthService'

@Component
export struct NotesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '文墨集'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @State items: WisdomItem[] = []
  @State filtered: WisdomItem[] = []
  @State tagOptions: string[] = []
  @State activeTag: string = '全部'
  @State loading: boolean = true
  @State cardView: boolean = true
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const tags = await WisdomHallBizService.loadTags()
    const names: string[] = ['全部']
    for (const t of tags) {
      names.push(t.title)
    }
    if (names.length === 1) {
      names.push('职场', '人生', '阅读', '情感', '灵感', '其他')
    }
    this.tagOptions = names
    this.items = await WisdomHallBizService.loadThoughts()
    this.applyFilter()
    this.loading = false
  }

  private applyFilter(): void {
    if (this.activeTag === '全部') {
      this.filtered = this.items
      return
    }
    const out: WisdomItem[] = []
    for (const item of this.items) {
      if (item.category === this.activeTag || item.tags.includes(this.activeTag)) {
        out.push(item)
      }
    }
    this.filtered = out
  }

  private openCreate(): void {
    if (!AuthService.requireAuth('create_thought')) {
      this.onRequireAuth()
      return
    }
    WisdomHallNav.openWrite('')
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Row({ space: Theme.space.s3 }) {
          Stack({ alignContent: Alignment.Center }) {
            Column()
              .width(40)
              .height(40)
              .linearGradient({
                angle: 135,
                colors: [[Theme.colors().brandDeep, 0], [Theme.colors().brandPrimary, 1]]
              })
              .borderRadius(12)
            AppIcon({ name: 'book', iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
          }
          Column({ space: 2 }) {
            Text(this.appName)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('✍️ 智慧笔记')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Row({ space: 0 }) {
            Column() {
              AppIcon({
                name: 'grid',
                iconSize: Theme.icon.sm,
                color: this.cardView ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary
              })
            }
            .width(36)
            .height(32)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.cardView ? Theme.colors().brandPrimary : Color.Transparent)
            .borderRadius({ topLeft: 8, bottomLeft: 8 })
            .onClick((): void => { this.cardView = true })
            Column() {
              AppIcon({
                name: 'list',
                iconSize: Theme.icon.sm,
                color: !this.cardView ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary
              })
            }
            .width(36)
            .height(32)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(!this.cardView ? Theme.colors().brandPrimary : Color.Transparent)
            .borderRadius({ topRight: 8, bottomRight: 8 })
            .onClick((): void => { this.cardView = false })
          }
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .borderRadius(8)
          .margin({ right: Theme.space.s1 })
          Column() {
            AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .onClick((): void => { WisdomHallNav.openSearch() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s2 })

        TagChips({
          options: this.tagOptions,
          selected: this.activeTag,
          onSelect: (tag: string): void => {
            this.activeTag = tag
            this.applyFilter()
          }
        })

        if (this.loading) {
          Column({ space: Theme.space.s3 }) {
            ForEach([0, 1, 2, 3], (i: number) => {
              Column({ space: 8 }) {
                Column().width('55%').height(16).backgroundColor(Theme.colors().strokeHairline).borderRadius(4)
                Column().width('100%').height(this.cardView ? 88 : 48).backgroundColor(Theme.colors().strokeHairline).borderRadius(12)
              }
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }, (i: number) => `nsk-${i}`)
          }
          .layoutWeight(1)
        } else {
          List({ space: Theme.space.s3 }) {
            if (this.accessToken.length === 0) {
              ListItem() {
                AppEmpty({
                  title: '登录后记录智慧笔记',
                  description: '游客可浏览文墨精选与日历；登录后可创建、编辑笔记',
                  actionLabel: '去登录',
                  onAction: (): void => { this.onRequireAuth() }
                })
              }
            } else if (this.filtered.length === 0) {
              ListItem() {
                AppEmpty({
                  title: '还没有笔记',
                  description: '点击右下角 ➕，写下第一条心得',
                  actionLabel: '新建笔记',
                  onAction: (): void => { this.openCreate() }
                })
              }
            } else {
              ForEach(this.filtered, (item: WisdomItem) => {
                ListItem() {
                  if (this.cardView) {
                    ThoughtListCard({
                      itemId: item.id,
                      title: item.title,
                      summary: item.summaryLine(),
                      category: item.category,
                      coverKey: item.coverKey,
                      onOpen: (): void => { WisdomHallNav.openDetail('thought', item.id) }
                    })
                  } else {
                    Row({ space: Theme.space.s3 }) {
                      SymbolCover({
                        category: item.category,
                        coverKey: item.coverKey,
                        tileSize: 48,
                        cornerRadius: Theme.radius.sm
                      })
                      Column({ space: 4 }) {
                        Text(item.title)
                          .fontSize(Theme.type.subhead)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                          .maxLines(1)
                        Text(item.summaryLine())
                          .fontSize(Theme.type.caption)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                          .maxLines(1)
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
                    }
                    .width('100%')
                    .padding(Theme.space.s4)
                    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.md)
                    .onClick((): void => { WisdomHallNav.openDetail('thought', item.id) })
                  }
                }
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
              }, (item: WisdomItem) => item.id)
            }
            ListItem() {
              Column().height(Theme.space.s10).width('100%')
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(28)
      .margin({ right: Theme.space.pageX, bottom: Theme.space.s6 })
      .shadow({ radius: 12, color: Theme.colors().overlayScrim, offsetY: 4 })
      .onClick((): void => { this.openCreate() })
    }
    .width('100%')
    .height('100%')
  }
}
