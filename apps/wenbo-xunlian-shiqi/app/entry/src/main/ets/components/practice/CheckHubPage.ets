import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SolidButton } from '../design-system/SolidButton'
import { CheckLine, CheckState } from '../../models/TrainingModels'
import { PracticeHubStore } from '../../services/PracticeHubStore'
import { PracticeService } from '../../services/PracticeService'
import { DataRefresh } from '../../services/DataRefresh'

@Component
export struct CheckHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State before: CheckLine[] = []
  @State after: CheckLine[] = []
  @State newBefore: string = ''
  @State newAfter: string = ''
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.reloadFromStore()
  }

  private reloadFromStore(): void {
    const s = PracticeHubStore.getChecks()
    this.before = PracticeService.unpackLines(s.beforePacked)
    this.after = PracticeService.unpackLines(s.afterPacked)
  }

  private async persist(): Promise<void> {
    const s = new CheckState()
    s.beforePacked = PracticeService.packLines(this.before)
    s.afterPacked = PracticeService.packLines(this.after)
    await PracticeHubStore.saveChecks(s)
    DataRefresh.bump()
  }

  private async useTemplate(): Promise<void> {
    const next = PracticeService.applyCheckTemplate(PracticeHubStore.getChecks())
    await PracticeHubStore.saveChecks(next)
    DataRefresh.bump()
    this.reloadFromStore()
  }

  private async toggleBefore(index: number): Promise<void> {
    this.before = PracticeService.toggleLine(this.before, index)
    await this.persist()
  }

  private async toggleAfter(index: number): Promise<void> {
    this.after = PracticeService.toggleLine(this.after, index)
    await this.persist()
  }

  private async addBefore(): Promise<void> {
    const next = PracticeService.addLine(this.before, this.newBefore)
    if (next.length === this.before.length) {
      return
    }
    this.before = next.slice()
    this.newBefore = ''
    await this.persist()
  }

  private async addAfter(): Promise<void> {
    const next = PracticeService.addLine(this.after, this.newAfter)
    if (next.length === this.after.length) {
      return
    }
    this.after = next.slice()
    this.newAfter = ''
    await this.persist()
  }

  build() {
    Column() {
      Row({ space: Theme.space.s3 }) {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .rotate({ angle: 180 })
        .onClick((): void => { this.onClose() })

        Text('运动任务清单')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)

        Blank().width(40)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('训练前 / 训练后勾选。可用模板快速填入热身、拉伸等条目，再按自己的习惯增改。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Column() {
            SolidButton({
              label: '填入常用模板',
              tone: 'secondary',
              onTap: (): void => { void this.useTemplate() }
            })
          }
          .width('100%')
          .onClick((): void => { void this.useTemplate() })

          Text(`训练前（${this.before.length}）`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          if (this.before.length === 0) {
            Text('清单为空，可填入模板或自行添加。')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.before, (l: CheckLine) => {
              Row({ space: Theme.space.s3 }) {
                Text(l.done ? '已勾' : '未勾')
                  .fontSize(Theme.type.caption)
                  .fontColor(l.done ? Theme.colors().success : Theme.colors().textSecondary)
                Text(l.title)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { void this.toggleBefore(l.seq) })
            }, (l: CheckLine) => `b_${l.seq}_${l.title}_${l.done ? 1 : 0}`)
          }

          Row({ space: Theme.space.s2 }) {
            TextInput({ text: this.newBefore, placeholder: '添加训练前事项' })
              .layoutWeight(1)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => { this.newBefore = v })
            Text('添加')
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
              .padding({ left: 12, right: 12, top: 10, bottom: 10 })
              .backgroundColor(Theme.primaryButtonFill())
              .borderRadius(Theme.radius.md)
              .onClick((): void => { void this.addBefore() })
          }
          .width('100%')

          Text(`训练后（${this.after.length}）`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          if (this.after.length === 0) {
            Text('清单为空，可填入模板或自行添加。')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.after, (l: CheckLine) => {
              Row({ space: Theme.space.s3 }) {
                Text(l.done ? '已勾' : '未勾')
                  .fontSize(Theme.type.caption)
                  .fontColor(l.done ? Theme.colors().success : Theme.colors().textSecondary)
                Text(l.title)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { void this.toggleAfter(l.seq) })
            }, (l: CheckLine) => `a_${l.seq}_${l.title}_${l.done ? 1 : 0}`)
          }

          Row({ space: Theme.space.s2 }) {
            TextInput({ text: this.newAfter, placeholder: '添加训练后事项' })
              .layoutWeight(1)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => { this.newAfter = v })
            Text('添加')
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
              .padding({ left: 12, right: 12, top: 10, bottom: 10 })
              .backgroundColor(Theme.primaryButtonFill())
              .borderRadius(Theme.radius.md)
              .onClick((): void => { void this.addAfter() })
          }
          .width('100%')
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.pageBg(this.themeEpoch))
  }
}
