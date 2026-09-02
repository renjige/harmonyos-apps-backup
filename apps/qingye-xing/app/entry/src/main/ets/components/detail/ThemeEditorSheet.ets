import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { QyTheme } from '../../models/QyModels'
import { QyStore } from '../../services/QyStore'
import { QyDetailNav } from '../../services/QyDetailNav'
import { QyMedia } from '../../services/QyMedia'

class CoverOpt {
  key: string = ''
  label: string = ''
  static make(key: string, label: string): CoverOpt {
    const o = new CoverOpt()
    o.key = key
    o.label = label
    return o
  }
}

@Component
export struct ThemeEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  onChanged: () => void = () => {}
  @State title: string = ''
  @State summary: string = ''
  @State coverKey: string = 'paper'
  @State toastText: string = ''
  private covers: CoverOpt[] = [
    CoverOpt.make('paper', '纸页'),
    CoverOpt.make('tea', '茶席'),
    CoverOpt.make('reading', '阅读'),
    CoverOpt.make('corridor', '长廊'),
    CoverOpt.make('window', '窗光'),
    CoverOpt.make('empty', '留白')
  ]

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    if (this.editId.length === 0) {
      return
    }
    const found = await QyStore.findTheme(this.editId)
    if (found !== undefined) {
      this.title = found.title
      this.summary = found.summary
      this.coverKey = found.coverKey
    }
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.toastText = '请填写主题名称'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    let t = new QyTheme()
    if (this.editId.length > 0) {
      const found = await QyStore.findTheme(this.editId)
      if (found !== undefined) {
        t = found
      }
    } else {
      t = QyTheme.createNew(this.title.trim())
    }
    t.title = this.title.trim()
    t.summary = this.summary
    t.coverKey = this.coverKey
    await QyStore.saveTheme(t)
    this.onChanged()
    QyDetailNav.closeThemeEditor()
    QyDetailNav.openTheme(t.id)
  }

  build() {
    Stack() {
      DetailShell({ title: this.editId.length > 0 ? '编辑主题' : '新建主题', onClose: (): void => { QyDetailNav.closeThemeEditor() } }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.title, placeholder: '主题名称，如春日拾光' })
              .onChange((v: string): void => { this.title = v })
              .height(44)
            TextArea({ text: this.summary, placeholder: '一句话说明这个主题' })
              .onChange((v: string): void => { this.summary = v })
              .height(90)
            Text('封面')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.covers, (c: CoverOpt) => {
                Column({ space: 4 }) {
                  Image(QyMedia.coverOf(c.key))
                    .width(96)
                    .height(64)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(Theme.radius.sm)
                    .border({
                      width: this.coverKey === c.key ? 2 : 0,
                      color: Theme.colors().brandAccent
                    })
                  Text(c.label)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => { this.coverKey = c.key })
              }, (c: CoverOpt) => c.key)
            }
            AppButton({ label: '保存', onTap: (): void => { void this.save() } })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .layoutWeight(1)
        .width('100%')
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(12)
          .margin({ top: 16 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.sm)
      }
    }
    .width('100%')
    .height('100%')
  }
}
