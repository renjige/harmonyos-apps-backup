import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { MoodSelector } from '../components/zizai/MoodSelector'
import { MoodRecord } from '../models/ZizaiModels'
import { DateHelper } from '../services/DateHelper'
import { ZizaiStore } from '../services/ZizaiStore'

@Component
export struct RecordPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State selectedMood: string = '3'
  @State note: string = ''
  @State gratitude1: string = ''
  @State gratitude2: string = ''
  @State gratitude3: string = ''
  @State history: MoodRecord[] = []
  @State markedDays: string[] = []
  @State calendarYear: number = 2026
  @State calendarMonth: number = 8
  @State toastText: string = ''

  aboutToAppear(): void {
    const now = new Date()
    this.calendarYear = now.getFullYear()
    this.calendarMonth = now.getMonth() + 1
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    this.history = await ZizaiStore.loadAllMoods()
    this.markedDays = await ZizaiStore.moodKeysInMonth(this.calendarYear, this.calendarMonth)
    const today = await ZizaiStore.loadMood(DateHelper.todayKey())
    if (today !== undefined) {
      this.selectedMood = today.moodKey
      this.note = today.note
      this.gratitude1 = today.gratitude.length > 0 ? today.gratitude[0] : ''
      this.gratitude2 = today.gratitude.length > 1 ? today.gratitude[1] : ''
      this.gratitude3 = today.gratitude.length > 2 ? today.gratitude[2] : ''
    }
  }

  private async handleSave(): Promise<void> {
    const g: string[] = []
    if (this.gratitude1.trim().length > 0) {
      g.push(this.gratitude1.trim())
    }
    if (this.gratitude2.trim().length > 0) {
      g.push(this.gratitude2.trim())
    }
    if (this.gratitude3.trim().length > 0) {
      g.push(this.gratitude3.trim())
    }
    await ZizaiStore.saveMood(this.selectedMood, this.note, g)
    this.showToast('今日记录已保存')
    await this.reload()
  }

  private hasMoodMark(key: string): boolean {
    for (const k of this.markedDays) {
      if (k === key) {
        return true
      }
    }
    return false
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Text('生活记录')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Text(`${this.calendarMonth} 月概览`)
            .fontSize(Theme.type.title3)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('圆点表示已记录心情的日子')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          this.MonthGrid()

          Column({ space: Theme.space.s4 }) {
            Text('今日心情')
              .fontSize(Theme.type.title3)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            MoodSelector({
              selectedKey: this.selectedMood,
              onSelect: (key: string): void => { this.selectedMood = key }
            })

            TextInput({ text: this.note, placeholder: '一句话记录今天…' })
              .onChange((v: string): void => { this.note = v })
              .height(44)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .padding({ left: 12, right: 12 })

            Text('感恩小事（1-3 件）')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.gratitude1, placeholder: '感恩 1' })
              .onChange((v: string): void => { this.gratitude1 = v })
              .height(40)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .padding({ left: 12, right: 12 })
            TextInput({ text: this.gratitude2, placeholder: '感恩 2（选填）' })
              .onChange((v: string): void => { this.gratitude2 = v })
              .height(40)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .padding({ left: 12, right: 12 })
            TextInput({ text: this.gratitude3, placeholder: '感恩 3（选填）' })
              .onChange((v: string): void => { this.gratitude3 = v })
              .height(40)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .padding({ left: 12, right: 12 })

            AppButton({
              label: '保存今日记录',
              variant: 'primary',
              onTap: (): void => { void this.handleSave() }
            })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column({ space: Theme.space.s3 }) {
            Text('历史记录')
              .fontSize(Theme.type.title3)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.history.length === 0) {
              Text('还没有记录，从今天开始吧 🌱')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            } else {
              ForEach(this.history.slice(0, 14), (m: MoodRecord) => {
                Column({ space: 4 }) {
                  Row() {
                    Text(DateHelper.displayDate(m.dateKey))
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    Blank()
                    Text(m.moodLabel)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  }
                  .width('100%')
                  if (m.note.length > 0) {
                    Text(m.note)
                      .fontSize(Theme.type.body)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  }
                  if (m.gratitude.length > 0) {
                    Text(`感恩：${m.gratitude.join(' · ')}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textTertiary)
                  }
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
              }, (m: MoodRecord) => m.dateKey)
            }
          }
          .width('100%')
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: this.bottomInset + Theme.space.s6
        })
      }
      .edgeEffect(EdgeEffect.Spring)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MonthGrid() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        ForEach(['日', '一', '二', '三', '四', '五', '六'], (w: string) => {
          Text(w)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }, (w: string) => w)
      }
      .width('100%')

      Grid() {
        ForEach(DateHelper.monthGrid(this.calendarYear, this.calendarMonth), (key: string, idx: number) => {
          GridItem() {
            if (key.length === 0) {
              Text('')
            } else {
              Column({ space: 2 }) {
                Text(`${DateHelper.parseKey(key).getDate()}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(key === DateHelper.todayKey() ?
                    Theme.colors().brandPrimary : Theme.colors().textSecondary)
                if (this.hasMoodMark(key)) {
                  Circle({ width: 6, height: 6 })
                    .fill(Theme.colors().brandPrimary)
                }
              }
              .width('100%')
              .height(36)
              .justifyContent(FlexAlign.Center)
            }
          }
        }, (key: string, idx: number) => `${key}_${idx}`)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(4)
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }
}
