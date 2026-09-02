import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { TaskRow } from '../components/reno/TaskRow'
import { MaterialRow } from '../components/reno/MaterialRow'
import { NoteRow } from '../components/reno/NoteRow'
import { RenoDates, RenoMaterial, RenoNote, RenoProject, RenoStage, RenoTask } from '../models/RenoModels'
import { RenoCatalog } from '../services/RenoCatalog'
import { RenoMedia } from '../services/RenoMedia'
import { RenoService } from '../services/RenoService'
import { RenoLedger } from '../services/RenoLedger'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTick') refreshToken: number = 0
  @StorageLink('renoRev') @Watch('onRev') renoRev: number = 0
  @State project: RenoProject = new RenoProject()
  @State hasProject: boolean = false
  @State today: RenoTask[] = []
  @State materials: RenoMaterial[] = []
  @State notes: RenoNote[] = []
  @State stages: RenoStage[] = []
  @State spent: number = 0
  onOpenMessages: () => void = () => {}
  onOpenSettings: () => void = () => {}
  onCreateProject: () => void = () => {}
  onOpenProject: (item: RenoProject) => void = (_i: RenoProject) => {}
  onOpenStage: (stage: string) => void = (_s: string) => {}
  onOpenTask: (item: RenoTask) => void = (_i: RenoTask) => {}
  onToggleTask: (item: RenoTask) => void = (_i: RenoTask) => {}
  onOpenMaterial: (item: RenoMaterial) => void = (_i: RenoMaterial) => {}
  onOpenNote: (item: RenoNote) => void = (_i: RenoNote) => {}
  onQuick: (id: string) => void = (_id: string) => {}
  onAllTasks: () => void = () => {}
  onOpenTimeline: () => void = () => {}
  onOpenExpense: () => void = () => {}
  onExport: () => void = () => {}

  aboutToAppear(): void {
    void this.boot()
  }

  onTick(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async boot(): Promise<void> {
    await RenoService.hydrateUser()
    await this.reload()
  }

  private async reload(): Promise<void> {
    this.stages = await RenoCatalog.stages()
    const current = RenoService.currentProject()
    this.hasProject = current !== null
    if (current === null) {
      this.project = new RenoProject()
      this.today = []
      this.materials = []
      this.notes = []
      this.spent = 0
      return
    }
    this.project = current
    const tasks = await RenoService.tasks(current.id)
    this.today = RenoService.todayTasks(tasks)
    const mats = await RenoService.materials(current.id)
    this.materials = RenoService.pendingMaterials(mats)
    const notes = await RenoService.notes(current.id)
    this.notes = RenoService.recentNotes(notes, 3)
    this.spent = RenoLedger.spent(current.id)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        this.TopBar()
        Stack() {
          Image($r('app.media.home_hero'))
            .width('100%')
            .height(168)
            .borderRadius(Theme.radius.lg)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(168)
            .borderRadius(Theme.radius.lg)
            .linearGradient({
              angle: 180,
              colors: [['#66111827', 0.2], ['#E6111827', 1.0]]
            })
          Column({ space: 6 }) {
            Text('我的装修')
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
              .width('100%')
            Text(this.hasProject ? this.project.title : '还没有装修项目')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .width('100%')
            if (this.hasProject) {
              Text(`${this.project.status === 'done' ? '已完成' : '施工中'} · ${this.project.progress}%`)
                .fontSize(Theme.type.subtitleM)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .width('100%')
            }
          }
          .width('100%')
          .height(168)
          .padding(18)
          .justifyContent(FlexAlign.End)
        }
        .width('100%')
        .height(168)
        .onClick(() => {
          if (this.hasProject) {
            this.onOpenProject(this.project)
          } else {
            this.onCreateProject()
          }
        })

        if (!this.hasProject) {
          AppEmpty({
            title: '暂无装修项目',
            description: '创建一个项目，开始记录你的装修进度',
            actionLabel: '创建项目',
            onAction: () => this.onCreateProject()
          })
        } else {
          this.TodayBlock()
          this.ToolRow()
          this.StageLane()
          this.MaterialBlock()
          this.NoteBlock()
          this.QuickRow()
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s5,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  TopBar() {
    Row() {
      Column({ space: 4 }) {
        Text('筑科装修助手')
          .fontSize(Theme.type.titleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('装修有章法，施工更安心')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Row({ space: 8 }) {
        Column() {
          AppIcon({ name: 'bell', iconSize: 22, color: Theme.colors().textSecondary })
        }
        .width(44).height(44).borderRadius(22)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onOpenMessages())
        Column() {
          AppIcon({ name: 'user', iconSize: 22, color: Theme.colors().textSecondary })
        }
        .width(44).height(44).borderRadius(22)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onOpenSettings())
      }
    }
    .width('100%')
  }

  @Builder
  TodayBlock() {
    Column({ space: 10 }) {
      Row() {
        Text('今天要做什么')
          .fontSize(Theme.type.subtitleL)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('查看全部')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => this.onAllTasks())
      }
      .width('100%')
      if (this.today.length === 0) {
        Text('今天没有待办，可以记一笔现场情况。')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.today, (it: RenoTask) => {
          TaskRow({
            item: it,
            onOpen: (row: RenoTask) => this.onOpenTask(row),
            onToggle: (row: RenoTask) => this.onToggleTask(row)
          })
        }, (it: RenoTask) => `${it.id}_${it.status}_${it.title}`)
      }
    }
    .width('100%')
  }

  @Builder
  StageLane() {
    Column({ space: 10 }) {
      Text('装修进度')
        .fontSize(Theme.type.subtitleL)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.stages, (s: RenoStage) => {
            Column({ space: 6 }) {
              Image(RenoMedia.cover(s.coverKey.length > 0 ? s.coverKey : RenoDates.coverOf(s.title)))
                .width(72).height(48).borderRadius(10).objectFit(ImageFit.Cover)
              Text(s.title)
                .fontSize(Theme.type.caption)
                .fontWeight(this.project.stage === s.title ? FontWeight.Medium : FontWeight.Regular)
                .fontColor(this.project.stage === s.title ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
            }
            .padding(8)
            .backgroundColor(this.project.stage === s.title ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick(() => this.onOpenStage(s.title))
          }, (s: RenoStage) => s.id)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  MaterialBlock() {
    Column({ space: 10 }) {
      Text('近期需要确认')
        .fontSize(Theme.type.subtitleL)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (this.materials.length === 0) {
        Text('没有待确认材料。')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.materials, (it: RenoMaterial) => {
          MaterialRow({ item: it, onOpen: (row: RenoMaterial) => this.onOpenMaterial(row) })
        }, (it: RenoMaterial) => `${it.id}_${it.status}_${it.title}`)
      }
    }
    .width('100%')
  }

  @Builder
  NoteBlock() {
    Column({ space: 10 }) {
      Text('现场记录')
        .fontSize(Theme.type.subtitleL)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (this.notes.length === 0) {
        Text('把今天的施工情况记录下来吧')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.notes, (it: RenoNote) => {
          NoteRow({ item: it, onOpen: (row: RenoNote) => this.onOpenNote(row) })
        }, (it: RenoNote) => `${it.id}_${it.updatedAt}_${it.title}`)
      }
    }
    .width('100%')
  }

  @Builder
  ToolRow() {
    Column({ space: 8 }) {
      Text(`${this.project.budget.length > 0 ? `预算 ¥${this.project.budget} · ` : ''}已记费用 ¥${this.spent}`)
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row({ space: 8 }) {
        this.QuickBtn('timeline', '时间线')
        this.QuickBtn('expense', '费用')
        this.QuickBtn('export', '导出纪要')
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  QuickRow() {
    Row({ space: 8 }) {
      this.QuickBtn('note', '记一笔')
      this.QuickBtn('task', '加事项')
      this.QuickBtn('material', '记材料')
      this.QuickBtn('inspect', '做验收')
    }
    .width('100%')
  }

  @Builder
  QuickBtn(id: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .padding({ top: 12, bottom: 12 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)
      .onClick(() => {
        if (id === 'timeline') {
          this.onOpenTimeline()
          return
        }
        if (id === 'expense') {
          this.onOpenExpense()
          return
        }
        if (id === 'export') {
          this.onExport()
          return
        }
        this.onQuick(id)
      })
  }
}
