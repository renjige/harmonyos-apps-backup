import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ObserveImage } from './ObserveImage'
import { CategoryOption, ObserveSubject } from '../../models/ObserveCatalog'
import { ObserveAtlasStore } from '../../services/ObserveAtlasStore'
import { PhotoPickService } from '../../services/PhotoPickService'
import { AppContextService } from '../../services/AppContextService'

@Component
export struct SubjectEditorOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editing: ObserveSubject = new ObserveSubject()
  onClose: () => void = () => {}
  onSaved: (id: string) => void = () => {}
  @State name: string = ''
  @State categoryKey: string = 'nature'
  @State traits: string = ''
  @State knowledge: string = ''
  @State coverPath: string = ''
  @State remindWeekly: boolean = false
  @State toastText: string = ''
  @State saving: boolean = false

  aboutToAppear(): void {
    if (this.editing.id.length > 0) {
      this.name = this.editing.name
      this.categoryKey = this.editing.categoryKey
      this.traits = this.editing.traits
      this.knowledge = this.editing.knowledge
      this.coverPath = this.editing.coverPath
      this.remindWeekly = this.editing.remindWeekly
    } else {
      this.categoryKey = this.editing.categoryKey.length > 0 ? this.editing.categoryKey : 'nature'
      this.knowledge = CategoryOption.knowledgeOf(this.categoryKey)
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async pickCover(): Promise<void> {
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      this.showToast('无法打开相册')
      return
    }
    const picked = await PhotoPickService.pickImages(ctx, 1)
    if (picked.length > 0) {
      this.coverPath = picked[0]
    }
  }

  private onCat(key: string): void {
    this.categoryKey = key
    if (this.knowledge.length === 0 || this.knowledge === CategoryOption.knowledgeOf(this.editing.categoryKey)) {
      this.knowledge = CategoryOption.knowledgeOf(key)
    }
  }

  private async handleSave(): Promise<void> {
    if (this.saving) {
      return
    }
    this.saving = true
    const s = this.editing.id.length > 0 ? this.editing : ObserveSubject.create(this.name, this.categoryKey)
    s.name = this.name
    s.categoryKey = this.categoryKey
    s.traits = this.traits
    s.knowledge = this.knowledge
    s.coverPath = this.coverPath
    s.remindWeekly = this.remindWeekly
    const ok = await ObserveAtlasStore.save(s)
    this.saving = false
    if (!ok) {
      this.showToast('请填写物品名称')
      return
    }
    this.onSaved(s.id)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text(this.editing.id.length > 0 ? '编辑图鉴' : '新建图鉴')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Text('取消')
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => this.onClose())
        }
        .width('100%')
        .padding(Theme.space.s4)

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            TextInput({ text: this.name, placeholder: '名称，如阳台绿萝' })
              .onChange((v: string): void => { this.name = v })
            TextArea({ text: this.traits, placeholder: '特点：颜色、材质、发现地点…' })
              .height(80)
              .maxLength(200)
              .onChange((v: string): void => { this.traits = v })
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(CategoryOption.all(), (c: CategoryOption) => {
                Text(c.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.categoryKey === c.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.categoryKey === c.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => this.onCat(c.key))
              }, (c: CategoryOption) => c.key)
            }
            .width('100%')
            TextArea({ text: this.knowledge, placeholder: '知识补充 / 背景信息' })
              .height(96)
              .maxLength(400)
              .onChange((v: string): void => { this.knowledge = v })
            AppButton({
              label: this.coverPath.length > 0 ? '更换封面图片' : '添加封面图片',
              variant: 'secondary',
              onTap: (): void => { void this.pickCover() }
            })
            if (this.coverPath.length > 0) {
              ObserveImage({ path: this.coverPath, imgWidth: 120, imgHeight: 120 })
            }
            Row() {
              Text('每周观察提醒（在智慧提醒时段提示复访）').layoutWeight(1).fontSize(Theme.type.bodyS)
              Toggle({ type: ToggleType.Switch, isOn: this.remindWeekly })
                .onChange((v: boolean): void => { this.remindWeekly = v })
            }
            .width('100%')
          }
          .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s6 })
        }
        .layoutWeight(1)

        AppButton({
          label: this.saving ? '保存中…' : '保存到图鉴',
          variant: 'primary',
          disabled: this.saving || this.name.trim().length === 0,
          onTap: (): void => { void this.handleSave() }
        })
          .margin({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s6 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '12%', y: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
