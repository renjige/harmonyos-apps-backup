const STORAGE = new LocalStorage()

@Entry(STORAGE)
@Component
struct TodayListCard {
  @LocalStorageProp('title') title: string = '购物备忘'
  @LocalStorageProp('progress') progress: string = '打开应用查看进度'
  @LocalStorageProp('remain') remain: string = ''
  @LocalStorageProp('preview') preview: string = ''

  build() {
    FormLink({
      action: 'router',
      bundleName: 'gwbw.wxy.huawei',
      moduleName: 'entry',
      abilityName: 'EntryAbility'
    }) {
      Column({ space: 8 }) {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
          .maxLines(1)
        Text(this.progress)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1677FF')
        if (this.remain.length > 0) {
          Text(this.remain)
            .fontSize(12)
            .fontColor('#667085')
        }
        Text(this.preview.length > 0 ? this.preview : '点此打开购物备忘')
          .fontSize(12)
          .fontColor('#667085')
          .maxLines(2)
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
    }
  }
}
