import { common } from '@kit.AbilityKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { HomeItem } from '../../models/JujiaModels'
import { TaskMedia } from '../../services/TaskMedia'
import { ReminderService } from '../../services/ReminderService'

@Component
export struct ItemDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: HomeItem = new HomeItem()
  @State toastText: string = ''
  onEdit: () => void = () => {}
  onDelete: () => void = () => {}
  onClose: () => void = () => {}
  onFavorite: () => void = () => {}

  private async ring(): Promise<void> {
    const host = this.getUIContext().getHostContext() as common.UIAbilityContext
    const ok = await ReminderService.testRing(host, this.item.name)
    this.toastText = ok ? ReminderService.lastAction :
      (ReminderService.lastError.length > 0 ? ReminderService.lastError : '提醒未开启')
    setTimeout(() => { this.toastText = '' }, 2800)
  }

  build() {
    Stack() {
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
                .fontColor('#FFF8F5')
              Text(this.item.name)
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

          Column({ space: 14 }) {
            Column({ space: 6 }) {
              Text(this.item.expiryLabel())
                .fontSize(Theme.type.subtitleM)
                .fontColor(this.item.isExpiringSoon() ? Theme.colors().danger : Theme.colors().textPrimary)
                .width('100%')
              Text(`到期 ${this.item.expiryDate.length > 0 ? this.item.expiryDate : '未设置'} · 购入 ${this.item.purchaseDate.length > 0 ? this.item.purchaseDate : '未记录'}`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text(this.item.remindLeadLabel())
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            if (this.item.location.length > 0) {
              Column({ space: 6 }) {
                Text('存放位置')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Text(this.item.location)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
            }

            Column({ space: 8 }) {
              Text('备注')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text(this.item.remark.length > 0 ? this.item.remark : '为这件物品补充保修说明或使用提醒。')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            AppButton({
              label: '试响到期提醒',
              variant: 'secondary',
              onTap: () => { void this.ring() }
            })
            AppButton({
              label: '编辑物品',
              variant: 'primary',
              onTap: (): void => { this.onEdit() }
            })
            Row() {
              AppButton({
                label: '收藏',
                variant: 'secondary',
                onTap: (): void => { this.onFavorite() }
              })
            }
            .width('100%')
            .onClick((): void => { this.onFavorite() })
            AppButton({
              label: '删除物品',
              variant: 'ghost',
              onTap: (): void => { this.onDelete() }
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

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.sm)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }
}
