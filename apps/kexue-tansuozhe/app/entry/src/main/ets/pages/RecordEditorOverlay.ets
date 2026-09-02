import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { DetailShell } from '../components/detail/DetailShell'
import { UserDiscovery } from '../models/ExplorationModels'
import { ExplorationStore } from '../services/ExplorationStore'
import { ExploreNav } from '../services/ExploreNav'
import { ExploreToast } from '../services/ExploreToast'

class CatOption {
  key: string = ''
  label: string = ''
}

@Component
export struct RecordEditorOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('recordEditorId') @Watch('onEditorIdChange') editorId: string = ''
  @State title: string = ''
  @State category: string = 'nature'
  @State description: string = ''
  @State whyInteresting: string = ''
  @State feeling: string = ''
  @State learned: string = ''
  @State placeText: string = ''
  @State tagsText: string = ''
  @State errorText: string = ''
  onToast: (msg: string) => void = () => {}
  private cats: CatOption[] = RecordEditorOverlay.buildCats()

  aboutToAppear(): void {
    this.bootstrapForm()
  }

  onEditorIdChange(): void {
    this.bootstrapForm()
  }

  private static buildCats(): CatOption[] {
    const list: CatOption[] = []
    const defs: string[][] = [
      ['nature', '自然'], ['life', '生活'], ['science', '科学'], ['culture', '人文'], ['fun', '趣味']
    ]
    for (const d of defs) {
      const c = new CatOption()
      c.key = d[0]
      c.label = d[1]
      list.push(c)
    }
    return list
  }

  private bootstrapForm(): void {
    this.errorText = ''
    if (this.editorId.length === 0) {
      this.title = ''
      this.category = 'nature'
      this.description = ''
      this.whyInteresting = ''
      this.feeling = ''
      this.learned = ''
      this.placeText = ''
      this.tagsText = ''
      return
    }
    const d = ExplorationStore.findDiscovery(this.editorId)
    if (d === undefined) {
      return
    }
    this.title = d.title
    this.category = d.category
    this.description = d.description
    this.whyInteresting = d.whyInteresting
    this.feeling = d.feeling
    this.learned = d.learned
    this.placeText = d.placeText
    this.tagsText = d.tags.join(' ')
  }

  private clearError(): void {
    if (this.errorText.length > 0) {
      this.errorText = ''
    }
  }

  private async save(): Promise<void> {
    const titleTrim = this.title.trim()
    const descTrim = this.description.trim()
    if (titleTrim.length < 2) {
      this.errorText = '标题至少 2 个字'
      ExploreToast.show('标题至少 2 个字')
      return
    }
    if (descTrim.length < 2) {
      this.errorText = '「我注意到了什么」至少 2 个字'
      ExploreToast.show('请填写至少 2 字的观察描述')
      return
    }
    const input = new UserDiscovery()
    input.id = this.editorId
    input.title = titleTrim
    input.category = this.category
    input.description = descTrim
    input.whyInteresting = this.whyInteresting.trim()
    input.feeling = this.feeling.trim()
    input.learned = this.learned.trim()
    input.placeText = this.placeText.trim()
    input.status = 'exploring'
    const tags: string[] = []
    const parts = this.tagsText.split(/[\s,，]+/)
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0 && tags.length < 5) {
        tags.push(t)
      }
    }
    input.tags = tags
    await ExplorationStore.saveDiscovery(input)
    await ExplorationStore.completeTask('task_record1')
    if (this.feeling.trim().length > 0) {
      await ExplorationStore.completeTask('task_feeling1')
    }
    this.errorText = ''
    this.onToast('探索记录已保存')
    ExploreToast.show('探索记录已保存')
    ExploreNav.closeRecordEditor()
  }

  build() {
    DetailShell({
      title: this.editorId.length > 0 ? '编辑发现' : '新建发现',
      onClose: (): void => { ExploreNav.closeRecordEditor() }
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.errorText.length > 0) {
            Text(this.errorText)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().danger)
              .width('100%')
          }

          Text('标题')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          TextInput({ text: this.title, placeholder: '例如：窗台的绿萝新芽' })
            .width('100%')
            .height(44)
            .fontSize(Theme.type.body)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .padding({ left: 12, right: 12 })
            .onChange((v: string): void => {
              this.title = v
              this.clearError()
            })

          Text('分类')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.cats, (c: CatOption) => {
              Text(c.label)
                .fontSize(Theme.type.footnote)
                .fontColor(this.category === c.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.category === c.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => { this.category = c.key })
            }, (c: CatOption) => c.key)
          }
          .width('100%')

          Text('我注意到了什么')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(`至少 2 字 · 已输入 ${this.description.trim().length} 字`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.description, placeholder: '例如：叶片边缘有锯齿，颜色比旁边深' })
            .width('100%')
            .height(88)
            .fontSize(Theme.type.body)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onChange((v: string): void => {
              this.description = v
              this.clearError()
            })

          Text('为什么有趣')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          TextArea({ text: this.whyInteresting, placeholder: '可选：说说哪里吸引你' })
            .width('100%')
            .height(72)
            .fontSize(Theme.type.body)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onChange((v: string): void => { this.whyInteresting = v })

          Text('我的感受')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          TextArea({ text: this.feeling, placeholder: '可选' })
            .width('100%')
            .height(72)
            .fontSize(Theme.type.body)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onChange((v: string): void => { this.feeling = v })

          Text('我理解了什么')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          TextArea({ text: this.learned, placeholder: '可选' })
            .width('100%')
            .height(72)
            .fontSize(Theme.type.body)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onChange((v: string): void => { this.learned = v })

          Text('在哪里（文字描述）')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          TextArea({ text: this.placeText, placeholder: '例如：小区楼下、公司茶水间' })
            .width('100%')
            .height(72)
            .fontSize(Theme.type.body)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onChange((v: string): void => { this.placeText = v })

          Text('标签（空格分隔）')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          TextInput({ text: this.tagsText, placeholder: '自然 观察' })
            .width('100%')
            .height(44)
            .fontSize(Theme.type.body)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .padding({ left: 12, right: 12 })
            .onChange((v: string): void => { this.tagsText = v })

          AppButton({
            label: '保存记录',
            onTap: (): void => { void this.save() }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height('100%')
    }
  }
}
