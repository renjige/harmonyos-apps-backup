import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { MoodChipRow } from '../components/journal/MoodChipRow'
import { JournalEntry, PickupItem, TagItem } from '../models/ShiyiModels'
import { ShiyiNav } from '../services/ShiyiNav'
import { ShiyiStore } from '../services/ShiyiStore'

@Component
export struct ComposePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entryId: string = ''
  @Prop entryDate: string = ''
  @Prop @Watch('onOpenChange') openToken: number = 0
  onSaved: (message: string) => void = (message: string) => {}
  @State moodId: string = ''
  @State title: string = ''
  @State body: string = ''
  @State keyword: string = ''
  @State oneLiner: string = ''
  @State selectedTags: string[] = []
  @State allTags: TagItem[] = []
  @State dateLabel: string = ''
  @State editingId: string = ''

  aboutToAppear(): void {
    this.hydrate()
  }

  onOpenChange(): void {
    this.hydrate()
  }

  private hydrate(): void {
    this.allTags = ShiyiStore.tags()
    const date = this.entryDate.length > 0 ? this.entryDate : ShiyiStore.today()
    this.dateLabel = ShiyiStore.displayDate(date)
    let found: JournalEntry | null = null
    if (this.entryId.length > 0) {
      found = ShiyiStore.findJournal(this.entryId)
    }
    if (found === null && this.entryId.length === 0) {
      const list = ShiyiStore.findByDate(date)
      for (const item of list) {
        found = item
        break
      }
    }
    if (found !== null) {
      this.editingId = found.id
      this.moodId = found.mood
      this.title = found.title
      this.body = found.body
      this.keyword = found.keyword
      this.oneLiner = found.oneLiner
      this.selectedTags = found.tags
      this.dateLabel = ShiyiStore.displayDate(found.entryDate)
      return
    }
    this.editingId = ''
    this.moodId = ''
    this.title = ''
    this.body = ''
    this.keyword = ''
    this.oneLiner = ''
    this.selectedTags = []
  }

  private hasTag(name: string): boolean {
    for (const tag of this.selectedTags) {
      if (tag === name) {
        return true
      }
    }
    return false
  }

  private toggleTag(name: string): void {
    const next: string[] = []
    let removed = false
    for (const tag of this.selectedTags) {
      if (tag === name) {
        removed = true
      } else {
        next.push(tag)
      }
    }
    if (!removed) {
      next.push(name)
    }
    this.selectedTags = next
  }

  private async save(): Promise<void> {
    if (this.body.trim().length === 0 && this.oneLiner.trim().length === 0 && this.title.trim().length === 0) {
      this.onSaved('先写下一点心意吧。')
      return
    }
    const entry = new JournalEntry()
    entry.id = this.editingId.length > 0 ? this.editingId : ShiyiStore.newId('j')
    const existing = ShiyiStore.findJournal(entry.id)
    entry.entryDate = existing !== null ? existing.entryDate : (this.entryDate.length > 0 ? this.entryDate : ShiyiStore.today())
    entry.createdAt = existing !== null ? existing.createdAt : Date.now()
    entry.updatedAt = Date.now()
    entry.mood = this.moodId
    entry.title = this.title.trim()
    entry.body = this.body.trim()
    entry.keyword = this.keyword.trim()
    entry.oneLiner = this.oneLiner.trim()
    entry.tags = this.selectedTags
    entry.favorite = existing !== null ? existing.favorite : false
    const ok = await ShiyiStore.saveJournal(entry)
    if (!ok) {
      this.onSaved('暂时无法保存，请稍后再试。')
      return
    }
    if (entry.oneLiner.length > 0) {
      const pickup = new PickupItem()
      pickup.id = ShiyiStore.newId('p')
      pickup.kind = 'sentence'
      pickup.text = entry.oneLiner
      pickup.sourceId = entry.id
      pickup.createdAt = Date.now()
      await ShiyiStore.savePickup(pickup)
    }
    this.onSaved('已拾取今日心意')
    ShiyiNav.closeCompose()
  }

  build() {
    Column() {
      AppNavBar({
        title: '写下今天',
        onBack: (): void => {
          ShiyiNav.closeCompose()
        }
      })
      Text(this.dateLabel)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().brandAccent)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Column({ space: Theme.space.s3 }) {
            Text('今日心情')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            MoodChipRow({
              selectedId: this.moodId,
              onSelect: (id: string) => {
                this.moodId = id
              }
            })
          }
          .width('100%')

          this.Field('标题', this.title, '给这一页起个名字', (v: string) => {
            this.title = v
          })
          Column({ space: Theme.space.s2 }) {
            Text('正文')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            TextArea({ text: this.body, placeholder: '写下今天最值得记住的一件事……' })
              .height(160)
              .fontSize(Theme.type.body)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .padding(Theme.space.s4)
              .onChange((v: string) => {
                this.body = v
              })
          }
          .width('100%')
          this.Field('今日关键词', this.keyword, '一个词就好', (v: string) => {
            this.keyword = v
          })
          this.Field('今日一句话', this.oneLiner, '今天的风很温柔。', (v: string) => {
            this.oneLiner = v
          })

          Column({ space: Theme.space.s3 }) {
            Text('标签')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.allTags, (tag: TagItem) => {
                Text(tag.name)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.hasTag(tag.name) ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.hasTag(tag.name) ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.tag)
                  .onClick(() => {
                    this.toggleTag(tag.name)
                  })
              }, (tag: TagItem) => tag.id)
            }
            .width('100%')
          }
          .width('100%')
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s8
        })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)

      Column() {
        AppButton({
          label: '保存这份拾意',
          onTap: (): void => {
            void this.save()
          }
        })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s3,
        bottom: Theme.space.pageY
      })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Field(label: string, value: string, placeholder: string, onChange: (v: string) => void) {
    Column({ space: Theme.space.s2 }) {
      Text(label)
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      TextInput({ text: value, placeholder: placeholder })
        .height(48)
        .fontSize(Theme.type.body)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .padding({ left: 14, right: 14 })
        .onChange((v: string) => {
          onChange(v)
        })
    }
    .width('100%')
  }
}
