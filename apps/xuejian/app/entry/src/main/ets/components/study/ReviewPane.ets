import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { KnowledgeCardItem } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'
import { StudyMedia } from '../../services/StudyMedia'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct ReviewPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State item: KnowledgeCardItem = new KnowledgeCardItem()
  @State hasItem: boolean = false
  @State revealed: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  onClose: () => void = () => {}
  onChanged: () => void = () => {}
  onOpenCard: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.draw()
  }

  private async draw(): Promise<void> {
    const found = await StudyStore.randomReviewCard()
    if (found === undefined) {
      this.hasItem = false
      return
    }
    this.item = found
    this.hasItem = true
    this.revealed = false
    this.confirmDelete = false
  }

  private async markMastered(): Promise<void> {
    this.item.mastery = 'mastered'
    await StudyStore.saveCard(this.item)
    this.onChanged()
    this.toastText = '已标记掌握'
    setTimeout((): void => { this.toastText = '' }, 1600)
    await this.draw()
  }

  private async keepReview(): Promise<void> {
    this.item.mastery = 'review'
    await StudyStore.saveCard(this.item)
    this.onChanged()
    await this.draw()
  }

  private async deleteCard(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.toastText = '再点一次确认删除此卡'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    await StudyStore.deleteCard(this.item.id)
    this.confirmDelete = false
    this.onChanged()
    this.toastText = '已删除'
    setTimeout((): void => { this.toastText = '' }, 1600)
    await this.draw()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(48).height(48).justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text('随机复习')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')

        if (!this.hasItem) {
          AppEmpty({
            title: '还没有知识卡片',
            description: '先创建一张卡片，再回来抽一张复习',
            actionLabel: '关闭',
            onAction: (): void => { this.onClose() }
          })
            .layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Image(StudyMedia.resource(this.item.coverKey))
                .width('100%')
                .height(140)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.md)
              Text(CategoryEmojiUtil.chipLabel(this.item.category))
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .width('100%')
              Text(this.item.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              if (this.item.isPlaceholder()) {
                Text('这是测试占位卡片（旧版误触生成），建议删除或点「打开详情」编辑成真实内容')
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              if (this.revealed) {
                Text(this.item.body.length > 0 ? this.item.body : '这张卡片还没有说明')
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                  .lineHeight(22)
                AppButton({ label: '已掌握', onTap: (): void => { void this.markMastered() } })
                AppButton({ label: '仍需复习', variant: 'secondary', onTap: (): void => { void this.keepReview() } })
                AppButton({
                  label: '打开详情',
                  variant: 'ghost',
                  onTap: (): void => { this.onOpenCard(this.item.id) }
                })
                AppButton({
                  label: '删除此卡',
                  variant: 'danger',
                  onTap: (): void => { void this.deleteCard() }
                })
              } else {
                AppButton({ label: '翻看说明', onTap: (): void => { this.revealed = true } })
                AppButton({ label: '换一张', variant: 'secondary', onTap: (): void => { void this.draw() } })
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
          }
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(12)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(12)
          .margin({ top: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }
}
