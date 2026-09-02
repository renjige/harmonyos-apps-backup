import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { DetailShell } from '../components/detail/DetailShell'
import { ExploreRecord } from '../models/ExploreRecordModels'
import { ExploreRecordStore } from '../services/ExploreRecordStore'
import { NqDetailNav } from '../services/NqDetailNav'

@Component
export struct FootprintMapPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: ExploreRecord[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await ExploreRecordStore.recordsWithCoords()
    this.loading = false
  }

  build() {
    DetailShell({ title: '足迹地图', onClose: () => NqDetailNav.close() }) {
      Column({ space: Theme.space.s4 }) {
        if (this.loading) {
          AppLoading({ label: '加载足迹' })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '还没有可标注的位置',
            description: '在探索记录中填写地点或坐标后，会出现在这里。'
          })
        } else {
          Column({ space: Theme.space.s2 }) {
            Text('地图预览')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Stack({ alignContent: Alignment.Center }) {
              Column()
                .width('100%')
                .height(180)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.lg)
              Column({ space: Theme.space.s2 }) {
                ForEach(this.items, (r: ExploreRecord, idx: number) => {
                  Row({ space: Theme.space.s2 }) {
                    Column()
                      .width(10)
                      .height(10)
                      .backgroundColor(Theme.colors().brandPrimary)
                      .borderRadius(Theme.radius.pill)
                    Text(r.location.length > 0 ? r.location : r.title)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandDeep)
                  }
                }, (r: ExploreRecord, idx: number) => `m-${r.id}`)
              }
              .padding(Theme.space.s4)
            }
            .width('100%')
            .height(180)
          }
          .width('100%')

          Text('位置列表')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          ForEach(this.items, (r: ExploreRecord) => {
            Row({ space: Theme.space.s3 }) {
              Column({ space: 4 }) {
                Text(r.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(r.location.length > 0 ? r.location : '未填地点')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                if (r.lat !== 0 || r.lng !== 0) {
                  Text(`${r.lat.toFixed(4)}, ${r.lng.toFixed(4)}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .width('100%')
                }
              }
              .layoutWeight(1)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick(() => NqDetailNav.openRecord(r.id))
          }, (r: ExploreRecord) => r.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
