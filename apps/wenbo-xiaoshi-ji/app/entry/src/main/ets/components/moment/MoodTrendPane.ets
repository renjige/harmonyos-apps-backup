import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from '../detail/DetailShell'
import { MoodDay } from '../../models/MomentModels'
import { DateHelper } from '../../services/DateHelper'
import { MomentStore } from '../../services/MomentStore'
import { MomentNav } from '../../services/MomentNav'

@Component
export struct MoodTrendPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @State days: MoodDay[] = []
  @State filled: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.days = await MomentStore.loadMoodTrend(14)
    let n = 0
    for (const d of this.days) {
      if (d.mood.length > 0) {
        n++
      }
    }
    this.filled = n
  }

  build() {
    DetailShell({
      title: '心情轨迹',
      onClose: (): void => MomentNav.close()
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(`近 14 天记下心情 ${this.filled} 天。开心、平静、充实、疲惫、低落、惊喜都会留在这里。`)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .lineHeight(22)
            .width('100%')
            .padding(14)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(16)

          ForEach(this.days, (d: MoodDay) => {
            Row({ space: Theme.space.s3 }) {
              Text(DateHelper.monthDayLabel(d.dateKey))
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width(64)
              Text(d.mood.length > 0 ? d.mood : '未记')
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(d.mood.length > 0 ? '#FFFFFF' : Theme.colors().textSecondary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(d.mood.length > 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
              Text(d.short.length > 0 ? d.short : ' ')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(12)
          }, (d: MoodDay) => d.dateKey)

          AppButton({
            label: '写下今日心情',
            onTap: (): void => MomentNav.openDailyWrap()
          })
          Row().height(Theme.space.s10)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      }
      .width('100%')
      .layoutWeight(1)
    }
  }
}
