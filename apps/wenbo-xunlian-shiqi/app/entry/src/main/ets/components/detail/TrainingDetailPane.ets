import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { SolidButton } from '../design-system/SolidButton'
import { DetailShell } from './DetailShell'
import { TrainingDraft, TrainingRecord } from '../../models/TrainingModels'
import { TrainingStore } from '../../services/TrainingStore'
import { TrainingDetailNav } from '../../services/TrainingDetailNav'
import { TrainingRecordService } from '../../services/TrainingRecordService'
import { TrainingFormOverlay } from '../training/TrainingFormOverlay'
import { DataRefresh } from '../../services/DataRefresh'

@Component
export struct TrainingDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRecordIdChange') recordId: string = ''
  @State record: TrainingRecord = new TrainingRecord()
  @State confirmDelete: boolean = false
  @State showEdit: boolean = false
  @State draft: TrainingDraft = TrainingRecordService.emptyDraft()
  @State formError: string = ''
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.load()
  }

  onRecordIdChange(): void {
    this.showEdit = false
    this.confirmDelete = false
    this.load()
  }

  private load(): void {
    const found = TrainingStore.findById(this.recordId)
    if (found !== null) {
      this.record = found
    }
  }

  private openEdit(): void {
    this.draft = TrainingRecordService.toDraft(this.record)
    this.formError = ''
    this.showEdit = true
  }

  private async submitEdit(): Promise<void> {
    const res = TrainingRecordService.update(this.record.id, this.draft, this.record.createdAt)
    if (!res.ok) {
      this.formError = res.message
      return
    }
    await TrainingStore.saveItem(res.record)
    this.showEdit = false
    this.record = res.record
    DataRefresh.bump()
    this.onChanged()
  }

  private async deleteRecord(): Promise<void> {
    await TrainingStore.deleteItem(this.recordId)
    DataRefresh.bump()
    this.onChanged()
    TrainingDetailNav.close()
  }

  build() {
    if (this.showEdit) {
      TrainingFormOverlay({
        draft: this.draft,
        formError: this.formError,
        formTitle: '编辑训练',
        onClose: (): void => { this.showEdit = false },
        onSubmit: (): void => { void this.submitEdit() },
        onDraftChange: (d: TrainingDraft): void => { this.draft = d }
      })
    } else {
      DetailShell({
        title: '训练详情',
        onClose: (): void => { TrainingDetailNav.close() },
        body: (): void => { this.BodyContent() },
        footer: (): void => { this.FooterActions() }
      })
    }
  }

  @Builder
  BodyContent() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_training_bg'))
        .width('100%')
        .height(220)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column()
        .width('100%')
        .height(220)
        .borderRadius(Theme.radius.xl)
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(10,14,26,0.08)', 0.0],
            ['rgba(10,14,26,0.90)', 1.0]
          ]
        })
      Column({ space: 8 }) {
        Text(this.record.recordDate)
          .fontSize(Theme.type.caption)
          .fontColor('rgba(255,255,255,0.92)')
        Text(this.record.trainingType)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.heroOnPhoto())
        Text(`${this.record.durationMin} 分钟 · ${this.record.completeStatus}`)
          .fontSize(Theme.type.subhead)
          .fontColor('rgba(255,255,255,0.95)')
      }
      .padding(Theme.space.s5)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }

    AppCard({ title: '训练心得' }) {
      Text(this.record.note.length > 0 ? this.record.note : '未填写心得。点「编辑训练」可记下今天哪里有趣、哪种方式更适合自己。')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(22)
    }

    AppCard({ title: '训练收获' }) {
      Text(this.record.harvest.length > 0 ? this.record.harvest : '未填写收获。例如「身体状态更好」。')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(22)
    }

    Column({ space: Theme.space.s2 }) {
      Text('记录信息')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
      Text(`类型：${this.record.trainingType}`)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
      Text(`时长：${this.record.durationMin} 分钟`)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
      Text(`日期：${this.record.recordDate}`)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
      Text(`完成状态：${this.record.completeStatus}`)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
      Text(`体感：${this.record.feeling} · 强度：${this.record.intensity}`)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  FooterActions() {
    if (this.confirmDelete) {
      Text('确定删除这条训练记录？删除后不可恢复。')
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().danger)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        Column() {
          SolidButton({
            label: '取消',
            tone: 'secondary',
            onTap: (): void => { this.confirmDelete = false }
          })
        }
        .layoutWeight(1)
        .onClick((): void => { this.confirmDelete = false })
        Column() {
          SolidButton({
            label: '确认删除',
            tone: 'danger',
            onTap: (): void => { void this.deleteRecord() }
          })
        }
        .layoutWeight(1)
        .onClick((): void => { void this.deleteRecord() })
      }
      .width('100%')
    } else {
      Column() {
        SolidButton({
          label: '编辑训练',
          tone: 'primary',
          onTap: (): void => { this.openEdit() }
        })
      }
      .width('100%')
      .onClick((): void => { this.openEdit() })
      Column() {
        SolidButton({
          label: '删除记录',
          tone: 'secondary',
          onTap: (): void => { this.confirmDelete = true }
        })
      }
      .width('100%')
      .onClick((): void => { this.confirmDelete = true })
    }
  }
}
