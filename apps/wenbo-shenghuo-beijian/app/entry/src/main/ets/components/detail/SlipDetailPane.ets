import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { ConfirmSheet } from '../slip/ConfirmSheet'
import { SlipItem } from '../../models/SlipModels'
import { SlipStore } from '../../services/SlipStore'
import { SlipMedia } from '../../services/SlipMedia'
import { SlipNav } from '../../services/SlipNav'
import { SlipDateUtil } from '../../services/SlipDateUtil'

@Component
export struct SlipDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  @State item: SlipItem | undefined = undefined
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    this.loadItem()
  }

  onItemIdChange(): void {
    this.confirmDelete = false
    this.loadItem()
  }

  private loadItem(): void {
    this.item = SlipStore.find(this.itemId)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async doDelete(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    await SlipStore.remove(this.item.id)
    this.confirmDelete = false
    SlipNav.closeDetail()
  }

  private async toggleDone(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    await SlipStore.toggleDone(this.item.id)
    this.loadItem()
    this.showToast(this.item !== undefined && this.item.isCompleted ? '已完成，生活被轻轻记下' : '已恢复为待办')
  }

  build() {
    Stack() {
      if (this.item === undefined) {
        Column() {
          AppEmpty({ title: '这条备笺不在了', description: '也许它已经被轻轻放走。' })
          AppButton({ label: '返回', variant: 'secondary', onTap: (): void => { SlipNav.closeDetail() } })
        }
        .width('100%')
        .height('100%')
        .padding(Theme.space.pageX)
        .justifyContent(FlexAlign.Center)
      } else {
        DetailShell({ title: '备笺', onClose: (): void => { SlipNav.closeDetail() } }) {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(SlipMedia.cover(SlipMedia.coverForCategory(this.item.category)))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(220)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(36,49,47,0)', 0.35], ['rgba(36,49,47,0.72)', 1]]
                  })
                Column({ space: 6 }) {
                  Text(this.item.category)
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                  Text(this.item.title)
                    .fontSize(Theme.type.title2)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FFFFFF')
                    .width('100%')
                }
                .width('100%')
                .padding({ left: 20, right: 20, bottom: 18 })
              }
              .width('100%')
              .borderRadius(Theme.radius.card)
              .clip(true)

              AppCard() {
                Column({ space: 8 }) {
                  Text(`${SlipDateUtil.shortDate(this.item.date)} · ${this.item.category}`)
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                  if (this.item.isReminderEnabled && this.item.reminderTime.length > 0) {
                    Text(`智能提醒 ${this.item.reminderTime}`)
                      .fontSize(Theme.type.body)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                      .width('100%')
                  }
                  if (this.item.isImportant) {
                    Text('重要')
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  }
                }
              }

              Text(this.item.content.length > 0 ? this.item.content : '没有更多说明，标题已经足够。')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
                .lineHeight(24)

              AppButton({
                label: this.item.isCompleted ? '标为未完成' : '完成这件事',
                onTap: (): void => { void this.toggleDone() }
              })
              AppButton({
                label: '编辑备笺',
                variant: 'secondary',
                onTap: (): void => {
                  const id = this.item !== undefined ? this.item.id : ''
                  SlipNav.closeDetail()
                  SlipNav.openWrite(id)
                }
              })
              AppButton({
                label: '删除',
                variant: 'ghost',
                onTap: (): void => { this.confirmDelete = true }
              })
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

      if (this.confirmDelete) {
        ConfirmSheet({
          title: '删除后无法恢复，确定要删除吗？',
          subtitle: '这条备笺会从本机移除。',
          keepLabel: '先留着',
          leaveLabel: '删除',
          onKeep: (): void => { this.confirmDelete = false },
          onLeave: (): void => { void this.doDelete() }
        })
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
