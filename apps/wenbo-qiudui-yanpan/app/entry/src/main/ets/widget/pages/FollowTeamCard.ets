const STORAGE = new LocalStorage()

@Entry(STORAGE)
@Component
struct FollowTeamCard {
  @LocalStorageProp('title') title: string = '球队研判'
  @LocalStorageProp('count') count: string = '0'
  @LocalStorageProp('preview') preview: string = '尚未关注球队'
  @LocalStorageProp('status') status: string = '关注后，卡片将显示近期状态'

  build() {
    FormLink({
      action: 'router',
      bundleName: 'qdyp.wxy.huawei',
      moduleName: 'entry',
      abilityName: 'EntryAbility'
    }) {
      Column({ space: 6 }) {
        Row() {
          Text(this.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#F8FAFC')
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.count === '0' ? '未关注' : `关注 ${this.count}`)
            .fontSize(12)
            .fontColor('#67E8F9')
        }
        .width('100%')
        Text(this.preview)
          .fontSize(13)
          .fontColor('#E2E8F0')
          .maxLines(2)
        Text(this.status)
          .fontSize(12)
          .fontColor('#94A3B8')
          .maxLines(2)
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .linearGradient({ angle: 135, colors: [['#0F172A', 0], ['#0E7490', 1]] })
      .borderRadius(16)
    }
  }
}
