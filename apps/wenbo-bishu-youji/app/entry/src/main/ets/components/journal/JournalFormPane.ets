import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { DetailShell } from '../detail/DetailShell'
import { DestItem, JournalCreateRequest } from '../../models/EscapeModels'
import { EscapeBizService } from '../../services/EscapeBizService'
import { EscapeDetailNav } from '../../services/EscapeDetailNav'
import { EscapeMedia } from '../../services/EscapeMedia'

@Component
export struct JournalFormPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @State title: string = ''
  @State body: string = ''
  @State destId: string = ''
  @State destName: string = ''
  @State visitDate: string = ''
  @State coverKey: string = ''
  @State dests: DestItem[] = []
  @State errorText: string = ''
  @State saving: boolean = false

  aboutToAppear(): void {
    void this.hydrate()
  }

  onRefresh(): void {
    void this.hydrate()
  }

  private async hydrate(): Promise<void> {
    this.errorText = ''
    this.dests = await EscapeBizService.loadDestinations()
    const did = AppStorage.get<string>('journalDraftDestId')
    const dname = AppStorage.get<string>('journalDraftDestName')
    const dc = AppStorage.get<string>('journalDraftCover')
    this.destId = did !== undefined && did !== null ? did : ''
    this.destName = dname !== undefined && dname !== null ? dname : ''
    this.coverKey = dc !== undefined && dc !== null ? dc : ''
    this.title = this.destName.length > 0 ? `${this.destName}这一天` : ''
    this.body = ''
    this.visitDate = JournalFormPane.today()
    AppStorage.setOrCreate('journalDraftDestId', '')
    AppStorage.setOrCreate('journalDraftDestName', '')
    AppStorage.setOrCreate('journalDraftCover', '')
  }

  private static today(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  private pickDest(d: DestItem): void {
    this.destId = d.id
    this.destName = d.title
    this.coverKey = d.coverKey
    if (this.title.length === 0) {
      this.title = `${d.title}这一天`
    }
  }

  private async save(): Promise<void> {
    if (this.saving) {
      return
    }
    if (this.title.trim().length === 0) {
      this.errorText = '请填写标题'
      return
    }
    if (this.body.trim().length === 0) {
      this.errorText = '请写下一段旅途'
      return
    }
    if (this.destId.length === 0) {
      this.errorText = '请标记一个目的地'
      return
    }
    this.saving = true
    const req = new JournalCreateRequest()
    req.title = this.title.trim()
    req.body = this.body.trim()
    req.destId = this.destId
    req.destName = this.destName
    req.placeLabel = this.destName
    req.visitDate = this.visitDate
    req.coverKey = this.coverKey
    const ok = await EscapeBizService.createJournal(req)
    this.saving = false
    if (ok) {
      EscapeDetailNav.close()
      return
    }
    this.errorText = '保存失败，请检查网络后重试'
  }

  build() {
    DetailShell({ title: '新建游记', onClose: () => EscapeDetailNav.close() }) {
      Column({ space: Theme.space.s4 }) {
        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
        }
        TextInput({ text: this.title, placeholder: '标题' })
          .onChange((v: string) => { this.title = v })
          .height(48)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
        TextArea({ text: this.body, placeholder: '写一段凉快的记忆…' })
          .onChange((v: string) => { this.body = v })
          .height(140)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
        AppDatePickerField({
          label: '出行日期',
          value: this.visitDate,
          minDaysFromToday: -400,
          maxDaysFromToday: 1,
          onChange: (v: string) => { this.visitDate = v }
        })
        Text('标记目的地')
          .fontSize(Theme.type.subtitleS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.dests, (d: DestItem) => {
            Text(d.title)
              .fontSize(Theme.type.caption)
              .fontColor(this.destId === d.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.destId === d.id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick(() => this.pickDest(d))
          }, (d: DestItem) => d.id)
        }
        .width('100%')
        if (this.coverKey.length > 0) {
          Image(EscapeMedia.resource(this.coverKey))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
        }
        AppButton({
          label: this.saving ? '保存中…' : '保存游记',
          disabled: this.saving,
          onTap: (): void => { void this.save() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
