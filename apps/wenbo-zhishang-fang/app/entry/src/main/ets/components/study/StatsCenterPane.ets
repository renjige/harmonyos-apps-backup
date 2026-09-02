import { Theme } from '../design-system/Theme'
import { OverlayShell } from './OverlayShell'
import { CategoryStat, StatsSnapshot } from '../../models/StudyModels'
import { WeekDayStat } from '../../models/BookNoteModels'
import { BookRankItem } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct StatsCenterPane {
  @StorageLink('studyEpoch') @Watch('onChange') studyEpoch: number = 0
  @StorageLink('noteEpoch') @Watch('onChange') noteEpoch: number = 0
  @State snap: StatsSnapshot = new StatsSnapshot()
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.snap = await StudyStore.statsSnapshot()
  }

  build() {
    OverlayShell({
      title: '数据统计',
      onClose: (): void => { this.onClose() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      Image($r('app.media.paper_texture'))
        .width('100%')
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sm)
        .opacity(0.85)

      Row({ space: 8 }) {
        this.StatBox(`${this.snap.checkInStreak}`, '连续打卡')
        this.StatBox(`${this.snap.unlockedAchievements}/${this.snap.totalAchievements}`, '成就')
      }
      .width('100%')

      Text('近 7 日摘录趋势')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Row({ space: 6 }) {
        ForEach(this.snap.weekDays, (d: WeekDayStat) => {
          Column({ space: 4 }) {
            Column()
              .width(28)
              .height(Math.max(8, d.count * 16))
              .backgroundColor(d.count > 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(4)
            Text(d.label)
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }, (d: WeekDayStat) => d.label)
      }
      .width('100%')
      .height(72)
      .alignItems(VerticalAlign.Bottom)

      Text('分类占比')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      if (this.snap.categoryStats.length === 0) {
        Text('添加书摘并标注分类后，这里会显示分布')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.snap.categoryStats, (c: CategoryStat) => {
          Row({ space: 8 }) {
            Text(CategoryEmojiUtil.chipLabel(c.name))
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textPrimary)
              .width(72)
            Column()
              .layoutWeight(c.percent <= 0 ? 1 : c.percent)
              .height(8)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(4)
            Column()
              .layoutWeight(c.percent >= 100 ? 1 : (100 - c.percent))
              .height(8)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(4)
            Text(`${c.count}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width(24)
          }
          .width('100%')
        }, (c: CategoryStat) => c.name)
      }

      Text('常读书籍 Top3')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.snap.topBooks, (b: BookRankItem) => {
        Row() {
          Text(b.bookName)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
            .maxLines(1)
          Text(`${b.count} 条`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
      }, (b: BookRankItem) => `${b.bookName}_${b.count}`)
    }
    .width('100%')
  }

  @Builder
  StatBox(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(12)
  }
}
