import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { NoteListCard } from '../note/NoteListCard'
import { OverlayShell } from './OverlayShell'
import { ReadingPlan } from '../../models/StudyModels'
import { BookNote } from '../../models/BookNoteModels'
import { StudyStore } from '../../services/StudyStore'
import { NoteStore } from '../../services/NoteStore'

@Component
export struct ReadingPlanDetailPane {
  @Prop planId: string = ''
  @State plan: ReadingPlan = new ReadingPlan()
  @State notes: BookNote[] = []
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  onOpenDetail: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await StudyStore.findPlan(this.planId)
    if (found !== undefined) {
      this.plan = found
    }
    const all = await NoteStore.loadAll()
    const monthStart = new Date(new Date().getFullYear(), new Date().getMonth(), 1).getTime()
    const out: BookNote[] = []
    for (const n of all) {
      if (n.createdAt < monthStart) {
        continue
      }
      if (this.plan.bookName.length > 0 && n.bookName.trim() !== this.plan.bookName) {
        continue
      }
      out.push(n)
    }
    this.notes = out
  }

  build() {
    OverlayShell({
      title: '计划详情',
      showBack: true,
      onClose: (): void => { this.onClose() },
      onBack: (): void => { this.onClose() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s3 }) {
      Column({ space: 8 }) {
        Text(this.plan.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(`进度 ${this.plan.doneCount}/${this.plan.targetCount} · ${this.plan.progressPercent()}%`)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Row() {
          Column()
            .layoutWeight(this.plan.progressPercent() <= 0 ? 1 : this.plan.progressPercent())
            .height(8)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(4)
          Column()
            .layoutWeight(this.plan.progressPercent() >= 100 ? 1 : (100 - this.plan.progressPercent()))
            .height(8)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(4)
        }
        .width('100%')
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(12)

      AppButton({
        label: '编辑计划',
        variant: 'secondary',
        onTap: (): void => { this.onEdit() }
      })

      Text('关联书摘')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      if (this.notes.length === 0) {
        AppEmpty({ title: '暂无关联书摘', description: '本月添加的书摘会自动计入进度' })
      } else {
        ForEach(this.notes, (n: BookNote) => {
          NoteListCard({
            item: n,
            onOpen: (): void => { this.onOpenDetail(n.id) }
          })
        }, (n: BookNote) => `${n.id}_${n.updatedAt}`)
      }
    }
    .width('100%')
  }
}
