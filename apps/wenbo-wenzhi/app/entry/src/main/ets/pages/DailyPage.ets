import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { InsightItem } from '../models/AskModels'
import { AskBizService } from '../services/AskBizService'
import { AskMedia } from '../services/AskMedia'
import { AskNav } from '../services/AskNav'
import { LearnStore } from '../services/LearnStore'
import { GrowthStore } from '../services/GrowthStore'
import { VaultStore } from '../services/VaultStore'

class DailyOption {
  index: number = 0
  text: string = ''
}

@Component
export struct DailyPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: InsightItem = new InsightItem()
  @State loaded: boolean = false
  @State empty: boolean = false
  @State toastText: string = ''
  @State marked: boolean = false
  @State options: DailyOption[] = []
  @State picked: number = -1
  @State judged: boolean = false

  aboutToAppear(): void {
    void this.load()
  }

  onRefreshTokenChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const list = await AskBizService.loadDaily()
    if (list.length === 0) {
      this.empty = true
      this.loaded = true
      return
    }
    const idx = new Date().getDate() % list.length
    this.item = list[idx]
    this.empty = false
    this.loaded = true
    this.marked = VaultStore.hasReadToday()
    this.picked = -1
    this.judged = false
    const opts: DailyOption[] = []
    const texts = this.item.choices()
    for (let n = 0; n < texts.length; n++) {
      const opt = new DailyOption()
      opt.index = n
      opt.text = texts[n]
      opts.push(opt)
    }
    this.options = opts
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async markRead(): Promise<void> {
    await VaultStore.markDailyRead()
    await LearnStore.markRead()
    await GrowthStore.logActivity('read', this.item.title, this.item.id, this.item.category)
    this.marked = true
    AskNav.bumpRefresh()
    this.showToast('已记录今日阅读')
  }

  private async collectNow(): Promise<void> {
    await VaultStore.collect(this.item.title, this.item, this.item.category, '')
    await GrowthStore.logActivity('collect', this.item.title, this.item.id, this.item.category)
    AskNav.bumpRefresh()
    this.showToast('已收入知识库')
  }

  private shareHint(): void {
    this.showToast('分享为界面示意，可复制摘要到剪贴板（当前仅提示）')
  }

  private async judgeDaily(): Promise<void> {
    if (this.picked < 0 || this.judged) {
      return
    }
    this.judged = true
    const ok = this.picked === this.item.answerIndex
    if (!ok) {
      await LearnStore.addWrong(
        this.item,
        this.item.choiceAt(this.picked),
        this.item.choiceAt(this.item.answerIndex)
      )
    }
    await LearnStore.recordQuiz(ok)
    await GrowthStore.logActivity('quiz', this.item.title, this.item.id, this.item.category)
    this.showToast(ok ? '答对了' : '已记入错题本')
  }

  private dailyOptBg(i: number): string {
    if (this.judged && i === this.item.answerIndex) {
      return Theme.colors().successContainer
    }
    if (this.judged && i === this.picked && i !== this.item.answerIndex) {
      return Theme.colors().dangerContainer
    }
    if (this.picked === i) {
      return Theme.colors().brandPrimaryContainer
    }
    return Theme.colors().surfaceSubtle
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('每日新知')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text(VaultStore.todayLabel())
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s3
        })

        if (!this.loaded) {
          Column()
            .layoutWeight(1)
        } else if (this.empty) {
          AppEmpty({
            title: '今日新知尚未同步',
            description: '下拉或点击重试，从平台拉取精选',
            actionLabel: '重试',
            onAction: (): void => { void this.load() }
          })
            .layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(AskMedia.resource(this.item.coverKey.length > 0 ? this.item.coverKey : 'daily_hero'))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(120)
                  .linearGradient({
                    direction: GradientDirection.Bottom,
                    colors: [['rgba(11,31,58,0)', 0], ['rgba(11,31,58,0.78)', 1]]
                  })
                Text(this.item.title)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
              }
              .width('100%')
              .borderRadius(Theme.radius.card)
              .clip(true)
              .onClick(() => { AskNav.openDetail('daily', this.item.id) })

              Column({ space: Theme.space.s3 }) {
                Text(this.item.category)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandAccent)
                  .width('100%')
                Text(this.item.summary)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(this.item.body)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)

              Row({ space: Theme.space.s2 }) {
                AppButton({
                  label: this.marked ? '今日已阅' : '已阅',
                  variant: this.marked ? 'secondary' : 'primary',
                  onTap: (): void => { void this.markRead() }
                })
              }
              .width('100%')
              Row({ space: Theme.space.s2 }) {
                AppButton({
                  label: '收藏',
                  variant: 'secondary',
                  onTap: (): void => { void this.collectNow() }
                })
                  .layoutWeight(1)
                AppButton({
                  label: '分享',
                  variant: 'secondary',
                  onTap: (): void => { this.shareHint() }
                })
                  .layoutWeight(1)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)

              if (this.item.hasQuiz()) {
                Text('今日一题')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                ForEach(this.options, (opt: DailyOption) => {
                  Text(`${opt.index + 1}. ${opt.text}`)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                    .padding(Theme.space.s3)
                    .constraintSize({ minHeight: 44 })
                    .backgroundColor(this.dailyOptBg(opt.index))
                    .borderRadius(Theme.radius.sm)
                    .onClick(() => {
                      if (!this.judged) {
                        this.picked = opt.index
                      }
                    })
                }, (opt: DailyOption) => `d_${opt.index}`)
                if (!this.judged) {
                  AppButton({
                    label: this.picked < 0 ? '选一项再确认' : '确认答案',
                    disabled: this.picked < 0,
                    onTap: (): void => { void this.judgeDaily() }
                  })
                } else {
                  Text(this.picked === this.item.answerIndex ? '答对了，可看上方解析。' : '答错了，正确答案已标出。')
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                }
              }

              Text(`已连续学习 ${VaultStore.streakDays()} 天`)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().brandAccent)
                .width('100%')
                .textAlign(TextAlign.Center)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s8 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
