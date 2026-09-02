import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { UserRecordItem } from '../../models/InkModels'
import { InkBizService } from '../../services/InkBizService'
import { InkDetailNav } from '../../services/InkDetailNav'
import { InkMedia } from '../../services/InkMedia'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop kind: string = 'note'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: UserRecordItem = new UserRecordItem()
  @State loaded: boolean = false
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    const found = this.kind === 'review' ?
      await InkBizService.findReview(this.itemId) :
      await InkBizService.findNote(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
    }
  }

  private async handleDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认删除')
      return
    }
    const ok = this.kind === 'review' ?
      await InkBizService.deleteReview(this.item.id) :
      await InkBizService.deleteNote(this.item.id)
    if (ok) {
      InkDetailNav.bumpRefresh()
      InkDetailNav.close()
    } else {
      this.showToast('删除失败')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.kind === 'review' ? '书评' : '墨迹',
        onClose: (): void => { InkDetailNav.close() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '记录不存在', description: '可能已删除。' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(InkMedia.resource('hero_ink'))
                  .width('100%')
                  .height(180)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(180)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(26,26,46,0)', 0.22], ['rgba(26,26,46,0.82)', 1]]
                  })
                Text(this.kind === 'review' ? '我的书评' : '我的墨迹')
                  .fontSize(Theme.type.caption)
                  .fontColor('#E8D5A3')
                  .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
              }
              .width('100%')
              .borderRadius(Theme.radius.card)
              .clip(true)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column({ space: 8 }) {
                Text(this.item.title)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(this.item.category.length > 0 ? this.item.category : this.item.createdAt)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .padding(Theme.space.cardPadding)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Text(this.item.body)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(26)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column({ space: Theme.space.s3 }) {
                AppButton({
                  label: '编辑',
                  variant: 'primary',
                  onTap: (): void => {
                    InkDetailNav.openEditor(this.kind, this.item.id)
                  }
                })
                AppButton({
                  label: this.confirmDelete ? '确认删除' : '删除',
                  variant: 'secondary',
                  onTap: (): void => { void this.handleDelete() }
                })
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s10
              })
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}

