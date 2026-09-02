import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { InspectListCard } from './InspectListCard'
import { InspectRecord } from '../../models/InspectModels'
import { InspectService } from '../../services/InspectService'
import { InspectNav } from '../../services/InspectNav'

@Component
export struct FollowListOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('inspectTick') @Watch('onDataTick') inspectTick: number = 0
  @State items: InspectRecord[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onDataTick(): void {
    this.reload()
  }

  private reload(): void {
    this.items = []
    this.items = InspectService.pendingFollow()
  }

  build() {
    Column() {
      Row() {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            .rotate({ angle: 180 })
          Text('返回')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .margin({ left: 2 })
        }
        .height(44)
        .onClick(() => InspectNav.closeExtra())
        Text('异常跟进')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(56)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

      Text('不通过或待处理的记录会列在这里，可写整改说明并关闭跟进。')
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })

      if (this.items.length === 0) {
        Column() {
          AppEmpty({
            title: '暂无待跟进',
            description: '验收不通过或待处理后，会出现在此清单。',
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
                stamp: `${item.id}_${item.updatedAt}`,
                onTap: () => InspectNav.openFollow(item.id)
              })
            }
          }, (item: InspectRecord) => `${item.id}_${item.updatedAt}`)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        .scrollBar(BarState.Off)
      }

      if (this.items.length > 0) {
        Column() {
          AppButton({
            label: '返回',
            variant: 'secondary',
            onTap: (): void => InspectNav.closeExtra()
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
