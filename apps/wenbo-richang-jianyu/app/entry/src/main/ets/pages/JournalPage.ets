import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { JournalListCard } from '../components/journal/JournalListCard'
import { DiaryEditorSheet } from '../components/journal/DiaryEditorSheet'
import { JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalCatalog, JournalChoice } from '../services/JournalCatalog'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct JournalPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  onRequireAuth: () => void = () => {}
  onDiaryCreated: () => void = () => {}
  @StorageLink('diaryDataVersion') @Watch('onDiaryDataVersionChange') diaryDataVersion: number = 0
  @State diaries: JournalItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State sceneFilter: string = ''
  @State searchQuery: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  private scenes: JournalChoice[] = JournalCatalog.scenes()

  aboutToAppear(): void {
    void this.reload()
  }

  onCreateTriggerChange(): void {
    if (this.createTrigger > 0) {
      this.openCreateForm()
    }
  }

  onDiaryDataVersionChange(): void {
    void this.syncFromLocal()
  }

  private async syncFromLocal(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.diaries = []
      return
    }
    this.diaries = await JournalBizService.cachedDiaries(this.currentUsername)
  }

  private async reload(): Promise<void> {
    try {
      if (this.diaries.length === 0) {
        this.loading = true
      }
      if (AuthService.isLoggedIn()) {
        const cached = await JournalBizService.cachedDiaries(this.currentUsername)
        if (cached.length > 0) {
          this.diaries = cached
          this.loading = false
        }
        this.diaries = await JournalBizService.loadDiaries(this.currentUsername)
      } else {
        this.diaries = []
      }
    } catch {
      this.diaries = this.diaries
    }
    this.loading = false
  }

  private visibleItems(): JournalItem[] {
    const q = this.searchQuery.trim()
    const out: JournalItem[] = []
    for (const item of this.diaries) {
      if (this.sceneFilter.length > 0 && item.category !== this.sceneFilter) {
        continue
      }
      if (q.length > 0) {
        const hit = item.title.indexOf(q) >= 0 || item.summary.indexOf(q) >= 0 || item.body.indexOf(q) >= 0
        if (!hit) {
          continue
        }
      }
      out.push(item)
    }
    return out
  }

  private openCreateForm(): void {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private onSaved(item: JournalItem): void {
    const next: JournalItem[] = []
    next.push(item)
    for (const row of this.diaries) {
      if (row.id !== item.id) {
        next.push(row)
      }
    }
    this.diaries = next
    this.closeForm()
    this.onDiaryCreated()
    JournalDetailNav.notifyDiaryChanged()
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        AppHeader({ title: '时光轴', subtitle: '按场景整理 · 写下每一页生活' })
        if (this.loading) {
          AppLoading({ label: '加载笺语…' }).layoutWeight(1)
        } else if (this.diaries.length === 0) {
          Column() {
            AppEmpty({
              title: '笺页尚空',
              description: AuthService.isLoggedIn()
                ? '选一个心情和场景，写下一页生活笺语'
                : '登录后可创建并同步你的笺语',
              actionLabel: '写一页',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              TextInput({ text: this.searchQuery, placeholder: '搜索标题或正文…' })
                .width('100%')
                .height(40)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onChange((v: string) => { this.searchQuery = v })
              Flex({ wrap: FlexWrap.Wrap }) {
                Text('全部')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.sceneFilter.length === 0 ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.sceneFilter.length === 0 ?
                    Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.sceneFilter = '' })
                ForEach(this.scenes, (s: JournalChoice) => {
                  Text(s.label)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.sceneFilter === s.id ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.sceneFilter === s.id ?
                      Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                    .onClick((): void => { this.sceneFilter = s.id })
                }, (s: JournalChoice) => s.id)
              }
              .width('100%')

              ForEach(this.visibleItems(), (item: JournalItem) => {
                JournalListCard({
                  item: item,
                  onTap: (): void => { JournalDetailNav.openDiary(item.id) }
                })
              }, (item: JournalItem) => item.id)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10 + 72
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (!this.showForm) {
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .shadow({ radius: 12, color: 'rgba(92,107,115,0.2)', offsetY: 4 })
        .margin({ right: Theme.space.pageX, bottom: Theme.space.s8 })
        .onClick((): void => { this.openCreateForm() })
      }

      if (this.showForm) {
        DiaryEditorSheet({
          editId: '',
          onClose: (): void => { this.closeForm() },
          onSaved: (item: JournalItem): void => { this.onSaved(item) },
          onRequireAuth: (): void => this.onRequireAuth()
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
