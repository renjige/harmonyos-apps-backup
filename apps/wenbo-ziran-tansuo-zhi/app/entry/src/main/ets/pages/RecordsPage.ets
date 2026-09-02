import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecordTimelineCard } from '../components/nq/RecordTimelineCard'
import { ExploreRecord } from '../models/ExploreRecordModels'
import { ExploreRecordStore } from '../services/ExploreRecordStore'
import { NqDetailNav } from '../services/NqDetailNav'
import { NqMedia } from '../services/NqMedia'

@Component
export struct RecordsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @StorageLink('recordRefreshToken') @Watch('onRecordRefresh') recordRefreshToken: number = 0
  @State items: ExploreRecord[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  onRecordRefresh(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await ExploreRecordStore.loadAll()
    this.loading = false
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        AppHeader({ title: '探索记录', subtitle: '本机保存，随时回顾' })

        if (this.loading) {
          Scroll() {
            Column() {
              AppLoading({ label: '读取记录' })
            }
            .width('100%')
            .padding({ top: Theme.space.s6, bottom: Theme.space.s10 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        } else if (this.items.length === 0) {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Image(NqMedia.resource('empty_trail'))
                .width('100%')
                .height(160)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              AppEmpty({
                title: '还没有探索记录',
                description: '点击右下角按钮，记录你的第一次自然探索。',
                actionLabel: '写第一条',
                onAction: (): void => NqDetailNav.openRecordEditor('')
              })
            }
            .width('100%')
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              top: Theme.space.s3,
              bottom: Theme.space.s10 + 72
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        } else {
          List() {
            ForEach(this.items, (r: ExploreRecord) => {
              ListItem() {
                RecordTimelineCard({
                  item: r,
                  onTap: (): void => NqDetailNav.openRecord(r.id)
                })
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s3
              })
            }, (r: ExploreRecord) => r.id)
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .padding({ top: Theme.space.s3, bottom: Theme.space.s10 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.pill)
      .shadow({ radius: 12, color: 'rgba(45,90,39,0.28)', offsetY: 4 })
      .margin({ right: Theme.space.pageX, bottom: Theme.space.s8 })
      .onClick(() => NqDetailNav.openRecordEditor(''))
    }
    .width('100%')
    .height('100%')
  }
}
