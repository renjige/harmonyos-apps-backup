import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { SportRecordCard } from '../components/sport/SportRecordCard'
import { SportRecord, SportStats } from '../models/SportRecord'
import { RecordStore } from '../services/RecordStore'
import { StatisticsUtil } from '../services/StatisticsUtil'
import { SportDetailNav } from '../services/SportDetailNav'

@Component
export struct TimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '运动图册'
  @Prop reloadToken: number = 0
  @State records: SportRecord[] = []
  @State stats: SportStats = new SportStats()
  @State loading: boolean = true
  @State lastToken: number = -1

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (this.reloadToken === this.lastToken && this.records.length > 0) {
      return
    }
    this.lastToken = this.reloadToken
    this.loading = true
    this.records = await RecordStore.loadAll()
    this.stats = await StatisticsUtil.computeStats()
    this.loading = false
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_home'))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column() {
              Blank()
              Column({ space: 4 }) {
                Text(this.appName)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text('我的蜕变历程')
                  .fontSize(Theme.type.bodyS)
                  .fontColor('#FFFFFF')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.72)', 1]]
              })
            }
            .width('100%')
            .height('100%')
          }
          .width('100%')
          .height(200)

          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '累计次数', value: `${this.stats.totalCount}` }).layoutWeight(1)
            AppStatCard({ label: '总时长', value: `${this.stats.totalMinutes}` }).layoutWeight(1)
            AppStatCard({ label: '照片数', value: `${this.stats.totalPhotos}` }).layoutWeight(1)
          }
          .width('100%')

          Text(`本月已运动 ${this.stats.monthCount} 天`)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')

          Text('时光轴')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          if (this.loading) {
            Text('加载中…')
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          } else if (this.records.length === 0) {
            Column({ space: Theme.space.s3 }) {
              Image($r('app.media.empty_timeline'))
                .width('72%')
                .aspectRatio(1)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              AppEmpty({
                title: '还没有运动记录',
                description: '去「记录」页添加第一条蜕变瞬间',
                actionLabel: '',
                onAction: (): void => {}
              })
            }
            .width('100%')
          } else {
            Column({ space: Theme.space.s4 }) {
              ForEach(this.records, (item: SportRecord) => {
                SportRecordCard({
                  record: item,
                  onTap: (): void => { SportDetailNav.openDetail(item.id) }
                })
              }, (item: SportRecord) => item.id)
            }
            .width('100%')
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .onVisibleAreaChange([0.0, 1.0], (_expanding: boolean, ratio: number): void => {
      if (ratio > 0) {
        void this.reload()
      }
    })
  }
}
