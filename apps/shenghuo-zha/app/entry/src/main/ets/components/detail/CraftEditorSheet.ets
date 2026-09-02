import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { LifeCraftItem, LifeCraftPreset } from '../../models/LifeModels'
import { LifeDateHelper } from '../../services/LifeLocalStore'
import { LifeCraftStore } from '../../services/LifeCraftStore'
import { LifeDetailNav } from '../../services/LifeDetailNav'

@Component
export struct CraftEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('lifeCraftEditorId') @Watch('onOpenChange') editorId: string = ''
  @StorageLink('lifeCraftEditorKind') startKind: string = 'tip'
  @StorageLink('lifeCraftEditorOpen') @Watch('onOpenChange') editorOpen: boolean = false
  onSaved: () => void = () => {}
  @State kind: string = 'tip'
  @State title: string = ''
  @State body: string = ''
  @State extra: string = ''
  @State category: string = '家庭'
  @State toast: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  onOpenChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    if (this.editorId.length === 0) {
      this.kind = this.startKind.length > 0 && this.startKind !== 'all' && this.startKind !== 'pin' ?
        this.startKind : 'tip'
      this.title = ''
      this.body = ''
      this.extra = this.kind === 'goal' ? '每周' : (this.kind === 'challenge' ? '7' : '')
      this.category = '家庭'
      return
    }
    const found = await LifeCraftStore.find(this.editorId)
    if (found !== undefined) {
      this.kind = found.kind
      this.title = found.title
      this.body = found.body
      this.extra = found.extra
      this.category = found.category
    }
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 1800)
  }

  private extraLabel(): string {
    if (this.kind === 'issue') {
      return '解决办法'
    }
    if (this.kind === 'goal') {
      return '周期（每周 / 每月 / 持续）'
    }
    if (this.kind === 'challenge') {
      return '目标天数'
    }
    return '补充'
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.showToast('请填写标题')
      return
    }
    if (this.kind === 'issue' && this.extra.trim().length === 0 && this.body.trim().length === 0) {
      this.showToast('请写下问题或解决办法')
      return
    }
    let item = new LifeCraftItem()
    if (this.editorId.length > 0) {
      const found = await LifeCraftStore.find(this.editorId)
      if (found !== undefined) {
        item = found
      }
    } else {
      item = LifeCraftItem.create(LifeDateHelper.newId(), this.kind, this.title.trim())
    }
    item.kind = this.kind
    item.title = this.title.trim()
    item.body = this.body.trim()
    item.extra = this.extra.trim()
    item.category = this.category
    const ok = await LifeCraftStore.save(item)
    if (!ok) {
      this.showToast('保存失败，请重开应用后再试')
      return
    }
    this.onSaved()
    LifeDetailNav.closeCraftEditor()
    LifeDetailNav.openCraft(item.id)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text(this.editorId.length > 0 ? '编辑锦囊' : '新建锦囊')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
            .onClick((): void => { LifeDetailNav.closeCraftEditor() })
        }
        .width('100%')
        .padding(Theme.space.pageX)
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('类型')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(['tip', 'issue', 'goal', 'plan', 'challenge', 'idea'], (k: string) => {
                Text(LifeCraftPreset.kindLabel(k))
                  .fontSize(Theme.type.caption)
                  .fontColor(this.kind === k ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: Theme.space.s2, bottom: Theme.space.s1 })
                  .backgroundColor(this.kind === k ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.kind = k })
              }, (k: string) => k)
            }
            .width('100%')
            Text('分类')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(LifeCraftPreset.board(), (c: string) => {
                Text(c)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.category === c ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: Theme.space.s2, bottom: Theme.space.s1 })
                  .backgroundColor(this.category === c ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.category = c })
              }, (c: string) => c)
            }
            .width('100%')
            TextInput({ text: this.title, placeholder: '标题' })
              .height(44)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .backgroundColor('#FFFFFF')
              .padding({ left: 12, right: 12 })
              .onChange((v: string) => { this.title = v })
            TextArea({ text: this.body, placeholder: this.kind === 'issue' ? '遇到了什么问题' : '写下方法、步骤或想法' })
              .height(120)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .backgroundColor('#FFFFFF')
              .onChange((v: string) => { this.body = v })
            TextArea({ text: this.extra, placeholder: this.extraLabel() })
              .height(80)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .backgroundColor('#FFFFFF')
              .onChange((v: string) => { this.extra = v })
            AppButton({
              label: '保存',
              variant: 'primary',
              onTap: (): void => { void this.save() }
            })
          }
          .padding(Theme.space.pageX)
          .width('100%')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 && this.editorOpen ?
        Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '16%', y: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
