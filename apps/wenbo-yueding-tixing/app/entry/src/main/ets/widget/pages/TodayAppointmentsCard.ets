const STORAGE = new LocalStorage()

@Entry(STORAGE)
@Component
struct TodayAppointmentsCard {
  @LocalStorageProp('title') title: string = '今日约定'
  @LocalStorageProp('summary') summary: string = '打开应用查看详情'
  @LocalStorageProp('count') count: string = '0'

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
          .layoutWeight(1)
        Text(this.count)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1677FF')
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
