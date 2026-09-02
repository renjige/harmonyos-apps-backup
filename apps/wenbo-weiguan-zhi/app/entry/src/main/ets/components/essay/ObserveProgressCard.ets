import { Theme } from '../design-system/Theme'

/** 今日观察进度卡 — @Prop 保证专题进度条随数据刷新 */
@Component
export struct ObserveProgressCard {
  @Prop todayDone: boolean = false
  @Prop themeTitle: string = ''
  @Prop themeLine: string = ''
  @Prop themePct: number = 0
  onWrite: () => void = () => {}

  build() {
    Column({ space: 8 }) {
      Text('今日观察')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandAccent)
        .width('100%')
      Text(this.todayDone ? '今天已经写下观察' : '今天还没有写下观察')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      if (this.themeTitle.length > 0) {
        Text(this.themeTitle)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Row() {
          Column()
            .height(8)
            .width(`${this.themePct}%`)
            .backgroundColor('#1A2A3A')
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .height(8)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        Text(`${this.themeLine} · 完成度 ${this.themePct}%`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      Text(this.todayDone ? '再写一篇加深' : '用观察卡写下')
        .fontSize(Theme.type.bodyS)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding({ top: 10, bottom: 10 })
        .backgroundColor('#1A2A3A')
        .borderRadius(Theme.radius.sm)
        .onClick((): void => { this.onWrite() })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
