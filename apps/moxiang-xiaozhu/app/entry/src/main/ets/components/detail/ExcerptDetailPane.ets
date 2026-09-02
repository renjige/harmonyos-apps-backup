import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { ExcerptItem, InkWriteRequest } from '../../models/InkModels'
import { InkBizService } from '../../services/InkBizService'
import { InkDetailNav } from '../../services/InkDetailNav'
import { InkMedia } from '../../services/InkMedia'
import { AuthService } from '../../services/AuthService'

@Component
export struct ExcerptDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State item: ExcerptItem = new ExcerptItem()
  @State loaded: boolean = false
  @State toastText: string = ''
  @State noteTitle: string = ''
  @State noteBody: string = ''

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
    const found = await InkBizService.findExcerpt(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
    }
  }

  private async saveNote(): Promise<void> {
    if (!AuthService.requireAuth('create_note')) {
      this.onRequireAuth()
      return
    }
    const req = new InkWriteRequest()
    req.title = this.noteTitle.trim().length > 0 ? this.noteTitle.trim() : `读${this.item.title}`
    req.body = this.noteBody.trim()
    req.excerptId = this.item.id
    req.category = '札记'
    if (req.body.length === 0) {
      this.showToast('请先写下墨迹')
      return
    }
    const ok = await InkBizService.saveNote(req)
    if (ok) {
      this.noteBody = ''
      InkDetailNav.bumpRefresh()
      this.showToast('墨迹已保存')
    } else {
      this.showToast('保存失败，请稍后重试')
    }
  }

  private async checkin(): Promise<void> {
    if (!AuthService.requireAuth('create_checkin')) {
      this.onRequireAuth()
      return
    }
    const ok = await InkBizService.saveCheckin(this.item.id, `读完《${this.item.title}》`)
    if (ok) {
      InkDetailNav.bumpRefresh()
      this.showToast('今日已打卡')
    } else {
      this.showToast('打卡失败，请稍后重试')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '书摘',
        onClose: (): void => { InkDetailNav.close() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '书摘不存在', description: '请返回后刷新再试。' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(InkMedia.resource(this.item.coverKey))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(220)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(26,26,46,0)', 0.22], ['rgba(26,26,46,0.82)', 1]]
                  })
                Column({ space: 6 }) {
                  Text(`${this.item.dynasty} · ${this.item.source}`)
                    .fontSize(Theme.type.caption)
                    .fontColor('#F4EFE4')
                  Text(this.item.title)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#F4EFE4')
                  Text(this.item.author)
                    .fontSize(Theme.type.footnote)
                    .fontColor('#E8D5A3')
                }
                .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
              }
              .width('100%')
              .borderRadius(Theme.radius.card)
              .clip(true)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column() {
                Text(this.item.summary)
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

              Text(this.item.annotation)
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .lineHeight(22)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column({ space: Theme.space.s2 }) {
                Text('写下墨迹')
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                TextInput({ text: this.noteTitle, placeholder: '✨ 墨迹标题' })
                  .onChange((v: string): void => { this.noteTitle = v })
                TextArea({ text: this.noteBody, placeholder: '💭 这一句带给你什么…' })
                  .height(100)
                  .onChange((v: string): void => { this.noteBody = v })
                AppButton({
                  label: '保存墨迹',
                  variant: 'primary',
                  onTap: (): void => { void this.saveNote() }
                })
                AppButton({
                  label: '读书打卡',
                  variant: 'secondary',
                  onTap: (): void => { void this.checkin() }
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
