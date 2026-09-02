import { Theme } from '../../components/design-system/Theme'
import { AppEmpty } from '../../components/design-system/AppEmpty'
import { SearchResultRow } from '../../models/GrowthModels'
import { GrowthService } from '../../services/GrowthService'

@Component
export struct SearchHubOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State query: string = ''
  @State results: SearchResultRow[] = []
  @State searching: boolean = false
  onClose: () => void = () => {}
  onOpenAppointment: (id: string) => void = () => {}
  onOpenPlan: (id: string) => void = () => {}

  private async runSearch(): Promise<void> {
    this.searching = true
    this.results = await GrowthService.search(this.query)
    this.searching = false
  }

  build() {
    Column() {
      Row() {
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text('搜索')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('')
          .width(40)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      TextInput({ text: this.query, placeholder: '搜索约定、计划、专题…' })
        .margin({ left: 20, right: 20, bottom: 12 })
        .onChange((v: string) => {
          this.query = v
          void this.runSearch()
        })

      if (this.searching) {
        Text('搜索中…')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .layoutWeight(1)
      } else if (this.query.trim().length === 0) {
        Column() {
          AppEmpty({
            title: '输入关键词开始搜索',
            description: '可搜索约定标题、地点、备注、计划名称'
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.results.length === 0) {
        Column() {
          AppEmpty({ title: '没有找到结果', description: '换个关键词试试' })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.results, (row: SearchResultRow) => {
              Row({ space: 8 }) {
                Column({ space: 2 }) {
                  Text(row.title)
                    .fontSize(Theme.type.subhead)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(row.meta)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => {
                if (row.kind === 'plan') {
                  this.onOpenPlan(row.id)
                } else {
                  this.onOpenAppointment(row.id)
                }
              })
            }, (row: SearchResultRow) => `${row.kind}_${row.id}`)
          }
          .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
