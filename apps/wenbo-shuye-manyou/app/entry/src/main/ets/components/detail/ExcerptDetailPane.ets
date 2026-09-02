import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { ExcerptItem, RoamNote } from '../../models/RoamModels'
import { RoamBizService } from '../../services/RoamBizService'
import { RoamDetailNav } from '../../services/RoamDetailNav'
import { RoamMedia } from '../../services/RoamMedia'
import { RoamStore } from '../../services/RoamStore'

@Component
export struct ExcerptDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: ExcerptItem = new ExcerptItem()
  @State noteText: string = ''
  @State favorited: boolean = false
  @State readLater: boolean = false
  @State finished: boolean = false
  @State loaded: boolean = false
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
    const found = await RoamBizService.findExcerpt(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
      this.favorited = RoamStore.isFavorite(found.id)
      this.readLater = RoamStore.isReadLater(found.id)
      this.finished = RoamStore.isFinished(found.id)
    }
  }

  private async toggleFavorite(): Promise<void> {
    await RoamStore.toggleFavorite(this.item.id, this.item.bookTitle, this.item.theme)
    await this.reload()
    this.showToast(this.favorited ? '已取消收藏' : '已收藏')
  }

  private async toggleReadLater(): Promise<void> {
    await RoamStore.toggleReadLater(this.item.id, this.item.bookTitle, this.item.theme)
    await this.reload()
    this.showToast(this.readLater ? '已从稍后读移除' : '已加入稍后读')
  }

  private async markFinished(): Promise<void> {
    await RoamStore.markFinished(this.item.id, this.item.bookTitle, this.item.theme)
    await this.reload()
    this.showToast('已标记读完')
  }

  private async saveNote(): Promise<void> {
    const text = this.noteText.trim()
    if (text.length === 0) {
      this.showToast('请先写下笔记')
      return
    }
    const note = new RoamNote()
    note.id = RoamStore.newNoteId()
    note.excerptId = this.item.id
    note.excerptTitle = this.item.title
    note.bookTitle = this.item.bookTitle
    note.body = text
    note.createdAt = Date.now()
    note.updatedAt = note.createdAt
    await RoamStore.saveNote(note)
    this.noteText = ''
    this.showToast('笔记已保存到本机')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '每日节选',
        showFavorite: true,
        favorited: this.favorited,
        onClose: (): void => { RoamDetailNav.close() },
        onFavorite: (): void => { void this.toggleFavorite() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '节选不存在', description: '请返回后刷新再试。' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(RoamMedia.resource(this.item.coverKey))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(220)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(45,74,62,0)', 0.28], ['rgba(45,74,62,0.78)', 1]]
                  })
                Column({ space: 6 }) {
                  Text(this.item.theme)
                    .fontSize(Theme.type.caption)
                    .fontColor('#F4EFE6')
                  Text(this.item.bookTitle)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#F4EFE6')
                    .maxLines(2)
                  Text(this.item.author)
                    .fontSize(Theme.type.footnote)
                    .fontColor('#E8DFD0')
                }
                .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
              }
              .width('100%')
              .borderRadius(Theme.radius.card)
              .clip(true)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column() {
                Text(this.item.summaryLine())
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .lineHeight(24)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Text(this.item.body)
                .fontSize(Theme.type.bodyL)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(28)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column({ space: Theme.space.s3 }) {
                AppButton({
                  label: this.favorited ? '取消收藏' : '收藏',
                  variant: 'primary',
                  onTap: (): void => { void this.toggleFavorite() }
                })
                AppButton({
                  label: this.readLater ? '移出稍后读' : '稍后读',
                  variant: 'secondary',
                  onTap: (): void => { void this.toggleReadLater() }
                })
                AppButton({
                  label: this.finished ? '已标记读完' : '标记读完',
                  variant: 'ghost',
                  onTap: (): void => { void this.markFinished() }
                })
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column({ space: Theme.space.s2 }) {
                Text('写一条笔记（最多 200 字，仅保存在本机）')
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                TextArea({ text: this.noteText, placeholder: '这段文字带给你的感受…' })
                  .height(120)
                  .maxLength(200)
                  .onChange((v: string): void => { this.noteText = v })
                AppButton({
                  label: '保存笔记',
                  variant: 'secondary',
                  onTap: (): void => { void this.saveNote() }
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
          .align(Alignment.Top)
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
