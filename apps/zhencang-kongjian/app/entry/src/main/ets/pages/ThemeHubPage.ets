import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { DomainBucket, TreasureAlbum } from '../models/TreasureModels'
import { TreasureNav } from '../services/TreasureNav'
import { TreasureStore } from '../services/TreasureStore'

@Component
export struct ThemeHubPage {
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @State albums: TreasureAlbum[] = []
  @State domains: DomainBucket[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefresh(): void {
    this.reload()
  }

  private reload(): void {
    this.albums = TreasureStore.albums()
    this.domains = TreasureStore.domainBuckets()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s6 }) {
        Row() {
          Column({ space: Theme.space.s1 }) {
            Text('主题空间').fontSize(Theme.type.title2).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textPrimary)
            Text('用主题册与收藏领域整理你的珍藏').fontSize(Theme.type.subhead).fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          AppButton({ label: '创建', variant: 'primary', onTap: (): void => { TreasureNav.openSubPage('albumEditor') } })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        Text('收藏领域').fontSize(Theme.type.title3).fontColor(Theme.colors().textPrimary).padding({ left: Theme.space.pageX })
        GridRow({ columns: 2, gutter: Theme.space.s3 }) {
          ForEach(this.domains, (d: DomainBucket) => {
            GridCol({ span: 1 }) {
              Column({ space: Theme.space.s2 }) {
                Text(d.label).fontSize(Theme.type.title3).fontColor(Theme.colors().textOnInverse)
                Text(`${d.count} 件`).fontSize(Theme.type.caption).fontColor(Theme.colors().textOnInverse)
              }
              .width('100%')
              .height(88)
              .padding(Theme.space.s4)
              .borderRadius(Theme.radius.lg)
              .backgroundColor(d.tone)
              .justifyContent(FlexAlign.End)
              .alignItems(HorizontalAlign.Start)
              .onClick((): void => { TreasureNav.openDomainArchive(d.key) })
            }
          }, (d: DomainBucket) => d.key)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Text('我的主题册').fontSize(Theme.type.title3).fontColor(Theme.colors().textPrimary).padding({ left: Theme.space.pageX })
        ForEach(this.albums, (a: TreasureAlbum) => {
          Column({ space: Theme.space.s2 }) {
            Text(a.name).fontSize(Theme.type.title3).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary)
            Text(a.intro.length > 0 ? a.intro : '暂无简介').fontSize(Theme.type.subhead).fontColor(Theme.colors().textSecondary)
            Text(`${a.itemIds.length} 件 · ${TreasureStore.dateLabel(a.createdAt)}`).fontSize(Theme.type.caption).fontColor(Theme.colors().brandPrimary)
          }
          .width('100%')
          .padding(Theme.space.s5)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .onClick((): void => { TreasureNav.openAlbumDetail(a.id) })
        }, (a: TreasureAlbum) => a.id)

        if (this.albums.length === 0) {
          Text('还没有主题册，创建第一个主题开始整理').fontColor(Theme.colors().textSecondary).padding({ left: Theme.space.pageX })
        }
      }
      .padding({ bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
