const STORAGE = new LocalStorage()

@Entry(STORAGE)
@Component
struct TodayListCard {
  @LocalStorageProp('title') title: string = '今日家庭'
  @LocalStorageProp('progress') progress: string = '打开应用查看进度'

  build() {
    Column({ space: 8 }) {
      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')
      Text(this.progress)
        .fontSize(13)
        .fontColor('#667085')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
