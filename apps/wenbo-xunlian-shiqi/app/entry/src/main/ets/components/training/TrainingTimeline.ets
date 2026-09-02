import { Theme } from '../design-system/Theme'
import { TrainingListCard } from './TrainingListCard'
import { TrainingRecord } from '../../models/TrainingModels'
import { TrainingStore } from '../../services/TrainingStore'
import { TrainingDetailNav } from '../../services/TrainingDetailNav'
import { AppEmpty } from '../design-system/AppEmpty'

@Component
export struct TrainingTimeline {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @State dates: string[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onEpoch(): void {
    this.reload()
  }

  private reload(): void {
    const raw = TrainingStore.datesWithRecords()
    raw.sort((a: string, b: string) => b.localeCompare(a))
    this.dates = raw
  }

  private recordsOf(key: string): TrainingRecord[] {
    return TrainingStore.byDate(key)
  }

  build() {
    if (this.dates.length === 0) {
      AppEmpty({
        title: '时间轴还是空的',
        description: '保存训练后，会按日期排成成长轨迹'
      })
    } else {
      Column({ space: Theme.space.s5 }) {
        ForEach(this.dates, (key: string) => {
          Column({ space: Theme.space.s3 }) {
            Text(key)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.recordsOf(key), (item: TrainingRecord) => {
              TrainingListCard({
                record: item,
                onTap: (): void => { TrainingDetailNav.open(item.id) }
              })
            }, (item: TrainingRecord) => item.id)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }, (key: string) => key)
      }
      .width('100%')
    }
  }
}
