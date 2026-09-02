import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ArchiveCard } from '../components/archive/ArchiveCard'
import { CategoryChips } from '../components/archive/CategoryChips'
import { Archive } from '../models/ArchiveModels'
import { ArchiveStore } from '../services/ArchiveStore'
import { ArchiveDetailNav } from '../services/ArchiveDetailNav'

@Component
export struct ArchiveLibraryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State searchText: string = ''
  @State selectedCategory: string = ''
  @State showFavoritesOnly: boolean = false
  @State archives: Archive[] = []
  @State filtered: Archive[] = []
  @State pending: Archive[] = []
  @State catLabels: string[] = []
  @State catKeys: string[] = []
  @State nodeCounts: Map<string, number> = new Map()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.archives = await ArchiveStore.loadArchives()
    this.pending = await ArchiveStore.pendingArchives()
    const cats = await ArchiveStore.loadCategories()
    const labels: string[] = []
    const keys: string[] = []
    for (const c of cats) {
      labels.push(c.label)
      keys.push(c.key)
    }
    this.catLabels = labels
    this.catKeys = keys
    const nodes = await ArchiveStore.loadNodes()
    const countMap: Map<string, number> = new Map()
    for (const a of this.archives) {
      let cnt = 0
      for (const n of nodes) {
        if (n.archiveId === a.id) {
          cnt++
        }
      }
      countMap.set(a.id, cnt)
    }
    this.nodeCounts = countMap
    this.applyFilter()
  }

  private applyFilter(): void {
    const q = this.searchText.trim().toLowerCase()
    const out: Archive[] = []
    for (const a of this.archives) {
      if (this.showFavoritesOnly && !a.isFavorite) {
        continue
      }
      if (this.selectedCategory.length > 0 && a.categoryKey !== this.selectedCategory) {
        continue
      }
      if (q.length > 0) {
        const hay = `${a.title} ${a.summary}`.toLowerCase()
        if (!hay.includes(q)) {
          continue
        }
      }
      out.push(a)
    }
    this.filtered = out
  }

  private pendingNotInFiltered(): Archive[] {
    const out: Archive[] = []
    for (const p of this.pending) {
      let inFiltered = false
      for (const f of this.filtered) {
        if (f.id === p.id) {
          inFiltered = true
        }
      }
      if (!inFiltered) {
        out.push(p)
      }
    }
    return out
  }

  private labelFor(key: string): string {
    for (let i = 0; i < this.catKeys.length; i++) {
      if (this.catKeys[i] === key) {
        return this.catLabels[i]
      }
    }
    return key
  }

  private nodeCountFor(id: string): number {
    const v = this.nodeCounts.get(id)
    return v !== undefined ? v : 0
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('档案库')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        TextInput({ text: this.searchText, placeholder: '搜索档案名称或摘要…' })
          .fontSize(Theme.type.body)
          .onChange((v: string): void => {
            this.searchText = v
            this.applyFilter()
          })

        CategoryChips({
          labels: this.catLabels,
          keys: this.catKeys,
          selectedKey: this.selectedCategory,
          showAll: true,
          onSelect: (key: string): void => {
            this.selectedCategory = key
            this.applyFilter()
          }
        })

        Row({ space: Theme.space.s2 }) {
          Text('收藏')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.showFavoritesOnly ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.showFavoritesOnly ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => {
              this.showFavoritesOnly = !this.showFavoritesOnly
              this.applyFilter()
            })
        }
        .width('100%')

        if (this.pendingNotInFiltered().length > 0) {
          Text(`待整理 · ${this.pendingNotInFiltered().length}`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().warning)
            .width('100%')
          ForEach(this.pendingNotInFiltered(), (a: Archive) => {
            ArchiveCard({
              archive: a,
              categoryLabel: this.labelFor(a.categoryKey),
              nodeCount: this.nodeCountFor(a.id),
              completion: ArchiveStore.completionPercent(a, this.nodeCountFor(a.id)),
              onTap: (): void => { ArchiveDetailNav.openArchiveDetail(a.id) }
            })
          }, (a: Archive) => `pending_${a.id}`)
        }

        Text('全部档案')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        if (this.filtered.length === 0) {
          AppEmpty({
            title: '暂无匹配档案',
            description: '调整筛选条件，或创建一份新档案',
            actionLabel: '创建档案',
            onAction: (): void => { ArchiveDetailNav.openCreateArchive() }
          })
        } else {
          ForEach(this.filtered, (a: Archive) => {
            ArchiveCard({
              archive: a,
              categoryLabel: this.labelFor(a.categoryKey),
              nodeCount: this.nodeCountFor(a.id),
              completion: ArchiveStore.completionPercent(a, this.nodeCountFor(a.id)),
              onTap: (): void => { ArchiveDetailNav.openArchiveDetail(a.id) }
            })
          }, (a: Archive) => a.id)
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: this.bottomInset + Theme.space.s6
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
