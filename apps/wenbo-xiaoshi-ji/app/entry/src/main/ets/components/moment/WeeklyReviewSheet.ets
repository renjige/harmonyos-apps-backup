import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { WeeklyReview } from '../../models/MomentModels'
import { DateHelper } from '../../services/DateHelper'
import { MomentStore } from '../../services/MomentStore'
import { MomentNav } from '../../services/MomentNav'

@Component
export struct WeeklyReviewSheet {
  @Prop weekKey: string = ''
  onSaved: () => void = () => {}
  @State highlight: string = ''
  @State learned: string = ''
  @State nextIntent: string = ''
  @State toast: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const key = this.weekKey.length > 0 ? this.weekKey : DateHelper.weekStartKey()
    const r = await MomentStore.loadWeeklyReview(key)
    this.highlight = r.highlight
    this.learned = r.learned
    this.nextIntent = r.nextIntent
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2400)
  }

  private async save(): Promise<void> {
    const r = new WeeklyReview()
    r.weekKey = this.weekKey.length > 0 ? this.weekKey : DateHelper.weekStartKey()
    r.highlight = this.highlight.trim()
    r.learned = this.learned.trim()
    r.nextIntent = this.nextIntent.trim()
    if (r.highlight.length === 0 && r.learned.length === 0 && r.nextIntent.length === 0) {
      this.showToast('请至少填写一问')
      return
    }
    await MomentStore.saveWeeklyReview(r)
    this.onSaved()
    MomentNav.close()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('取消')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .padding({ left: 4, right: 12, top: 8, bottom: 8 })
            .onClick((): void => MomentNav.close())
          Text('本周复盘')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Text('保存')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 12, right: 4, top: 8, bottom: 8 })
            .onClick((): void => { void this.save() })
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s5 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('用三问整理一周：不是流水账，而是帮你看清自己')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .lineHeight(20)
              .width('100%')

            Text('本周最亮的一件事？')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.highlight, placeholder: '写下让你会心一笑或印象深刻的小事…' })
              .height(72)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .caretColor(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().surfaceCard)
              .onChange((v: string): void => { this.highlight = v })

            Text('从随记里新收获到什么？')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.learned, placeholder: '一句感悟、一个习惯或一个决定…' })
              .height(72)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .caretColor(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().surfaceCard)
              .onChange((v: string): void => { this.learned = v })

            Text('下周想坚持的一件小事？')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.nextIntent, placeholder: '可落到待办或每日一句里…' })
              .height(72)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .caretColor(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().surfaceCard)
              .onChange((v: string): void => { this.nextIntent = v })

            AppButton({
              label: '保存本周复盘',
              onTap: (): void => { void this.save() }
            })
            Row().height(Theme.space.s10)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 52 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
