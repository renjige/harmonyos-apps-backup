import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { SlipListCard } from '../components/slip/SlipListCard'
import { CategoryCatalog, SlipItem } from '../models/SlipModels'
import { SlipStore } from '../services/SlipStore'
import { SlipNav } from '../services/SlipNav'

@Component
export struct NotesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State query: string = ''
  @State category: string = '全部'
  @State items: SlipItem[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.items = this.filterList(SlipStore.sorted())
  }

  private filterList(all: SlipItem[]): SlipItem[] {
    const out: SlipItem[] = []
    const q = this.query.trim()
    for (const n of all) {
      if (this.category !== '全部' && n.category !== this.category) {
        continue
      }
      if (q.length > 0 && n.title.indexOf(q) < 0 && n.content.indexOf(q) < 0) {
        continue
      }
      out.push(n)
    }
    return out
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('我的备笺')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Row({ space: 8 }) {
        AppIcon({ name: 'search', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
        TextInput({ text: this.query, placeholder: '搜索备笺' })
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .placeholderColor(Theme.colors().textTertiary)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .onChange((v: string) => {
            this.query = v
            this.reload()
          })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })

      Scroll() {
        Row({ space: 8 }) {
          ForEach(CategoryCatalog.withAll(), (c: string) => {
            Text(c)
              .fontSize(Theme.type.caption)
              .fontColor(this.category === c ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.category === c ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => {
                this.category = c
                this.reload()
              })
          }, (c: string) => c)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      if (this.items.length === 0) {
        AppEmpty({
          title: '想到什么，就写下来。',
          description: '一条备笺，就能让心里轻松一些。',
          actionLabel: '新建备笺',
          onAction: (): void => { SlipNav.openWrite('') }
        })
          .layoutWeight(1)
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.items, (it: SlipItem) => {
            ListItem() {
              SlipListCard({
                item: it,
                onOpen: (id: string): void => { SlipNav.openDetail(id) },
                onToggle: (id: string): void => { void SlipStore.toggleDone(id) }
              })
            }
          }, (it: SlipItem) => it.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
