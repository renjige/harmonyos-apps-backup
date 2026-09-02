import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { TeaItem, TeaTypeDef, TagItem } from '../../models/TeaModels'
import { TeaNav } from '../../services/TeaNav'
import { TeaStore } from '../../services/TeaStore'
import { DateFormatUtil } from '../design-system/DateFormatUtil'

@Component
export struct TeaEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop teaId: string = ''
  @State name: string = ''
  @State typeKey: string = 'green'
  @State brand: string = ''
  @State origin: string = ''
  @State yearText: string = ''
  @State collectedAt: string = ''
  @State packageNote: string = ''
  @State story: string = ''
  @State aromaNote: string = ''
  @State tasteNote: string = ''
  @State liquorNote: string = ''
  @State aftertasteNote: string = ''
  @State review: string = ''
  @State stockStatus: string = 'collected'
  @State selectedTags: string[] = []
  @State typeDefs: TeaTypeDef[] = []
  @State tagDefs: TagItem[] = []
  @State err: string = ''
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    this.typeDefs = TeaTypeDef.six()
    this.tagDefs = TeaStore.tags()
    this.collectedAt = DateFormatUtil.formatDate(new Date())
    if (this.teaId.length === 0) {
      return
    }
    const tea = TeaStore.findTea(this.teaId)
    if (tea === null) {
      return
    }
    this.name = tea.name
    this.typeKey = tea.typeKey.length > 0 ? tea.typeKey : 'green'
    this.brand = tea.brand
    this.origin = tea.origin
    this.yearText = tea.yearText
    this.collectedAt = tea.collectedAt
    this.packageNote = tea.packageNote
    this.story = tea.story
    this.aromaNote = tea.aromaNote
    this.tasteNote = tea.tasteNote
    this.liquorNote = tea.liquorNote
    this.aftertasteNote = tea.aftertasteNote
    this.review = tea.review
    this.stockStatus = tea.stockStatus
    this.selectedTags = tea.tagIds.slice()
  }

  private selectType(key: string): void {
    this.typeKey = key
  }

  private selectStatus(key: string): void {
    this.stockStatus = key
  }

  private toggleTag(id: string): void {
    const next: string[] = []
    let found = false
    for (const t of this.selectedTags) {
      if (t === id) {
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(id)
    }
    this.selectedTags = next
  }

  private isTagOn(id: string): boolean {
    return this.selectedTags.indexOf(id) >= 0
  }

  private async save(): Promise<void> {
    if (this.name.trim().length === 0) {
      this.err = '请填写茶名'
      return
    }
    let item = new TeaItem()
    if (this.teaId.length > 0) {
      const found = TeaStore.findTea(this.teaId)
      if (found !== null) {
        item = found
      }
    }
    if (item.id.length === 0) {
      item.id = TeaStore.newId('tea_')
    }
    item.name = this.name.trim()
    item.typeKey = this.typeKey
    item.brand = this.brand.trim()
    item.origin = this.origin.trim()
    item.yearText = this.yearText.trim()
    item.collectedAt = this.collectedAt
    item.packageNote = this.packageNote.trim()
    item.story = this.story.trim()
    item.aromaNote = this.aromaNote.trim()
    item.tasteNote = this.tasteNote.trim()
    item.liquorNote = this.liquorNote.trim()
    item.aftertasteNote = this.aftertasteNote.trim()
    item.review = this.review.trim()
    item.stockStatus = this.stockStatus
    item.tagIds = this.selectedTags.slice()
    await TeaStore.saveTea(item)
    this.onSaved()
    TeaNav.closeTeaEditor()
    TeaNav.openTea(item.id)
  }

  @Builder
  typeChip(d: TeaTypeDef) {
    Text(d.name)
      .fontSize(Theme.type.caption)
      .fontColor(this.typeKey === d.key ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.typeKey === d.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .margin({ right: 8, bottom: 8 })
      .onClick((): void => { this.selectType(d.key) })
  }

  @Builder
  statusChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.stockStatus === key ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.stockStatus === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .margin({ right: 8, bottom: 8 })
      .onClick((): void => { this.selectStatus(key) })
  }

  @Builder
  tagChip(t: TagItem) {
    Text(t.name)
      .fontSize(Theme.type.caption)
      .fontColor(this.isTagOn(t.id) ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.isTagOn(t.id) ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .margin({ right: 8, bottom: 8 })
      .onClick((): void => { this.toggleTag(t.id) })
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text(this.teaId.length > 0 ? '编辑茶档案' : '新增茶档案')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { TeaNav.closeTeaEditor() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          TextInput({ text: this.name, placeholder: '茶名（必填）' })
            .onChange((v: string) => { this.name = v })
          Text('茶类')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.typeDefs, (d: TeaTypeDef) => {
              this.typeChip(d)
            }, (d: TeaTypeDef) => d.key)
          }
          .width('100%')
          TextInput({ text: this.brand, placeholder: '品牌' }).onChange((v: string) => { this.brand = v })
          TextInput({ text: this.origin, placeholder: '产地' }).onChange((v: string) => { this.origin = v })
          TextInput({ text: this.yearText, placeholder: '年份' }).onChange((v: string) => { this.yearText = v })
          AppDatePickerField({
            label: '收藏日期',
            value: this.collectedAt,
            minDaysFromToday: -3650,
            maxDaysFromToday: 0,
            onChange: (v: string): void => { this.collectedAt = v }
          })
          TextInput({ text: this.packageNote, placeholder: '包装备注' }).onChange((v: string) => { this.packageNote = v })
          TextArea({ text: this.story, placeholder: '为什么收藏它？谁送的、哪里获得…' })
            .height(80)
            .onChange((v: string) => { this.story = v })
          TextInput({ text: this.aromaNote, placeholder: '香气印象' }).onChange((v: string) => { this.aromaNote = v })
          TextInput({ text: this.tasteNote, placeholder: '口感印象' }).onChange((v: string) => { this.tasteNote = v })
          TextInput({ text: this.liquorNote, placeholder: '茶汤特点' }).onChange((v: string) => { this.liquorNote = v })
          TextInput({ text: this.aftertasteNote, placeholder: '回甘' }).onChange((v: string) => { this.aftertasteNote = v })
          TextArea({ text: this.review, placeholder: '我的评价' })
            .height(64)
            .onChange((v: string) => { this.review = v })
          Text('库存状态')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            this.statusChip('已收藏', 'collected')
            this.statusChip('正在品饮', 'sipping')
            this.statusChip('已饮完', 'finished')
            this.statusChip('想尝试', 'wishlist')
          }
          .width('100%')
          Text('标签')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.tagDefs, (t: TagItem) => {
              this.tagChip(t)
            }, (t: TagItem) => t.id)
          }
          .width('100%')
          if (this.err.length > 0) {
            Text(this.err).fontSize(Theme.type.bodyS).fontColor(Theme.colors().danger)
          }
          AppButton({ label: '保存档案', variant: 'primary', onTap: (): void => { void this.save() } })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
