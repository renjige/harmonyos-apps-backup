import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { EntryListCard } from '../components/wrong/EntryListCard'
import { AnalyzeEngine, CatalogOptions } from '../services/AnalyzeEngine'
import { WrongBizService } from '../services/WrongBizService'
import { WrongDetailNav } from '../services/WrongDetailNav'
import { AuthService } from '../services/AuthService'
import { SubjectOption, WrongEntry } from '../models/WrongModels'

@Component
export struct NotebookPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State entries: WrongEntry[] = []
  @State query: string = ''
  @State subjectFilter: string = 'all'
  @State statusFilter: string = 'all'
  @State batchMode: boolean = false
  @State selectedIds: string[] = []
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.entries = await WrongBizService.loadEntries()
  }

  private visibleEntries(): WrongEntry[] {
    const out: WrongEntry[] = []
    const q = this.query.trim()
    for (const e of this.entries) {
      if (this.subjectFilter !== 'all' && e.subjectCode !== this.subjectFilter) {
        continue
      }
      if (this.statusFilter === 'pending' && e.status === 'mastered') {
        continue
      }
      if (this.statusFilter === 'mastered' && e.status !== 'mastered') {
        continue
      }
      if (q.length > 0 && e.stem.indexOf(q) < 0 && e.knowledgeTag.indexOf(q) < 0) {
        continue
      }
      out.push(e)
    }
    return out
  }

  private startCapture(): void {
    if (!AuthService.requireAuth('create')) {
      this.onRequireAuth()
      return
    }
    WrongDetailNav.openCapture('manual', '')
  }

  private toggleSelect(id: string): void {
    const next: string[] = []
    let found = false
    for (const s of this.selectedIds) {
      if (s === id) {
        found = true
      } else {
        next.push(s)
      }
    }
    if (!found) {
      next.push(id)
    }
    this.selectedIds = next
  }

  private async deleteSelected(): Promise<void> {
    if (!AuthService.requireAuth('create')) {
      this.onRequireAuth()
      return
    }
    for (const id of this.selectedIds) {
      await WrongBizService.deleteEntry(id)
    }
    this.selectedIds = []
    this.batchMode = false
    await this.reload()
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Text('错题本')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.pageY
          })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.query, placeholder: '搜索题目或知识点' })
              .onChange((v: string) => { this.query = v })
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .width('100%')

            Scroll() {
              Row({ space: Theme.space.s2 }) {
                this.chip('全部', this.subjectFilter === 'all', () => { this.subjectFilter = 'all' })
                ForEach(CatalogOptions.subjects(), (s: SubjectOption) => {
                  this.chip(s.label, this.subjectFilter === s.code, () => { this.subjectFilter = s.code })
                }, (s: SubjectOption) => s.code)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            Row({ space: Theme.space.s2 }) {
              this.chip('全部状态', this.statusFilter === 'all', () => { this.statusFilter = 'all' })
              this.chip('待复习', this.statusFilter === 'pending', () => { this.statusFilter = 'pending' })
              this.chip('已掌握', this.statusFilter === 'mastered', () => { this.statusFilter = 'mastered' })
              Text(this.batchMode ? '取消批量' : '批量')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick(() => {
                  this.batchMode = !this.batchMode
                  this.selectedIds = []
                })
            }
            .width('100%')

            if (this.batchMode && this.selectedIds.length > 0) {
              Text(`删除已选 ${this.selectedIds.length} 条`)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().danger)
                .width('100%')
                .onClick(() => { void this.deleteSelected() })
            }

            if (this.visibleEntries().length === 0) {
              AppEmpty({
                title: this.entries.length === 0 ? '错题本还是空的' : '没有匹配的错题',
                description: '登录后录入的错题会保存在这里，支持按学科与掌握状态筛选。',
                actionLabel: '录入错题',
                onAction: () => this.startCapture()
              })
            } else {
              ForEach(this.visibleEntries(), (e: WrongEntry) => {
                Row() {
                  if (this.batchMode) {
                    AppIcon({
                      name: this.selectedIds.indexOf(e.id) >= 0 ? 'check' : 'empty',
                      iconSize: Theme.icon.sm,
                      color: Theme.colors().brandPrimary
                    })
                      .width(28)
                      .onClick(() => this.toggleSelect(e.id))
                  }
                  EntryListCard({
                    entry: e,
                    onOpen: () => {
                      if (this.batchMode) {
                        this.toggleSelect(e.id)
                      } else {
                        WrongDetailNav.openEntry(e.id)
                      }
                    }
                  }).layoutWeight(1)
                }
                .width('100%')
              }, (e: WrongEntry) => e.id)
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(28)
      .margin({ right: Theme.space.pageX, bottom: Theme.space.s6 })
      .shadow({ radius: 12, color: 'rgba(0,85,255,0.25)', offsetY: 4 })
      .onClick(() => this.startCapture())
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  chip(label: string, active: boolean, action: () => void) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(active ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(active ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => action())
  }
}
