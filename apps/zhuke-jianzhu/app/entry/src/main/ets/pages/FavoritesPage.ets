import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { UserPrefsService } from '../services/UserPrefsService'
import { BrowseRecord } from '../models/ZhukeModels'
import { AppEmpty } from '../components/design-system/AppEmpty'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: BrowseRecord[] = []
  onBack: () => void = () => {}
  onOpenItem: (type: string, id: string) => void = (_type: string, _id: string) => {}

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.items = UserPrefsService.favorites()
  }

  private removeItem(type: string, id: string): void {
    UserPrefsService.removeFavorite(type, id)
    this.reload()
  }

  build() {
    Column() {
      AppNavBar({ title: '我的收藏', onBack: () => this.onBack() })

      if (this.items.length === 0) {
        AppEmpty({ title: '暂无收藏内容', description: '浏览工程案例或资讯时可收藏' }).layoutWeight(1)
      } else {
        Scroll() {
          Column() {
            ForEach(this.items, (r: BrowseRecord, index: number) => {
              Column() {
                Row() {
                  Column({ space: Theme.space.s1 }) {
                    Text(r.title)
                      .fontSize(Theme.type.body)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .width('100%')
                    Text(r.type === 'project' ? '工程案例' : '新闻资讯')
                      .fontSize(Theme.type.footnote)
                      .fontColor(Theme.colors().textTertiary)
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .onClick(() => this.onOpenItem(r.type, r.id))

                  Text('取消收藏')
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().danger)
                    .padding({ left: Theme.space.s2, top: Theme.space.s2, bottom: Theme.space.s2 })
                    .onClick(() => this.removeItem(r.type, r.id))
                }
                .width('100%')
                .padding({ top: Theme.space.s3, bottom: Theme.space.s3 })
                .alignItems(VerticalAlign.Center)

                if (index < this.items.length - 1) {
                  Divider()
                    .color(Theme.colors().strokeHairline)
                    .strokeWidth(1)
                }
              }
              .width('100%')
            }, (r: BrowseRecord) => `${r.type}:${r.id}`)
          }
          .padding({ left: Theme.space.s3, right: Theme.space.s3 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .margin({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s8
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
