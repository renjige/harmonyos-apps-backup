import { Theme } from '../components/design-system/Theme'
import { AppError } from '../components/design-system/AppError'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { FilterChip, PoemListCard } from '../components/poetry/PoetryCards'
import { PoemItem } from '../models/PoetryModels'
import { PoetryBizService } from '../services/PoetryBizService'
import { PoetryMedia } from '../services/PoetryMedia'
import { PoetryNav } from '../services/PoetryNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct LibraryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State poems: PoemItem[] = []
  @State loading: boolean = true
  @State failed: boolean = false
  @State query: string = ''
  @State dynasty: string = ''
  @State author: string = ''
  @State theme: string = ''
  @StorageLink('poetryTick') tick: number = 0
  @StorageLink('favoriteCount') favoriteCount: number = 0
  onOpenMine: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    this.poems = await PoetryBizService.loadPoems()
    this.loading = false
    this.failed = this.poems.length === 0
  }

  private shown(): PoemItem[] {
    return PoetryBizService.filterPoems(this.poems, this.dynasty, this.author, this.theme, this.query)
  }

  private pickDynasty(v: string): void {
    this.dynasty = this.dynasty === v ? '' : v
  }

  private pickTheme(v: string): void {
    this.theme = this.theme === v ? '' : v
  }

  private pickAuthor(v: string): void {
    this.author = this.author === v ? '' : v
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Text('我的诗库')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'user', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onOpenMine())
      }
      .width('100%')
      .padding({ left: 20, right: 12, top: 16 })

      Row({ space: 8 }) {
        Text(`收藏 ${this.favoriteCount} 首`)
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        Blank()
        Text('设置与账号')
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .onClick(() => this.onOpenMine())
      }
      .width('100%')
      .padding({ left: 20, right: 20 })

      TextInput({ text: this.query, placeholder: '检索诗名、作者或诗句' })
        .margin({ left: 16, right: 16 })
        .onChange((v: string) => { this.query = v })

      Scroll() {
        Row({ space: 8 }) {
          FilterChip({ label: '全部朝代', active: this.dynasty.length === 0, onPick: (): void => { this.dynasty = '' } })
          ForEach(PoetryBizService.uniqueDynasties(this.poems), (d: string) => {
            FilterChip({ label: d, active: this.dynasty === d, onPick: (): void => this.pickDynasty(d) })
          }, (d: string) => `d-${d}`)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(36)
      .padding({ left: 16, right: 16 })

      Scroll() {
        Row({ space: 8 }) {
          FilterChip({ label: '全部主题', active: this.theme.length === 0, onPick: (): void => { this.theme = '' } })
          ForEach(PoetryBizService.uniqueThemes(this.poems), (t: string) => {
            FilterChip({ label: t, active: this.theme === t, onPick: (): void => this.pickTheme(t) })
          }, (t: string) => `t-${t}`)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(36)
      .padding({ left: 16, right: 16 })

      Scroll() {
        Row({ space: 8 }) {
          FilterChip({ label: '全部作者', active: this.author.length === 0, onPick: (): void => { this.author = '' } })
          ForEach(PoetryBizService.uniqueAuthors(this.poems), (a: string) => {
            FilterChip({ label: a, active: this.author === a, onPick: (): void => this.pickAuthor(a) })
          }, (a: string) => `a-${a}`)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(36)
      .padding({ left: 16, right: 16 })

      if (this.failed && !this.loading) {
        AppError({
          title: '诗库暂不可用',
          message: PoetryBizService.lastHint(),
          retryLabel: '重试',
          onRetry: (): void => { void this.reload() }
        })
      } else if (this.shown().length === 0) {
        AppEmpty({
          title: '没有匹配的诗词',
          description: '换一个朝代、主题或关键词试试',
          actionLabel: '清除筛选',
          onAction: (): void => {
            this.query = ''
            this.dynasty = ''
            this.author = ''
            this.theme = ''
          }
        })
      } else {
        List({ space: 12 }) {
          ForEach(this.shown(), (p: PoemItem) => {
            ListItem() {
              PoemListCard({
                dynasty: p.dynasty,
                title: p.title,
                author: p.author,
                summary: p.summary,
                cover: PoetryMedia.cover(p.coverKey),
                onOpen: (): void => PoetryNav.openPoem(p.id)
              })
            }
            .padding({ left: 16, right: 16 })
          }, (p: PoemItem) => p.id)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
        .padding({ bottom: 16, top: 4 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
