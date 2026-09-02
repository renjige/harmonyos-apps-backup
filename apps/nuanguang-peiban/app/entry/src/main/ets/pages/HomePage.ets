import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppLoading } from '../components/design-system/AppLoading'
import { WarmMediaHero } from '../components/warm/WarmMediaHero'
import { MoodSelectorRow } from '../components/warm/MoodSelectorRow'
import { MoodItem } from '../models/WarmCompanionModels'
import { WarmCompanionBizService } from '../services/WarmCompanionBizService'
import { WarmCompanionLocalStore } from '../services/WarmCompanionLocalStore'
import { WarmCompanionNav } from '../services/WarmCompanionNav'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

class StreakDot {
  dateKey: string = ''
  filled: boolean = false
  label: string = ''
}

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '暖光陪伴'
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @State greeting: string = ''
  @State selectedMood: string = ''
  @State diaryText: string = ''
  @State feedbackText: string = ''
  @State loading: boolean = true
  @State toastText: string = ''
  @State saving: boolean = false
  @State streakDots: StreakDot[] = []
  @State todayRecorded: boolean = false

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

  private buildStreakDots(moods: MoodItem[]): void {
    const dots: StreakDot[] = []
    let i = 6
    while (i >= 0) {
      const key = WarmCompanionLocalStore.dateKeyOffset(i)
      const dot = new StreakDot()
      dot.dateKey = key
      dot.filled = WarmCompanionBizService.hasRecordOnDate(moods, key)
      const parts = key.split('-')
      dot.label = parts.length === 3 ? `${Number.parseInt(parts[2], 10)}` : ''
      dots.push(dot)
      i -= 1
    }
    this.streakDots = dots
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.greeting = WarmCompanionBizService.greeting()
    const today = WarmCompanionLocalStore.todayKey()
    const moods = await WarmCompanionBizService.loadMoods()
    this.buildStreakDots(moods)
    this.selectedMood = ''
    this.diaryText = ''
    this.todayRecorded = false
    for (const m of moods) {
      if (m.noteDate === today) {
        this.selectedMood = m.mood
        this.diaryText = m.body
        this.todayRecorded = true
      }
    }
    if (this.selectedMood.length > 0) {
      const fb = await WarmCompanionBizService.loadMoodFeedback(this.selectedMood)
      this.feedbackText = fb !== undefined ? fb.text : ''
    } else {
      this.feedbackText = ''
    }
    this.loading = false
  }

  private async pickMood(mood: string): Promise<void> {
    this.selectedMood = mood
    const fb = await WarmCompanionBizService.loadMoodFeedback(mood)
    this.feedbackText = fb !== undefined ? fb.text : '谢谢你愿意分享此刻的心情。'
  }

  private async submitRecord(): Promise<void> {
    if (this.selectedMood.length === 0) {
      this.showToast('请先选择一种心情')
      return
    }
    if (this.diaryText.trim().length > 200) {
      this.showToast('日记最多 200 字')
      return
    }
    this.saving = true
    const today = WarmCompanionLocalStore.todayKey()
    const ok = await WarmCompanionBizService.recordMood(this.selectedMood, this.diaryText.trim(), today)
    this.saving = false
    if (ok) {
      this.todayRecorded = true
      this.showToast('已记录此刻')
      void this.reload()
    } else {
      this.showToast('记录失败，请稍后重试')
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
              colors: [[Theme.colors().brandPrimary, 0], [Theme.colors().brandAccent, 1]]
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
          AppLoading({ label: '读取今日心情' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              WarmMediaHero({
                coverKey: 'hero_warm_glow',
                overline: this.appName,
                title: '今日心情',
                bannerHeight: 140,
                compact: true
              })

              AppCard({ title: '💛 此刻心情', variant: 'plain' }) {
                Column({ space: Theme.space.s3 }) {
                  MoodSelectorRow({
                    selectedMood: this.selectedMood,
                    onPick: (mood: string): void => { void this.pickMood(mood) }
                  })
                  if (this.feedbackText.length > 0) {
                    Text(this.feedbackText)
                      .fontSize(Theme.type.body)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .width('100%')
                      .padding(Theme.space.s3)
                      .backgroundColor(Theme.colors().brandPrimaryContainer)
                      .borderRadius(Theme.radius.md)
                  }
                }
              }

              AppCard({ title: '💭 今日日记', variant: 'plain' }) {
                Column({ space: Theme.space.s3 }) {
                  TextArea({ text: this.diaryText, placeholder: '写一句给自己的话（可选，最多 200 字）…' })
                    .height(96)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .backgroundColor(Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.md)
                    .maxLength(200)
                    .onChange((v: string) => { this.diaryText = v })
                  Text(`${this.diaryText.length}/200`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                    .textAlign(TextAlign.End)
                }
              }

              Column({ space: Theme.space.s2 }) {
                Text('连续打卡')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Row({ space: Theme.space.s2 }) {
                  ForEach(this.streakDots, (d: StreakDot) => {
                    Column({ space: 4 }) {
                      Circle()
                        .width(d.filled ? 12 : 8)
                        .height(d.filled ? 12 : 8)
                        .fill(d.filled ? Theme.colors().brandPrimary : Theme.colors().strokeStrong)
                        .shadow(d.filled ?
                          { radius: 8, color: 'rgba(245,166,35,0.5)', offsetY: 0 } :
                          { radius: 0, color: 'transparent', offsetY: 0 })
                      Text(d.label)
                        .fontSize(Theme.type.overline)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Center)
                  }, (d: StreakDot) => d.dateKey)
                }
                .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .border({ width: 1, color: Theme.colors().strokeHairline })

              AppButton({
                label: this.saving ? '记录中…' : (this.todayRecorded ? '更新记录' : '记录此刻'),
                onTap: (): void => { void this.submitRecord() }
              })

              AppButton({
                label: '去陪伴时光放松',
                variant: 'secondary',
                onTap: (): void => WarmCompanionNav.switchTabCompanion()
              })
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
