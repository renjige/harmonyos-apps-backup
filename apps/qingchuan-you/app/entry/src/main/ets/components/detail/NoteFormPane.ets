import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { NoteCreateRequest } from '../../models/ScenicModels'
import { ScenicBizService } from '../../services/ScenicBizService'
import { ScenicDetailNav } from '../../services/ScenicDetailNav'

@Component
export struct NoteFormPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop refreshToken: number = 0
  @State title: string = ''
  @State body: string = ''
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.showToast('请填写标题')
      return
    }
    const req = new NoteCreateRequest()
    req.title = this.title.trim()
    req.body = this.body
    req.destId = AppStorage.get<string>('noteDraftDestId') ?? ''
    req.destName = AppStorage.get<string>('noteDraftDestName') ?? ''
    req.coverKey = AppStorage.get<string>('noteDraftCover') ?? 'note_westlake'
    const ok = await ScenicBizService.createNote(req)
    if (ok) {
      this.showToast('已发布')
      setTimeout(() => { ScenicDetailNav.close() }, 500)
      return
    }
    this.showToast('发布失败，请稍后重试')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({ title: '发布笔记', onClose: () => ScenicDetailNav.close() }) {
        Column({ space: 12 }) {
          TextInput({ text: this.title, placeholder: '标题' })
            .onChange((v: string) => { this.title = v })
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
          TextArea({ text: this.body, placeholder: '写下这段路上的事' })
            .onChange((v: string) => { this.body = v })
            .height(160)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
          AppButton({ label: '发布', onTap: (): void => { void this.save() } })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText).fontSize(Theme.type.footnote).fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary).borderRadius(Theme.radius.pill)
        }.width('100%').padding({ top: Theme.space.s6 }).alignItems(HorizontalAlign.Center).zIndex(30)
      }
    }
    .width('100%').height('100%')
  }
}
