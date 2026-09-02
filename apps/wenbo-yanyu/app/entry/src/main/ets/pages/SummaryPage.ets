import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { LanguageEngineService } from '../services/LanguageEngineService'
import { LanguageCraftMedia } from '../services/LanguageCraftMedia'
import { SummaryRecord, StyleChip } from '../models/LanguageCraftModels'
import { LocalRecordStore } from '../services/LocalRecordStore'
import { ClipboardService } from '../services/ClipboardService'
import { HubStore } from '../services/HubStore'
import { Manuscript } from '../models/HubModels'
import { OptionPickGrid } from '../components/polish/OptionPickGrid'
import { ExpressToast } from '../services/ExpressToast'

@Component
export struct SummaryPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('summarySeedText') @Watch('onSeed') summarySeedText: string = ''
  @StorageLink('summaryModeSeed') @Watch('onSeed') summaryModeSeed: string = ''
  @Prop embedded: boolean = false
  @State inputText: string = ''
  @State summaryMode: string = 'brief'
  @State summaryText: string = ''
  @State toastText: string = ''
  private modes: StyleChip[] = [
    StyleChip.of('brief', '精简', '抽出主线几句'),
    StyleChip.of('detail', '详细', '逐段编成要点'),
    StyleChip.of('actions', '待办', '抽出请/需要/负责'),
    StyleChip.of('conclusions', '结论', '抽出决定/综上')
  ]

  aboutToAppear(): void {
    this.consumeSeed()
  }

  onSeed(): void {
    this.consumeSeed()
  }

  private consumeSeed(): void {
    if (this.summarySeedText.length > 0) {
      this.inputText = this.summarySeedText
      AppStorage.setOrCreate('summarySeedText', '')
    }
    if (this.summaryModeSeed.length > 0) {
      this.summaryMode = this.summaryModeSeed
      AppStorage.setOrCreate('summaryModeSeed', '')
    }
    if (this.inputText.trim().length > 0) {
      this.runSummary()
    }
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

  private handleGenerateSummary(): void {
    this.runSummary()
  }

  private pickMode(key: string): void {
    this.summaryMode = key
    if (this.inputText.trim().length === 0) {
      this.inputText = LanguageEngineService.summarySample()
    }
    this.runSummary()
    this.showToast(`已按「${LanguageEngineService.modeLabel(key)}」抽出结果`)
  }

  private runSummary(): void {
    if (this.inputText.trim().length === 0) {
      this.showToast('请先粘贴长文，或点「载入会议样例」')
      return
    }
    this.summaryText = LanguageEngineService.summarize(this.inputText, this.summaryMode)
    if (this.summaryText.length === 0) {
      this.showToast('未能抽取摘要，请检查输入')
    } else {
      const label = LanguageEngineService.modeLabel(this.summaryMode)
      this.showToast(`已生成「${label}」· ${this.summaryText.length} 字`)
      void HubStore.recordSummary(label)
    }
  }

  private async copySummary(): Promise<void> {
    const ok = await ClipboardService.copyText(this.summaryText)
    this.showToast(ok ? '已复制摘要' : '复制失败')
  }

  private async saveSummary(): Promise<void> {
    if (this.summaryText.length === 0) {
      this.showToast('请先生成摘要')
      return
    }
    const record = new SummaryRecord()
    record.id = LocalRecordStore.newId('summary')
    record.sourceText = this.inputText
    record.resultText = this.summaryText
    record.mode = this.summaryMode
    record.modeLabel = LanguageEngineService.modeLabel(this.summaryMode)
    record.createdAt = LocalRecordStore.nowLabel()
    await LocalRecordStore.addSummary(record)
    this.showToast('已保存到摘要历史')
  }

  private async saveManuscript(): Promise<void> {
    if (this.summaryText.length === 0) {
      this.showToast('请先生成摘要')
      return
    }
    const m = Manuscript.create('summary')
    m.title = LanguageEngineService.modeLabel(this.summaryMode)
    m.body = this.summaryText
    m.sourceText = this.inputText
    m.modeKey = this.summaryMode
    await HubStore.saveManuscript(m)
    this.showToast('已存入稿本库')
  }

  private handleLoadSample(): void {
    this.inputText = LanguageEngineService.summarySample()
    this.summaryText = ''
    this.runSummary()
    this.showToast('已载入会议样例并生成摘要')
  }

  @Builder
  summaryFormBody() {
    Column({ space: Theme.space.s4 }) {
          if (!this.embedded) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(LanguageCraftMedia.cover('banner_summary'))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(80)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,58,92,0)', 0], ['rgba(26,58,92,0.75)', 1]]
              })
            Text('智能摘要 · 主线 / 待办 / 结论')
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor('#F5F7FA')
              .padding({ left: Theme.space.s4, bottom: Theme.space.s4 })
              .width('100%')
          }
          .width('100%')
          .borderRadius(Theme.radius.lg)
          .clip(true)
          }

          if (!this.embedded) {
          Text('长文可抽出待办与结论，不只是缩短段落。')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
            .width('100%')

          AppButton({
            label: '载入会议样例',
            variant: 'secondary',
            onTap: (): void => {
              this.inputText = LanguageEngineService.summarySample()
              this.summaryText = ''
            }
          })
          }

          if (this.embedded) {
          Row() {
            Text('没有长文？点这里载入会议样例')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).brandPrimary)
          }
          .width('100%')
          .constraintSize({ minHeight: 40 })
          .onClick((): void => { this.handleLoadSample() })
          .gesture(
            TapGesture({ count: 1 }).onAction((): void => { this.handleLoadSample() })
          )
          }

          Column({ space: Theme.space.s2 }) {
            Text('长文输入')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            TextArea({ text: this.inputText, placeholder: '粘贴文章、报告或会议纪要…' })
              .height(160)
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
            title: '抽取方式（点选立即出结果）',
            selectedKey: this.summaryMode,
            chips: this.modes,
            onPick: (key: string): void => { this.pickMode(key) }
          })

          Row() {
            AppButton({
              label: '智能生成摘要',
              onTap: (): void => { this.handleGenerateSummary() }
            })
          }
          .width('100%')
          .onClick((): void => { this.handleGenerateSummary() })
          .gesture(
            TapGesture({ count: 1 }).onAction((): void => { this.handleGenerateSummary() })
          )

          if (this.summaryText.length > 0) {
            Column({ space: Theme.space.s3 }) {
              Text(LanguageEngineService.modeLabel(this.summaryMode))
                .fontSize(Theme.type.caption)
                .fontColor(Theme.of(this.darkModeOn).textSecondary)
                .width('100%')
              Text(this.summaryText)
                .fontSize(Theme.type.body)
                .fontColor(Theme.of(this.darkModeOn).textPrimary)
                .lineHeight(26)
                .width('100%')
              Row({ space: Theme.space.s3 }) {
                Column() {
                  AppButton({
                    label: '复制',
                    variant: 'secondary',
                    onTap: (): void => { void this.copySummary() }
                  })
                }
                .layoutWeight(1)
                Column() {
                  AppButton({
                    label: '存稿本',
                    variant: 'secondary',
                    onTap: (): void => { void this.saveManuscript() }
                  })
                }
                .layoutWeight(1)
                Column() {
                  AppButton({
                    label: '存历史',
                    onTap: (): void => { void this.saveSummary() }
                  })
                }
                .layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
            .borderRadius(Theme.radius.lg)
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
        this.summaryFormBody()
      } else {
        Scroll() {
          this.summaryFormBody()
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.of(this.darkModeOn).surfacePage)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
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
