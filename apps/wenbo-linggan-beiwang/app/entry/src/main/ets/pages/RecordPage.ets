import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppIcon } from '../components/design-system/AppIcon'
import { InspirationListCard } from '../components/inspiration/InspirationListCard'
import { AppCard } from '../components/design-system/AppCard'
import { CreateInspirationRequest, InspirationItem, UpdateInspirationRequest } from '../models/InspirationModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'
import { AuthService } from '../services/AuthService'
import { BoardPinService } from '../services/BoardPinService'
import { GrowthService } from '../services/GrowthService'
import {
  ConversionPipelineService,
  PipelineSnapshot,
  PipelineStageItem
} from '../services/ConversionPipelineService'

class StageFilterChip {
  key: string = ''
  label: string = ''
}

@Component
export struct RecordPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  @Prop @Watch('onListRefresh') refreshToken: number = 0
  @StorageLink('captureOpenNonce') @Watch('onCaptureNonceChange') captureOpenNonce: number = 0
  onRequireAuth: () => void = () => {}
  onInspirationCreated: () => void = () => {}
  @State inspirations: InspirationItem[] = []
  @State pipelineSnap: PipelineSnapshot = PipelineSnapshot.empty()
  @State stageFilter: string = 'all'
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formBody: string = ''
  @State formTags: string = ''
  @State formDate: string = ''
  @State formCoverKey: string = ''
  @State formError: string = ''
  @State submitting: boolean = false
  @State pinAfterSave: boolean = false
  @State editingId: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    this.formDate = RecordPage.todayIso()
    void this.reload()
    this.tryOpenFromNonce()
  }

  onCreateTriggerChange(): void {
    this.tryOpenFromNonce()
  }

  onListRefresh(): void {
    void this.reload()
  }

  onCaptureNonceChange(): void {
    this.tryOpenFromNonce()
  }

  private tryOpenFromNonce(): void {
    const handled = AppStorage.get<number>('captureHandledNonce')
    const h = handled !== undefined && handled !== null ? handled : 0
    if (this.captureOpenNonce <= h) {
      return
    }
    if (!AuthService.isLoggedIn()) {
      this.onRequireAuth()
      return
    }
    AppStorage.setOrCreate('captureHandledNonce', this.captureOpenNonce)
    this.openCreateForm()
  }

  private static todayIso(): string {
    return new Date().toISOString().slice(0, 10)
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.inspirations = await InspirationBizService.loadInspirations(this.currentUsername)
      this.pipelineSnap = await ConversionPipelineService.load(this.currentUsername)
    } else {
      this.inspirations = []
      this.pipelineSnap = PipelineSnapshot.empty()
    }
    this.loading = false
  }

  private stageChips(): StageFilterChip[] {
    const list: StageFilterChip[] = []
    const all = new StageFilterChip()
    all.key = 'all'
    all.label = `全部 ${this.pipelineSnap.totalCount()}`
    list.push(all)
    const c0 = new StageFilterChip()
    c0.key = 'capture'
    c0.label = `待钉板 ${this.pipelineSnap.capture.length}`
    list.push(c0)
    const c1 = new StageFilterChip()
    c1.key = 'board'
    c1.label = `待拆计划 ${this.pipelineSnap.board.length}`
    list.push(c1)
    const c2 = new StageFilterChip()
    c2.key = 'plan'
    c2.label = `推进中 ${this.pipelineSnap.plan.length}`
    list.push(c2)
    const c3 = new StageFilterChip()
    c3.key = 'done'
    c3.label = `已完成 ${this.pipelineSnap.done.length}`
    list.push(c3)
    return list
  }

  private filteredRows(): PipelineStageItem[] {
    return ConversionPipelineService.filterByStage(this.pipelineSnap, this.stageFilter)
  }

  private joinTags(tags: string[]): string {
    return tags.join(', ')
  }

  private async loadEdit(id: string): Promise<void> {
    const item = await InspirationBizService.findInspiration(id)
    if (item === undefined) {
      this.editingId = ''
      this.formError = '要编辑的灵感不存在'
      return
    }
    this.formTitle = item.title
    this.formBody = item.body
    this.formTags = this.joinTags(item.tags)
    this.formDate = item.recordDate.length > 0 ? item.recordDate : RecordPage.todayIso()
    this.formCoverKey = item.coverKey.length > 0 ? item.coverKey : 'hero_latest_inspiration'
    this.pinAfterSave = false
    this.formError = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openCreateForm(): void {
    if (!AuthService.requireAuth('create_inspiration')) {
      this.onRequireAuth()
      return
    }
    const editId = AppStorage.get<string>('captureEditId') ?? ''
    if (editId.length > 0) {
      AppStorage.setOrCreate('captureEditId', '')
      this.editingId = editId
      void this.loadEdit(editId)
      return
    }
    this.editingId = ''
    const draftTitle = AppStorage.get<string>('captureDraftTitle') ?? ''
    if (draftTitle.length > 0) {
      this.formTitle = draftTitle
      this.formBody = AppStorage.get<string>('captureDraftBody') ?? ''
      this.formTags = AppStorage.get<string>('captureDraftTags') ?? ''
      this.pinAfterSave = true
      AppStorage.setOrCreate('captureDraftTitle', '')
      AppStorage.setOrCreate('captureDraftBody', '')
      AppStorage.setOrCreate('captureDraftTags', '')
    } else {
      this.formTitle = ''
      this.formBody = ''
      this.formTags = ''
      this.pinAfterSave = false
    }
    this.formCoverKey = 'hero_latest_inspiration'
    this.formDate = RecordPage.todayIso()
    this.formError = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    this.editingId = ''
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private appendContinue(): void {
    const stamp = new Date().toISOString().slice(0, 16).replace('T', ' ')
    const extra = `\n\n【续写 ${stamp}】\n`
    this.formBody = `${this.formBody}${extra}`
  }

  private parseTags(raw: string): string[] {
    const parts = raw.split(',')
    const out: string[] = []
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  private async submitInspiration(): Promise<void> {
    if (!AuthService.requireAuth('create_inspiration')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写标题'
      return
    }
    this.submitting = true
    this.formError = ''
    const req = new CreateInspirationRequest()
    req.title = this.formTitle.trim()
    req.body = this.formBody.trim()
    req.summary = req.body.length > 80 ? req.body.substring(0, 80) : req.body
    req.tags = this.parseTags(this.formTags)
    req.recordDate = this.formDate.length > 0 ? this.formDate : RecordPage.todayIso()
    req.coverKey = this.formCoverKey.length > 0 ? this.formCoverKey : 'hero_latest_inspiration'
    req.userId = this.currentUsername
    if (this.editingId.length > 0) {
      const upd = new UpdateInspirationRequest()
      upd.title = req.title
      upd.body = req.body
      upd.summary = req.summary
      upd.tags = req.tags
      upd.recordDate = req.recordDate
      upd.coverKey = req.coverKey
      const saved = await InspirationBizService.updateInspiration(this.editingId, upd)
      this.submitting = false
      if (saved !== undefined) {
        this.closeForm()
        await this.reload()
        this.onInspirationCreated()
      } else {
        this.formError = InspirationBizService.lastError.length > 0
          ? InspirationBizService.lastError
          : '保存失败，请稍后重试'
      }
      return
    }
    const created = await InspirationBizService.createInspiration(req)
    if (created !== undefined && this.pinAfterSave) {
      const pinText = req.body.length > 0 ? `${req.title}\n${req.body}` : req.title
      await BoardPinService.pinToWorkbench(pinText, req.coverKey, this.currentUsername)
    }
    this.submitting = false
    if (created !== undefined) {
      this.closeForm()
      await this.reload()
      await GrowthService.afterEventAuto(
        this.currentUsername, 'capture', created.title, 'inspiration', created.id
      )
      this.onInspirationCreated()
    } else {
      this.formError = InspirationBizService.lastError.length > 0
        ? InspirationBizService.lastError
        : '保存失败，请稍后重试'
    }
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '捕捉', subtitle: '按转化阶段管理队列：钉板 → 拆计划 → 勾选推进' })
        if (AuthService.isLoggedIn() && this.pipelineSnap.totalCount() > 0) {
          Scroll() {
            Row({ space: Theme.space.s2 }) {
              ForEach(this.stageChips(), (chip: StageFilterChip) => {
                Text(chip.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.stageFilter === chip.key
                    ? Theme.colors().brandPrimary
                    : Theme.colors().textPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.stageFilter === chip.key
                    ? Theme.colors().brandPrimaryContainer
                    : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .border({
                    width: 1,
                    color: this.stageFilter === chip.key
                      ? Theme.colors().brandPrimary
                      : Theme.colors().strokeHairline
                  })
                  .onClick((): void => { this.stageFilter = chip.key })
              }, (chip: StageFilterChip) => chip.key)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }
        if (this.loading) {
          AppLoading({ label: '加载灵感…' }).layoutWeight(1)
        } else if (this.inspirations.length === 0) {
          Column() {
            AppEmpty({
              title: '还没有灵感',
              description: AuthService.isLoggedIn()
                ? '捕捉后进入转化流水线：钉板对照 → 创意计划三步 → 归档回顾'
                : '登录后可创建并同步你的转化队列',
              actionLabel: '开始捕捉',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.filteredRows().length === 0) {
          Column() {
            AppEmpty({
              title: '该阶段暂无条目',
              description: '切换其他阶段筛选，或捕捉新灵感开始转化',
              actionLabel: '开始捕捉',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              AppCard({ title: '转化队列', variant: 'plain' }) {
                Text('每条灵感按阶段推进：待钉板 → 待拆计划 → 推进中 → 已完成。点进详情可钉板或生成带三步的创意计划。')
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                  .lineHeight(20)
              }
              ForEach(this.filteredRows(), (row: PipelineStageItem) => {
                InspirationListCard({
                  item: row.inspiration,
                  stageKey: row.stage,
                  onTap: (): void => { InspirationDetailNav.openInspiration(row.inspiration.id) }
                })
              }, (row: PipelineStageItem) => `${row.stage}_${row.inspiration.id}`)
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
        .shadow({ radius: 12, color: 'rgba(27,42,65,0.2)', offsetY: 4 })
        .position({ x: '78%', y: '82%' })
        .onClick((): void => { this.openCreateForm() })
      }

      if (this.showForm) {
        this.InspirationFormOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  InspirationFormOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.closeForm() })
        Text(this.editingId.length > 0 ? '编辑灵感' : '捕捉灵感')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.formError.length > 0) {
        Text(this.formError)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 6 }) {
            Text('标题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTitle, placeholder: '给灵感起个名字…' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTitle = v })
          }
          .width('100%')

          AppDatePickerField({
            label: '记录日期',
            value: this.formDate,
            minDaysFromToday: -3650,
            maxDaysFromToday: 0,
            onChange: (v: string) => { this.formDate = v }
          })

          Column({ space: 6 }) {
            Text('正文')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextArea({ text: this.formBody, placeholder: '写下创意想法、观察与灵感…' })
              .width('100%')
              .height(160)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formBody = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('标签（逗号分隔）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTags, placeholder: '视觉, 品牌, UI' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTags = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('封面标识（media key）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formCoverKey, placeholder: 'hero_latest_inspiration' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formCoverKey = v })
          }
          .width('100%')

          Row() {
            Text('保存后钉到画板')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.pinAfterSave })
              .selectedColor(Theme.colors().brandPrimary)
              .onChange((v: boolean) => { this.pinAfterSave = v })
          }
          .width('100%')

          AppButton({
            label: '追加续写段落',
            variant: 'secondary',
            onTap: (): void => { this.appendContinue() }
          })

          AppButton({
            label: this.submitting ? '保存中…' : (this.editingId.length > 0 ? '保存修改' : '保存灵感'),
            disabled: this.submitting,
            onTap: (): void => { void this.submitInspiration() }
          })
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(25)
  }
}
