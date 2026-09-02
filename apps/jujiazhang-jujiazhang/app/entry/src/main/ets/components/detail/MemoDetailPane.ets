import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { FamilyMemo } from '../../models/JujiaModels'
import { TaskMedia } from '../../services/TaskMedia'

@Component
export struct MemoDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: FamilyMemo = new FamilyMemo()
  onEdit: () => void = () => {}
  onDelete: () => void = () => {}
  onClose: () => void = () => {}

  private triggerEdit(): void {
    this.onEdit()
  }

  private triggerDelete(): void {
    this.onDelete()
  }

  build() {
    Column() {
      Row() {
        Row({ space: 6 }) {
          AppIcon({ name: 'chevron', iconSize: 18, color: Theme.colors().textPrimary })
            .rotate({ angle: 180 })
          Text('返回')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.button)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .onClick(() => this.onClose())
        Blank()
        Row({ space: 6 }) {
          AppIcon({ name: 'edit', iconSize: 18, color: Theme.colors().textPrimary })
          Text('编辑')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.button)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .onClick(() => this.triggerEdit())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Scroll() {
        Column() {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(TaskMedia.cover(this.item.coverKey()))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
            Column() {
              Text(this.item.tag)
                .fontSize(Theme.type.caption)
                .fontColor('#FFF8F5')
              Text(this.item.title)
                .fontSize(Theme.type.titleM)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFF8F5')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 20, right: 20, bottom: 20, top: 48 })
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,58,92,0)', 0], ['rgba(26,58,92,0.85)', 1]]
            })
          }
          .width('100%')
          .clip(true)

          Column({ space: 8 }) {
            Text('备忘内容')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(this.item.body.length > 0 ? this.item.body : '写下家人共享的清单或计划。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .margin({ left: 16, right: 16, top: 16 })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Column({ space: 10 }) {
        Row() {
          AppButton({
            label: '编辑备忘',
            variant: 'primary',
            onTap: (): void => { this.triggerEdit() }
          })
        }
        .width('100%')
        .onClick((): void => { this.triggerEdit() })
        Row() {
          AppButton({
            label: '删除备忘',
            variant: 'ghost',
            onTap: (): void => { this.triggerDelete() }
          })
        }
        .width('100%')
        .onClick((): void => { this.triggerDelete() })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: Theme.space.s10 })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
