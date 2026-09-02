import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { MomentNote, TagStat, WeekCompare, DailyWrap } from '../../models/MomentModels'
import { DateHelper } from '../../services/DateHelper'
import { MomentStore } from '../../services/MomentStore'
import { MomentNav } from '../../services/MomentNav'
import { NoteCardBinder } from './NoteCard'

@Component
export struct InsightPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  onChanged: () => void = () => {}
  @State compare: WeekCompare = new WeekCompare()
  @State stars: MomentNote[] = []
  @State tags: TagStat[] = []
  @State wrap: DailyWrap = new DailyWrap()

  aboutToAppear(): void {
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.compare = await MomentStore.weekCompare()
    this.stars = await MomentStore.starredNotes()
    this.tags = await MomentStore.tagStats()
    this.wrap = await MomentStore.loadDailyWrap(DateHelper.todayKey())
  }

  build() {
    DetailShell({
      title: '生活见解',
      onClose: (): void => MomentNav.close()
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(this.compare.line)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .lineHeight(22)
            .width('100%')
            .padding(14)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(16)

          Row({ space: Theme.space.s3 }) {
            this.StatCell(`${this.compare.thisNotes}`, '本周小事')
            this.StatCell(`${this.compare.lastNotes}`, '上周小事')
            this.StatCell(`${this.compare.starCount}`, '星标')
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text(this.wrap.filled() ? `今日收束 · ${this.wrap.mood.length > 0 ? this.wrap.mood : '已写'}` : '今日还没收束')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.wrap.filled() ? this.wrap.preview() : '睡前三分钟，把今天收成一句')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: this.wrap.filled() ? '改今日收束' : '写今日收束',
              variant: 'secondary',
              onTap: (): void => MomentNav.openDailyWrap()
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(14)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(16)

          Text('星标精选')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.stars.length === 0) {
            AppEmpty({
              title: '还没有星标',
              description: '在小事见解里点星标，重要片段会集中到这里'
            })
          } else {
            ForEach(this.stars, (n: MomentNote) => {
              Column({ space: 4 }) {
                Text(n.preview())
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                Text(`${NoteCardBinder.tagsText(n)}  ${DateHelper.displayDate(n.dateKey)}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding(12)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(12)
              .onClick((): void => MomentNav.openNote(n.id))
            }, (n: MomentNote) => `${n.id}_${n.updatedAt}`)
          }

          if (this.tags.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text('标签分布')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.tags, (s: TagStat) => {
                Row() {
                  Text(`#${s.label}`)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(s.color)
                  Blank()
                  Text(`${s.count}`)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().textSecondary)
                }
                .width('100%')
              }, (s: TagStat) => s.label)
            }
            .width('100%')
            .padding(14)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(16)
          }

          AppButton({
            label: '写本周复盘',
            variant: 'secondary',
            onTap: (): void => MomentNav.openWeeklyReview()
          })
          Row().height(Theme.space.s10)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
      }
      .width('100%')
      .layoutWeight(1)
    }
  }

  @Builder
  StatCell(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(16)
  }
}
