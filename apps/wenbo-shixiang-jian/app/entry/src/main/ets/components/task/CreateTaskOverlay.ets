import { Theme } from '../design-system/Theme'
import { AppTextInput } from '../design-system/AppTextInput'
import { AppTextArea } from '../design-system/AppTextArea'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { AppIcon } from '../design-system/AppIcon'
import {
  CategoryItem,
  CreateTaskRequest,
  TagPresetItem,
  TaskItem,
  UpdateTaskRequest
} from '../../models/TaskModels'
import { TaskBizService } from '../../services/TaskBizService'
import { AuthService } from '../../services/AuthService'
import { CommitmentRules } from '../../services/CommitmentRules'

@Component
export struct CreateTaskOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editItem: TaskItem | undefined = undefined
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onSaved: () => void = () => {}
  @State title: string = ''
  @State description: string = ''
  @State dueDate: string = ''
  @State priority: string = 'medium'
  @State selectedTags: string[] = []
  @State categories: CategoryItem[] = []
  @State tagPresets: TagPresetItem[] = []
  @State categoryId: string = ''
  @State timeSlot: string = 'morning'
  @State wantCommitment: boolean = true
  @State todayTasks: TaskItem[] = []
  @State saving: boolean = false
  @State errorText: string = ''
  @State toastText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.initForm()
  }

  private async initForm(): Promise<void> {
    this.categories = await TaskBizService.loadCategories()
    this.tagPresets = await TaskBizService.loadTagPresets()
    this.todayTasks = await TaskBizService.loadTasks(this.currentUsername, '', '', TaskBizService.todayLocal())
    if (this.editItem !== undefined) {
      this.title = this.editItem.title
      this.description = this.editItem.description.length > 0 ?
        this.editItem.description : this.editItem.body
      this.dueDate = this.editItem.dueDate
      this.priority = this.editItem.priority
      this.selectedTags = [...this.editItem.tags]
      this.categoryId = this.editItem.categoryId.length > 0 ?
        this.editItem.categoryId : this.editItem.category
      this.timeSlot = this.editItem.timeSlot.length > 0 ? this.editItem.timeSlot : CommitmentRules.defaultSlot()
      this.wantCommitment = this.editItem.isCommitment()
    } else {
      this.dueDate = TaskBizService.todayLocal()
      this.timeSlot = CommitmentRules.defaultSlot()
      this.wantCommitment = true
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private toggleTag(tag: string): void {
    const idx = this.selectedTags.indexOf(tag)
    if (idx >= 0) {
      const next: string[] = []
      for (const t of this.selectedTags) {
        if (t !== tag) {
          next.push(t)
        }
      }
      this.selectedTags = next
    } else {
      this.selectedTags = [...this.selectedTags, tag]
    }
  }

  private laneHint(): string {
    if (!this.wantCommitment) {
      return '将写入候补池，不占用今日 3 个承诺席位。'
    }
    const today = this.dueDate.length > 0 ? this.dueDate : TaskBizService.todayLocal()
    if (CommitmentRules.slotTaken(this.todayTasks, today, this.timeSlot,
      this.editItem !== undefined ? this.editItem.id : '')) {
      return '该时段已有承诺，保存后会进入候补池。'
    }
    if (CommitmentRules.commitmentsOf(this.todayTasks, today).length >= 3) {
      return '今日承诺已满 3 件，保存后会进入候补池。'
    }
    return '将锁定为今日承诺，完成后须先走专注计时。'
  }

  private categoryTitle(): string {
    for (const c of this.categories) {
      if (c.id === this.categoryId || c.title === this.categoryId) {
        return c.title
      }
    }
    return ''
  }

  private async handleSave(): Promise<void> {
    const action = this.editItem !== undefined ? 'edit_task' : 'create_task'
    if (!AuthService.requireAuth(action)) {
      this.onRequireAuth()
      return
    }
    if (this.title.trim().length === 0) {
      this.errorText = '请填写事项标题'
      return
    }
    this.errorText = ''
    this.saving = true
    try {
      const username = this.currentUsername
      if (this.editItem !== undefined) {
        const req = new UpdateTaskRequest()
        req.title = this.title.trim()
        req.description = this.description.trim()
        req.dueDate = this.dueDate
        req.priority = this.priority
        req.tags = this.selectedTags
        req.category = this.categoryTitle()
        req.categoryId = this.categoryId
        req.userId = username
        req.timeSlot = this.timeSlot
        req.lane = this.wantCommitment ? 'commitment' : 'waitlist'
        req.closeReason = this.editItem.closeReason
        const updated = await TaskBizService.updateTask(this.editItem.id, req)
        if (updated !== undefined) {
          this.showToast('事项已更新')
          this.onSaved()
          this.onClose()
        } else {
          this.errorText = TaskBizService.lastError.length > 0 ?
            TaskBizService.lastError : '保存失败，请稍后重试'
        }
        return
      }
      const req = new CreateTaskRequest()
      req.title = this.title.trim()
      req.description = this.description.trim()
      req.dueDate = this.dueDate
      req.priority = this.priority
      req.tags = this.selectedTags
      req.category = this.categoryTitle()
      req.categoryId = this.categoryId
      req.userId = username
      req.timeSlot = this.timeSlot
      req.wantCommitment = this.wantCommitment
      req.lane = this.wantCommitment ? 'commitment' : 'waitlist'
      const created = await TaskBizService.createTask(req)
      if (created !== undefined) {
        const msg = created.isCommitment() ? '已锁定为今日承诺' : '已写入候补池（承诺席位已满或未勾选）'
        this.showToast(msg)
        this.onSaved()
        this.onClose()
      } else {
        this.errorText = TaskBizService.lastError.length > 0 ?
          TaskBizService.lastError : '创建失败，请登录后重试'
      }
    } catch {
      this.errorText = TaskBizService.lastError.length > 0 ?
        TaskBizService.lastError : '保存失败，请稍后重试'
    } finally {
      this.saving = false
    }
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => this.onClose())
          Text(this.editItem !== undefined ? '编辑事项' : '新建事项')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Column({ space: 6 }) {
              Text('事项标题')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              AppTextInput({
                text: this.title,
                placeholder: '输入事项标题…',
                onChange: (v: string) => { this.title = v }
              })
            }
            .width('100%')

            Column({ space: 6 }) {
              Text('详细说明')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              AppTextArea({
                text: this.description,
                placeholder: '补充事项详情、步骤或备注…',
                onChange: (v: string) => { this.description = v }
              })
            }
            .width('100%')

            AppDatePickerField({
              label: '截止日期',
              value: this.dueDate,
              placeholder: '请选择日期',
              minDaysFromToday: -365,
              maxDaysFromToday: 365,
              onChange: (v: string) => { this.dueDate = v }
            })

            Column({ space: 8 }) {
              Text('时段工位（必选）')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              Row({ space: 8 }) {
                ForEach(CommitmentRules.slotKeys(), (slot: string) => {
                  Text(CommitmentRules.slotTitle(slot).replace('工位', ''))
                    .fontSize(Theme.type.caption)
                    .fontColor(this.timeSlot === slot ?
                      Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor(this.timeSlot === slot ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.timeSlot = slot })
                }, (slot: string) => slot)
              }
              .width('100%')
              Text(this.wantCommitment ? '锁定为今日承诺' : '仅放入候补池')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .onClick((): void => { this.wantCommitment = !this.wantCommitment })
              Text(this.laneHint())
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
            }
            .width('100%')

            Column({ space: 8 }) {
              Text('优先级')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              Row({ space: 8 }) {
                ForEach(['low', 'medium', 'high'], (p: string) => {
                  Text(p === 'low' ? '低' : (p === 'high' ? '高' : '中'))
                    .fontSize(Theme.type.caption)
                    .fontColor(this.priority === p ?
                      Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                    .backgroundColor(this.priority === p ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.priority = p })
                }, (p: string) => p)
              }
              .width('100%')
            }
            .width('100%')

            Column({ space: 8 }) {
              Text('分类')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                if (this.categories.length > 0) {
                  ForEach(this.categories, (c: CategoryItem) => {
                      Text(c.title)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.categoryId === c.id ?
                          Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .backgroundColor(this.categoryId === c.id ?
                          Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                        .borderRadius(Theme.radius.pill)
                        .margin({ right: 8, bottom: 8 })
                        .onClick((): void => { this.categoryId = c.id })
                    }, (c: CategoryItem) => c.id)
                  } else {
                    Text('分类加载中…')
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textTertiary)
                  }
                }
                .width('100%')
              }
              .width('100%')

            Column({ space: 8 }) {
              Text('标签（多选）')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                if (this.tagPresets.length > 0) {
                  ForEach(this.tagPresets, (tag: TagPresetItem) => {
                    Text(tag.title)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.selectedTags.indexOf(tag.title) >= 0 ?
                        Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                      .backgroundColor(this.selectedTags.indexOf(tag.title) >= 0 ?
                        Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                      .borderRadius(Theme.radius.pill)
                      .margin({ right: 8, bottom: 8 })
                      .onClick((): void => { this.toggleTag(tag.title) })
                  }, (tag: TagPresetItem) => tag.id)
                } else {
                  Text('标签加载中…')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
              }
              .width('100%')
            }
            .width('100%')

            AppButton({
              label: this.saving ? '保存中…' : '保存事项',
              disabled: this.saving,
              onTap: (): void => { void this.handleSave() }
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

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
