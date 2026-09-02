import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { Narrative } from '../models/XingyuModels'
import { XingyuStore } from '../services/XingyuStore'
import { XingyuNav } from '../services/XingyuNav'
import { NarrativeCard } from '../components/xingyu/ArchiveCards'

@Component
export struct NarrativePage {
  @StorageLink('xingyuRev') @Watch('onRev') xingyuRev: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: Narrative[] = []
  @State filter: string = 'all'
  @State query: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const all = await XingyuStore.loadNarratives()
    const out: Narrative[] = []
    for (const n of all) {
      if (this.filter !== 'all' && n.status !== this.filter) {
        continue
      }
      if (this.query.length > 0) {
        const blob = `${n.title} ${n.bodyText()} ${n.tags.join(' ')}`
        if (blob.indexOf(this.query) < 0) {
          continue
        }
      }
      out.push(n)
    }
    this.items = out
  }

  @Builder
  filterChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.filter === key ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .margin({ right: 8 })
      .backgroundColor(this.filter === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.filter = key
        void this.reload()
      })
  }

  build() {
    Column() {
      AppHeader({ title: '叙事', subtitle: '生活档案卡片' })
      Row({ space: Theme.space.s2 }) {
        TextInput({ text: this.query, placeholder: '搜索标题、正文、标签' })
          .layoutWeight(1)
          .height(40)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .padding({ left: 12, right: 12 })
          .onChange((v: string) => {
            this.query = v
            void this.reload()
          })
        Row() {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => XingyuNav.openSearch())
        Row() {
          AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(20)
        .onClick(() => XingyuNav.openEditor('narrative', ''))
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
      Scroll() {
        Row() {
          this.filterChip('全部', 'all')
          this.filterChip('珍藏', 'treasure')
          this.filterChip('重要', 'important')
          this.filterChip('回忆', 'memory')
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: Theme.space.pageX, top: Theme.space.s3 })
      .width('100%')

      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有叙事',
          description: '用模板写下今天的片段，而不是一页空白日记。',
          actionLabel: '新建叙事',
          onAction: () => XingyuNav.openEditor('narrative', '')
        })
          .layoutWeight(1)
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.items, (n: Narrative) => {
            ListItem() {
              NarrativeCard({
                title: n.title,
                dateKey: n.dateKey,
                statusLabel: n.statusLabel(),
                preview: n.preview(),
                coverKey: n.coverKey(),
                onOpen: () => XingyuNav.openNarrative(n.id)
              })
            }
          }, (n: Narrative) => n.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s10 })
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
