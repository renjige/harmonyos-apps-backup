import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { TagChips } from './TagChips'
import { WisdomHallBizService } from '../../services/WisdomHallBizService'
import { WisdomHallNav } from '../../services/WisdomHallNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct WriteThoughtPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @Prop @Watch('onToken') refreshToken: number = 0
  @State title: string = ''
  @State body: string = ''
  @State tag: string = '其他'
  @State tagOptions: string[] = []
  @State toastText: string = ''
  @State loading: boolean = false
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.hydrate()
  }

  onToken(): void {
    void this.hydrate()
  }

  private async hydrate(): Promise<void> {
    const tags = await WisdomHallBizService.loadTags()
    const names: string[] = []
    for (const t of tags) {
      names.push(t.title)
    }
    if (names.length === 0) {
      names.push('职场', '人生', '阅读', '情感', '灵感', '其他')
    }
    this.tagOptions = names

    const preTitle = AppStorage.get<string>('writePrefillTitle') ?? ''
    const preBody = AppStorage.get<string>('writePrefillBody') ?? ''
    if (this.editId.length === 0 && preTitle.length > 0) {
      this.title = preTitle
      this.body = preBody
      return
    }
    if (this.editId.length === 0) {
      this.title = ''
      this.body = ''
      this.tag = '其他'
      return
    }
    const found = await WisdomHallBizService.findThought(this.editId)
    if (found !== undefined) {
      this.title = found.title
      this.body = found.body
      this.tag = found.category.length > 0 ? found.category : '其他'
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    if (!AuthService.requireAuth('create_thought')) {
      this.onRequireAuth()
      return
    }
    if (this.title.trim().length === 0) {
      this.showToast('请填写笔记标题')
      return
    }
    if (this.loading) {
      return
    }
    this.loading = true
    let ok = false
    if (this.editId.length > 0) {
      ok = await WisdomHallBizService.updateThought(this.editId, this.title, this.body, this.tag)
    } else {
      const row = await WisdomHallBizService.createThought(this.title, this.body, this.tag)
      ok = row !== undefined
    }
    this.loading = false
    if (ok) {
      AppStorage.setOrCreate('whRefresh', Date.now())
      this.showToast('笔记已保存')
      setTimeout(() => { WisdomHallNav.closeWrite() }, 700)
    } else {
      this.showToast('保存失败，请登录后重试')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(26,26,46,0.45)')
          .onClick((): void => { WisdomHallNav.closeWrite() })

        Column() {
        Row() {
          Column()
            .width(36)
            .height(4)
            .backgroundColor(Theme.colors().strokeStrong)
            .borderRadius(2)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: Theme.space.s2, bottom: Theme.space.s2 })

        Row() {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { WisdomHallNav.closeWrite() })
          Text(this.editId.length > 0 ? '✏️ 编辑笔记' : '📝 新建笔记')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 12, right: Theme.space.pageX })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.title, placeholder: '✨ 笔记标题' })
              .onChange((v: string) => { this.title = v })
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
            TextArea({ text: this.body, placeholder: '💭 写下此刻的思考…' })
              .height(160)
              .onChange((v: string) => { this.body = v })
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
            Text('🏷 选择标签')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TagChips({
              selected: this.tag,
              options: this.tagOptions,
              onSelect: (name: string): void => { this.tag = name }
            })
            AppButton({
              label: this.loading ? '保存中…' : '保存笔记',
              disabled: this.loading,
              onTap: (): void => { void this.save() }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s6
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('72%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .borderRadius({ topLeft: Theme.radius.sheet, topRight: Theme.radius.sheet })
      .shadow({ radius: 24, color: Theme.colors().overlayScrim, offsetY: -4 })
      }
      .width('100%')
      .height('100%')

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
