import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ChoiceChip, PrepareProgressCard } from '../components/travel/TravelCards'
import { ChecklistItem, ChecklistPreset } from '../models/TravelModels'
import { TravelService } from '../services/TravelService'
import { AuthService } from '../services/AuthService'

@Component
export struct ChecklistPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: ChecklistItem[] = []
  @State presets: ChecklistPreset[] = []
  @State loading: boolean = false
  @State importing: boolean = false
  @Prop embedded: boolean = false
  @Prop @Watch('onEpochChange') dataEpoch: number = 0
  onCreate: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  onEditItem: (item: ChecklistItem) => void = () => {}
  onProgressChange: (done: number, total: number, percent: number) => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onEpochChange(): void {
    void this.load(true)
  }

  private async load(silent: boolean = false): Promise<void> {
    if (!silent) {
      this.loading = true
    }
    try {
      this.items = await TravelService.checklistItems()
      this.presets = await TravelService.presets()
    } catch {
      this.items = []
      this.presets = []
    }
    this.loading = false
    this.emitProgress()
  }

  private doneCount(): number {
    const stats = TravelService.checklistProgress(this.items)
    return stats[0]
  }

  private totalCount(): number {
    const stats = TravelService.checklistProgress(this.items)
    return stats[1]
  }

  private emitProgress(): void {
    const stats = TravelService.checklistProgress(this.items)
    this.onProgressChange(stats[0], stats[1], stats[2])
  }

  private categoryItems(category: string): ChecklistItem[] {
    const result: ChecklistItem[] = []
    for (const item of this.items) {
      if (item.category === category) {
        result.push(item)
      }
    }
    return result
  }

  private categoryPresets(category: string): ChecklistPreset[] {
    const result: ChecklistPreset[] = []
    for (const item of this.presets) {
      if (item.category === category) {
        result.push(item)
      }
    }
    return result
  }

  private async toggle(item: ChecklistItem): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.onRequireAuth()
      return
    }
    const next = item.completed !== true
    const ok = await TravelService.setChecklistCompleted(item.id, next)
    if (!ok) {
      return
    }
    const copied: ChecklistItem[] = []
    for (const row of this.items) {
      const mapped = TravelService.mapChecklist(row)
      if (row.id === item.id) {
        mapped.completed = next
        mapped.status = next ? 'done' : 'pending'
      }
      copied.push(mapped)
    }
    this.items = copied
    this.emitProgress()
    this.onChanged()
  }

  private confirmDelete(item: ChecklistItem): void {
    AlertDialog.show({
      title: '删除清单事项',
      message: `确定删除「${item.title}」？此操作不可恢复。`,
      primaryButton: {
        value: '删除',
        action: (): void => { void this.deleteItem(item) }
      },
      secondaryButton: {
        value: '取消',
        action: (): void => {}
      }
    })
  }

  private async deleteItem(item: ChecklistItem): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.onRequireAuth()
      return
    }
    const ok = await TravelService.deleteChecklist(item.id)
    if (!ok) {
      return
    }
    const copied: ChecklistItem[] = []
    for (const row of this.items) {
      if (row.id !== item.id) {
        copied.push(row)
      }
    }
    this.items = copied
    this.emitProgress()
    this.onChanged()
  }

  private async importPresets(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.onRequireAuth()
      return
    }
    this.importing = true
    await TravelService.importPresets('')
    await this.load()
    this.importing = false
    this.onChanged()
  }

  build() {
    if (this.embedded) {
      this.ListBody()
    } else {
      Column() {
        AppHeader({ title: '清单', subtitle: '分类整理，出发前从容核对' })
        Scroll() {
          this.ListBody()
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    }
  }

  @Builder
  ListBody() {
    Column({ space: Theme.space.s4 }) {
          if (this.embedded && this.items.length > 0) {
            PrepareProgressCard({ done: this.doneCount(), total: this.totalCount() })
          }
          AppButton({ label: '创建清单事项', onTap: () => this.onCreate() })
          if (this.items.length === 0 && this.presets.length > 0) {
            AppButton({
              label: this.importing ? '正在导入…' : `导入 ${this.presets.length} 项出行清单模板`,
              variant: 'secondary',
              disabled: this.importing,
              onTap: () => { void this.importPresets() }
            })
          }
          if (this.loading) {
            LoadingProgress()
              .width(32)
              .height(32)
              .color(Theme.colors().brandPrimary)
          }
          if (this.items.length === 0 && !this.loading) {
            AppEmpty({
              title: '清单还是空的',
              description: this.presets.length > 0 ? `已有 ${this.presets.length} 项公开模板，可一键导入后逐项勾选` : '登录后创建第一条出行事项',
              actionLabel: '重新加载',
              onAction: () => { void this.load() }
            })
          }
          this.Category('证件')
          this.Category('衣物')
          this.Category('设备')
          this.Category('用品')
    }
    .width('100%')
    .padding({
      left: Theme.space.pageX,
      right: Theme.space.pageX,
      bottom: this.embedded ? Theme.space.s4 : Theme.space.s10
    })
  }

  @Builder
  Category(name: string) {
    Column({ space: Theme.space.s2 }) {
      Text(name)
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.categoryItems(name), (item: ChecklistItem) => {
        Row({ space: Theme.space.s2 }) {
          Row() {
            if (item.completed) {
              AppIcon({ name: 'check', iconSize: Theme.icon.sm, color: '#FFFFFF' })
            }
          }
          .width(28)
          .height(28)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(item.completed ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick(() => { void this.toggle(item) })
          Text(item.title)
            .fontSize(Theme.type.bodyM)
            .fontColor(item.completed ? Theme.colors().textSecondary : Theme.colors().textPrimary)
            .decoration({ type: item.completed ? TextDecorationType.LineThrough : TextDecorationType.None })
            .layoutWeight(1)
            .onClick(() => { void this.toggle(item) })
          Text('编辑')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 8, right: 8, top: 6, bottom: 6 })
            .onClick(() => this.onEditItem(item))
          Text('删除')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().danger)
            .padding({ left: 8, right: 8, top: 6, bottom: 6 })
            .onClick(() => this.confirmDelete(item))
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
      }, (item: ChecklistItem) => `${item.id}-${item.completed ? '1' : '0'}`)
      if (this.categoryItems(name).length === 0) {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.categoryPresets(name), (item: ChecklistPreset) => {
            Text(item.title)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .padding({ left: 10, right: 10, top: 7, bottom: 7 })
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
          }, (item: ChecklistPreset) => item.id)
        }
      }
    }
    .width('100%')
  }
}
