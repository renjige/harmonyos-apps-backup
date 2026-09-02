import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { HomeFilterChip } from '../components/courtyard/HomeFilterChip'
import { PingzeCell, CipaiItem, RhymeItem } from '../models/CourtyardModels'
import { CourtyardBizService } from '../services/CourtyardBizService'
import { CourtyardDetailNav } from '../services/CourtyardDetailNav'
import { CourtyardLocalStore } from '../services/CourtyardLocalStore'
import { PingzeEngine } from '../services/PingzeEngine'

@Component
export struct MeterPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('meterDraft') meterDraft: string = ''
  @State inputText: string = ''
  @State cells: PingzeCell[] = []
  @State summary: string = ''
  @State couplet: string = ''
  @State rhymeHint: string = ''
  @State cipaiGuess: string = ''
  @State cipaiList: CipaiItem[] = []
  @State rhymes: RhymeItem[] = []
  @State book: string = '平水韵'
  @State toastText: string = ''
  @State showQuiz: boolean = false

  aboutToAppear(): void {
    if (this.meterDraft.length > 0) {
      this.inputText = this.meterDraft
      AppStorage.setOrCreate('meterDraft', '')
    }
    this.book = CourtyardLocalStore.rhymeBook()
    void this.loadRefs()
  }

  private async loadRefs(): Promise<void> {
    this.cipaiList = await CourtyardBizService.loadCipai()
    this.rhymes = await CourtyardBizService.loadRhymes(this.book)
  }

  private async runDetect(): Promise<void> {
    if (this.inputText.trim().length === 0) {
      this.toastText = '请先粘贴或输入诗词'
      setTimeout((): void => { this.toastText = '' }, 2000)
      return
    }
    this.cells = PingzeEngine.analyze(this.inputText)
    this.summary = PingzeEngine.summary(this.cells)
    this.couplet = PingzeEngine.coupletHint(this.inputText)
    this.rhymeHint = PingzeEngine.rhymeHint(this.cells)
    const guess = CourtyardBizService.guessCipai(this.inputText, this.cipaiList)
    this.cipaiGuess = guess !== undefined ? `接近词牌「${guess.title}」· ${guess.formHint}` : '未匹配到常用词牌，可在下方浏览谱式。'
    await CourtyardLocalStore.bumpDetect()
  }

  private async saveWork(): Promise<void> {
    if (this.inputText.trim().length === 0) {
      this.toastText = '没有可保存的正文'
      setTimeout((): void => { this.toastText = '' }, 2000)
      return
    }
    await CourtyardLocalStore.saveWork('格律习作', this.inputText, this.summary)
    this.toastText = '已保存到个人作品'
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async switchBook(next: string): Promise<void> {
    this.book = next
    await CourtyardLocalStore.setRhymeBook(next)
    this.rhymes = await CourtyardBizService.loadRhymes(next)
  }

  @Builder
  GraphRow() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.cells, (c: PingzeCell) => {
        Column({ space: 2 }) {
          Text(c.ch === '\n' ? ' ' : c.ch)
            .fontSize(18)
            .fontColor(c.isRhyme ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
            .fontWeight(c.isRhyme ? FontWeight.Bold : FontWeight.Normal)
          Text(c.mark.length > 0 ? c.mark : ' ')
            .fontSize(10)
            .fontColor(c.mark === '平' ? Theme.colors().textSecondary :
              (c.mark === '仄' ? Theme.colors().brandPrimary : Theme.colors().textTertiary))
          Rect()
            .width(10)
            .height(c.mark === '平' ? 16 : (c.mark === '仄' ? 8 : 4))
            .fill(c.mark === '平' ? Theme.colors().brandDeep : Theme.colors().brandPrimary)
            .borderRadius(2)
        }
        .width(c.ch === '\n' ? '100%' : 28)
        .padding({ bottom: 6 })
      }, (c: PingzeCell) => `pz_${c.idx}`)
    }
    .width('100%')
  }

  build() {
    Stack() {
      Column() {
        Text('格律工坊')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        Text('智慧识别平仄 · 韵脚 · 词牌提示')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, bottom: Theme.space.s3 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextArea({ text: this.inputText, placeholder: '粘贴或输入诗词，做格律检测' })
              .height(120)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .onChange((v: string) => { this.inputText = v })

            AppButton({ label: '开始检测', onTap: (): void => { void this.runDetect() } })

            if (this.summary.length > 0) {
              AppCard({ title: '检测结果' }) {
                Column({ space: 8 }) {
                  Text(this.summary).fontSize(Theme.type.bodyM).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
                  Text(this.cipaiGuess).fontSize(Theme.type.bodyS).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
                  this.GraphRow()
                }
              }
              AppCard({ title: '创作辅助' }) {
                Column({ space: 6 }) {
                  Text(this.couplet).fontSize(Theme.type.bodyS).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
                  Text(this.rhymeHint).fontSize(Theme.type.bodyS).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
                }
              }
              AppButton({ label: '保存为个人作品', variant: 'secondary', onTap: (): void => { void this.saveWork() } })
            }

            Text('词牌规范').fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
            if (this.cipaiList.length === 0) {
              AppEmpty({ title: '词牌加载中', description: '请检查网络后重试' })
            }
            ForEach(this.cipaiList, (c: CipaiItem) => {
              Column({ space: 4 }) {
                Text(c.title).fontSize(Theme.type.bodyM).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
                Text(c.summary).fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onClick((): void => { CourtyardDetailNav.openCipai(c.id) })
            }, (c: CipaiItem) => c.id)

            Scroll() {
              Row({ space: 8 }) {
                Text('韵典')
                  .fontSize(Theme.type.subtitleS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                HomeFilterChip({
                  label: '平水韵',
                  selected: this.book === '平水韵',
                  onPick: (): void => { void this.switchBook('平水韵') }
                })
                HomeFilterChip({
                  label: '词林正韵',
                  selected: this.book === '词林正韵',
                  onPick: (): void => { void this.switchBook('词林正韵') }
                })
                HomeFilterChip({
                  label: '中华新韵',
                  selected: this.book === '中华新韵',
                  onPick: (): void => { void this.switchBook('中华新韵') }
                })
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            ForEach(this.rhymes, (r: RhymeItem) => {
              Text(`${r.title} · ${r.tone}`)
                .fontSize(Theme.type.bodyM)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { CourtyardDetailNav.openRhyme(r.id) })
            }, (r: RhymeItem) => r.id)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(12)
          .backgroundColor('rgba(44,24,16,0.92)')
          .borderRadius(8)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
