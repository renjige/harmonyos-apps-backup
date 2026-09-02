import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ProgramDaySnap, ProgramItem } from '../../models/TuceModels'
import { MoveLibrary } from '../../services/MoveLibrary'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'
import { TuceEngine } from '../../services/TuceEngine'
import { MoveListCard } from '../tuce/MoveListCard'

@Component
export struct ProgramDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('tuceReload') @Watch('onReload') reloadToken: number = 0
  @Prop programId: string = ''
  @State program: ProgramItem = new ProgramItem()
  @State snap: ProgramDaySnap = new ProgramDaySnap()
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  onReload(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await TuceStore.findProgram(this.programId)
    if (found !== undefined) {
      const copy = new ProgramItem()
      copy.id = found.id
      copy.name = found.name
      copy.days = found.days
      copy.planId = found.planId
      copy.startDate = found.startDate
      copy.doneDates = found.doneDates
      this.program = copy
    }
    this.snap = await TuceEngine.programDaySnap(this.programId)
  }

  private doneCount(): number {
    return TuceEngine.splitIdsSafe(this.program.doneDates).length
  }

  private pct(): number {
    if (this.program.days <= 0) {
      return 0
    }
    return Math.min(1, this.doneCount() / this.program.days)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async finishToday(): Promise<void> {
    await TuceEngine.completeProgramDay(this.programId)
    await this.load()
    TuceNav.bump()
    this.showToast('今日训练已完成，已打卡并写入日志')
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认删除计划')
      return
    }
    await TuceStore.deleteProgram(this.programId)
    TuceNav.bump()
    TuceNav.close()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.cat_strength'))
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column({ space: 4 }) {
              Text(this.program.name)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(`第 ${this.snap.dayIndex} / ${this.program.days} 天`)
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.75)', 1]]
            })
          }
          .width('100%')
          .height(160)

          Row({ space: Theme.space.s3 }) {
            Column({ space: 4 }) {
              Text('完成进度')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              Text(`${this.doneCount()} / ${this.program.days} 天`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            Stack() {
              Progress({ value: this.pct() * 100, total: 100, type: ProgressType.Ring })
                .width(72)
                .height(72)
                .color(Theme.colors().brandPrimary)
                .style({ strokeWidth: 8 })
              Text(`${Math.round(this.pct() * 100)}%`)
                .fontSize(Theme.type.caption)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandPrimary)
            }
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Column({ space: Theme.space.s2 }) {
            Text('今日训练')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.snap.planName.length > 0 ? this.snap.planName : '请先为计划绑定训练方案')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.snap.todayDone) {
              Text('今日已完成 · 明天继续加油')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().brandPrimary)
                .width('100%')
            }
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Text('动作列表')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(MoveLibrary.splitIds(this.snap.moveIds), (moveId: string) => {
            this.MoveRow(moveId)
          }, (moveId: string) => moveId)

          if (!this.snap.todayDone && this.snap.moveIds.length > 0) {
            AppButton({
              label: '完成今日训练并打卡',
              variant: 'primary',
              onTap: (): void => { void this.finishToday() }
            })
          }
          AppButton({
            label: '打开训练清单',
            variant: 'secondary',
            onTap: (): void => { TuceNav.open('checklist', '') }
          })
          if (this.program.planId.length > 0) {
            AppButton({
              label: '查看绑定方案详情',
              variant: 'ghost',
              onTap: (): void => { TuceNav.open('plan', this.program.planId) }
            })
          }
          AppButton({
            label: this.confirmDelete ? '确认删除此计划' : '删除周期计划',
            variant: 'secondary',
            onTap: (): void => { void this.remove() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  MoveRow(moveId: string) {
    MoveListCard({
      moveId: moveId,
      name: MoveLibrary.find(moveId)?.name ?? moveId,
      meta: MoveLibrary.find(moveId)?.category ?? '',
      coverKey: MoveLibrary.find(moveId)?.coverKey ?? 'warmup'
    })
  }
}
