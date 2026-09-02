import { Theme } from '../design-system/Theme'
import { AppHeader } from '../design-system/AppHeader'
import { AppButton } from '../design-system/AppButton'
import { TeamNoteStore } from '../../services/TeamNoteStore'

@Component
export struct TeamNoteSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop teamId: string = ''
  @Prop teamTitle: string = ''
  @Prop @Watch('onTeamChange') refreshToken: number = 0
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  @State draft: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    this.draft = TeamNoteStore.getNote(this.teamId)
  }

  onTeamChange(): void {
    this.draft = TeamNoteStore.getNote(this.teamId)
  }

  private async save(): Promise<void> {
    await TeamNoteStore.saveNote(this.teamId, this.draft)
    this.toastText = '研判笔记已保存到本机'
    this.onSaved()
    setTimeout((): void => {
      this.toastText = ''
      this.onClose()
    }, 900)
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '研判笔记', subtitle: this.teamTitle })
        Text('仅保存在本机，新用户默认为空。用于记录你对公开资料的观察，不是历史战绩。')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
        TextArea({ text: this.draft, placeholder: '例如：边路传中质量、客场防守、伤病对阵容的影响…' })
          .onChange((v: string): void => { this.draft = v })
          .layoutWeight(1)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        Row({ space: Theme.space.s3 }) {
          Column() {
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => { this.onClose() }
            })
          }
          .layoutWeight(1)
          Column() {
            AppButton({
              label: '保存笔记',
              onTap: (): void => { void this.save() }
            })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(Theme.space.pageX)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

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
      }
    }
    .width('100%')
    .height('100%')
  }
}
