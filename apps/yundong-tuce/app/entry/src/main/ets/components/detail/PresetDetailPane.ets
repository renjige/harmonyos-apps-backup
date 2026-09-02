import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { PlanItem, PresetPack } from '../../models/TuceModels'
import { PresetLibrary } from '../../services/PresetLibrary'
import { MoveLibrary } from '../../services/MoveLibrary'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'
import { TuceMedia } from '../../services/TuceMedia'
import { MoveListCard } from '../tuce/MoveListCard'

@Component
export struct PresetDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop presetId: string = ''
  @State preset: PresetPack = new PresetPack()
  @State toastText: string = ''

  aboutToAppear(): void {
    const found = PresetLibrary.find(this.presetId)
    if (found !== undefined) {
      this.preset = found
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async saveAsPlan(): Promise<void> {
    const plan = new PlanItem()
    plan.id = TuceStore.newId('plan')
    plan.name = this.preset.name
    plan.moveIds = this.preset.moveIds
    const ids = MoveLibrary.splitIds(this.preset.moveIds)
    const reps: string[] = []
    for (let i = 0; i < ids.length; i++) {
      reps.push('10')
    }
    plan.reps = reps.join('|')
    plan.minutes = this.preset.minutes
    plan.restSec = this.preset.restSec
    plan.note = this.preset.summary
    plan.createdAt = Date.now()
    await TuceStore.savePlan(plan)
    TuceNav.bump()
    this.showToast('已保存到我的训练方案')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(TuceMedia.cover(this.preset.coverKey))
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column({ space: 4 }) {
              Text(this.preset.name)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(`${this.preset.scene} · ${this.preset.minutes} 分钟 · 休息 ${this.preset.restSec} 秒`)
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.78)', 1]]
            })
          }
          .width('100%')
          .height(160)

          Text(this.preset.summary)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')

          Text('动作序列')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(MoveLibrary.splitIds(this.preset.moveIds), (moveId: string, idx: number) => {
            MoveListCard({
              moveId: moveId,
              name: `${idx + 1}. ${MoveLibrary.find(moveId)?.name ?? moveId}`,
              meta: MoveLibrary.find(moveId)?.category ?? '',
              coverKey: MoveLibrary.find(moveId)?.coverKey ?? 'warmup'
            })
          }, (moveId: string) => moveId)

          AppButton({
            label: '开始跟练',
            variant: 'primary',
            onTap: (): void => { TuceNav.open('session', this.preset.id) }
          })
          AppButton({
            label: '保存为我的方案',
            variant: 'secondary',
            onTap: (): void => { void this.saveAsPlan() }
          })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s10
        })
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)

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
  }
}
