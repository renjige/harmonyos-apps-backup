import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { LanguageEngineService } from '../services/LanguageEngineService'
import { LanguageCraftNav } from '../services/LanguageCraftNav'
import {
  IssueItem,
  PolishChange,
  PolishRecord,
  PolishResult,
  SampleChip,
  StyleChip
} from '../models/LanguageCraftModels'
import { LanguageCraftBizService } from '../services/LanguageCraftBizService'
import { LocalRecordStore } from '../services/LocalRecordStore'
import { ClipboardService } from '../services/ClipboardService'
import { HubStore } from '../services/HubStore'
import { Manuscript } from '../models/HubModels'
import { PolishResultBlock } from '../components/polish/PolishResultBlock'
import { PolishQuadSheet } from '../components/polish/PolishQuadSheet'
import { OptionPickGrid } from '../components/polish/OptionPickGrid'
import { ExpressToast } from '../services/ExpressToast'

@Component
export struct HomePage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('polishSeedText') @Watch('onSeed') polishSeedText: string = ''
  @StorageLink('polishStyleKey') @Watch('onStyleSeed') polishStyleKey: string = ''
  @StorageLink('polishSceneKey') @Watch('onSceneSeed') polishSceneKey: string = ''
  @StorageLink('polishAutoDemo') @Watch('onAutoDemo') polishAutoDemo: boolean = false
  @Prop appName: string = '研语'
  @Prop embedded: boolean = false
  @State inputText: string = ''
  @State styleKey: string = 'formal'
  @State sceneKey: string = 'general'
  @State polishedText: string = ''
  @State polishNote: string = ''
  @State showCompare: boolean = false
  @State showQuad: boolean = false
  @State toastText: string = ''
  @State changes: PolishChange[] = []
  @State issues: IssueItem[] = []
  @State quadItems: PolishResult[] = []
  @State rewriteLevel: string = ''
  @State origLen: number = 0
  @State polishedLen: number = 0
  private styles: StyleChip[] = LanguageCraftBizService.styleChips()
  private scenes: StyleChip[] = LanguageEngineService.sceneChips()
  private samples: SampleChip[] = LanguageEngineService.sampleChips()

  aboutToAppear(): void {
    this.consumeStyle()
    this.consumeScene()
    this.consumeSeed()
    this.tryAutoDemo()
  }

  onAutoDemo(): void {
    this.tryAutoDemo()
  }

  onSceneSeed(): void {
    this.consumeScene()
  }

  private tryAutoDemo(): void {
    if (!this.polishAutoDemo) {
      return
    }
    AppStorage.setOrCreate('polishAutoDemo', false)
    this.consumeStyle()
    this.consumeScene()
    this.consumeSeed()
    if (this.inputText.trim().length === 0) {
      return
    }
    this.styleKey = 'formal'
    this.runPolish()
    this.quadItems = LanguageEngineService.compareAll(this.inputText, this.sceneKey)
    this.showQuad = true
    this.showToast('已载入场景样例，下方为润色结果，可查看四风格对照')
  }

  private consumeScene(): void {
    if (this.polishSceneKey.length === 0) {
      return
    }
    this.sceneKey = this.polishSceneKey
    AppStorage.setOrCreate('polishSceneKey', '')
  }

  onSeed(): void {
    this.consumeSeed()
  }

  onStyleSeed(): void {
    this.consumeStyle()
  }

  private consumeStyle(): void {
    if (this.polishStyleKey.length === 0) {
      return
    }
    this.styleKey = this.polishStyleKey
    AppStorage.setOrCreate('polishStyleKey', '')
  }

  private consumeSeed(): void {
    if (this.polishSeedText.length === 0) {
      return
    }
    this.inputText = this.polishSeedText
    AppStorage.setOrCreate('polishSeedText', '')
    this.showToast('已填入润色台，点「智慧润色」查看改写')
  }

  private showToast(message: string): void {
    if (this.embedded) {
      ExpressToast.show(message)
      return
    }
    this.toastText = message
    setTimeout((): void => {
      this.toastText = ''
    }, 2200)
  }

  private handleRunPolish(): void {
    this.runPolish()
    if (this.polishedText.length > 0) {
      this.showToast(`润色完成 · ${this.polishedLen} 字`)
    }
  }

  private applyResult(result: PolishResult): void {
    this.polishedText = result.polished
    this.polishNote = result.note
    this.changes = result.changes
    this.issues = result.issues
    this.rewriteLevel = result.rewriteLevel
    this.origLen = result.origLen
    this.polishedLen = result.polishedLen
    this.showCompare = result.polished.length > 0
  }

  private pickStyle(key: string): void {
    this.styleKey = key
    if (this.inputText.trim().length === 0) {
      this.inputText = LanguageEngineService.oralSample()
    }
    this.runPolish()
    this.showToast(`已选「${LanguageEngineService.styleLabel(key)}」，正文已按此风格重写`)
  }

  private pickScene(key: string): void {
    this.sceneKey = key
    if (this.inputText.trim().length === 0) {
      this.inputText = LanguageEngineService.oralSample()
    }
    this.runPolish()
    this.showToast(`已选「${LanguageEngineService.sceneLabel(key)}」场景，正文已成稿`)
  }

  private fillSample(text: string): void {
    this.inputText = text
    this.showCompare = false
    this.runPolish()
  }

  private runPolish(): void {
    if (this.inputText.trim().length === 0) {
      this.showToast('请先输入要润色的文字，或点「口语催办」样例')
      return
    }
    this.applyResult(LanguageEngineService.polish(this.inputText, this.styleKey, this.sceneKey))
    void HubStore.recordPolish(`${LanguageEngineService.styleLabel(this.styleKey)}·${LanguageEngineService.sceneLabel(this.sceneKey)}`)
  }

  private runScan(): void {
    if (this.inputText.trim().length === 0) {
      this.showToast('请先输入原文再扫描')
      return
    }
    this.issues = LanguageEngineService.scanIssues(this.inputText)
    this.showToast(`检出 ${this.issues.length} 条表达提示`)
  }

  private runDemo(): void {
    this.inputText = LanguageEngineService.oralSample()
    this.styleKey = 'formal'
    this.sceneKey = 'email'
    this.runPolish()
    this.quadItems = LanguageEngineService.compareAll(this.inputText, this.sceneKey)
    this.showQuad = true
    this.showToast('已演示：口语 → 正式邮件成稿，可切换风格对照')
  }

  private runQuad(): void {
    if (this.inputText.trim().length === 0) {
      this.showToast('请先输入原文')
      return
    }
    this.quadItems = LanguageEngineService.compareAll(this.inputText, this.sceneKey)
    this.showQuad = true
  }

  private async copyResult(): Promise<void> {
    const ok = await ClipboardService.copyText(this.polishedText)
    this.showToast(ok ? '已复制润色结果' : '复制失败')
  }

  private async saveHistory(): Promise<void> {
    if (this.polishedText.length === 0) {
      this.showToast('请先完成润色')
      return
    }
    const record = new PolishRecord()
    record.id = LocalRecordStore.newId('polish')
    record.sourceText = this.inputText
    record.resultText = this.polishedText
    record.styleKey = this.styleKey
    record.styleLabel = `${LanguageEngineService.styleLabel(this.styleKey)}·${LanguageEngineService.sceneLabel(this.sceneKey)}`
    record.createdAt = LocalRecordStore.nowLabel()
    await LocalRecordStore.addPolish(record)
    this.showToast('已保存到润色历史')
  }

  private async saveManuscript(): Promise<void> {
    if (this.polishedText.length === 0) {
      this.showToast('请先完成润色')
      return
    }
    const m = Manuscript.create('polish')
    m.title = `${LanguageEngineService.styleLabel(this.styleKey)}·${LanguageEngineService.sceneLabel(this.sceneKey)}`
    m.body = this.polishedText
    m.sourceText = this.inputText
    m.styleKey = this.styleKey
    m.sceneKey = this.sceneKey
    await HubStore.saveManuscript(m)
    this.showToast('已存入稿本库')
  }

  @Builder
  polishFormBody() {
    Column({ space: Theme.space.s4 }) {
          if (!this.embedded) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_desk'))
              .width('100%')
              .height(148)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(90)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,58,92,0)', 0], ['rgba(26,58,92,0.82)', 1]]
              })
            Column({ space: 4 }) {
              Text(this.appName)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F5F7FA')
              Text('智慧润色 · 按风格重写成稿')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.of(this.darkModeOn).brandAccent)
            }
            .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
          .width('100%')
          .borderRadius(Theme.radius.lg)
          .clip(true)

          Image($r('app.media.banner_polish'))
            .width('100%')
            .height(72)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          }

          if (!this.embedded) {
          Text('点样例即可看到润色前后的明显差异')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
            .width('100%')
          }
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppButton({
                label: '一键演示润色',
                variant: 'secondary',
                onTap: (): void => { this.runDemo() }
              })
            }
            .layoutWeight(1)
            Column() {
              AppButton({
                label: '四风格对照',
                variant: 'secondary',
                onTap: (): void => { this.runQuad() }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.samples, (chip: SampleChip) => {
              Column() {
                Text(chip.label)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.of(this.darkModeOn).brandPrimary)
              }
              .padding({ left: 12, right: 12, top: 10, bottom: 10 })
              .margin({ right: 8, bottom: 8 })
              .constraintSize({ minHeight: 40 })
              .backgroundColor(Theme.of(this.darkModeOn).brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.fillSample(chip.text) })
            }, (chip: SampleChip) => chip.key)
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('原文')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            TextArea({ text: this.inputText, placeholder: '粘贴邮件、纪要或日常表达…' })
              .height(120)
              .fontSize(Theme.type.body)
              .fontColor(Theme.of(this.darkModeOn).textPrimary)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onChange((v: string): void => {
                this.inputText = v
              })
          }
          .width('100%')

          OptionPickGrid({
            title: '风格（点选立即重写成稿）',
            selectedKey: this.styleKey,
            chips: this.styles,
            onPick: (key: string): void => { this.pickStyle(key) }
          })
          Column() {
            Text('查看当前风格说明')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).brandPrimary)
              .width('100%')
          }
          .width('100%')
          .constraintSize({ minHeight: 40 })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Start)
          .onClick((): void => { LanguageCraftNav.openStyle(this.styleKey) })
          OptionPickGrid({
            title: '场景（点选套成邮件 / 纪要 / 汇报）',
            selectedKey: this.sceneKey,
            chips: this.scenes,
            onPick: (key: string): void => { this.pickScene(key) }
          })

          Row() {
            AppButton({
              label: '智慧润色',
              onTap: (): void => { this.handleRunPolish() }
            })
          }
          .width('100%')
          .onClick((): void => { this.handleRunPolish() })
          .gesture(
            TapGesture({ count: 1 }).onAction((): void => { this.handleRunPolish() })
          )
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppButton({
                label: '问题扫描',
                variant: 'secondary',
                onTap: (): void => { this.runScan() }
              })
            }
            .layoutWeight(1)
            Column() {
              AppButton({
                label: '四风格对照',
                variant: 'secondary',
                onTap: (): void => { this.runQuad() }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
          AppButton({
            label: '场景成稿（填空）',
            variant: 'ghost',
            onTap: (): void => { LanguageCraftNav.openDraft() }
          })

          if (this.issues.length > 0 && !this.showCompare) {
            Column({ space: 6 }) {
              ForEach(this.issues, (row: IssueItem) => {
                Text(`${row.title}：${row.hint}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
                  .width('100%')
              }, (row: IssueItem) => row.id)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.of(this.darkModeOn).surfaceSubtle)
            .borderRadius(Theme.radius.lg)
          }

          if (this.showCompare && this.polishedText.length > 0) {
            PolishResultBlock({
              note: this.polishNote,
              originalText: this.inputText,
              polishedText: this.polishedText,
              changes: this.changes,
              rewriteLevel: this.rewriteLevel,
              origLen: this.origLen,
              polishedLen: this.polishedLen,
              onCopy: (): void => { void this.copyResult() },
              onSave: (): void => { void this.saveHistory() },
              onSaveManuscript: (): void => { void this.saveManuscript() }
            })
          }
    }
    .padding({
      left: Theme.space.pageX,
      right: Theme.space.pageX,
      top: this.embedded ? Theme.space.s2 : Theme.space.pageY,
      bottom: Theme.space.s10
    })
    .width('100%')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.embedded) {
        this.polishFormBody()
      } else {
        Scroll() {
          this.polishFormBody()
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.of(this.darkModeOn).surfacePage)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }

      if (this.showQuad) {
        PolishQuadSheet({
          items: this.quadItems,
          originalText: this.inputText,
          onClose: (): void => { this.showQuad = false },
          onPick: (row: PolishResult): void => {
            this.styleKey = row.styleKey
            this.applyResult(row)
            this.showQuad = false
          }
        })
          .width('100%')
          .height(this.embedded ? 560 : '100%')
          .zIndex(22)
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6, left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
  }

}
