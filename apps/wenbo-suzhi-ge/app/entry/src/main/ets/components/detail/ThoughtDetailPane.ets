import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { WisdomItem } from '../../models/WisdomHallModels'
import { WisdomHallBizService } from '../../services/WisdomHallBizService'
import { WisdomHallNav } from '../../services/WisdomHallNav'
import { WisdomMedia } from '../../services/WisdomMedia'
import { AuthService } from '../../services/AuthService'

@Component
export struct ThoughtDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: WisdomItem = new WisdomItem()
  @State loaded: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await WisdomHallBizService.findThought(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private edit(): void {
    WisdomHallNav.closeDetail()
    WisdomHallNav.openWrite(this.itemId)
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认删除')
      return
    }
    const ok = await WisdomHallBizService.deleteThought(this.itemId)
    if (ok) {
      this.showToast('已删除')
      setTimeout(() => { WisdomHallNav.closeDetail() }, 600)
    } else {
      this.showToast('删除失败')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '我的思录',
        showFavorite: false,
        favorited: false,
        onClose: (): void => { WisdomHallNav.closeDetail() },
        onFavorite: (): void => {}
      }) {
        if (!AuthService.isLoggedIn()) {
          AppEmpty({ title: '请先登录', description: '登录后可查看与编辑思录' })
        } else if (!this.loaded) {
          AppEmpty({ title: '思录不存在', description: '' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(WisdomMedia.resource(this.item.coverKey))
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(200)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(26,26,46,0)', 0.28], ['rgba(26,26,46,0.78)', 1]]
                  })
                Column({ space: 6 }) {
                  Text(this.item.category.length > 0 ? this.item.category : '思录')
                    .fontSize(Theme.type.caption)
                    .fontColor('#C9A84C')
                  Text(this.item.title)
                    .fontSize(Theme.type.title2)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#F5F0E8')
                    .maxLines(3)
                }
                .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
              }
              .width('100%')
              .borderRadius(Theme.radius.card)
              .clip(true)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Text(this.item.body)
                .fontSize(Theme.type.bodyL)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(28)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column({ space: Theme.space.s3 }) {
                AppButton({
                  label: '编辑思录',
                  variant: 'primary',
                  onTap: (): void => { this.edit() }
                })
                AppButton({
                  label: this.confirmDelete ? '确认删除' : '删除思录',
                  variant: 'danger',
                  onTap: (): void => { void this.remove() }
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
