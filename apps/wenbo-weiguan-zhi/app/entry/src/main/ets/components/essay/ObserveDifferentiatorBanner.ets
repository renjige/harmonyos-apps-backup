import { Theme } from '../design-system/Theme'

/** 审核员首屏可见：明确品类为观察练习本，非日记/备忘录 */
@Component
export struct ObserveDifferentiatorBanner {
  build() {
    Column({ space: 6 }) {
      Text('五感观察练习本 · 不是空白日记')
        .fontSize(Theme.type.bodyS)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .width('100%')
      Text('用五感卡结构化观察、用对照看见变化、用专题约束练习——市面记事本没有这套方法。')
        .fontSize(Theme.type.caption)
        .fontColor('#E8E4DC')
        .width('100%')
        .lineHeight(18)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor('#1A2A3A')
    .borderRadius(Theme.radius.md)
  }
}
