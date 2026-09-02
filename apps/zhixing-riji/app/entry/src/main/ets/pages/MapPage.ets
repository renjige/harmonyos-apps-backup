import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { FootprintItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalMedia } from '../services/JournalMedia'
import { AuthService } from '../services/AuthService'

@Component
export struct MapPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onRequireAuth: () => void = () => {}
  @State footprints: FootprintItem[] = []
  @State routeCount: number = 0
  @State loading: boolean = true
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (!AuthService.isLoggedIn()) {
      this.footprints = []
      this.routeCount = 0
      this.loading = false
      return
    }
    const data = await JournalBizService.loadFootprints(this.currentUsername)
    this.footprints = data.list ?? []
    this.routeCount = data.routeCount ?? this.footprints.length
    this.loading = false
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        AppHeader({ title: '旅行地图', subtitle: '足迹标记 · 路线连线 · 点击预览日记摘要' })

        if (!AuthService.isLoggedIn()) {
          AppEmpty({
            title: '登录后查看足迹',
            description: '足迹由你创建的旅程与目的地自动生成；新用户首次进入暂无个人足迹数据',
            actionLabel: '去登录',
            onAction: (): void => { this.onRequireAuth() }
          })
        } else {
          Row({ space: Theme.space.s3 }) {
            Column({ space: 4 }) {
              Text(`${this.routeCount}`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Text('足迹城市')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
            .border({ width: 1, color: Theme.colors().strokeHairline })

            Column({ space: 4 }) {
              Text(`${this.footprints.length}`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().success)
              Text('路线节点')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
            .border({ width: 1, color: Theme.colors().strokeHairline })
          }
          .width('100%')

          Stack({ alignContent: Alignment.Center }) {
            Image($r('app.media.map_journey_bg'))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column()
              .width('100%')
              .height(180)
              .linearGradient({
                angle: 180,
                colors: [['rgba(44,62,107,0.05)', 0], ['rgba(44,62,107,0.55)', 1]]
              })
              .borderRadius(Theme.radius.xl)
            Column({ space: Theme.space.s2 }) {
              AppIcon({ name: 'location', iconSize: Theme.icon.xl, color: Theme.colors().brandPrimary })
              Text('我的旅行路线')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textOnInverse)
              Text(`${this.routeCount} 座城市 · ${this.footprints.length} 个节点`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textOnInverse)
            }
          }
          .width('100%')

          if (this.loading) {
            AppLoading({ variant: 'skeleton' })
          } else if (this.footprints.length === 0) {
            AppEmpty({
              title: '暂无足迹',
              description: '创建旅程并填写目的地（如「云南·大理」），足迹将在此展示',
              actionLabel: '',
              onAction: (): void => {}
            })
          } else {
            Column({ space: Theme.space.s3 }) {
              Text('我的城市记录')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.footprints, (fp: FootprintItem, index: number) => {
                Row({ space: Theme.space.s3 }) {
                  Column() {
                    Column()
                      .width(10)
                      .height(10)
                      .borderRadius(Theme.radius.pill)
                      .backgroundColor(index === 0 ? Theme.colors().brandPrimary : Theme.colors().brandAccent)
                    if (index < this.footprints.length - 1) {
                      Column()
                        .width(2)
                        .height(48)
                        .backgroundColor(Theme.colors().strokeStrong)
                    }
                  }
                  .alignItems(HorizontalAlign.Center)
                  if (fp.coverKey.length > 0) {
                    Image(JournalMedia.coverMedia(fp.coverKey))
                      .width(72)
                      .height(72)
                      .borderRadius(Theme.radius.lg)
                      .objectFit(ImageFit.Cover)
                  }
                  Column({ space: 4 }) {
                    Text(fp.city)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .width('100%')
                    Text(`最近 ${fp.lastDate} · ${fp.count} 条记录`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.colors().strokeHairline })
              }, (fp: FootprintItem) => fp.city)
            }
            .width('100%')
          }
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
  }
}
