import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DailyItem } from '../../models/ThinkModels'
import { ThinkStore } from '../../services/ThinkStore'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct DailyPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onPaneReload') paneToken: number = 0
  @State today: DailyItem = new DailyItem()
  @State history: DailyItem[] = []
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onPaneReload(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const todayKey = DateHelper.todayKey()
    this.today = await ThinkStore.todayDaily()
    const all = await ThinkStore.loadDailies()
    const past: DailyItem[] = []
    for (const it of all) {
      if (it.dateKey !== todayKey) {
        past.push(it)
      } else if (it.id !== this.today.id && it.answer.trim().length > 0) {
        past.push(it)
      }
    }
    this.history = past
  }

  private async save(): Promise<void> {
    if (this.today.answer.trim().length === 0) {
      this.toastText = '先写下今天的回答'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    await ThinkStore.saveDaily(this.today)
    await this.reload()
    this.toastText = '今日思考已收下'
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('每日思考')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Column({ space: Theme.space.s3 }) {
            Text(this.today.dateKey)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Text(this.today.prompt)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            TextArea({ text: this.today.answer, placeholder: '写下你的回答，形成长期思考习惯' })
              .height(140)
              .onChange((v: string) => { this.today.answer = v })
            AppButton({ label: '保存今日思考', onTap: (): void => { void this.save() } })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Text('过往记录')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.history.length === 0) {
            AppEmpty({ title: '还没有历史', description: '连续回答会在顶部统计里累计天数' })
          } else {
            ForEach(this.history, (it: DailyItem) => {
              Column({ space: 6 }) {
                Text(`${it.dateKey} · ${it.prompt}`)
                  .fontSize(Theme.type.footnote)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(it.answer.length > 0 ? it.answer : '（未作答）')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }, (it: DailyItem) => `${it.id}|${it.dateKey}|${it.updatedAt}`)
          }
        }
        .padding({ bottom: Theme.space.s10 })
      }
      .scrollBar(BarState.On)
      .edgeEffect(EdgeEffect.Spring)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding(12)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.md)
          .margin({ top: 8 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
