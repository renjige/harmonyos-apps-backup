import { Theme } from '../design-system/Theme'

@Component
export struct YdTodayProgressCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop doneCount: number = 0
  @Prop totalCount: number = 0
  @Prop leapIndex: number = 0
  @Prop checkInToday: boolean = false
  onContinueTap: () => void = () => {}

  private percent(): number {
    if (this.totalCount <= 0) {
      return 0
    }
    return Math.floor((this.doneCount * 100) / this.totalCount)
  }

  build() {
    Row({ space: Theme.space.s5 }) {
      Stack() {
        Progress({ value: this.percent(), total: 100, type: ProgressType.Ring })
          .width(96)
          .height(96)
          .color(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .style({ strokeWidth: 8 })
        Column({ space: 2 }) {
          Text(`${this.percent()}%`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text('今日')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
      }
      Column({ space: Theme.space.s2 }) {
        Text('今日进度')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(`已完成 ${this.doneCount} / ${this.totalCount}`)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
        Text(`跃动指数 ${this.leapIndex}${this.checkInToday ? ' · 已打卡' : ''}`)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
        Row() {
          Text(this.totalCount === 0 ? '添加第一步 →' : '继续完成 →')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
        }
        .padding({ top: 6, bottom: 6, right: 8 })
        .onClick((): void => { this.onContinueTap() })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 16, color: 'rgba(10,37,64,0.06)', offsetY: 4 })
  }
}
