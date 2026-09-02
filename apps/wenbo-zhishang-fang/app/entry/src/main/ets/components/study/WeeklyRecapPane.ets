import { Theme } from '../design-system/Theme'
import { OverlayShell } from './OverlayShell'
import { WeeklyRecap } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct WeeklyRecapPane {
  @StorageLink('studyEpoch') @Watch('onChange') studyEpoch: number = 0
  @StorageLink('noteEpoch') @Watch('onChange') noteEpoch: number = 0
  @State recap: WeeklyRecap = new WeeklyRecap()
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.recap = await StudyStore.weeklyRecap()
  }

  build() {
    OverlayShell({
      title: '本周回顾',
      onClose: (): void => { this.onClose() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      Text(this.recap.weekLabel)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')

      Row({ space: 8 }) {
        this.Chip('新增摘录', `${this.recap.newNotes} 条`)
        this.Chip('打卡天数', `${this.recap.checkInDays} 天`)
        this.Chip('复习次数', `${this.recap.recallCount} 次`)
      }
      .width('100%')

      if (this.recap.topTag.length > 0) {
        Text(`本周常读分类：${CategoryEmojiUtil.chipLabel(this.recap.topTag)}`)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }

      if (this.recap.highlightQuote.length > 0) {
        Column({ space: 8 }) {
          Text('本周精选金句')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(`「${this.recap.highlightQuote}」`)
            .fontSize(Theme.type.bodyM)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(`——《${this.recap.highlightBook}》`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(12)
      } else {
        Text('本周还没有书摘，去添加一条开始本周阅读吧')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  Chip(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.overline)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.sm)
  }
}
