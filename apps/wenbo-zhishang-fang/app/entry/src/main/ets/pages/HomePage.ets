import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { NoteListCard } from '../components/note/NoteListCard'
import { StudyWorkbench } from '../components/study/StudyWorkbench'
import { BookNote, BookProfile, BookShelfGroup } from '../models/BookNoteModels'
import { NoteStore } from '../services/NoteStore'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'
import { ExportService } from '../services/ExportService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('noteEpoch') @Watch('onNoteEpochChange') noteEpoch: number = 0
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @Prop @Watch('onActiveChange') active: boolean = true
  @State items: BookNote[] = []
  @State shelf: BookShelfGroup[] = []
  @State bookProfile: BookProfile = new BookProfile()
  @State query: string = ''
  @State bookFilter: string = ''
  @State confirmId: string = ''
  @State toastText: string = ''
  onOpenSettings: () => void = () => {}
  onOpenDetail: (id: string) => void = (_id: string) => {}
  onGoCapture: () => void = () => {}
  onDataChanged: () => void = () => {}
  onOpenPlans: () => void = () => {}
  onOpenTopics: () => void = () => {}
  onOpenStats: () => void = () => {}
  onOpenPlan: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  onNoteEpochChange(): void {
    void this.load()
  }

  onActiveChange(): void {
    if (this.active) {
      void this.load()
    }
  }

  private async load(): Promise<void> {
    this.shelf = await NoteStore.bookShelf()
    let list = await NoteStore.searchByBook(this.query)
    if (this.bookFilter.length > 0) {
      const filtered: BookNote[] = []
      for (const it of list) {
        if (it.bookName.trim() === this.bookFilter) {
          filtered.push(it)
        }
      }
      list = filtered
    }
    this.items = list
    if (this.bookFilter.length > 0) {
      const profile = await NoteStore.bookProfile(this.bookFilter)
      this.bookProfile = profile ?? new BookProfile()
    } else {
      this.bookProfile = new BookProfile()
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async fav(id: string): Promise<void> {
    const on = await NoteStore.toggleFavorite(id)
    await this.load()
    this.onDataChanged()
    this.showToast(on ? '已收藏' : '已取消收藏')
  }

  private async remove(id: string): Promise<void> {
    if (this.confirmId !== id) {
      this.confirmId = id
      this.showToast('再点删除确认')
      return
    }
    await NoteStore.deleteById(id)
    this.confirmId = ''
    await this.load()
    this.onDataChanged()
    this.showToast('已删除')
  }

  private pickBook(name: string): void {
    if (name.length === 0) {
      this.bookFilter = ''
    } else if (this.bookFilter === name) {
      this.bookFilter = ''
    } else {
      this.bookFilter = name
    }
    void this.load()
  }

  private async copyBookQuotes(): Promise<void> {
    if (this.bookFilter.length === 0) {
      return
    }
    const text = await NoteStore.exportBookQuotes(this.bookFilter)
    const ok = await ExportService.copyText(text)
    this.showToast(ok ? '该书书摘合集已复制' : '复制失败')
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('纸上方')
            .fontSize(Theme.type.titleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Row() {
            AppIcon({ name: 'gear', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onOpenSettings() })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s2
        })

        Row({ space: 8 }) {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          TextInput({ text: this.query, placeholder: '搜索书名、摘录或感悟' })
            .layoutWeight(1)
            .height(40)
            .backgroundColor(Color.Transparent)
            .fontColor(Theme.colors().textPrimary)
            .placeholderColor(Theme.colors().textSecondary)
            .onChange((v: string): void => {
              this.query = v
              void this.load()
            })
        }
        .width('100%')
        .height(44)
        .padding({ left: 14, right: 14 })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.pill)

        List({ space: 12 }) {
          ListItem() {
            Column({ space: Theme.space.s2 }) {
              StudyWorkbench({
                reloadToken: this.reloadToken,
                onOpenDetail: (id: string): void => { this.onOpenDetail(id) },
                onGoCapture: (): void => { this.onGoCapture() },
                onOpenPlans: (): void => { this.onOpenPlans() },
                onOpenTopics: (): void => { this.onOpenTopics() },
                onOpenStats: (): void => { this.onOpenStats() },
                onOpenPlan: (id: string): void => { this.onOpenPlan(id) }
              })

              if (this.shelf.length > 1) {
                Scroll() {
                  Row({ space: 8 }) {
                    Text('全部')
                      .fontSize(Theme.type.caption)
                      .fontColor(this.bookFilter.length === 0 ? '#FFFFFF' : Theme.colors().brandPrimary)
                      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                      .backgroundColor(this.bookFilter.length === 0 ?
                        Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                      .borderRadius(Theme.radius.pill)
                      .onClick((): void => { this.pickBook('') })
                    ForEach(this.shelf, (g: BookShelfGroup) => {
                      Text(`${g.bookName} · ${g.noteCount}`)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.bookFilter === g.bookName ? '#FFFFFF' : Theme.colors().textPrimary)
                        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                        .backgroundColor(this.bookFilter === g.bookName ?
                          Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                        .borderRadius(Theme.radius.pill)
                        .onClick((): void => { this.pickBook(g.bookName) })
                    }, (g: BookShelfGroup) => g.bookName)
                  }
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
                .width('100%')
              }

              if (this.bookProfile.bookName.length > 0) {
                Column({ space: Theme.space.s2 }) {
                  Text(`书籍档案 · ${this.bookProfile.bookName}`)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Row({ space: 8 }) {
                    this.ProfileChip('摘录', `${this.bookProfile.noteCount} 条`)
                    this.ProfileChip('收藏', `${this.bookProfile.favoriteCount} 条`)
                    if (this.bookProfile.topTag.length > 0) {
                      this.ProfileChip('主分类', CategoryEmojiUtil.chipLabel(this.bookProfile.topTag))
                    }
                  }
                  .width('100%')
                  if (this.bookProfile.firstDate.length > 0) {
                    Text(`阅读跨度 ${this.bookProfile.firstDate} 至 ${this.bookProfile.latestDate}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .width('100%')
                  }
                  Text('复制本书书摘合集')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .width('100%')
                    .textAlign(TextAlign.End)
                    .onClick((): void => { void this.copyBookQuotes() })
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(12)
              }
            }
            .width('100%')
          }

          if (this.items.length === 0) {
            ListItem() {
              Column({ space: Theme.space.s3 }) {
                this.HeroBanner('从纸页摘录，在书房回看')
                Image($r('app.media.empty_desk'))
                  .width('100%')
                  .height(140)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
                AppEmpty({
                  title: '还没有书摘',
                  description: '点击添加，写下你的第一条书摘吧',
                  actionLabel: '添加书摘',
                  onAction: (): void => { this.onGoCapture() }
                })
              }
              .width('100%')
            }
          } else {
            ListItem() {
              this.HeroBanner(`已收录 ${this.shelf.length} 本书 · ${this.items.length} 条书摘`)
            }
            ForEach(this.items, (it: BookNote) => {
              ListItem() {
                NoteListCard({
                  item: it,
                  onOpen: (): void => { this.onOpenDetail(it.id) }
                })
              }
              .swipeAction({
                end: {
                  actionAreaDistance: 148,
                  builder: (): void => {
                    this.SwipeEnd(it)
                  }
                }
              })
            }, (it: BookNote) => `${it.id}_${it.updatedAt}_${it.tags.join('|')}`)
          }

          ListItem() {
            Column().height(Theme.space.s10)
          }
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  HeroBanner(subtitle: string) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_library'))
        .width('100%')
        .height(168)
        .objectFit(ImageFit.Cover)
      Column() {
        Blank()
        Column({ space: 6 }) {
          Text('让每本书都留下智慧')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
          Text(subtitle)
            .fontSize(Theme.type.bodyS)
            .fontColor('#FFFFFF')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .linearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0)', 0], ['rgba(26,39,68,0.78)', 1]]
        })
      }
      .width('100%')
      .height(168)
    }
    .width('100%')
    .height(168)
    .borderRadius(Theme.radius.md)
    .clip(true)
  }

  @Builder
  ProfileChip(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(Theme.type.overline)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Text(value)
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
    .borderRadius(Theme.radius.sm)
  }

  @Builder
  SwipeEnd(it: BookNote) {
    Row() {
      Column() {
        AppIcon({ name: 'heart', iconSize: 20, color: '#FFFFFF' })
      }
      .width(72)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandAccent)
      .onClick((): void => { void this.fav(it.id) })
      Column() {
        AppIcon({ name: 'trash', iconSize: 20, color: '#FFFFFF' })
      }
      .width(72)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().danger)
      .onClick((): void => { void this.remove(it.id) })
    }
    .height('100%')
  }
}
