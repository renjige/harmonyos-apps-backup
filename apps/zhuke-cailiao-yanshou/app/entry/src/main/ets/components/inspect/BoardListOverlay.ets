import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { InspectListCard } from './InspectListCard'
import { InspectRecord } from '../../models/InspectModels'
import { InspectService } from '../../services/InspectService'
import { InspectNav } from '../../services/InspectNav'

@Component
export struct BoardListOverlay {
  @Prop mode: string = ''
  @Prop boardKey: string = ''
  @StorageLink('inspectTick') @Watch('onDataTick') inspectTick: number = 0
  @State title: string = ''
  @State items: InspectRecord[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onDataTick(): void {
    this.reload()
  }

  private reload(): void {
    this.title = InspectService.boardTitle(this.mode, this.boardKey)
    this.items = []
    this.items = InspectService.boardList(this.mode, this.boardKey)
  }

  build() {
    Column() {
      Row() {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            .rotate({ angle: 180 })
          Text('返回')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .margin({ left: 2 })
        }
        .height(44)
        .onClick(() => InspectNav.closeExtra())
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(56)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

      if (this.items.length === 0) {
        Column() {
          AppEmpty({
            title: '暂无相关记录',
            description: '完成一次验收后，这里会显示对应清单。',
            actionLabel: '开始验收',
            onAction: () => {
              InspectNav.closeExtra()
              InspectNav.openCreate()
            }
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
                stamp: `${item.id}_${item.updatedAt}_${this.inspectTick}`,
                onTap: () => {
                  InspectNav.closeExtra()
                  InspectNav.openDetail(item.id)
                }
              })
            }
          }, (item: InspectRecord) => `${item.id}_${item.updatedAt}_${this.inspectTick}`)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        .scrollBar(BarState.Off)
      }

      Column() {
        AppButton({
          label: '新建验收',
          onTap: (): void => {
            InspectNav.closeExtra()
            InspectNav.openCreate()
          }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
