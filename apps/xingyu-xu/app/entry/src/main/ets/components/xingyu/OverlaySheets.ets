import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { Narrative, SparkItem, FavoriteItem, AchievementDef, TagItem } from '../../models/XingyuModels'
import { XingyuStore } from '../../services/XingyuStore'
import { XingyuStats } from '../../services/XingyuStats'
import { XingyuNav } from '../../services/XingyuNav'
import { NarrativeCard } from './ArchiveCards'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct SearchSheet {
  @State query: string = ''
  @State narratives: Narrative[] = []
  @State sparks: SparkItem[] = []

  private async run(): Promise<void> {
    this.narratives = await XingyuStore.searchAll(this.query)
    this.sparks = await XingyuStore.searchSparks(this.query)
  }

  build() {
    DetailShell({ title: '搜索档案', onBack: () => XingyuNav.closeSearch() }) {
      Column({ space: Theme.space.s4 }) {
        TextInput({ text: this.query, placeholder: '标题、正文、标签、日期' })
          .onChange((v: string) => {
            this.query = v
            void this.run()
          })
          .height(44)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .padding({ left: 14, right: 14 })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.query.length > 0 && this.narratives.length === 0 && this.sparks.length === 0) {
              AppEmpty({ title: '没有匹配', description: '换个关键词试试' })
            }
            ForEach(this.narratives, (n: Narrative) => {
              NarrativeCard({
                title: n.title,
                dateKey: n.dateKey,
                statusLabel: n.statusLabel(),
                preview: n.preview(),
                coverKey: n.coverKey(),
                onOpen: () => {
                  XingyuNav.closeSearch()
                  XingyuNav.openNarrative(n.id)
                }
              })
            }, (n: Narrative) => n.id)
            ForEach(this.sparks, (s: SparkItem) => {
              NarrativeCard({
                title: s.title,
                dateKey: s.dateKey,
                statusLabel: s.kindLabel(),
                preview: s.preview(),
                coverKey: 'cover_hobby',
                onOpen: () => {
                  XingyuNav.closeSearch()
                  XingyuNav.openSpark(s.id)
                }
              })
            }, (s: SparkItem) => s.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
    }
  }
}

@Component
export struct FavoritesSheet {
  @StorageLink('xingyuRev') @Watch('onRev') xingyuRev: number = 0
  @State items: FavoriteItem[] = []
  @State titles: string[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await XingyuStore.loadFavorites()
    const labels: string[] = []
    for (const f of this.items) {
      if (f.targetType === 'narrative') {
        const n = await XingyuStore.findNarrative(f.targetId)
        labels.push(`${f.id}\t${n !== undefined ? n.title : '已删除的叙事'}`)
      } else {
        const s = await XingyuStore.findSpark(f.targetId)
        labels.push(`${f.id}\t${s !== undefined ? s.title : '已删除的灵感'}`)
      }
    }
    this.titles = labels
  }

  private titleOf(id: string): string {
    for (const line of this.titles) {
      if (line.indexOf(`${id}\t`) === 0) {
        return line.substring(id.length + 1)
      }
    }
    return '收藏'
  }

  private openFav(f: FavoriteItem): void {
    XingyuNav.closeFavorites()
    if (f.targetType === 'spark') {
      XingyuNav.openSpark(f.targetId)
      return
    }
    XingyuNav.openNarrative(f.targetId)
  }

  build() {
    DetailShell({ title: '星光收藏', onBack: () => XingyuNav.closeFavorites() }) {
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.items.length === 0) {
            AppEmpty({
              title: '收藏还是空的',
              description: '在详情里把重要片段收入星光收藏。'
            })
          }
          ForEach(this.items, (f: FavoriteItem) => {
            Column({ space: 4 }) {
              Text(this.titleOf(f.id))
                .fontSize(Theme.type.subtitleM)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(f.excerpt.length > 0 ? f.excerpt : (f.targetType === 'spark' ? '灵感' : '叙事'))
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick(() => this.openFav(f))
          }, (f: FavoriteItem) => f.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
  }
}

@Component
export struct AchievementSheet {
  @StorageLink('xingyuRev') @Watch('onRev') xingyuRev: number = 0
  @State items: AchievementDef[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await XingyuStats.achievements()
  }

  build() {
    DetailShell({ title: '星徽墙', onBack: () => XingyuNav.closeAchievements() }) {
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.items, (a: AchievementDef) => {
            Column({ space: 6 }) {
              Text(a.title)
                .fontSize(Theme.type.subtitleM)
                .fontWeight(FontWeight.Medium)
                .fontColor(a.unlocked ? Theme.colors().brandAccent : Theme.colors().textPrimary)
                .width('100%')
              Text(a.hint)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Text(a.unlocked ? '已点亮' : '尚未点亮')
                .fontSize(Theme.type.caption)
                .fontColor(a.unlocked ? Theme.colors().brandAccent : Theme.colors().textTertiary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .opacity(a.unlocked ? 1 : 0.7)
          }, (a: AchievementDef) => a.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
  }
}

@Component
export struct TagManagerSheet {
  @StorageLink('xingyuRev') @Watch('onRev') xingyuRev: number = 0
  @State tags: TagItem[] = []
  @State name: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.tags = await XingyuStore.loadTags()
  }

  private async add(): Promise<void> {
    const t = this.name.trim()
    if (t.length === 0) {
      return
    }
    const item = TagItem.make(`tag_${Date.now()}`, t, false)
    await XingyuStore.saveTag(item)
    this.name = ''
    await this.reload()
  }

  build() {
    DetailShell({ title: '标签', onBack: () => XingyuNav.closeTags() }) {
      Column({ space: Theme.space.s4 }) {
        Row({ space: Theme.space.s2 }) {
          TextInput({ text: this.name, placeholder: '自定义标签' })
            .layoutWeight(1)
            .height(44)
            .onChange((v: string) => {
              this.name = v
            })
          Text('添加')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .onClick(() => {
              void this.add()
            })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
        Scroll() {
          Column({ space: Theme.space.s2 }) {
            ForEach(this.tags, (t: TagItem) => {
              Text(`${t.name}${t.systemTag ? ' · 默认' : ''}`)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.sm)
            }, (t: TagItem) => t.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
    }
  }
}
