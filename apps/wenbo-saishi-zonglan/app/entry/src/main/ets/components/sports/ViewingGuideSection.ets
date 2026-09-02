import { Theme, ThemeColors } from '../design-system/Theme'

class ViewingTip {
  sport: string = ''
  title: string = ''
  body: string = ''

  static all(): ViewingTip[] {
    const out: ViewingTip[] = []
    const f = new ViewingTip()
    f.sport = '足球'
    f.title = '赛前 30 分钟到场'
    f.body = '关注首发名单与伤病报告；开赛前在详情页设置提醒，避免错过开球。'
    out.push(f)
    const b = new ViewingTip()
    b.sport = '篮球'
    b.title = '关注末节节奏'
    b.body = 'CBA/NBA 末节暂停较多，可查看详情赛况时间线掌握比分走势与关键球。'
    out.push(b)
    const t = new ViewingTip()
    t.sport = '网球'
    t.title = '盘间休息查数据'
    t.body = '硬地/红土节奏不同，详情页可看 Ace 球、一发成功率等统计辅助观赛。'
    out.push(t)
    const e = new ViewingTip()
    e.sport = '电竞'
    e.title = 'BP 与版本理解'
    e.body = '关注战队近期战绩与对阵历史；BO 系列建议从第一局看起掌握节奏。'
    out.push(e)
    return out
  }
}

@Component
export struct ViewingGuideSection {
  @StorageLink('themeColorMode') themeColorMode: string = 'light'
  private tips: ViewingTip[] = ViewingTip.all()

  private palette(): ThemeColors {
    return Theme.palette(this.themeColorMode === 'dark')
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Column({ space: 2 }) {
        Text('观赛百科')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.palette().textPrimary)
          .width('100%')
        Text('不同项目的观赛要点与实用建议')
          .fontSize(Theme.type.caption)
          .fontColor(this.palette().textSecondary)
          .width('100%')
      }
      .width('100%')

      ForEach(this.tips, (tip: ViewingTip) => {
        Row({ space: Theme.space.s3 }) {
          Column({ space: 4 }) {
            Text(tip.sport)
              .fontSize(Theme.type.caption)
              .fontColor(this.palette().brandPrimary)
              .fontWeight(FontWeight.Medium)
            Text(tip.title)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.palette().textPrimary)
              .width('100%')
            Text(tip.body)
              .fontSize(Theme.type.caption)
              .fontColor(this.palette().textSecondary)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.palette().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .border({ width: 1, color: this.palette().strokeHairline })
      }, (tip: ViewingTip) => tip.sport)
    }
    .width('100%')
  }
}
