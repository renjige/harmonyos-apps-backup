import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { SolidButton } from '../design-system/SolidButton'
import { DetailShell } from './DetailShell'
import { FunQuest, FunQuestDraft, FunQuestProgress } from '../../models/TrainingModels'
import { FunQuestStore } from '../../services/FunQuestStore'
import { FunQuestService } from '../../services/FunQuestService'
import { TrainingDetailNav } from '../../services/TrainingDetailNav'
import { FunQuestFormOverlay } from '../training/FunQuestFormOverlay'
import { DataRefresh } from '../../services/DataRefresh'
import { VitalityService } from '../../services/VitalityService'

@Component
export struct FunQuestDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onQuestIdChange') questId: string = ''
  @State quest: FunQuest = new FunQuest()
  @State progress: FunQuestProgress = new FunQuestProgress()
  @State confirmDelete: boolean = false
  @State showEdit: boolean = false
  @State draft: FunQuestDraft = FunQuestService.emptyDraft()
  @State formError: string = ''
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.load()
  }

  onQuestIdChange(): void {
    this.showEdit = false
    this.confirmDelete = false
    this.load()
  }

  private load(): void {
    const found = FunQuestStore.findById(this.questId)
    if (found !== null) {
      this.quest = found
      this.progress = FunQuestService.progress(found)
    }
  }

  private async markDone(): Promise<void> {
    this.quest.status = 'done'
    await FunQuestStore.saveItem(this.quest)
    await VitalityService.award(20)
    DataRefresh.bump()
    this.onChanged()
    this.load()
  }

  private async deleteQuest(): Promise<void> {
    await FunQuestStore.deleteItem(this.questId)
    DataRefresh.bump()
    this.onChanged()
    TrainingDetailNav.closeQuest()
  }

  private openEdit(): void {
    this.draft = FunQuestService.toDraft(this.quest)
    this.formError = ''
    this.showEdit = true
  }

  private async submitEdit(): Promise<void> {
    const res = FunQuestService.update(this.quest.id, this.draft, this.quest.createdAt, this.quest.weekStart, this.quest.status)
    if (!res.ok) {
      this.formError = res.message
      return
    }
    await FunQuestStore.saveItem(res.quest)
    this.showEdit = false
    this.quest = res.quest
    DataRefresh.bump()
    this.onChanged()
    this.load()
  }

  build() {
    if (this.showEdit) {
      FunQuestFormOverlay({
        draft: this.draft,
        formError: this.formError,
        formTitle: '编辑挑战',
        onClose: (): void => { this.showEdit = false },
        onSubmit: (): void => { void this.submitEdit() },
        onDraftChange: (d: FunQuestDraft): void => { this.draft = d }
      })
    } else {
      DetailShell({
        title: '拾趣挑战',
        onClose: (): void => { TrainingDetailNav.closeQuest() },
        body: (): void => { this.BodyContent() },
        footer: (): void => { this.FooterActions() }
      })
    }
  }

  @Builder
  BodyContent() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.fun_quest_bg'))
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
        Text(`${this.quest.theme} · 自 ${this.quest.weekStart}`)
          .fontSize(Theme.type.caption)
          .fontColor('rgba(255,255,255,0.92)')
        Text(this.quest.title)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.heroOnPhoto())
        Text(`${this.progress.current} / ${this.progress.target} ${this.progress.unit} · ${this.progress.percent}%`)
          .fontSize(Theme.type.subhead)
          .fontColor('rgba(255,255,255,0.95)')
      }
      .padding(Theme.space.s5)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }

    AppCard({ title: '挑战说明' }) {
      Text(this.quest.note.length > 0 ? this.quest.note : '把训练变成可完成的小游戏：次数、分钟或尝试新类型都会自动计入本周进度。')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(22)
    }

    Column({ space: Theme.space.s2 }) {
      Text('规则')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
      Text(`计入类型：${this.quest.sportType}`)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
      Text(`目标：${FunQuestService.kindLabel(this.quest.targetKind)} ${this.quest.targetValue}`)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
      Text(`状态：${this.quest.status === 'done' ? '已完成' : '进行中'}`)
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
      Text('确定删除这条挑战？训练记录不会被删除。')
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
            onTap: (): void => { void this.deleteQuest() }
          })
        }
        .layoutWeight(1)
        .onClick((): void => { void this.deleteQuest() })
      }
      .width('100%')
    } else {
      if (this.quest.status !== 'done' && this.progress.done) {
        Column() {
          SolidButton({
            label: '领取完成',
            tone: 'primary',
            onTap: (): void => { void this.markDone() }
          })
        }
        .width('100%')
        .onClick((): void => { void this.markDone() })
      }
      Column() {
        SolidButton({
          label: '编辑挑战',
          tone: 'secondary',
          onTap: (): void => { this.openEdit() }
        })
      }
      .width('100%')
      .onClick((): void => { this.openEdit() })
      Column() {
        SolidButton({
          label: '删除挑战',
          tone: 'secondary',
          onTap: (): void => { this.confirmDelete = true }
        })
      }
      .width('100%')
      .onClick((): void => { this.confirmDelete = true })
    }
  }
}
