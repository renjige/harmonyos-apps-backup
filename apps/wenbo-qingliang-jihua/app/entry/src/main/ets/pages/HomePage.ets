import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { CoolIndexRing } from '../components/cool/CoolIndexRing'
import { MoodTagRow } from '../components/cool/MoodTagRow'
import { QuoteItem } from '../models/CoolPlanModels'
import { CoolPlanBizService } from '../services/CoolPlanBizService'
import { CoolPlanLocalStore } from '../services/CoolPlanLocalStore'
import { CoolPlanNav } from '../services/CoolPlanNav'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '清凉计划'
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @State greeting: string = ''
  @State quote: QuoteItem | undefined = undefined
  @State coolIndex: number = 60
  @State selectedMood: string = ''
  @State journalText: string = ''
  @State loading: boolean = true
  @State toastText: string = ''
  @State saving: boolean = false
  onOpenMessages: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2600)
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.greeting = CoolPlanBizService.greeting()
    this.quote = await CoolPlanBizService.loadDailyQuote()
    this.coolIndex = await CoolPlanBizService.todayCoolIndex()
    const today = CoolPlanLocalStore.todayKey()
    const moods = await CoolPlanBizService.loadMoods()
    this.selectedMood = ''
    for (const m of moods) {
      if (m.noteDate === today) {
        this.selectedMood = m.mood
      }
    }
    const journals = await CoolPlanBizService.loadJournals()
    this.journalText = ''
    for (const j of journals) {
      if (j.noteDate === today) {
        this.journalText = j.body
      }
    }
    this.loading = false
  }

  private async pickMood(mood: string): Promise<void> {
    this.selectedMood = mood
    const today = CoolPlanLocalStore.todayKey()
    const ok = await CoolPlanBizService.recordMood(mood, today)
    if (ok) {
      this.coolIndex = await CoolPlanBizService.todayCoolIndex()
      this.showToast(`已记录心情：${mood}`)
    } else {
      this.showToast('记录失败，请稍后重试')
    }
  }

  private async saveJournal(): Promise<void> {
    if (this.journalText.trim().length === 0) {
      this.showToast('写一句今日心语吧')
      return
    }
    this.saving = true
    const today = CoolPlanLocalStore.todayKey()
    const title = this.journalText.trim().length > 20 ?
      this.journalText.trim().substring(0, 20) : this.journalText.trim()
    const ok = await CoolPlanBizService.saveJournal(title, this.journalText.trim(), this.selectedMood, today)
    this.saving = false
    if (ok) {
      this.showToast('心语已保存')
    } else {
      this.showToast('保存失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row({ space: Theme.space.s3 }) {
            Column() {
              AppIcon({ name: 'sparkle', iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .linearGradient({
              angle: 135,
              colors: [[Theme.colors().brandPrimary, 0], ['#4A9E9E', 1]]
            })
            .borderRadius(Theme.radius.lg)

            Column({ space: 4 }) {
              Text(`${CategoryEmojiUtil.weekdayMark()} ${this.greeting}`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(CategoryEmojiUtil.dailyHint())
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .layoutWeight(1)

          Column() {
            AppIcon({ name: 'message', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick(() => this.onOpenMessages())

          Column() {
            AppIcon({ name: 'refresh', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick(() => { void this.reload() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

        if (this.loading) {
          AppLoading({ label: '读取今日清凉' })
        } else if (this.quote === undefined) {
          AppEmpty({
            title: '暂时读不到语录',
            description: '请检查网络后重试。栏目来自平台，不会用本地假数据顶上。',
            actionLabel: '重新加载',
            iconName: 'book',
            emojiMark: '📖',
            onAction: (): void => { void this.reload() }
          })
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              AppCard({ title: '✨ 早安智慧', variant: 'glass' }) {
                Column({ space: 8 }) {
                  Text(this.quote !== undefined ? this.quote.title : '')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(this.quote !== undefined ? this.quote.summary : '')
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                  if (this.quote !== undefined && this.quote.author.length > 0) {
                    Text(`— ${this.quote.author}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                      .width('100%')
                  }
                  AppButton({
                    label: '阅读全文',
                    variant: 'secondary',
                    onTap: (): void => {
                      if (this.quote !== undefined) {
                        CoolPlanNav.openQuote(this.quote.id)
                      }
                    }
                  })
                  AppButton({
                    label: '浏览全部语录',
                    variant: 'secondary',
                    onTap: (): void => { CoolPlanNav.openQuoteList() }
                  })
                }
              }

              Row({ space: Theme.space.s4 }) {
                CoolIndexRing({ score: this.coolIndex, label: '清凉指数' })
                Column({ space: Theme.space.s2 }) {
                  Text('今日心情')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  MoodTagRow({
                    selectedMood: this.selectedMood,
                    onPick: (mood: string): void => { void this.pickMood(mood) }
                  })
                  Text('选心情后指数会更新；登录可同步本机记录到云端。')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)

              AppButton({
                label: '开始智慧呼吸',
                onTap: (): void => CoolPlanNav.switchTabBreath()
              })

              AppCard({ title: '💭 今日心语', variant: 'plain' }) {
                Column({ space: Theme.space.s3 }) {
                  TextArea({ text: this.journalText, placeholder: '写一句给自己的话…' })
                    .height(96)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .backgroundColor(Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.md)
                    .onChange((v: string) => { this.journalText = v })
                  AppButton({
                    label: this.saving ? '保存中…' : '保存心语',
                    variant: 'secondary',
                    onTap: (): void => { void this.saveJournal() }
                  })
                }
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
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
        .padding({ top: Theme.space.s6, left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
