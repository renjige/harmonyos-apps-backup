import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { GoalItem } from '../../models/ThinkModels'
import { ThinkStore } from '../../services/ThinkStore'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct GoalPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onPaneReload') paneToken: number = 0
  @State items: GoalItem[] = []
  @State editing: GoalItem = new GoalItem()
  @State stepDraft: string = ''
  @State stepView: string[] = []
  @State showEdit: boolean = false
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onPaneReload(): void {
    this.showEdit = false
    this.confirmDelete = false
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await ThinkStore.loadGoals()
  }

  private openNew(): void {
    const it = new GoalItem()
    it.id = ThinkStore.newId('gl')
    it.createdAt = Date.now()
    it.updatedAt = it.createdAt
    this.editing = it
    this.stepView = []
    this.stepDraft = ''
    this.confirmDelete = false
    this.showEdit = true
  }

  private openEdit(it: GoalItem): void {
    this.editing = ThinkStore.cloneGoal(it)
    this.stepView = it.steps()
    this.stepDraft = ''
    this.confirmDelete = false
    this.showEdit = true
  }

  private addStep(): void {
    const t = this.stepDraft.trim()
    if (t.length === 0) {
      return
    }
    const next: string[] = []
    for (const s of this.stepView) {
      next.push(s)
    }
    next.push(t)
    this.stepView = next
    this.editing.stepsCsv = next.join(';;')
    this.stepDraft = ''
  }

  private async save(): Promise<void> {
    if (this.editing.title.trim().length === 0 || this.editing.target.trim().length === 0) {
      return
    }
    this.editing.stepsCsv = this.stepView.join(';;')
    await ThinkStore.saveGoal(this.editing)
    this.showEdit = false
    await this.reload()
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await ThinkStore.removeGoal(this.editing.id)
    this.showEdit = false
    await this.reload()
  }

  build() {
    Column() {
      Row() {
        Text('目标推演')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('新建')
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.openNew() })
      }
      .width('100%')
      if (this.showEdit) {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            TextInput({ text: this.editing.title, placeholder: '标题，例如：提升英语能力' })
              .height(44)
              .onChange((v: string) => { this.editing.title = v })
            TextArea({ text: this.editing.target, placeholder: '目标描述' })
              .height(88)
              .onChange((v: string) => { this.editing.target = v })
            ForEach(this.stepView, (s: string) => {
              Text(`· ${s}`)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
            }, (s: string) => s)
            TextInput({ text: this.stepDraft, placeholder: '添加一步实现路径' })
              .height(44)
              .onChange((v: string) => { this.stepDraft = v })
            AppButton({ label: '添加步骤', variant: 'secondary', onTap: (): void => { this.addStep() } })
            AppButton({ label: '保存目标', onTap: (): void => { void this.save() } })
            AppButton({ label: '返回列表', variant: 'secondary', onTap: (): void => { this.showEdit = false } })
            AppButton({
              label: this.confirmDelete ? '再点一次删除' : '删除',
              variant: 'danger',
              onTap: (): void => { void this.remove() }
            })
          }
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.On)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.items.length === 0) {
              AppEmpty({ title: '还没有目标', description: '设定目标并拆分阶段步骤' })
            } else {
              ForEach(this.items, (it: GoalItem) => {
                Column({ space: 6 }) {
                  Text(it.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(`${it.steps().length} 步 · ${DateHelper.formatShort(it.updatedAt)}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { this.openEdit(it) })
              }, (it: GoalItem) => `${it.id}|${it.updatedAt}|${it.stepsCsv}`)
            }
          }
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.On)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
  }
}
