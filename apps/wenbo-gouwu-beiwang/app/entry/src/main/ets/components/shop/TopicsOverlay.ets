import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppButton } from '../design-system/AppButton'
import { ListMiniCard } from './ShoppingCards'
import { ProcurementTopic } from '../../models/ShoppingModels'
import { GrowthService } from '../../services/GrowthService'

@Component
export struct TopicsOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State topics: ProcurementTopic[] = []
  @State newTitle: string = ''
  @Prop @Watch('onTick') refreshToken: number = 0
  onClose: () => void = () => {}
  onOpenTopic: (id: string) => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private reload(): void {
    this.topics = GrowthService.topics()
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('采购主题')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: 12 }) {
          Text('把多份清单、备忘归到同一主题，例如「宝宝辅食」「周末大采购」。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.paint(this.themeEpoch).textSecondary)
            .width('100%')
          Row({ space: 8 }) {
            TextInput({ text: this.newTitle, placeholder: '新主题名称' })
              .layoutWeight(1)
              .height(44)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.lg)
              .padding({ left: 12, right: 12 })
              .onChange((v: string) => { this.newTitle = v })
            AppButton({
              label: '创建',
              onTap: (): void => {
                const title = this.newTitle.trim()
                if (title.length === 0) {
                  return
                }
                void GrowthService.createTopic(title, 'tpl_family').then(() => {
                  this.newTitle = ''
                  this.reload()
                  this.onChanged()
                })
              }
            })
          }
          .width('100%')

          if (this.topics.length === 0) {
            AppEmpty({
              title: '还没有采购主题',
              description: '创建主题后，可在主题详情里关联清单'
            })
          } else {
            Grid() {
              ForEach(this.topics, (row: ProcurementTopic) => {
                GridItem() {
                  ListMiniCard({
                    title: row.title,
                    meta: `${row.listIds.length} 份清单`,
                    coverKey: row.coverKey,
                    onTap: (): void => { this.onOpenTopic(row.id) }
                  })
                }
              }, (row: ProcurementTopic) => row.id)
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(12)
            .rowsGap(12)
            .width('100%')
          }
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
