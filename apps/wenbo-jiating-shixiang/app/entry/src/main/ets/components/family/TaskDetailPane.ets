import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { FamilyTaskItem } from '../../models/FamilyTaskModels'
import { TaskMedia } from '../../services/TaskMedia'
import { CategorySuggest } from '../../services/CategorySuggest'

@Component
export struct TaskDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: FamilyTaskItem = new FamilyTaskItem()
  onComplete: () => void = () => {}
  onEdit: () => void = () => {}
  onDelete: () => void = () => {}
  onClose: () => void = () => {}

  build() {
    Column() {
      Row() {
        AppIcon({ name: 'close', iconSize: 20, color: Theme.colors().brandOnPrimary })
          .onClick(() => this.onClose())
        Blank()
        AppIcon({ name: 'edit', iconSize: 20, color: Theme.colors().brandOnPrimary })
          .onClick(() => this.onEdit())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .position({ x: 0, y: 0 })
      .zIndex(2)

      Scroll() {
        Column() {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(TaskMedia.cover(this.item.coverKey()))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
            Column() {
              Text(this.item.category)
                .fontSize(Theme.type.caption)
                .fontColor('#F6F1E8')
              Text(this.item.title)
                .fontSize(Theme.type.titleM)
                .fontWeight(FontWeight.Bold)
                .fontColor('#F6F1E8')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 20, right: 20, bottom: 20, top: 48 })
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,50,43,0)', 0], ['rgba(26,50,43,0.82)', 1]]
            })
          }
          .width('100%')
          .clip(true)

          Column({ space: 14 }) {
            Column({ space: 6 }) {
              Text(this.item.time.length > 0 ? this.item.time : '全天')
                .fontSize(Theme.type.subtitleM)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(`${this.item.date} · ${CategorySuggest.repeatLabel(this.item.repeatType)} · ${CategorySuggest.reminderLabel(this.item.reminder)}`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            Column({ space: 8 }) {
              Text('说明')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text(this.item.remark.length > 0 ? this.item.remark : '把这件事记下来，做完再轻轻勾选。')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            AppButton({
              label: this.item.completed ? '标为未完成' : '完成这件事',
              variant: 'primary',
              onTap: () => this.onComplete()
            })
            AppButton({
              label: '删除事项',
              variant: 'ghost',
              onTap: () => this.onDelete()
            })
          }
          .padding({ left: 16, right: 16, top: 16, bottom: Theme.space.s10 })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
