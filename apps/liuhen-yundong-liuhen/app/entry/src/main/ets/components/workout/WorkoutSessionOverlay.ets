import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { WorkoutTypeOption, WorkoutRecord } from '../../models/WorkoutModels'
import { DateHelper } from '../../services/DateHelper'
import { WorkoutStore } from '../../services/WorkoutStore'
import { AchievementService } from '../../services/StatsService'

@Component
export struct WorkoutSessionOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  @State selectedType: string = 'run'
  @State elapsedSeconds: number = 0
  @State running: boolean = false
  @State showSummary: boolean = false
  @State noteText: string = ''
  @State toastText: string = ''
  private timerId: number = -1

  aboutToDisappear(): void {
    this.stopTimer()
  }

  private stopTimer(): void {
    if (this.timerId >= 0) {
      clearTimeout(this.timerId)
      this.timerId = -1
    }
  }

  private tick(): void {
    if (!this.running) {
      return
    }
    this.elapsedSeconds++
    this.timerId = setTimeout((): void => { this.tick() }, 1000)
  }

  private toggleRun(): void {
    this.running = !this.running
    if (this.running) {
      this.tick()
    } else {
      this.stopTimer()
    }
  }

  private finishSession(): void {
    this.running = false
    this.stopTimer()
    if (this.elapsedSeconds < 30) {
      this.toastText = '运动时长至少 30 秒'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    this.showSummary = true
  }

  private async saveWorkout(): Promise<void> {
    const rec = WorkoutRecord.create(this.selectedType, this.elapsedSeconds, this.noteText.trim())
    await WorkoutStore.saveWorkout(rec)
    await AchievementService.evaluateAndUnlock()
    this.showSummary = false
    this.onSaved()
  }

  @Builder
  TypeChip(opt: WorkoutTypeOption) {
    Column({ space: 6 }) {
      Column() {
        AppIcon({
          name: opt.key === 'bike' ? 'chart' : 'biz',
          iconSize: Theme.icon.md,
          color: this.selectedType === opt.key ? Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(52)
      .height(52)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.selectedType === opt.key ?
        Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.lg)
      Text(opt.label)
        .fontSize(Theme.type.caption)
        .fontColor(this.selectedType === opt.key ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .onClick((): void => { if (!this.running) { this.selectedType = opt.key } })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfacePage)

      Column({ space: Theme.space.s5 }) {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => {
            this.stopTimer()
            this.onClose()
          })
          Blank()
          Text('运动记录')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Column().width(48)
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s2 })

        Text('选择运动类型')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.s4 })

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround }) {
          ForEach(WorkoutTypeOption.all(), (opt: WorkoutTypeOption) => {
            this.TypeChip(opt)
          }, (opt: WorkoutTypeOption) => opt.key)
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4 })

        Column({ space: Theme.space.s2 }) {
          Text(DateHelper.formatDuration(this.elapsedSeconds))
            .fontSize(56)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
          Text(this.running ? '计时中…' : '已暂停')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .padding({ top: Theme.space.s8 })

        Row({ space: Theme.space.s4 }) {
          AppButton({
            label: this.running ? '暂停' : '继续',
            variant: 'secondary',
            onTap: (): void => { this.toggleRun() }
          })
            .layoutWeight(1)
          AppButton({
            label: '结束',
            variant: 'primary',
            onTap: (): void => { this.finishSession() }
          })
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4 })

        if (!this.running && this.elapsedSeconds === 0) {
          AppButton({
            label: '开始计时',
            variant: 'primary',
            onTap: (): void => {
              this.running = true
              this.tick()
            }
          })
            .width('88%')
        }
      }
      .width('100%')
      .height('100%')

      if (this.showSummary) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.colors().overlayScrim)
          .onClick((): void => { this.showSummary = false })

        Column({ space: Theme.space.s4 }) {
          Text('本次运动摘要')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text(`${WorkoutTypeOption.labelFor(this.selectedType)} · ${DateHelper.formatDuration(this.elapsedSeconds)}`)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
          TextInput({ text: this.noteText, placeholder: '备注（选填）' })
            .onChange((v: string): void => { this.noteText = v })
          AppButton({ label: '保存', variant: 'primary', onTap: (): void => { void this.saveWorkout() } })
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.showSummary = false } })
        }
        .width('86%')
        .padding(Theme.space.s6)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.88)')
          .borderRadius(Theme.radius.pill)
          .position({ top: 56 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(50)
  }
}
