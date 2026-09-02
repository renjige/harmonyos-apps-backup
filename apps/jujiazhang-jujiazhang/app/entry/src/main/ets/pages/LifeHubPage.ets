import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ChoiceChip } from '../components/family/ChoiceChip'
import { MemoRow } from '../components/jujia/MemoRow'
import { MemoFormOverlay } from '../components/jujia/MemoFormOverlay'
import { ChecklistFormOverlay } from '../components/jujia/ChecklistFormOverlay'
import { ChecklistDetailPane } from '../components/jujia/ChecklistDetailPane'
import { DiaryFormOverlay } from '../components/jujia/DiaryFormOverlay'
import { MemoDetailPane } from '../components/detail/MemoDetailPane'
import { FamilyMemo, ChecklistPack, DiaryEntry, KnowledgeArticle } from '../models/JujiaModels'
import { MemoService } from '../services/MemoService'
import { ChecklistService } from '../services/ChecklistService'
import { DiaryService } from '../services/DiaryService'
import { KnowledgeService } from '../services/KnowledgeService'
import { TasksPage } from './TasksPage'
import { FamilyTaskItem } from '../models/FamilyTaskModels'

@Component
export struct LifeHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('lifeHubSegment') @Watch('onLifeSegment') lifeHubSegment: string = 'memo'
  @State segment: string = 'memo'
  @State memos: FamilyMemo[] = []
  @State checklists: ChecklistPack[] = []
  @State diaries: DiaryEntry[] = []
  @State articles: KnowledgeArticle[] = []
  @State showMemoForm: boolean = false
  @State memoEdit: boolean = false
  @State memoSeed: FamilyMemo = new FamilyMemo()
  @State showMemoDetail: boolean = false
  @State memoDetail: FamilyMemo = new FamilyMemo()
  @State showChecklistForm: boolean = false
  @State showChecklistDetail: boolean = false
  @State checklistDetail: ChecklistPack = new ChecklistPack()
  @State showDiaryForm: boolean = false
  @State diaryEdit: boolean = false
  @State diarySeed: DiaryEntry = new DiaryEntry()
  @State showKnowledge: boolean = false
  @State knowledgeItem: KnowledgeArticle = new KnowledgeArticle()
  @State listEpoch: number = 0
  @Prop @Watch('onTick') refreshToken: number = 0
  @Prop taskRefreshToken: number = 0
  onOpenTask: (item: FamilyTaskItem) => void = (_i: FamilyTaskItem) => {}
  onToggleTask: (item: FamilyTaskItem) => void = (_i: FamilyTaskItem) => {}
  onAddTask: () => void = () => {}
  onToast: (msg: string) => void = (_m: string) => {}
  onDataChanged: () => void = () => {}

  aboutToAppear(): void {
    this.syncSegment()
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  onLifeSegment(): void {
    this.syncSegment()
  }

  private syncSegment(): void {
    if (this.lifeHubSegment.length > 0) {
      this.segment = this.lifeHubSegment
    }
  }

  private pickSegment(next: string): void {
    this.segment = next
    AppStorage.setOrCreate('lifeHubSegment', next)
  }

  private hideBar(hidden: boolean): void {
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }

  async reload(): Promise<void> {
    this.memos = await MemoService.list()
    this.checklists = await ChecklistService.list()
    this.diaries = await DiaryService.list()
    this.articles = KnowledgeService.articles()
    this.listEpoch += 1
  }

  private async refreshMemoDetail(id: string): Promise<void> {
    const fresh = await MemoService.find(id)
    if (fresh !== null) {
      this.memoDetail = fresh
    }
  }

  private fabLabel(): string {
    if (this.segment === 'checklist') {
      return '新建清单'
    }
    if (this.segment === 'diary') {
      return '写日记'
    }
    return '新建备忘'
  }

  private openFab(): void {
    if (this.segment === 'checklist') {
      this.showChecklistForm = true
      this.hideBar(true)
      return
    }
    if (this.segment === 'diary') {
      this.diaryEdit = false
      this.diarySeed = new DiaryEntry()
      this.showDiaryForm = true
      this.hideBar(true)
      return
    }
    this.memoEdit = false
    this.memoSeed = new FamilyMemo()
    this.showMemoForm = true
    this.hideBar(true)
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Text('家庭生活')
          .fontSize(Theme.type.titleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5 })
        Text('备忘 · 清单 · 计划 · 日记 · 实用技巧，一站式管理。')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
        Scroll() {
          Row({ space: 8 }) {
            ChoiceChip({ label: '备忘', active: this.segment === 'memo', onPick: () => { this.pickSegment('memo') } })
            ChoiceChip({ label: '清单', active: this.segment === 'checklist', onPick: () => { this.pickSegment('checklist') } })
            ChoiceChip({ label: '计划', active: this.segment === 'plan', onPick: () => { this.pickSegment('plan') } })
            ChoiceChip({ label: '日记', active: this.segment === 'diary', onPick: () => { this.pickSegment('diary') } })
            ChoiceChip({ label: '技巧', active: this.segment === 'tips', onPick: () => { this.pickSegment('tips') } })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        if (this.segment === 'plan') {
          TasksPage({
            compact: true,
            refreshToken: this.taskRefreshToken,
            onOpen: (it: FamilyTaskItem) => this.onOpenTask(it),
            onToggle: (it: FamilyTaskItem) => this.onToggleTask(it),
            onAdd: () => this.onAddTask()
          })
            .layoutWeight(1)
        } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (this.segment === 'memo') {
              if (this.memos.length === 0) {
                AppEmpty({ title: '还没有备忘', description: '写下购物清单、旅行计划或维修待办。', actionLabel: '写第一条', onAction: () => this.openFab() })
              } else {
                ForEach(this.memos, (row: FamilyMemo) => {
                  MemoRow({ item: row, onTap: () => { this.memoDetail = row; this.showMemoDetail = true; this.hideBar(true) } })
                }, (row: FamilyMemo) => `${row.id}_${this.listEpoch}_${row.updatedAt}`)
              }
            }
            if (this.segment === 'checklist') {
              if (this.checklists.length === 0) {
                AppEmpty({ title: '还没有居家清单', description: '搬家、清洁、装修或日用品采购，一键生成清单。', actionLabel: '创建清单', onAction: () => this.openFab() })
              } else {
                ForEach(this.checklists, (pack: ChecklistPack) => {
                  Row() {
                    Column({ space: 4 }) {
                      Text(pack.title).fontSize(Theme.type.body).fontColor(Theme.colors().textPrimary).width('100%')
                      Text(`${pack.kind} · ${pack.progressLabel()}`).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width('100%')
                    }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                    AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textSecondary })
                  }
                  .width('100%').padding(14).backgroundColor(Theme.colors().surfaceCard).borderRadius(Theme.radius.lg)
                  .onClick(() => { void ChecklistService.find(pack.id).then((p) => { if (p !== null) { this.checklistDetail = p; this.showChecklistDetail = true; this.hideBar(true) } }) })
                }, (pack: ChecklistPack) => `${pack.id}_${this.listEpoch}_${pack.progressLabel()}`)
              }
            }
            if (this.segment === 'diary') {
              if (this.diaries.length === 0) {
                AppEmpty({ title: '还没有日记', description: '记录家庭生活片段，保存温馨回忆。', actionLabel: '写第一篇', onAction: () => this.openFab() })
              } else {
                ForEach(this.diaries, (row: DiaryEntry) => {
                  Column({ space: 4 }) {
                    Text(row.title).fontSize(Theme.type.body).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary).width('100%')
                    Text(`${row.mood} · ${row.body.length > 40 ? `${row.body.substring(0, 40)}…` : row.body}`)
                      .fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width('100%')
                  }
                  .width('100%').padding(14).backgroundColor(Theme.colors().surfaceCard).borderRadius(Theme.radius.lg)
                  .onClick(() => { this.diaryEdit = true; this.diarySeed = DiaryService.clone(row); this.showDiaryForm = true; this.hideBar(true) })
                }, (row: DiaryEntry) => `${row.id}_${this.listEpoch}_${row.updatedAt}`)
              }
            }
            if (this.segment === 'tips') {
              ForEach(this.articles, (art: KnowledgeArticle) => {
                Column({ space: 4 }) {
                  Text(art.category).fontSize(Theme.type.caption).fontColor(Theme.colors().brandPrimary).width('100%')
                  Text(art.title).fontSize(Theme.type.body).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary).width('100%')
                  Text(art.summary).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width('100%')
                }
                .width('100%').padding(14).backgroundColor(Theme.colors().surfaceCard).borderRadius(Theme.radius.lg)
                .onClick(() => { this.knowledgeItem = art; this.showKnowledge = true; this.hideBar(true) })
              }, (art: KnowledgeArticle) => art.id)
            }
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 96 })
        }
        .layoutWeight(1).scrollBar(BarState.Off)
        }
      }
      .width('100%').height('100%').backgroundColor(Theme.colors().surfacePage)

      if (this.segment !== 'tips' && this.segment !== 'plan') {
        Column() {
          Row({ space: 6 }) {
            AppIcon({ name: 'add', iconSize: 18, color: Theme.colors().brandOnPrimary })
            Text(this.fabLabel()).fontSize(Theme.type.body).fontWeight(FontWeight.Medium).fontColor(Theme.colors().brandOnPrimary)
          }
        }
        .height(48).padding({ left: 18, right: 20 }).backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.button).margin({ right: 20, bottom: 12 }).justifyContent(FlexAlign.Center)
        .onClick(() => this.openFab())
      }

      if (this.showMemoForm) {
        MemoFormOverlay({
          isEdit: this.memoEdit, seed: this.memoSeed,
          onClose: () => { this.showMemoForm = false; this.hideBar(this.showMemoDetail) },
          onSave: (d: FamilyMemo) => { void this.saveMemo(d) }
        })
          .width('100%')
          .height('100%')
          .zIndex(40)
      }
      if (this.showMemoDetail) {
        MemoDetailPane({
          item: this.memoDetail,
          onClose: () => { this.showMemoDetail = false; this.hideBar(false) },
          onEdit: () => {
            this.memoEdit = true
            this.memoSeed = MemoService.clone(this.memoDetail)
            this.showMemoForm = true
            this.hideBar(true)
          },
          onDelete: () => { void MemoService.remove(this.memoDetail.id).then(async () => { this.showMemoDetail = false; this.hideBar(false); await this.reload(); this.onDataChanged(); this.onToast('已删除') }) }
        })
          .width('100%')
          .height('100%')
          .zIndex(this.showMemoForm ? 20 : 30)
      }
      if (this.showChecklistForm) {
        ChecklistFormOverlay({
          onClose: () => { this.showChecklistForm = false; this.hideBar(false) },
          onSave: (title: string, kind: string) => { void this.createChecklist(title, kind) }
        })
      }
      if (this.showChecklistDetail) {
        ChecklistDetailPane({
          pack: this.checklistDetail,
          onClose: () => { this.showChecklistDetail = false; this.hideBar(false); void this.reload() },
          onToggleLine: (id: string) => { void ChecklistService.toggleLine(this.checklistDetail.id, id).then(() => { void ChecklistService.find(this.checklistDetail.id).then((p) => { if (p !== null) { this.checklistDetail = p } }); void this.reload(); this.onDataChanged() }) },
          onDelete: () => { void ChecklistService.remove(this.checklistDetail.id).then(async () => { this.showChecklistDetail = false; this.hideBar(false); await this.reload(); this.onDataChanged(); this.onToast('已删除') }) }
        })
      }
      if (this.showDiaryForm) {
        DiaryFormOverlay({
          isEdit: this.diaryEdit, seed: this.diarySeed,
          onClose: () => { this.showDiaryForm = false; this.hideBar(false) },
          onSave: (d: DiaryEntry) => { void this.saveDiary(d) }
        })
      }
      if (this.showKnowledge) {
        Column() {
          Row({ space: 6 }) {
            AppIcon({ name: 'close', iconSize: 18, color: Theme.colors().textPrimary })
            Text('关闭').fontSize(Theme.type.body).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary)
          }
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().surfaceCard).borderRadius(Theme.radius.button)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .margin({ left: 16, top: 16, bottom: 8 })
          .onClick(() => { this.showKnowledge = false; this.hideBar(false) })
          Scroll() {
            Column({ space: 10 }) {
              Text(this.knowledgeItem.title).fontSize(Theme.type.titleM).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textPrimary).width('100%')
              Text(this.knowledgeItem.summary).fontSize(Theme.type.body).fontColor(Theme.colors().textPrimary).width('100%')
              Text(this.knowledgeItem.body).fontSize(Theme.type.bodyS).fontColor(Theme.colors().textSecondary).width('100%')
            }.padding(16)
          }.layoutWeight(1)
        }.width('100%').height('100%').backgroundColor(Theme.colors().surfacePage)
      }
    }.width('100%').height('100%')
  }

  private async saveMemo(draft: FamilyMemo): Promise<void> {
    const savedId = draft.id
    if (this.memoEdit && draft.id.length > 0) {
      const row = MemoService.clone(this.memoDetail)
      row.title = draft.title; row.body = draft.body; row.tag = draft.tag; row.pinned = draft.pinned
      await MemoService.update(row)
      await this.refreshMemoDetail(row.id)
    } else {
      const created = await MemoService.create(draft)
      if (this.showMemoDetail) {
        await this.refreshMemoDetail(created.id)
      }
    }
    this.showMemoForm = false
    this.hideBar(this.showMemoDetail)
    await this.reload()
    if (savedId.length > 0 && this.showMemoDetail) {
      await this.refreshMemoDetail(savedId)
    }
    this.onDataChanged()
    this.onToast('已保存')
  }

  private async createChecklist(title: string, kind: string): Promise<void> {
    await ChecklistService.create(title, kind)
    this.showChecklistForm = false
    this.hideBar(false)
    await this.reload()
    this.onDataChanged()
    this.onToast('清单已创建')
  }

  private async saveDiary(draft: DiaryEntry): Promise<void> {
    if (this.diaryEdit && draft.id.length > 0) {
      const row = DiaryService.clone(draft)
      await DiaryService.update(row)
    } else {
      await DiaryService.create(draft)
    }
    this.showDiaryForm = false
    this.hideBar(false)
    await this.reload()
    this.onDataChanged()
    this.onToast('日记已保存')
  }
}
