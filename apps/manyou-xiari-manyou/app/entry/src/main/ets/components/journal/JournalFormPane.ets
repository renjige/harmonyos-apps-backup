import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { DetailShell } from '../detail/DetailShell'
import { JournalItem, CoverOption } from '../../models/WanderModels'
import { WanderDetailNav } from '../../services/WanderDetailNav'
import { WanderLocalStore } from '../../services/WanderLocalStore'
import { WanderMedia } from '../../services/WanderMedia'

@Component
export struct JournalFormPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @Prop @Watch('onEditIdChange') refreshToken: number = 0
  @State title: string = ''
  @State place: string = ''
  @State body: string = ''
  @State mood: string = '开心'
  @State dateLabel: string = ''
  @State coverKey: string = ''
  @State errorText: string = ''
  @State saving: boolean = false
  private moods: string[] = ['开心', '放松', '惊喜', '治愈']
  private covers: CoverOption[] = JournalFormPane.coverOptions()

  private static coverOptions(): CoverOption[] {
    const out: CoverOption[] = []
    const a = new CoverOption()
    a.key = ''
    a.label = '不配图'
    out.push(a)
    const b = new CoverOption()
    b.key = 'hero_summer'
    b.label = '夏风'
    out.push(b)
    const c = new CoverOption()
    c.key = 'route_valley'
    c.label = '溪谷'
    out.push(c)
    const d = new CoverOption()
    d.key = 'route_lake'
    d.label = '湖畔'
    out.push(d)
    const e = new CoverOption()
    e.key = 'route_park'
    e.label = '树影'
    out.push(e)
    return out
  }

  aboutToAppear(): void {
    void this.hydrate()
  }

  onEditIdChange(): void {
    void this.hydrate()
  }

  private async hydrate(): Promise<void> {
    this.errorText = ''
    if (this.editId.length > 0) {
      const found = await WanderLocalStore.findJournal(this.editId)
      if (found !== undefined) {
        this.title = found.title
        this.place = found.place
        this.body = found.body
        this.mood = found.mood
        this.dateLabel = found.dateLabel
        this.coverKey = found.coverKey.length > 0 ? found.coverKey :
          (found.photoUri.length > 0 ? 'hero_summer' : '')
        return
      }
    }
    const dt = AppStorage.get<string>('journalDraftTitle')
    const dp = AppStorage.get<string>('journalDraftPlace')
    const dc = AppStorage.get<string>('journalDraftCover')
    this.title = dt !== undefined && dt !== null ? dt : ''
    this.place = dp !== undefined && dp !== null ? dp : ''
    this.coverKey = dc !== undefined && dc !== null ? dc : ''
    this.body = ''
    this.mood = '开心'
    this.dateLabel = WanderLocalStore.todayLabel().replace(/\./g, '-')
    AppStorage.setOrCreate('journalDraftTitle', '')
    AppStorage.setOrCreate('journalDraftPlace', '')
    AppStorage.setOrCreate('journalDraftCover', '')
  }

  private async save(): Promise<void> {
    if (this.saving) {
      return
    }
    if (this.title.trim().length === 0) {
      this.errorText = '先写一个标题吧'
      return
    }
    if (this.body.trim().length === 0) {
      this.errorText = '沿途想留下一句？'
      return
    }
    this.saving = true
    const item = new JournalItem()
    item.id = this.editId.length > 0 ? this.editId : WanderLocalStore.newId('jn')
    item.title = this.title.trim()
    item.place = this.place.trim()
    item.body = this.body.trim()
    item.mood = this.mood
    item.dateLabel = this.dateLabel.length > 0 ? this.dateLabel : WanderLocalStore.todayLabel()
    item.coverKey = this.coverKey
    item.photoUri = ''
    if (this.editId.length > 0) {
      const prev = await WanderLocalStore.findJournal(this.editId)
      item.createdAt = prev !== undefined ? prev.createdAt : Date.now()
    } else {
      item.createdAt = Date.now()
    }
    await WanderLocalStore.upsertJournal(item)
    WanderLocalStore.notifyDataChanged()
    this.saving = false
    WanderDetailNav.close()
  }

  build() {
    DetailShell({ title: this.editId.length > 0 ? '编辑记录' : '新建记录', onClose: () => WanderDetailNav.close() }) {
      Column({ space: 14 }) {
        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
        }
        Text('标题')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextInput({ text: this.title, placeholder: '给这段路起个名字' })
          .onChange((v: string) => { this.title = v })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
        Text('地点')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextInput({ text: this.place, placeholder: '在哪儿走了走' })
          .onChange((v: string) => { this.place = v })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
        AppDatePickerField({
          label: '日期',
          value: this.dateLabel,
          minDaysFromToday: -365,
          maxDaysFromToday: 1,
          onChange: (v: string) => { this.dateLabel = v }
        })
        Text('心情')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Row({ space: 8 }) {
          ForEach(this.moods, (m: string) => {
            Text(m)
              .fontSize(Theme.type.footnote)
              .fontColor(this.mood === m ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.mood === m ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.mood = m })
          }, (m: string) => m)
        }
        .width('100%')
        Text('配图')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text('从应用内置夏景图里选一张，不读取相册、不申请相机权限。')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.covers, (c: CoverOption) => {
              Text(c.label)
                .fontSize(Theme.type.footnote)
                .fontColor(this.coverKey === c.key ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.coverKey === c.key ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.coverKey = c.key })
            }, (c: CoverOption) => `cv_${c.key}`)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        if (this.coverKey.length > 0) {
          Image(WanderMedia.resource(this.coverKey))
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
        }
        Text('正文')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextArea({ text: this.body, placeholder: '风、光、一句不想赶路的话。' })
          .onChange((v: string) => { this.body = v })
          .height(160)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
        AppButton({
          label: this.saving ? '保存中' : '保存记录',
          variant: 'primary',
          disabled: this.saving,
          onTap: (): void => { void this.save() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
