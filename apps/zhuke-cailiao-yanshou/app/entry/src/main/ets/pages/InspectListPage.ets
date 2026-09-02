import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { FilterChips } from '../components/inspect/FilterChips'
import { InspectListCard } from '../components/inspect/InspectListCard'
import { InspectRecord } from '../models/InspectModels'
import { InspectService } from '../services/InspectService'
import { InspectNav } from '../services/InspectNav'

@Component
export struct InspectListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('inspectTick') @Watch('onTick') inspectTick: number = 0
  @Prop refreshToken: number = 0
  @State keyword: string = ''
  @State filter: string = 'all'
  @State items: InspectRecord[] = []
  @State showSearch: boolean = false

  aboutToAppear(): void {
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private reload(): void {
    this.items = []
    this.items = InspectService.search(this.keyword, this.filter, true)
  }

  build() {
    Column() {
      Row() {
        Text('材料验收')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => { this.showSearch = !this.showSearch })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX - 8,
        top: Theme.space.pageY,
        bottom: 8
      })

      if (this.showSearch) {
        TextInput({ text: this.keyword, placeholder: '搜索材料名称 / 供应商' })
          .height(44)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(12)
          .onChange((v: string) => {
            this.keyword = v
            this.reload()
          })
      }

      Scroll() {
        FilterChips({
          current: this.filter,
          inspectMode: true,
          onChange: (key: string) => {
            this.filter = key
            this.reload()
          }
        })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })

      if (this.items.length === 0) {
        Column() {
          AppEmpty({
            title: '还没有验收记录',
            description: '开始一次材料验收，让现场记录更清晰。',
            actionLabel: '开始验收',
            onAction: () => InspectNav.openCreate()
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.items, (item: InspectRecord) => {
            ListItem() {
              InspectListCard({
                item: item,
                stamp: `${item.updatedAt}_${item.result}`,
                onTap: () => InspectNav.openDetail(item.id)
              })
            }
          }, (item: InspectRecord) => `${item.id}_${item.updatedAt}_${item.result}`)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .scrollBar(BarState.Off)
      }

      Column() {
        Text('开始材料验收')
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandOnPrimary)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 16, bottom: 16 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(14)
          .onClick(() => InspectNav.openCreate())
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: 8,
        bottom: 12
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .opacity(this.refreshToken >= 0 ? 1 : 1)
  }
}
