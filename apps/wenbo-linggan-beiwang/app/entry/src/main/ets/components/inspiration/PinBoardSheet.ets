import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AppIcon } from '../design-system/AppIcon'
import { InspirationItem } from '../../models/InspirationModels'
import { BoardPinService } from '../../services/BoardPinService'
import { InspirationBizService } from '../../services/InspirationBizService'
import { AuthService } from '../../services/AuthService'
import { InspirationMedia } from '../../services/InspirationMedia'

@Component
export struct PinBoardSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @Prop pinTitle: string = ''
  @Prop pinBody: string = ''
  @Prop pinCoverKey: string = ''
  onClose: () => void = () => {}
  onPinned: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State boards: InspirationItem[] = []
  @State loading: boolean = true
  @State busy: boolean = false
  @State errorText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private pinText(): string {
    if (this.pinBody.length > 0) {
      return `${this.pinTitle}\n${this.pinBody}`
    }
    return this.pinTitle
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.boards = await BoardPinService.listOwnBoards(this.currentUsername)
    this.loading = false
  }

  private pinFailText(): string {
    if (InspirationBizService.lastError.length > 0) {
      return InspirationBizService.lastError
    }
    return '钉入失败，请稍后重试'
  }

  private async pinExisting(board: InspirationItem): Promise<void> {
    if (this.busy) {
      return
    }
    if (!AuthService.requireAuth('create_board')) {
      this.onRequireAuth()
      return
    }
    this.busy = true
    this.errorText = ''
    const ok = await BoardPinService.pinToBoard(board, this.pinText())
    this.busy = false
    if (ok) {
      this.onPinned()
      this.onClose()
    } else {
      this.errorText = this.pinFailText()
    }
  }

  private async pinWorkbench(): Promise<void> {
    if (this.busy) {
      return
    }
    if (!AuthService.requireAuth('create_board')) {
      this.onRequireAuth()
      return
    }
    this.busy = true
    this.errorText = ''
    const ok = await BoardPinService.pinToWorkbench(
      this.pinText(),
      this.pinCoverKey,
      this.currentUsername
    )
    this.busy = false
    if (ok) {
      this.onPinned()
      this.onClose()
    } else {
      this.errorText = this.pinFailText()
    }
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text('钉到画板')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Text('把这段灵感做成画板文字卡片，方便对照构图与文案。')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      if (this.loading) {
        AppLoading({ label: '加载画板…' }).layoutWeight(1)
      } else if (this.boards.length === 0) {
        Column() {
          AppEmpty({
            title: '还没有自己的画板',
            description: '将自动创建「灵感工作台」并钉入这张卡片',
            actionLabel: this.busy ? '钉入中…' : '创建并钉入',
            onAction: (): void => { void this.pinWorkbench() }
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.boards, (board: InspirationItem) => {
              Row({ space: Theme.space.s3 }) {
                Image(InspirationMedia.coverMedia(board.coverKey))
                  .width(56)
                  .height(56)
                  .borderRadius(Theme.radius.md)
                  .objectFit(ImageFit.Cover)
                Text(board.title)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .layoutWeight(1)
                  .maxLines(2)
                Text(this.busy ? '…' : '钉入')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => { void this.pinExisting(board) })
            }, (board: InspirationItem) => board.id)

            Column() {
              AppButton({
                label: this.busy ? '处理中…' : '钉到灵感工作台',
                variant: 'secondary',
                disabled: this.busy,
                onTap: (): void => { void this.pinWorkbench() }
              })
            }
            .width('100%')
            .onClick((): void => { void this.pinWorkbench() })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
