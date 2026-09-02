import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { RmTheme } from '../../models/RmModels'
import { RmStore } from '../../services/RmStore'
import { RmDetailNav } from '../../services/RmDetailNav'
import { RmMedia } from '../../services/RmMedia'

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
  @Prop @Watch('onEditIdChange') editId: string = ''
  onChanged: () => void = () => {}
  @State title: string = ''
  @State summary: string = ''
  @State coverKey: string = 'paper'
  @State toastText: string = ''
  @State saving: boolean = false
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

  onEditIdChange(): void {
    void this.bootstrap()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async bootstrap(): Promise<void> {
    if (this.editId.length === 0) {
      this.title = ''
      this.summary = ''
      this.coverKey = 'paper'
      return
    }
    const found = await RmStore.findTheme(this.editId)
    if (found !== undefined) {
      this.title = found.title
      this.summary = found.summary
      this.coverKey = found.coverKey
    }
  }

  private async save(): Promise<void> {
    if (this.saving) {
      return
    }
    if (this.title.trim().length === 0) {
      this.showToast('请填写主题名称')
      return
    }
    this.saving = true
    let t = new RmTheme()
    if (this.editId.length > 0) {
      const found = await RmStore.findTheme(this.editId)
      if (found !== undefined) {
        t = found
      }
    } else {
      t = RmTheme.createNew(this.title.trim())
    }
    t.title = this.title.trim()
    t.summary = this.summary
    t.coverKey = this.coverKey
    await RmStore.saveTheme(t)
    this.saving = false
    this.onChanged()
    this.showToast('主题已保存')
    RmDetailNav.closeThemeEditor()
    RmDetailNav.openTheme(t.id)
  }

  build() {
    Stack() {
      DetailShell({ title: this.editId.length > 0 ? '编辑主题' : '新建主题', onClose: (): void => { RmDetailNav.closeThemeEditor() } }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(RmMedia.coverOf(this.coverKey))
                .id(`preview_${this.coverKey}`)
                .width('100%')
                .height(140)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(72)
                .linearGradient({ angle: 180, colors: [['rgba(12,74,110,0)', 0], ['rgba(12,74,110,0.75)', 1]] })
              Text(this.title.length > 0 ? this.title : '封面预览')
                .fontSize(Theme.type.subtitleS)
                .fontColor('#F8FAFC')
                .padding({ left: Theme.space.s4, bottom: Theme.space.s3 })
            }
            .width('100%')
            .clip(true)
            .borderRadius(Theme.radius.md)

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
                  Image(RmMedia.coverOf(c.key))
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
            Row() {
              AppButton({
                label: this.saving ? '保存中…' : '保存',
                disabled: this.saving,
                onTap: (): void => { void this.save() }
              })
            }
            .width('100%')
            .onClick((): void => { void this.save() })
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
