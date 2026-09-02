import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { DiaryListCard } from '../components/diary/DiaryListCard'
import { DiaryEntry, DiaryFilter, MoodOption } from '../models/DiaryModels'
import { DiaryStore } from '../services/DiaryStore'

@Component
export struct TimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State entries: DiaryEntry[] = []
  @State keyword: string = ''
  @State moodFilter: string = ''
  @State loading: boolean = true
  onOpenEditor: (entryId: string) => void = () => {}
  onCreateNew: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const f = new DiaryFilter()
    f.keyword = this.keyword.trim()
    f.moodKey = this.moodFilter
    this.entries = await DiaryStore.filterEntries(f)
    this.loading = false
  }

  build() {
    List({ space: Theme.space.s3 }) {
      ListItem() {
        this.PageHeader()
      }

      if (this.loading) {
        ListItem() {
          Text('加载中…')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s6 })
        }
      } else if (this.entries.length === 0) {
        ListItem() {
          Column() {
            AppEmpty({
              title: '还没有日记',
              description: '点击右上角 ＋ 写下第一篇',
              actionLabel: '',
              onAction: (): void => {}
            })
          }
          .width('100%')
          .padding({ top: Theme.space.s8, bottom: Theme.space.s6 })
        }
      } else {
        ForEach(this.entries, (item: DiaryEntry) => {
          ListItem() {
            DiaryListCard({
              entry: item,
              onTap: (): void => this.onOpenEditor(item.id)
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }, (item: DiaryEntry) => item.id)
      }

      ListItem() {
        Column() {
          Blank().height(this.bottomInset)
        }
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  PageHeader() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Column({ space: 2 }) {
          Text('私人日记')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('记录生活每一刻的温暖与思考')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Row({ space: Theme.space.s4 }) {
          Column() {
            AppIcon({ name: 'search', iconSize: Theme.icon.lg, color: Theme.colors().textSecondary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { void this.reload() })

          Column() {
            AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => this.onCreateNew())
        }
      }
      .width('100%')

      TextInput({ text: this.keyword, placeholder: '搜索日记关键词…' })
        .width('100%')
        .height(44)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .padding({ left: Theme.space.s4, right: Theme.space.s4 })
        .onChange((v: string) => { this.keyword = v })
        .onSubmit((): void => { void this.reload() })

      Stack({ alignContent: Alignment.Bottom }) {
        Image($r('app.media.hero_ambient'))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
        Row()
          .width('100%')
          .height(48)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,42,58,0)', 0], ['rgba(26,42,58,0.55)', 1]]
          })
      }
      .width('100%')
      .height(120)
      .borderRadius(Theme.radius.lg)
      .clip(true)

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          this.MoodChip('全部', '')
          ForEach(MoodOption.all(), (m: MoodOption) => {
            this.MoodChip(m.label, m.key)
          }, (m: MoodOption) => m.key)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .padding({
      left: Theme.space.pageX,
      right: Theme.space.pageX,
      top: Theme.space.pageY,
      bottom: Theme.space.s2
    })
  }

  @Builder
  MoodChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.moodFilter === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.moodFilter === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.moodFilter = key
        void this.reload()
      })
  }
}
