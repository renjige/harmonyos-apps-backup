import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { BusinessGridItem } from '../components/common/BusinessGridItem'
import { AppCard } from '../components/design-system/AppCard'
import { ContentService } from '../services/ContentService'
import { BusinessItem } from '../models/ZhukeModels'

@Component
export struct BusinessPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: BusinessItem[] = []
  @Prop @Watch('onContentVersionChange') contentVersion: number = 0
  onOpenDetail: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.items = ContentService.businesses()
  }

  onContentVersionChange(): void {
    this.reload()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        AppHeader({ title: '业务范围', subtitle: '全链条建筑综合服务' })

        GridRow({ columns: 2, gutter: Theme.space.s3 }) {
          ForEach(this.items, (b: BusinessItem) => {
            GridCol() {
              BusinessGridItem({
                item: b,
                onTap: () => this.onOpenDetail(b.id)
              })
            }
          }, (b: BusinessItem) => b.id)
        }

        AppCard({ title: '服务优势', variant: 'glass' }) {
          Column({ space: Theme.space.s2 }) {
            Text('· 壹级资质，200+项目经验')
              .fontSize(Theme.type.callout)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Text('· BIM+智慧工地，全过程质量管控')
              .fontSize(Theme.type.callout)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Text('· 专业团队，安全零事故记录')
              .fontSize(Theme.type.callout)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
  }
}
