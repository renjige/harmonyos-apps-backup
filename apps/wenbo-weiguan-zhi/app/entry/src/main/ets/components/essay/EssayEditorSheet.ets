import { common } from '@kit.AbilityKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { EssayWriteEditor } from './EssayWriteEditor'
import { MicroEssay, SenseOption } from '../../models/EssayModels'
import { EssayStore } from '../../services/EssayStore'
import { SmartTagService } from '../../services/SmartTagService'
import { PhotoPickService } from '../../services/PhotoPickService'
import { ImagePathUtil } from '../../services/ImagePathUtil'
import { SenseCardDraft, SenseCardService } from '../../services/SenseCardService'
import { SenseCardPanel } from './SenseCardPanel'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct EssayEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop essayId: string = ''
  @Prop fontScale: number = 1
  @Prop openAsCard: boolean = true
  @Prop presetDateKey: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  @State title: string = ''
  @State seedBody: string = ''
  @State seedVersion: number = 0
  @State flushNonce: number = 0
  @State tagsCsv: string = ''
  @State tagInput: string = ''
  @State suggestTags: string[] = []
  @State imagePath: string = ''
  @State wordCount: number = 0
  @State saving: boolean = false
  @State toastText: string = ''
  @State entryId: string = ''
  @State senseKey: string = ''
  @State favorite: boolean = false
  @State cardMode: boolean = true
  @State cardSee: string = ''
  @State cardHear: string = ''
  @State cardScent: string = ''
  @State cardTouch: string = ''
  @State cardVerdict: string = ''
  @State cardHint: string = ''
  @State observeDateKey: string = ''
  private liveBody: string = ''
  private saveTimer: number = -1
  private closedAfterSave: boolean = false
  private uiContext: common.UIAbilityContext | null = null
  private senses: SenseOption[] = SenseOption.all()

  aboutToAppear(): void {
    void this.bootstrap()
  }

  aboutToDisappear(): void {
    if (this.saveTimer >= 0) {
      clearTimeout(this.saveTimer)
    }
    if (!this.closedAfterSave) {
      void this.persistIfHasContent()
    }
  }

  private async bootstrap(): Promise<void> {
    if (this.essayId.length > 0) {
      const found = await EssayStore.findById(this.essayId)
      if (found !== undefined) {
        this.entryId = found.id
        this.title = found.title
        this.seedBody = found.body
        this.liveBody = found.body
        this.tagsCsv = found.tagsCsv
        this.imagePath = found.imagePath
        this.wordCount = found.wordCount
        this.senseKey = found.senseKey
        this.favorite = found.favorite
        this.observeDateKey = DateHelper.normalizeKey(found.dateKey)
        if (this.observeDateKey.length === 0) {
          this.observeDateKey = EssayStore.resolvedDateKey(found)
        }
        this.applyParsedCard(found.body)
        this.refreshSuggest()
        this.seedVersion++
        return
      }
    }
    const e = MicroEssay.createNew()
    const preset = DateHelper.normalizeKey(this.presetDateKey)
    if (preset.length > 0) {
      e.dateKey = preset
    }
    this.entryId = e.id
    this.observeDateKey = e.dateKey
    this.cardMode = this.openAsCard
    const hint = AppStorage.get<string>('essayPracticeHint') ?? ''
    const cardHint = AppStorage.get<string>('essayCardHint') ?? ''
    if (hint.length > 0) {
      this.cardHint = hint
      AppStorage.setOrCreate('essayPracticeHint', '')
    } else if (cardHint.length > 0) {
      this.cardHint = cardHint
      AppStorage.setOrCreate('essayCardHint', '')
    }
    this.cardMode = true
    if (!this.openAsCard) {
      this.cardMode = false
    }
  }

  private applyParsedCard(body: string): void {
    if (SenseCardService.looksLikeCard(body)) {
      const d = SenseCardService.parse(body)
      this.cardSee = d.see
      this.cardHear = d.hear
      this.cardScent = d.scent
      this.cardTouch = d.touch
      this.cardVerdict = d.verdict
      this.cardMode = true
      return
    }
    this.cardMode = false
  }

  private currentDraft(): SenseCardDraft {
    const d = new SenseCardDraft()
    d.see = this.cardSee
    d.hear = this.cardHear
    d.scent = this.cardScent
    d.touch = this.cardTouch
    d.verdict = this.cardVerdict
    return d
  }

  private syncCardToBody(): void {
    const body = SenseCardService.compose(this.currentDraft())
    this.liveBody = body
    this.seedBody = body
    this.seedVersion++
    this.updateWordCount()
  }

  private switchToFree(): void {
    this.syncCardToBody()
    this.cardMode = false
  }

  private switchToCard(): void {
    const d = SenseCardService.parse(this.liveBody)
    this.cardSee = d.see
    this.cardHear = d.hear
    this.cardScent = d.scent
    this.cardTouch = d.touch
    this.cardVerdict = d.verdict
    this.cardMode = true
  }

  private currentBody(): string {
    return this.liveBody
  }

  private onBodyChange(text: string): void {
    this.liveBody = text
    this.updateWordCount()
    this.refreshSuggest()
    this.scheduleAutoSave()
  }

  private refreshSuggest(): void {
    this.suggestTags = SmartTagService.extractFromText(this.title, this.currentBody(), 5)
  }

  private updateWordCount(): void {
    const e = new MicroEssay()
    e.title = this.title
    e.body = this.currentBody()
    e.recomputeWordCount()
    this.wordCount = e.wordCount
  }

  private scheduleAutoSave(): void {
    if (this.saveTimer >= 0) {
      clearTimeout(this.saveTimer)
    }
    this.saveTimer = setTimeout((): void => {
      this.saveTimer = -1
      void this.persistIfHasContent()
    }, 1600)
  }

  private async persistIfHasContent(): Promise<void> {
    this.flushNonce++
    if (this.cardMode) {
      this.syncCardToBody()
    }
    const body = this.currentBody()
    if (this.title.trim().length === 0 && body.trim().length === 0 && this.imagePath.length === 0) {
      if (this.entryId.length > 0) {
        await EssayStore.saveDraft(this.entryId, this.title, body, this.tagsCsv, this.imagePath)
      }
      return
    }
    await this.writeEssay()
  }

  private async persist(): Promise<void> {
    this.flushNonce++
    if (this.cardMode) {
      if (!SenseCardService.hasAny(this.currentDraft())) {
        this.showToast('请至少填写观察卡中的一项')
        return
      }
      this.syncCardToBody()
    }
    const body = this.currentBody()
    if (this.title.trim().length === 0 && body.trim().length === 0 && this.imagePath.length === 0) {
      this.showToast('请先输入标题或正文')
      return
    }
    this.saving = true
    await this.writeEssay()
    this.saving = false
    this.closedAfterSave = true
    this.showToast('已保存')
    this.onSaved()
  }

  private async writeEssay(): Promise<void> {
    const body = this.currentBody()
    let essay: MicroEssay
    if (this.entryId.length > 0) {
      const found = await EssayStore.findById(this.entryId)
      essay = found ?? MicroEssay.createNew()
      if (found === undefined) {
        essay.id = this.entryId
      }
    } else {
      essay = MicroEssay.createNew()
      this.entryId = essay.id
    }
    essay.title = this.title.trim()
    essay.body = body
    essay.imagePath = this.imagePath
    essay.senseKey = this.senseKey
    essay.favorite = this.favorite
    if (this.observeDateKey.length > 0) {
      essay.dateKey = DateHelper.normalizeKey(this.observeDateKey)
    } else if (essay.dateKey.length === 0) {
      essay.dateKey = MicroEssay.keyFromDate(new Date())
    }
    if (this.cardMode) {
      const d = this.currentDraft()
      if (essay.title.length === 0) {
        essay.title = SenseCardService.defaultTitle(d, essay.dateKey)
        this.title = essay.title
      }
      if (essay.senseKey.length === 0) {
        essay.senseKey = SenseCardService.inferSenseKey(d)
        this.senseKey = essay.senseKey
      }
      essay.kind = 'card'
    } else if (essay.kind !== 'contrast') {
      essay.kind = 'free'
    }
    const suggested = SmartTagService.extractFromText(essay.title, essay.body, 5)
    const merged = SmartTagService.mergeTags(MicroEssay.parseTags(this.tagsCsv), suggested, 8)
    essay.tagsCsv = MicroEssay.joinTags(merged)
    this.tagsCsv = essay.tagsCsv
    await EssayStore.saveEssay(essay)
  }

  private addManualTag(): void {
    const t = this.tagInput.trim()
    if (t.length === 0) {
      this.showToast('请输入标签')
      return
    }
    const list = MicroEssay.parseTags(this.tagsCsv)
    const merged = SmartTagService.mergeTags(list, [t], 8)
    this.tagsCsv = MicroEssay.joinTags(merged)
    this.tagInput = ''
    this.scheduleAutoSave()
  }

  private addSuggest(name: string): void {
    const list = MicroEssay.parseTags(this.tagsCsv)
    const merged = SmartTagService.mergeTags(list, [name], 8)
    this.tagsCsv = MicroEssay.joinTags(merged)
    this.scheduleAutoSave()
  }

  private removeTag(name: string): void {
    const list = MicroEssay.parseTags(this.tagsCsv)
    const next: string[] = []
    for (const t of list) {
      if (t !== name) {
        next.push(t)
      }
    }
    this.tagsCsv = MicroEssay.joinTags(next)
    this.scheduleAutoSave()
  }

  private async pickAlbum(): Promise<void> {
    if (this.uiContext === null) {
      const host = this.getUIContext().getHostContext()
      if (host !== undefined) {
        this.uiContext = host as common.UIAbilityContext
      }
    }
    if (this.uiContext === null) {
      this.showToast('无法打开相册')
      return
    }
    const uri = await PhotoPickService.pickAlbum(this.uiContext)
    if (uri.length > 0) {
      this.imagePath = uri
      void this.persistIfHasContent()
      this.showToast('配图已添加')
      return
    }
    if (PhotoPickService.lastError.length > 0) {
      this.showToast(PhotoPickService.lastError)
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private backfillLabel(): string {
    const key = DateHelper.normalizeKey(this.observeDateKey)
    if (key.length === 0 || key === DateHelper.todayKey()) {
      return ''
    }
    return `补记观察日：${DateHelper.displayDate(key)}`
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text(this.essayId.length > 0 ? '编辑观察' : (this.cardMode ? '新建观察卡' : '新建观察'))
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Text(this.saving ? '保存中…' : '保存')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor('#1A2A3A')
            .border({ width: 1, color: '#C9A96E' })
            .borderRadius(Theme.radius.sm)
            .onClick((): void => { void this.persist() })
        }
        .width('100%')
        .padding({ left: Theme.space.s2, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.backfillLabel().length > 0) {
              Text(this.backfillLabel())
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().brandPrimary)
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.sm)
            }
            Row({ space: Theme.space.s2 }) {
              Text('观察卡')
                .fontSize(Theme.type.bodyS)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.cardMode ? '#FFFFFF' : Theme.colors().textPrimary)
                .textAlign(TextAlign.Center)
                .layoutWeight(1)
                .padding({ top: 8, bottom: 8 })
                .backgroundColor(this.cardMode ? '#1A2A3A' : Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { this.switchToCard() })
              Text('自由观察')
                .fontSize(Theme.type.bodyS)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.cardMode ? Theme.colors().textPrimary : '#FFFFFF')
                .textAlign(TextAlign.Center)
                .layoutWeight(1)
                .padding({ top: 8, bottom: 8 })
                .backgroundColor(this.cardMode ? Theme.colors().brandPrimaryContainer : '#1A2A3A')
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { this.switchToFree() })
            }
            .width('100%')

            TextInput({ text: this.title, placeholder: '标题（可选，观察卡可自动生成）' })
              .width('100%')
              .height(48)
              .fontSize(Theme.type.title3 * this.fontScale)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .padding(Theme.space.s3)
              .onChange((v: string) => {
                this.title = v
                this.updateWordCount()
                this.refreshSuggest()
                this.scheduleAutoSave()
              })

            Text('观察维度')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.senses, (s: SenseOption) => {
                Text(s.label)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.senseKey === s.key ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.senseKey === s.key ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => {
                    this.senseKey = this.senseKey === s.key ? '' : s.key
                    this.scheduleAutoSave()
                  })
              }, (s: SenseOption) => s.key)
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('智慧标签')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text('输入后点添加，或点下方推荐词')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                TextInput({ text: this.tagInput, placeholder: '手动添加标签，如 晨光' })
                  .layoutWeight(1)
                  .height(44)
                  .backgroundColor(Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.md)
                  .padding({ left: 12, right: 12 })
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .onChange((v: string) => { this.tagInput = v })
                Text('添加')
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .textAlign(TextAlign.Center)
                  .width(88)
                  .height(44)
                  .backgroundColor('#1A2A3A')
                  .border({ width: 1, color: '#C9A96E' })
                  .borderRadius(Theme.radius.md)
                  .onClick((): void => { this.addManualTag() })
              }
              .width('100%')
              if (MicroEssay.parseTags(this.tagsCsv).length > 0) {
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(MicroEssay.parseTags(this.tagsCsv), (tag: string) => {
                    Text(`${tag}  ×`)
                      .fontSize(Theme.type.bodyS)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                      .backgroundColor(Theme.colors().brandPrimaryContainer)
                      .borderRadius(Theme.radius.pill)
                      .margin({ right: 8, bottom: 8 })
                      .onClick((): void => { this.removeTag(tag) })
                  }, (tag: string) => `sel_${tag}`)
                }
                .width('100%')
              }
              if (this.suggestTags.length > 0) {
                Text('推荐')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .width('100%')
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.suggestTags, (tag: string) => {
                    Text(`+ ${tag}`)
                      .fontSize(Theme.type.bodyS)
                      .fontColor('#FFFFFF')
                      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                      .backgroundColor('#1A2A3A')
                      .borderRadius(Theme.radius.pill)
                      .margin({ right: 8, bottom: 8 })
                      .onClick((): void => { this.addSuggest(tag) })
                  }, (tag: string) => `sug_${tag}`)
                }
                .width('100%')
              }
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)

            if (this.cardMode) {
              SenseCardPanel({
                cardSee: $cardSee,
                cardHear: $cardHear,
                cardScent: $cardScent,
                cardTouch: $cardTouch,
                cardVerdict: $cardVerdict,
                fontScale: this.fontScale,
                hint: this.cardHint,
                onChanged: (): void => {
                  this.syncCardToBody()
                  this.refreshSuggest()
                  this.scheduleAutoSave()
                }
              })
            } else {
              EssayWriteEditor({
                seedBody: this.seedBody,
                seedVersion: this.seedVersion,
                fontScale: this.fontScale,
                flushNonce: this.flushNonce,
                onDraftChange: (text: string): void => { this.onBodyChange(text) },
                onFormatToast: (msg: string): void => { this.showToast(msg) }
              })
                .height(240)
            }

            if (this.imagePath.length > 0) {
              Stack({ alignContent: Alignment.TopEnd }) {
                Image(ImagePathUtil.toDisplayUri(this.imagePath))
                  .width('100%')
                  .height(160)
                  .borderRadius(Theme.radius.md)
                  .objectFit(ImageFit.Cover)
                Row() {
                  AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textOnInverse })
                }
                .padding(8)
                .backgroundColor('rgba(0,0,0,0.35)')
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  this.imagePath = ''
                  void this.persistIfHasContent()
                })
              }
            }

            AppButton({ label: '从相册选图', variant: 'secondary', onTap: (): void => { void this.pickAlbum() } })
              .width('100%')

            Row() {
              AppIcon({
                name: 'heart',
                iconSize: Theme.icon.md,
                color: this.favorite ? Theme.colors().danger : Theme.colors().textSecondary
              })
              Text(this.favorite ? '已珍藏' : '珍藏这条观察')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .margin({ left: 8 })
            }
            .width('100%')
            .height(48)
            .padding({ left: 4 })
            .onClick((): void => {
              this.favorite = !this.favorite
              this.scheduleAutoSave()
            })

            Text(`${this.wordCount} 字 · 离开本页也会自动保存`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor('#1A2A3A')
          .borderRadius(Theme.radius.pill)
          .border({ width: 1, color: '#C9A96E' })
          .position({ x: '10%', y: 52 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(80)
    .onAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', true)
      const host = this.getUIContext().getHostContext()
      if (host !== undefined) {
        this.uiContext = host as common.UIAbilityContext
      }
    })
    .onDisAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
    })
  }
}
