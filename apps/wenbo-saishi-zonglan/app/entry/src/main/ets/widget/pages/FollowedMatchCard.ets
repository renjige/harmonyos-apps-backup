const STORAGE = new LocalStorage()

@Entry(STORAGE)
@Component
struct FollowedMatchCard {
  @LocalStorageProp('title') title: string = '关注比赛'
  @LocalStorageProp('summary') summary: string = '打开赛事纵览查看详情'
  @LocalStorageProp('count') count: string = '0'

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F8FAFC')
          .layoutWeight(1)
        Text(this.count)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1677FF')
      }
      .width('100%')
      Text(this.summary)
        .fontSize(13)
        .fontColor('#94A3B8')
        .maxLines(2)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#0F172A')
    .borderRadius(20)
  }
}
