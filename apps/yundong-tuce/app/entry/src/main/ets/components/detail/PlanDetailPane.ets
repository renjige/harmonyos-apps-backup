import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { PlanItem, TrainLog } from '../../models/TuceModels'
import { MoveLibrary } from '../../services/MoveLibrary'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'
import { TuceEngine } from '../../services/TuceEngine'
import { TuceMedia } from '../../services/TuceMedia'
import { MoveListCard } from '../tuce/MoveListCard'

@Component
export struct PlanDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop planId: string = ''
  @State plan: PlanItem = new PlanItem()
  @State confirm: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await TuceStore.findPlan(this.planId)
    if (found !== undefined) {
      this.plan = found
    }
  }

  private async finishToday(): Promise<void> {
    const log = new TrainLog()
    log.id = TuceStore.newId('log')
    log.date = TuceStore.today()
    log.planName = this.plan.name
    log.doneText = '已完成方案动作'
    log.feel = '状态平稳'
    log.difficulty = 3
    log.fun = 4
    log.complete = 4
    log.note = this.plan.note
    log.createdAt = Date.now()
    await TuceStore.saveLog(log)
    await TuceStore.addCheckin(TuceStore.today())
    const programs = await TuceStore.programs()
    for (const p of programs) {
      if (p.planId === this.plan.id) {
        const days = TuceEngine.splitIdsSafe(p.doneDates)
        let hit = false
        for (const d of days) {
          if (d === TuceStore.today()) {
            hit = true
          }
        }
        if (!hit) {
          days.push(TuceStore.today())
          p.doneDates = days.join('|')
          await TuceStore.saveProgram(p)
        }
      }
    }
    TuceNav.bump()
    this.toastText = '已完成今日训练并打卡'
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async remove(): Promise<void> {
    if (!this.confirm) {
      this.confirm = true
      this.toastText = '再点一次确认删除方案'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    await TuceStore.deletePlan(this.plan.id)
    TuceNav.bump()
    TuceNav.close()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(TuceMedia.cover('strength'))
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column({ space: 4 }) {
              Text(this.plan.name)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(`时长 ${this.plan.minutes} 分钟 · 休息 ${this.plan.restSec} 秒`)
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

          if (this.plan.note.length > 0) {
            Text(this.plan.note)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
          }

          ForEach(MoveLibrary.splitIds(this.plan.moveIds), (moveId: string) => {
            MoveListCard({
              moveId: moveId,
              name: MoveLibrary.find(moveId)?.name ?? moveId,
              meta: MoveLibrary.find(moveId)?.category ?? '',
              coverKey: MoveLibrary.find(moveId)?.coverKey ?? 'warmup'
            })
          }, (moveId: string) => moveId)

          AppButton({
            label: '完成今日训练并打卡',
            variant: 'primary',
            onTap: (): void => { void this.finishToday() }
          })
          AppButton({
            label: '打开训练清单',
            variant: 'secondary',
            onTap: (): void => { TuceNav.open('checklist', '') }
          })
          AppButton({
            label: this.confirm ? '再点一次确认删除' : '删除此方案',
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
}
