import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { JournalListCard } from '../components/journal/JournalListCard'
import { ShiyiEmpty } from '../components/journal/ShiyiEmpty'
import { FilterChip, JournalEntry } from '../models/ShiyiModels'
import { MoodCatalog } from '../services/MoodCatalog'
import { ShiyiNav } from '../services/ShiyiNav'
import { ShiyiStore } from '../services/ShiyiStore'

@Component
export struct JournalPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State query: string = ''
  @State filterId: string = 'all'
  @State items: JournalEntry[] = []
  @State chips: FilterChip[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private reload(): void {
    this.chips = this.buildChips()
    this.items = this.filtered()
  }

  private buildChips(): FilterChip[] {
    const list: FilterChip[] = []
    const all = new FilterChip()
    all.id = 'all'
    all.label = '全部'
    list.push(all)
    const moods = MoodCatalog.all()
    for (const mood of moods) {
      const chip = new FilterChip()
      chip.id = `mood:${mood.id}`
      chip.label = mood.label
      list.push(chip)
    }
    const tags = ShiyiStore.tags()
    for (const tag of tags) {
      const chip = new FilterChip()
      chip.id = `tag:${tag.name}`
      chip.label = tag.name
      list.push(chip)
    }
    return list
  }

  private filtered(): JournalEntry[] {
    const all = ShiyiStore.sortedJournals()
    const out: JournalEntry[] = []
    const q = this.query.trim()
    for (const item of all) {
      if (!this.matchFilter(item)) {
        continue
      }
      if (q.length > 0 && !this.matchQuery(item, q)) {
        continue
      }
      out.push(item)
    }
    return out
  }

  private matchFilter(item: JournalEntry): boolean {
    if (this.filterId === 'all') {
      return true
    }
    if (this.filterId.indexOf('mood:') === 0) {
      const mood = this.filterId.substring(5)
      return item.mood === mood
    }
    if (this.filterId.indexOf('tag:') === 0) {
      const name = this.filterId.substring(4)
      for (const tag of item.tags) {
        if (tag === name) {
          return true
        }
      }
      return false
    }
    return true
  }

  private matchQuery(item: JournalEntry, q: string): boolean {
    if (item.title.indexOf(q) >= 0) {
      return true
    }
    if (item.body.indexOf(q) >= 0) {
      return true
    }
    if (item.oneLiner.indexOf(q) >= 0) {
      return true
    }
    if (item.keyword.indexOf(q) >= 0) {
      return true
    }
    for (const tag of item.tags) {
      if (tag.indexOf(q) >= 0) {
        return true
      }
    }
    return MoodCatalog.labelOf(item.mood).indexOf(q) >= 0
  }

  build() {
    Column() {
      Row() {
        Text('我的手账')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          ShiyiNav.openCompose('', ShiyiStore.today())
        })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s3
      })

      TextInput({ text: this.query, placeholder: '搜索标题、心情或标签' })
        .height(44)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .padding({ left: 14, right: 14 })
        .onChange((v: string) => {
          this.query = v
          this.items = this.filtered()
        })

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.chips, (chip: FilterChip) => {
            Text(chip.label)
              .fontSize(Theme.type.footnote)
              .fontColor(this.filterId === chip.id ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.filterId === chip.id ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.tag)
              .onClick(() => {
                this.filterId = chip.id
                this.items = this.filtered()
              })
          }, (chip: FilterChip) => chip.id)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      if (this.items.length === 0) {
        ShiyiEmpty({
          title: '还没有手账。',
          description: '写下第一份拾意，以后就能在这里慢慢翻看。',
          actionLabel: '写下第一份拾意',
          onAction: (): void => {
            ShiyiNav.openCompose('', ShiyiStore.today())
          }
        })
          .layoutWeight(1)
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.items, (item: JournalEntry) => {
            ListItem() {
              JournalListCard({
                entry: item,
                onTap: (): void => {
                  ShiyiNav.openDetail(item.id)
                }
              })
            }
          }, (item: JournalEntry) => item.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
