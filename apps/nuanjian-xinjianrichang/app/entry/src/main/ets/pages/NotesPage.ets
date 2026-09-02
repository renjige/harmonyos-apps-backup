import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { NoteListCard } from '../components/note/NoteListCard'
import { NoteItem } from '../models/NoteModels'
import { HeartNoteStore } from '../services/HeartNoteStore'
import { MoodCatalog, MoodOption } from '../services/MoodCatalog'
import { NoteNav } from '../services/NoteNav'

@Component
export struct NotesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State keyword: string = ''
  @State filter: string = 'all'
  @State items: NoteItem[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.items = this.applyFilter(HeartNoteStore.sorted())
  }

  private applyFilter(source: NoteItem[]): NoteItem[] {
    const out: NoteItem[] = []
    const q = this.keyword.trim()
    for (const n of source) {
      if (q.length > 0) {
        const hit = n.title.indexOf(q) >= 0 || n.body.indexOf(q) >= 0 || n.tagsCsv.indexOf(q) >= 0
        if (!hit) {
          continue
        }
      }
      if (this.filter === 'mood' && n.mood.length === 0) {
        continue
      }
      if (this.filter.startsWith('mood:') && n.mood !== this.filter.substring(5)) {
        continue
      }
      if (this.filter === 'tag' && n.tagsCsv.length === 0) {
        continue
      }
      if (this.filter.startsWith('tag:')) {
        const want = this.filter.substring(4)
        if (n.tagsCsv.indexOf(want) < 0) {
          continue
        }
      }
      out.push(n)
    }
    return out
  }

  private setFilter(next: string): void {
    this.filter = next
    this.reload()
  }

  build() {
    Column() {
      Column({ space: 12 }) {
        Text('我的心笺')
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        TextInput({ text: this.keyword, placeholder: '搜索你的记录' })
          .width('100%')
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onChange((v: string) => {
            this.keyword = v
            this.reload()
          })
        Row({ space: 8 }) {
          this.Chip('全部', 'all')
          this.Chip('心情', 'mood')
          this.Chip('标签', 'tag')
          this.Chip('时间', 'time')
        }
        .width('100%')
        if (this.filter === 'mood') {
          Row({ space: 8 }) {
            ForEach(MoodCatalog.all(), (m: MoodOption) => {
              Text(m.label)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.setFilter(`mood:${m.id}`) })
            }, (m: MoodOption) => m.id)
          }
          .width('100%')
        }
        if (this.filter === 'tag') {
          Row({ space: 8 }) {
            ForEach(MoodCatalog.defaultTags(), (tag: string) => {
              Text(tag)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.setFilter(`tag:${tag}`) })
            }, (tag: string) => tag)
          }
          .width('100%')
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      .width('100%')

      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有心笺',
          description: '写一句话，给今天留个位置。',
          actionLabel: '写下今天',
          onAction: (): void => { NoteNav.openWrite('') }
        })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.items, (n: NoteItem) => {
            ListItem() {
              NoteListCard({
                item: n,
                onTap: (): void => { NoteNav.openDetail(n.id) }
              })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
          }, (n: NoteItem) => n.id)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Chip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.filter === key || (key === 'mood' && this.filter.startsWith('mood:')) ||
        (key === 'tag' && this.filter.startsWith('tag:')) ?
        Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 6, bottom: 6 })
      .backgroundColor(this.filter === key || (key === 'mood' && this.filter.startsWith('mood:')) ||
        (key === 'tag' && this.filter.startsWith('tag:')) ?
        Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.setFilter(key) })
  }
}
