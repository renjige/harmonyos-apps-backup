import { Theme, ThemeColors } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { MatchItem } from '../../models/MatchModels'
import { CreateViewingNoteBody } from '../../models/ViewingModels'
import { SportsBizService } from '../../services/SportsBizService'

@Component
export struct WatchNoteEditorOverlay {
  @StorageLink('themeColorMode') themeColorMode: string = 'light'
  @Prop match: MatchItem = new MatchItem()
  @State content: string = ''
  @State mood: string = '精彩'
  @State rating: number = 4
  @State saving: boolean = false
  @State toastText: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  private palette(): ThemeColors {
    return Theme.palette(this.themeColorMode === 'dark')
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async handleSave(): Promise<void> {
    if (this.saving) {
      return
    }
    if (this.content.trim().length < 4) {
      this.showToast('笔记至少 4 个字')
      return
    }
    this.saving = true
    const body = new CreateViewingNoteBody()
    body.matchId = this.match.id
    body.matchTitle = this.match.title
    body.content = this.content.trim()
    body.rating = this.rating
    body.mood = this.mood
    const row = await SportsBizService.createViewingNote(body)
    this.saving = false
    if (row === undefined) {
      this.showToast(SportsBizService.lastError.length > 0 ?
        SportsBizService.lastError : '保存失败')
      return
    }
    this.showToast('观赛笔记已保存')
    this.onSaved()
    this.onClose()
  }

  build() {
    Stack() {
      Column({ space: Theme.space.s4 }) {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: this.palette().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
          Text('写观赛笔记')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.palette().textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s4 })

        Column({ space: Theme.space.s3 }) {
          Text(this.match.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.palette().textPrimary)
            .width('100%')
          TextArea({ text: this.content, placeholder: '记录观赛感受、关键瞬间…' })
            .height(140)
            .padding(12)
            .backgroundColor(this.palette().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
            .border({ width: 1, color: this.palette().strokeStrong })
            .fontColor(this.palette().textPrimary)
            .placeholderColor(this.palette().textTertiary)
            .onChange((v: string): void => { this.content = v })
          Row({ space: Theme.space.s2 }) {
            ForEach(['一般', '精彩', '震撼'], (label: string) => {
              Text(label)
                .fontSize(Theme.type.caption)
                .fontColor(this.mood === label ? this.palette().brandOnPrimary : this.palette().textSecondary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.mood === label ?
                  this.palette().brandPrimary : this.palette().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.mood = label })
            }, (label: string) => label)
          }
          .width('100%')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')

        AppButton({
          label: this.saving ? '保存中…' : '保存笔记',
          onTap: (): void => { void this.handleSave() }
        })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.palette().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(this.palette().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(this.palette().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
