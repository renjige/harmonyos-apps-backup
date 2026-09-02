import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { BookNote } from '../../models/BookNoteModels'
import { NoteStore } from '../../services/NoteStore'
import { StudyStore } from '../../services/StudyStore'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct RecallDrillPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('statTodayRecall') todayRecall: number = 0
  @State card: BookNote = new BookNote()
  @State empty: boolean = false
  @State revealed: boolean = false
  @State toastText: string = ''
  onClose: () => void = () => {}
  onOpenDetail: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.draw('')
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private async draw(excludeId: string): Promise<void> {
    const next = await NoteStore.nextRecall(excludeId)
    if (next === undefined) {
      this.empty = true
      return
    }
    this.empty = false
    this.card = next
    this.revealed = false
  }

  private async mark(remembered: boolean): Promise<void> {
    if (this.card.id.length === 0) {
      return
    }
    await NoteStore.markRecalled(this.card.id, remembered)
    await StudyStore.bumpRecallTotal()
    this.showToast(remembered ? '已记入掌握' : '已排入再复习')
    await this.draw(this.card.id)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text('抽卡回顾')
            .fontSize(Theme.type.titleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text(`今日 ${this.todayRecall}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

        if (this.empty) {
          AppEmpty({
            title: '还没有可回顾的书摘',
            description: '先去添加一条摘录，再回来抽卡回想出处',
            actionLabel: '关闭',
            onAction: (): void => { this.onClose() }
          })
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Text('先读摘录，试着想起出自哪一本书、哪一页')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Column({ space: Theme.space.s3 }) {
                Text(this.card.excerpt)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                if (this.revealed) {
                  Text(this.card.bookName)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .width('100%')
                  Text(`${this.card.pageLabel().length > 0 ? this.card.pageLabel() : '未标页码'} · ${CategoryEmojiUtil.chipLabel(this.card.primaryTag())} · 已回顾 ${this.card.recallCount} 次`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                  if (this.card.reflection.length > 0) {
                    Text(`感悟：${this.card.reflection}`)
                      .fontSize(Theme.type.bodyS)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .width('100%')
                  }
                } else {
                  Text('出处已隐藏，先在心里回答')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandAccent : Theme.colors().brandAccent)
                    .width('100%')
                }
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(12)

              if (!this.revealed) {
                AppButton({
                  label: '显示出处',
                  onTap: (): void => { this.revealed = true }
                })
              } else {
                AppButton({
                  label: '记住了，下一条',
                  onTap: (): void => { void this.mark(true) }
                })
                AppButton({
                  label: '有点模糊，稍后再看',
                  variant: 'secondary',
                  onTap: (): void => { void this.mark(false) }
                })
                AppButton({
                  label: '打开完整书摘',
                  variant: 'secondary',
                  onTap: (): void => { this.onOpenDetail(this.card.id) }
                })
              }
            }
            .width('100%')
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10,
              top: Theme.space.s3
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}
