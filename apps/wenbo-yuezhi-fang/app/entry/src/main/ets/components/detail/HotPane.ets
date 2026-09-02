import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { ContentCard } from '../ContentCard'
import { CardItem } from '../../models/AtelierModels'
import { AtelierBizService } from '../../services/AtelierBizService'
import { AtelierDetailNav } from '../../services/AtelierDetailNav'

@Component
export struct HotPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: CardItem[] = AtelierBizService.packCards()
  @State period: string = 'week'

  aboutToAppear(): void {
    this.items = AtelierBizService.packCards()
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await AtelierBizService.loadHot(this.period)
  }

  private selectPeriod(p: string): void {
    this.period = p
    void this.reload()
  }

  private openItem(row: CardItem): void {
    AtelierDetailNav.openCard(row.id)
  }

  build() {
    DetailShell({
      title: '工坊精选',
      onClose: (): void => { AtelierDetailNav.close() }
    }) {
      Column({ space: Theme.space.s3 }) {
        Row({ space: 8 }) {
          Text('本周')
            .fontSize(13)
            .fontColor(this.period === 'week' ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.period === 'week' ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
            .borderRadius(8)
            .onClick((): void => { this.selectPeriod('week') })
          Text('本月')
            .fontSize(13)
            .fontColor(this.period === 'month' ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.period === 'month' ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
            .borderRadius(8)
            .onClick((): void => { this.selectPeriod('month') })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.items.length === 0) {
          AppEmpty({
            title: '精选暂时为空',
            description: '发现页的官方知识卡会按工坊收录到这里。',
            actionLabel: '重新加载',
            onAction: (): void => { void this.reload() }
          })
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.items, (row: CardItem) => {
                ContentCard({
                  item: row,
                  onOpen: (): void => { this.openItem(row) }
                })
              }, (row: CardItem) => row.id)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
  }
}
