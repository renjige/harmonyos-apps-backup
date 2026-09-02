import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ThemeSpace } from '../../models/XingyuModels'
import { XingyuStore } from '../../services/XingyuStore'
import { XingyuNav } from '../../services/XingyuNav'
import { XingyuMedia } from '../../services/XingyuMedia'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct ThemeEditorSheet {
  @Prop editorId: string = ''
  @State title: string = ''
  @State coverKey: string = 'cover_life'
  @State toastText: string = ''
  private existingId: string = ''
  private covers: string[] = ['cover_reading', 'cover_travel', 'cover_growth', 'cover_hobby', 'cover_life']

  aboutToAppear(): void {
    void this.boot()
  }

  private async boot(): Promise<void> {
    if (this.editorId.length === 0) {
      this.existingId = ''
      return
    }
    const t = await XingyuStore.findTheme(this.editorId)
    if (t === undefined) {
      return
    }
    this.existingId = t.id
    this.title = t.title
    this.coverKey = t.coverKey
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.toastText = '请填写主题名称'
      setTimeout(() => {
        this.toastText = ''
      }, 2000)
      return
    }
    let t = ThemeSpace.createNew(this.title.trim(), this.coverKey)
    if (this.existingId.length > 0) {
      const old = await XingyuStore.findTheme(this.existingId)
      if (old !== undefined) {
        t = old
        t.title = this.title.trim()
        t.coverKey = this.coverKey
      }
    }
    await XingyuStore.saveTheme(t)
    XingyuNav.closeEditor()
    XingyuNav.openTheme(t.id)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.existingId.length > 0 ? '编辑主题' : '创建主题',
        onBack: () => XingyuNav.closeEditor()
      }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.title, placeholder: '例如：我的阅读角' })
              .onChange((v: string) => {
                this.title = v
              })
              .height(48)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .padding({ left: 12, right: 12 })
            Text('封面')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.covers, (k: string) => {
                Image(XingyuMedia.image(k))
                  .width(72)
                  .height(72)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.sm)
                  .margin({ right: 8, bottom: 8 })
                  .border({
                    width: this.coverKey === k ? 2 : 0,
                    color: Theme.colors().brandAccent
                  })
                  .onClick((): void => {
                    this.coverKey = k
                  })
              }, (k: string): string => k)
            }
            .width('100%')
            AppButton({
              label: '保存主题空间',
              onTap: () => {
                void this.save()
              }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.sm)
          .margin({ top: Theme.space.s8 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
