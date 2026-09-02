import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { DetailShell } from '../components/detail/DetailShell'
import { TreasureListCard } from '../components/treasure/TreasureListCard'
import {
  CollectionNote,
  CollectionPlan,
  TreasureAlbum,
  TreasureItem,
  WishItem
} from '../models/TreasureModels'
import { TreasureNav } from '../services/TreasureNav'
import { TreasureStore } from '../services/TreasureStore'

@Component
export struct DomainArchivePage {
  @StorageLink('treasureDomainKey') domainKey: string = ''
  @State domainLabel: string = ''
  @State domainTone: string = ''
  @State items: TreasureItem[] = []

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.domainLabel = ''
    this.domainTone = Theme.colors().brandDeep
    for (const d of TreasureStore.domainBuckets()) {
      if (d.key === this.domainKey) {
        this.domainLabel = d.label
        this.domainTone = d.tone
        break
      }
    }
    this.items = TreasureStore.itemsByDomain(this.domainKey)
  }

  private closePage(): void {
    AppStorage.setOrCreate('treasureDomainKey', '')
    TreasureNav.closeSubPage()
  }

  build() {
    DetailShell({
      title: this.domainLabel.length > 0 ? `收藏领域 · ${this.domainLabel}` : '收藏领域',
      onClose: (): void => { this.closePage() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      Column({ space: Theme.space.s2 }) {
        Text(this.domainLabel.length > 0 ? this.domainLabel : '领域')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textOnInverse)
        Text(`${this.items.length} 件珍藏`)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textOnInverse)
      }
      .width('100%')
      .padding(Theme.space.s5)
      .borderRadius(Theme.radius.xl)
      .backgroundColor(this.domainTone)
      .alignItems(HorizontalAlign.Start)

      if (this.items.length === 0) {
        AppEmpty({
          title: '这个领域还没有珍藏',
          description: '建档时选择对应分类，藏品会自动归入收藏领域',
          actionLabel: '去建档',
          onAction: (): void => {
            this.closePage()
            TreasureNav.openEditor('')
          }
        }).layoutWeight(1)
      } else {
        Scroll() {
          GridRow({ columns: 2, gutter: Theme.space.s3 }) {
            ForEach(this.items, (item: TreasureItem) => {
              GridCol({ span: 1 }) {
                TreasureListCard({
                  item: item,
                  onTap: (): void => { TreasureNav.openDetail(item.id) }
                })
              }
            }, (item: TreasureItem) => item.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}

@Component
export struct AlbumDetailPage {
  onToast: (text: string) => void = (text: string) => {}
  @StorageLink('treasureAlbumId') albumId: string = ''
  @State album: TreasureAlbum = new TreasureAlbum()
  @State items: TreasureItem[] = []
  @State candidates: TreasureItem[] = []
  @State showAddPanel: boolean = false

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    const found = TreasureStore.findAlbum(this.albumId)
    this.album = found !== null ? found : new TreasureAlbum()
    this.items = TreasureStore.itemsInAlbum(this.albumId)
    this.candidates = []
    for (const item of TreasureStore.activeItems()) {
      let inAlbum = false
      for (const id of this.album.itemIds) {
        if (id === item.id) {
          inAlbum = true
          break
        }
      }
      if (!inAlbum) {
        this.candidates.push(item)
      }
    }
  }

  private async removeItem(itemId: string): Promise<void> {
    await TreasureStore.removeItemFromAlbum(this.albumId, itemId)
    this.reload()
    this.onToast('已从主题册移除')
  }

  private async addItem(itemId: string): Promise<void> {
    await TreasureStore.addItemToAlbum(this.albumId, itemId)
    this.showAddPanel = false
    this.reload()
    this.onToast('已加入主题册')
  }

  build() {
    DetailShell({
      title: this.album.name.length > 0 ? this.album.name : '主题册',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      if (this.album.intro.length > 0) {
        Text(this.album.intro)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .lineHeight(22)
      }
      Row() {
        Text(`${this.items.length} 件珍藏`)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .layoutWeight(1)
        Text(TreasureStore.dateLabel(this.album.createdAt))
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
      }

      AppButton({
        label: '添加珍藏到此主题',
        variant: 'primary',
        onTap: (): void => { this.showAddPanel = !this.showAddPanel }
      })

      if (this.showAddPanel) {
        if (this.candidates.length === 0) {
          Text('暂无可添加的珍藏').fontColor(Theme.colors().textSecondary)
        } else {
          ForEach(this.candidates, (item: TreasureItem) => {
            Row() {
              Text(item.name).layoutWeight(1).fontColor(Theme.colors().textPrimary)
              Text('添加')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().brandPrimary)
                .onClick((): void => { void this.addItem(item.id) })
            }
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (item: TreasureItem) => `add_${item.id}`)
        }
      }

      if (this.items.length === 0) {
        AppEmpty({
          title: '主题册还是空的',
          description: '把珍藏加入此主题，形成你的数字收藏册。',
          actionLabel: '添加第一件',
          onAction: (): void => { this.showAddPanel = true }
        })
      } else {
        ForEach(this.items, (item: TreasureItem) => {
          Column() {
            TreasureListCard({
              item: item,
              onTap: (): void => {
                TreasureNav.closeSubPage()
                TreasureNav.openDetail(item.id)
              }
            })
            Text('移出主题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().danger)
              .width('100%')
              .textAlign(TextAlign.End)
              .onClick((): void => { void this.removeItem(item.id) })
          }
        }, (item: TreasureItem) => item.id)
      }
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
  }
}

@Component
export struct PlanListPage {
  onToast: (text: string) => void = (text: string) => {}
  @State plans: CollectionPlan[] = []

  aboutToAppear(): void {
    this.plans = TreasureStore.plans()
  }

  build() {
    DetailShell({
      title: '收藏计划',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      AppButton({
        label: '新建收藏计划',
        variant: 'primary',
        onTap: (): void => { TreasureNav.openPlanEditor('') }
      })

      if (this.plans.length === 0) {
        AppEmpty({
          title: '还没有收藏计划',
          description: '设定年度或主题目标，让收藏更有方向。',
          actionLabel: '创建计划',
          onAction: (): void => { TreasureNav.openPlanEditor('') }
        })
      } else {
        ForEach(this.plans, (p: CollectionPlan) => {
          Column({ space: Theme.space.s2 }) {
            Text(p.name).fontSize(Theme.type.title3).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary)
            Text(`${p.period} · 目标 ${p.targetCount} 件`).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
            Row() {
              Text(`${TreasureStore.planDoneCount(p)} / ${p.targetCount}`)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().brandPrimary)
                .layoutWeight(1)
              Text(`${TreasureStore.planProgress(p)}%`)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textSecondary)
            }
            Row()
              .width(`${TreasureStore.planProgress(p)}%`)
              .height(6)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { TreasureNav.openPlanEditor(p.id) })
        }, (p: CollectionPlan) => p.id)
      }
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
  }
}

@Component
export struct WishListPage {
  onToast: (text: string) => void = (text: string) => {}
  @State wishes: WishItem[] = []
  @State kindFilter: string = '全部'
  @State newName: string = ''
  @State newNote: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.wishes = TreasureStore.wishes()
  }

  private filtered(): WishItem[] {
    if (this.kindFilter === '全部') {
      return this.wishes
    }
    const out: WishItem[] = []
    for (const w of this.wishes) {
      if (w.listKind === this.kindFilter) {
        out.push(w)
      }
    }
    return out
  }

  private async addWish(): Promise<void> {
    if (this.newName.trim().length === 0) {
      this.onToast('请填写名称')
      return
    }
    const w = new WishItem()
    w.id = TreasureStore.newId()
    w.name = this.newName.trim()
    w.note = this.newNote.trim()
    w.listKind = this.kindFilter === '全部' ? '想寻找' : this.kindFilter
    await TreasureStore.saveWish(w)
    this.newName = ''
    this.newNote = ''
    this.reload()
    this.onToast('已加入收藏清单')
  }

  private async applyTemplate(row: string[]): Promise<void> {
    const w = new WishItem()
    w.id = TreasureStore.newId()
    w.name = row[0]
    w.note = row[1]
    w.listKind = row[2]
    await TreasureStore.saveWish(w)
    this.reload()
    this.onToast('模板已加入清单')
  }

  private async removeWish(id: string): Promise<void> {
    await TreasureStore.removeWish(id)
    this.reload()
    this.onToast('已删除')
  }

  build() {
    DetailShell({
      title: '收藏清单',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(['全部', '待收藏', '想寻找', '待整理'], (k: string) => {
            Text(k)
              .fontSize(Theme.type.caption)
              .fontColor(this.kindFilter === k ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.kindFilter === k ? Theme.colors().brandDeep : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.kindFilter = k })
          }, (k: string) => k)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      Text('清单模板').fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textSecondary)
      ForEach(TreasureStore.wishTemplateRows(), (row: string[]) => {
        Row() {
          Column({ space: 4 }) {
            Text(row[0]).fontColor(Theme.colors().textPrimary)
            Text(row[1]).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Text('使用').fontColor(Theme.colors().brandPrimary).onClick((): void => { void this.applyTemplate(row) })
        }
        .padding(Theme.space.s3)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
      }, (row: string[]) => row[0])

      TextInput({ text: this.newName, placeholder: '想收藏的物品名称' })
        .fontColor(Theme.colors().textPrimary)
        .placeholderColor(Theme.colors().textTertiary)
        .onChange((v: string) => { this.newName = v })
      TextInput({ text: this.newNote, placeholder: '备注（可选）' })
        .fontColor(Theme.colors().textPrimary)
        .placeholderColor(Theme.colors().textTertiary)
        .onChange((v: string) => { this.newNote = v })
      AppButton({ label: '添加到清单', variant: 'primary', onTap: (): void => { void this.addWish() } })

      ForEach(this.filtered(), (w: WishItem) => {
        Row() {
          Column({ space: 4 }) {
            Text(w.name).fontColor(Theme.colors().textPrimary)
            Text(`${w.listKind}${w.note.length > 0 ? ' · ' + w.note : ''}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Text('删除').fontSize(Theme.type.caption).fontColor(Theme.colors().danger)
            .onClick((): void => { void this.removeWish(w.id) })
        }
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
      }, (w: WishItem) => w.id)
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
  }
}

@Component
export struct NoteListPage {
  onToast: (text: string) => void = (text: string) => {}
  @State notes: CollectionNote[] = []

  aboutToAppear(): void {
    this.notes = TreasureStore.notes()
  }

  build() {
    DetailShell({
      title: '珍藏笔记',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s3 }) {
      AppButton({
        label: '写笔记',
        variant: 'primary',
        onTap: (): void => { TreasureNav.openNoteEditor('') }
      })
      if (this.notes.length === 0) {
        AppEmpty({
          title: '还没有笔记',
          description: '记录收藏心得、整理方法与鉴赏感受。',
          actionLabel: '写第一篇',
          onAction: (): void => { TreasureNav.openNoteEditor('') }
        })
      } else {
        ForEach(this.notes, (n: CollectionNote) => {
          Column({ space: Theme.space.s2 }) {
            Text(n.title.length > 0 ? n.title : '无标题笔记')
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text(n.body).fontSize(Theme.type.subhead).fontColor(Theme.colors().textSecondary).maxLines(3)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { TreasureNav.openNoteEditor(n.id) })
        }, (n: CollectionNote) => n.id)
      }
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
  }
}

@Component
export struct ComparePage {
  @StorageLink('treasureCompareFirst') firstId: string = ''
  @StorageLink('treasureCompareSecond') secondId: string = ''
  @State first: TreasureItem = new TreasureItem()
  @State second: TreasureItem = new TreasureItem()
  @State pickMode: boolean = true
  @State candidates: TreasureItem[] = []

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    const f = TreasureStore.findItem(this.firstId)
    this.first = f !== null ? f : new TreasureItem()
    const s = TreasureStore.findItem(this.secondId)
    this.second = s !== null ? s : new TreasureItem()
    this.candidates = TreasureStore.activeItems()
    this.pickMode = this.secondId.length === 0
  }

  build() {
    DetailShell({
      title: '珍藏对比',
      onClose: (): void => { TreasureNav.closeSubPage() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      if (this.pickMode) {
        Text('选择第二件珍藏进行对比').fontColor(Theme.colors().textSecondary)
        ForEach(this.candidates, (item: TreasureItem) => {
          if (item.id !== this.firstId) {
            Row() {
              Text(item.name).layoutWeight(1).fontColor(Theme.colors().textPrimary)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
            }
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .onClick((): void => {
              this.secondId = item.id
              this.pickMode = false
              this.reload()
            })
          }
        }, (item: TreasureItem) => `cmp_${item.id}`)
      } else {
        this.CompareColumn('第一件', this.first)
        this.CompareColumn('第二件', this.second)
        AppButton({
          label: '换一件对比',
          variant: 'secondary',
          onTap: (): void => { this.secondId = ''; this.pickMode = true }
        })
      }
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
  }

  @Builder
  CompareColumn(label: string, item: TreasureItem) {
    Column({ space: Theme.space.s2 }) {
      Text(label).fontSize(Theme.type.caption).fontColor(Theme.colors().brandPrimary)
      Text(item.name).fontSize(Theme.type.title3).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary)
      this.CompareRow('分类', TreasureStore.categoryName(item.categoryId))
      this.CompareRow('收藏时间', item.acquiredAt)
      this.CompareRow('状态', item.archiveStatus)
      this.CompareRow('清单', item.listStatus)
      this.CompareRow('评分', item.rating > 0 ? `${item.rating} 星` : '—')
      this.CompareRow('收藏原因', item.collectReason)
      this.CompareRow('备注', item.storageNote)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  @Builder
  CompareRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width(72)
      Text(value.length > 0 ? value : '—').fontSize(Theme.type.subhead).fontColor(Theme.colors().textPrimary).layoutWeight(1)
    }
    .width('100%')
  }
}

@Component
export struct OnboardingOverlay {
  onDone: () => void = () => {}

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)

      Column({ space: Theme.space.s6 }) {
        Text('欢迎来到珍藏空间')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
        Text('建立珍藏 · 整理主题 · 记录故事 · 回顾时光')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .textAlign(TextAlign.Center)
        Column({ space: Theme.space.s3 }) {
          this.IntroRow('建档', '为每件物品建立完整档案')
          this.IntroRow('主题', '用主题册整理收藏故事')
          this.IntroRow('回顾', '时间轴与日历记录收藏足迹')
        }
        AppButton({
          label: '创建第一件珍藏',
          variant: 'primary',
          onTap: (): void => {
            void this.finish(true)
          }
        })
        Text('稍后再说')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
          .onClick((): void => { void this.finish(false) })
      }
      .width('88%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .zIndex(40)
    .alignContent(Alignment.Center)
  }

  @Builder
  IntroRow(title: string, desc: string) {
    Row({ space: Theme.space.s3 }) {
      Text(title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandPrimary)
        .width(48)
      Text(desc).fontSize(Theme.type.subhead).fontColor(Theme.colors().textSecondary).layoutWeight(1)
    }
    .width('100%')
  }

  private async finish(openEditor: boolean): Promise<void> {
    const s = TreasureStore.settings()
    s.onboardingDone = true
    await TreasureStore.saveSettings(s)
    this.onDone()
    if (openEditor) {
      TreasureNav.openEditor('')
    }
  }
}
