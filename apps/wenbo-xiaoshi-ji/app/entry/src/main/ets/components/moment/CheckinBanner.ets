import { Theme } from '../design-system/Theme'

@Component
export struct CheckinBanner {
  @Prop streak: number = 0
  @Prop todayDone: boolean = false
  @Prop mood: string = ''
  onRecord: () => void = () => {}
  onBoard: () => void = () => {}

  private statusLine(): string {
    if (this.todayDone) {
      return this.mood.length > 0 ? `今日已打卡 · 心情 ${this.mood}` : '今日已打卡，生活轨迹又连了一天'
    }
    return '今天还没记下小事，打开就能打卡'
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(this.todayDone ? '今日已打卡' : '每日记录打卡')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(this.statusLine())
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Column({ space: 2 }) {
        Text(`${this.streak}`)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
        Text('连续天')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .width(56)
      .onClick((): void => this.onBoard())
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(16)
    .onClick((): void => {
      if (this.todayDone) {
        this.onBoard()
      } else {
        this.onRecord()
      }
    })
  }
}
