import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { InsightItem } from '../../models/AskModels'
import { AskBizService } from '../../services/AskBizService'
import { AskMedia } from '../../services/AskMedia'
import { AskNav } from '../../services/AskNav'
import { LearnStore } from '../../services/LearnStore'
import { GrowthStore } from '../../services/GrowthStore'
import { VaultStore } from '../../services/VaultStore'

class DailyQuizOption {
  index: number = 0
  text: string = ''
}

@Component
export struct DailyDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: InsightItem = new InsightItem()
  @State loaded: boolean = false
  @State toastText: string = ''
  @State marked: boolean = false
  @State collected: boolean = false
  @State options: DailyQuizOption[] = []
  @State picked: number = -1
  @State judged: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    const row = await AskBizService.findDaily(this.itemId)
    if (row === undefined) {
      this.loaded = false
      return
    }
    this.item = InsightItem.copy(row)
    this.loaded = true
    this.marked = VaultStore.hasReadToday()
    this.collected = VaultStore.isCollected(row.id)
    this.picked = -1
    this.judged = false
    const opts: DailyQuizOption[] = []
    const texts = this.item.choices()
    for (let n = 0; n < texts.length; n++) {
      const opt = new DailyQuizOption()
      opt.index = n
      opt.text = texts[n]
      opts.push(opt)
    }
    this.options = opts
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
    this.collected = true
    AskNav.bumpRefresh()
    this.showToast('已收入知识库')
  }

  private async saveCard(): Promise<void> {
    await LearnStore.saveCard(this.item)
    await GrowthStore.logActivity('card', this.item.title, this.item.id, this.item.category)
    AskNav.bumpRefresh()
    this.showToast('已生成知识卡片')
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
    AskNav.bumpRefresh()
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
      DetailShell({
        title: '每日新知',
        showFavorite: true,
        favorited: this.collected,
        onClose: (): void => { AskNav.closeDetail() },
        onFavorite: (): void => { void this.collectNow() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '未找到今日内容', description: '返回后重试' })
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

              Text(`${this.item.category} · ${VaultStore.todayLabel()}`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')

              Column({ space: Theme.space.s2 }) {
                Text('摘要')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(this.item.summary)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)

              Text(this.item.body)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(this.item.description)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')

              AppButton({
                label: this.marked ? '今日已阅' : '标记已阅',
                variant: this.marked ? 'secondary' : 'primary',
                onTap: (): void => { void this.markRead() }
              })
              AppButton({
                label: this.collected ? '已收藏' : '收藏到知识库',
                variant: 'secondary',
                onTap: (): void => { void this.collectNow() }
              })
              AppButton({
                label: '生成知识卡片',
                variant: 'secondary',
                onTap: (): void => { void this.saveCard() }
              })

              if (this.item.hasQuiz()) {
                Text('今日一题')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                ForEach(this.options, (opt: DailyQuizOption) => {
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
                }, (opt: DailyQuizOption) => `dq_${opt.index}`)
                if (!this.judged) {
                  AppButton({
                    label: this.picked < 0 ? '选一项再确认' : '确认答案',
                    disabled: this.picked < 0,
                    onTap: (): void => { void this.judgeDaily() }
                  })
                }
              }
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
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
