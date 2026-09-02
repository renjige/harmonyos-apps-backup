const STORAGE = new LocalStorage()

@Entry(STORAGE)
@Component
struct FollowStarCard {
  @LocalStorageProp('title') title: string = '我的关注'
  @LocalStorageProp('summary') summary: string = '打开应用查看关注球星与赛事'
  @LocalStorageProp('count') count: string = '0'

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0F172A')
          .layoutWeight(1)
        Text(this.count)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#0EA5E9')
      }
      .width('100%')
      Text(this.summary)
        .fontSize(13)
        .fontColor('#475569')
        .maxLines(2)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
