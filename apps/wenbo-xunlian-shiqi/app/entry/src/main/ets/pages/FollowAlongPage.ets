import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { SolidButton } from '../components/design-system/SolidButton'
import { MoveItem } from '../models/TrainingModels'
import { TrainingDraft } from '../models/TrainingModels'
import { PracticeHubStore } from '../services/PracticeHubStore'
import { FollowAlongService } from '../services/FollowAlongService'
import { MoveCatalog } from '../services/MoveCatalog'
import { DataRefresh } from '../services/DataRefresh'

type FollowPhase = 'pick' | 'work' | 'rest' | 'done'

@Component
export struct FollowAlongPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State phase: FollowPhase = 'pick'
  @State moves: MoveItem[] = []
  @State allMoves: MoveItem[] = []
  @State index: number = 0
  @State secondsLeft: number = 30
  @State totalMinutes: number = 0
  @State toast: string = ''
  @State queueRev: number = 0
  onClose: () => void = () => {}
  onSaveRecord: (draft: TrainingDraft) => void = () => {}

  aboutToAppear(): void {
    this.reloadPick()
  }

  aboutToDisappear(): void {
    this.clearTimer()
  }

  private clearTimer(): void {
    if (this.timerHandle >= 0) {
      clearTimeout(this.timerHandle)
      this.timerHandle = -1
    }
  }

  private timerHandle: number = -1

  private reloadPick(): void {
    this.allMoves = PracticeHubStore.listMoves()
    this.moves = FollowAlongService.resolveQueue()
    this.phase = 'pick'
    this.index = 0
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2200)
  }

  private async ensureMoves(): Promise<void> {
    if (this.allMoves.length > 0) {
      return
    }
    await MoveCatalog.importZone('热身')
    DataRefresh.bump()
    this.allMoves = PracticeHubStore.listMoves()
    this.showToast('已为你加入热身示例动作，可继续跟练')
  }

  private async togglePick(id: string): Promise<void> {
    const ids = FollowAlongService.listQueueIds()
    let inQueue = false
    for (const q of ids) {
      if (q === id) {
        inQueue = true
        break
      }
    }
    if (inQueue) {
      await FollowAlongService.removeFromQueue(id)
    } else {
      const ok = await FollowAlongService.addToQueue(id)
      if (!ok) {
        this.showToast('跟练清单最多 5 个动作')
        return
      }
    }
    this.moves = FollowAlongService.resolveQueue()
    this.queueRev += 1
  }

  private async startSession(): Promise<void> {
    await this.ensureMoves()
    this.moves = FollowAlongService.resolveQueue()
    if (this.moves.length === 0) {
      this.showToast('请先勾选 1～5 个动作')
      return
    }
    this.phase = 'work'
    this.index = 0
    this.totalMinutes = 0
    this.beginWork()
  }

  private beginWork(): void {
    this.secondsLeft = 30
    this.clearTimer()
    this.timerHandle = setTimeout((): void => { this.tickWork() }, 1000)
  }

  private tickWork(): void {
    if (this.secondsLeft > 1) {
      this.secondsLeft -= 1
      this.timerHandle = setTimeout((): void => { this.tickWork() }, 1000)
      return
    }
    this.totalMinutes += 1
    if (this.index >= this.moves.length - 1) {
      this.phase = 'done'
      this.clearTimer()
      return
    }
    this.phase = 'rest'
    this.secondsLeft = 10
    this.clearTimer()
    this.timerHandle = setTimeout((): void => { this.tickRest() }, 1000)
  }

  private tickRest(): void {
    if (this.secondsLeft > 1) {
      this.secondsLeft -= 1
      this.timerHandle = setTimeout((): void => { this.tickRest() }, 1000)
      return
    }
    this.index += 1
    this.phase = 'work'
    this.beginWork()
  }

  private skipStep(): void {
    this.clearTimer()
    if (this.phase === 'work') {
      this.totalMinutes += 1
      if (this.index >= this.moves.length - 1) {
        this.phase = 'done'
        return
      }
      this.phase = 'rest'
      this.secondsLeft = 10
      this.timerHandle = setTimeout((): void => { this.tickRest() }, 1000)
      return
    }
    if (this.phase === 'rest') {
      this.index += 1
      this.phase = 'work'
      this.beginWork()
    }
  }

  private finishSave(): void {
    const draft = FollowAlongService.draftAfterSession(this.moves, this.totalMinutes)
    this.onSaveRecord(draft)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => {
            this.clearTimer()
            this.onClose()
          })
          Text('动作跟练')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Blank().width(44)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        if (this.phase === 'pick') {
          this.PickBody()
        } else if (this.phase === 'done') {
          this.DoneBody()
        } else {
          this.RunBody()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.pageBg(this.themeEpoch))

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(15,23,42,0.88)')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(25)
  }

  @Builder
  PickBody() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('选择 1～5 个动作，逐步计时跟练（非单纯写计划）。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        if (this.allMoves.length === 0) {
          Text('图鉴还是空的，点下方按钮可快速加入热身示例。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          SolidButton({
            label: '加入热身示例动作',
            tone: 'secondary',
            onTap: (): void => { void this.ensureMoves() }
          })
        }
        ForEach(this.allMoves, (m: MoveItem) => {
          this.PickRow(m)
        }, (m: MoveItem) => `${m.id}_${this.queueRev}`)
        SolidButton({
          label: `开始跟练（${this.moves.length} 个动作）`,
          tone: 'primary',
          onTap: (): void => { void this.startSession() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .layoutWeight(1)
  }

  private isPicked(id: string): boolean {
    const ids = FollowAlongService.listQueueIds()
    for (const q of ids) {
      if (q === id) {
        return true
      }
    }
    return false
  }

  @Builder
  PickRow(m: MoveItem) {
    Row({ space: Theme.space.s3 }) {
      AppIcon({
        name: this.isPicked(m.id) ? 'check' : 'empty',
        iconSize: Theme.icon.md,
        color: this.isPicked(m.id) ? Theme.colors().brandPrimary : Theme.colors().textSecondary
      })
      Column({ space: 2 }) {
        Text(m.title)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
        Text(m.category)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { void this.togglePick(m.id) })
  }

  @Builder
  RunBody() {
    Column({ space: Theme.space.s5 }) {
      Text(this.phase === 'work' ? '跟练中' : '组间休息')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
      if (this.phase === 'work' && this.index < this.moves.length) {
        Text(this.moves[this.index].title)
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .textAlign(TextAlign.Center)
        Text(this.moves[this.index].purpose.length > 0 ? this.moves[this.index].purpose : '保持呼吸，动作缓慢可控')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .textAlign(TextAlign.Center)
          .padding({ left: Theme.space.s4, right: Theme.space.s4 })
      } else {
        Text('准备下一个动作')
          .fontSize(Theme.type.title2)
          .fontColor(Theme.colors().textPrimary)
      }
      Text(`${this.secondsLeft}`)
        .fontSize(56)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(`${this.index + 1} / ${this.moves.length}`)
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.colors().textSecondary)
      SolidButton({
        label: '跳过本步',
        tone: 'secondary',
        onTap: (): void => { this.skipStep() }
      })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .padding(Theme.space.pageX)
  }

  @Builder
  DoneBody() {
    Column({ space: Theme.space.s4 }) {
      Text('跟练完成')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text(`完成 ${this.moves.length} 个动作 · 约 ${this.totalMinutes} 分钟`)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
      SolidButton({
        label: '保存为训练记录',
        tone: 'primary',
        onTap: (): void => { this.finishSave() }
      })
      SolidButton({
        label: '返回工坊',
        tone: 'secondary',
        onTap: (): void => { this.onClose() }
      })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding(Theme.space.pageX)
  }
}
