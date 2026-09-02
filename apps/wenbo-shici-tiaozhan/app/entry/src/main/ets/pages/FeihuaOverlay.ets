import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppError } from '../components/design-system/AppError'
import { FeihuaItem } from '../models/PoetryModels'
import { PoetryBizService } from '../services/PoetryBizService'
import { PoetryNav } from '../services/PoetryNav'
import { ProgressStore } from '../services/ProgressStore'

class ChatBubble {
  role: string = 'system'
  text: string = ''
}

@Component
export struct FeihuaOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: FeihuaItem[] = []
  @State current: FeihuaItem = new FeihuaItem()
  @State loading: boolean = true
  @State failed: boolean = false
  @State step: string = 'pick'
  @State difficulty: string = 'intro'
  @State answerText: string = ''
  @State chatLines: ChatBubble[] = []
  @State round: number = 0
  @State toast: string = ''
  @State resultHint: string = ''
  @State candidateLines: string[] = []

  aboutToAppear(): void {
    void this.boot()
  }

  async boot(): Promise<void> {
    this.loading = true
    this.failed = false
    this.items = await PoetryBizService.loadFeihua()
    this.loading = false
    this.failed = this.items.length === 0
    const presetId = PoetryNav.feihuaId()
    if (presetId.length > 0) {
      const found = PoetryBizService.findFeihua(this.items, presetId)
      if (found !== undefined) {
        this.current = found
        this.difficulty = found.difficulty
        this.beginRound()
        return
      }
    }
    this.step = 'pick'
  }

  private introItems(): FeihuaItem[] {
    const out: FeihuaItem[] = []
    const seen: string[] = []
    for (const f of this.items) {
      if (f.difficulty !== 'intro') {
        continue
      }
      if (seen.indexOf(f.keyword) >= 0) {
        continue
      }
      seen.push(f.keyword)
      out.push(f)
    }
    return out
  }

  private pickKeyword(item: FeihuaItem): void {
    this.current = item
    this.difficulty = item.difficulty
    this.beginRound()
  }

  private beginRound(): void {
    this.step = 'play'
    this.round = 0
    this.answerText = ''
    this.resultHint = ''
    this.chatLines = []
    const pool = PoetryBizService.systemLinePool(this.current)
    this.candidateLines = []
    if (pool.length > 0) {
      const bubble = new ChatBubble()
      bubble.role = 'system'
      bubble.text = `参考句：${pool[0]}`
      this.chatLines.push(bubble)
      for (let i = 1; i < pool.length && this.candidateLines.length < 5; i++) {
        this.candidateLines.push(pool[i])
      }
    }
    const hint = new ChatBubble()
    hint.role = 'system'
    hint.text = `飞花令关键字「${this.current.keyword}」· ${this.current.subtitle.length > 0 ? this.current.subtitle : '接龙须含该字'}`
    this.chatLines.push(hint)
  }

  private async submitAnswer(): Promise<void> {
    const text = this.answerText.trim()
    if (text.length === 0) {
      return
    }
    const userBubble = new ChatBubble()
    userBubble.role = 'user'
    userBubble.text = text
    this.chatLines.push(userBubble)
    this.answerText = ''
    const ok = PoetryBizService.validateFeihuaAnswer(this.current, text)
    await ProgressStore.recordFeihuaRound(ok)
    if (ok) {
      this.resultHint = '接龙成功 · 句中含关键字且与参考库匹配'
      const sys = new ChatBubble()
      sys.role = 'system'
      sys.text = '答得好！可继续接龙或换令。'
      this.chatLines.push(sys)
      this.round = this.round + 1
    } else {
      this.resultHint = '暂未匹配参考句，请确保句中含关键字'
      const sys = new ChatBubble()
      sys.role = 'system'
      sys.text = '再试一句，或查看上方参考句。'
      this.chatLines.push(sys)
    }
    this.toast = ok ? '接龙成功' : '再试一次'
    setTimeout(() => { this.toast = '' }, 1600)
  }

  private pickCandidate(line: string): void {
    this.answerText = line
    void this.submitAnswer()
  }

  private switchDifficulty(mode: string): void {
    this.difficulty = mode
    for (const f of this.items) {
      if (f.keyword === this.current.keyword && f.difficulty === mode) {
        this.current = f
        break
      }
    }
    this.beginRound()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('返回')
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => PoetryNav.close())
          Blank()
          Text('飞花令')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 8 })

        if (this.failed && !this.loading) {
          AppError({
            title: '飞花令暂不可用',
            message: PoetryBizService.lastHint(),
            retryLabel: '重试',
            onRetry: (): void => { void this.boot() }
          })
        } else if (this.step === 'pick') {
          Scroll() {
            Column({ space: 12 }) {
              Text('选择关键字')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text('入门难度适合热身，进阶难度参考句更长。')
                .fontSize(14)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              ForEach(this.introItems(), (f: FeihuaItem) => {
                Row({ space: 12 }) {
                  Text(f.keyword)
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .width(48)
                  Column({ space: 4 }) {
                    Text(f.title)
                      .fontSize(16)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    Text(f.summary)
                      .fontSize(13)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .maxLines(2)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding(14)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => this.pickKeyword(f))
              }, (f: FeihuaItem) => f.id)
            }
            .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
          }
          .layoutWeight(1)
        } else {
          Column({ space: 10 }) {
            Row({ space: 8 }) {
              Text(`令字：${this.current.keyword}`)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Blank()
              Text(`第 ${this.round + 1} 轮`)
                .fontSize(13)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .width('100%')
            .padding({ left: 20, right: 20 })

            Row({ space: 8 }) {
              Column() {
                AppButton({
                  label: '入门',
                  variant: this.difficulty === 'intro' ? 'primary' : 'secondary',
                  onTap: (): void => this.switchDifficulty('intro')
                })
              }
              .layoutWeight(1)
              Column() {
                AppButton({
                  label: '进阶',
                  variant: this.difficulty === 'advanced' ? 'primary' : 'secondary',
                  onTap: (): void => this.switchDifficulty('advanced')
                })
              }
              .layoutWeight(1)
            }
            .width('100%')
            .padding({ left: 20, right: 20 })

            Scroll() {
              Column({ space: 10 }) {
                ForEach(this.chatLines, (line: ChatBubble, idx: number) => {
                  Row() {
                    if (line.role === 'user') {
                      Blank()
                    }
                    Text(line.text)
                      .fontSize(15)
                      .fontColor(line.role === 'user' ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                      .padding(12)
                      .backgroundColor(line.role === 'user' ?
                        Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                      .borderRadius(16)
                      .constraintSize({ maxWidth: '82%' })
                    if (line.role !== 'user') {
                      Blank()
                    }
                  }
                  .width('100%')
                }, (_line: ChatBubble, idx: number) => `chat-${idx}`)
              }
              .padding({ left: 20, right: 20, top: 8, bottom: 8 })
            }
            .layoutWeight(1)
            .edgeEffect(EdgeEffect.Spring)

            if (this.resultHint.length > 0) {
              Text(this.resultHint)
                .fontSize(13)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
                .padding({ left: 20, right: 20 })
            }

            Column({ space: 10 }) {
              Text('输入你的诗句')
                .fontSize(13)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')

              TextInput({ text: this.answerText, placeholder: `输入含「${this.current.keyword}」的诗句` })
                .width('100%')
                .height(48)
                .fontSize(16)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .placeholderColor(Theme.colors().textSecondary)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .padding({ left: 14, right: 14 })
                .onChange((v: string) => { this.answerText = v })

              if (this.candidateLines.length > 0) {
                Text('或点选候选句')
                  .fontSize(13)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Scroll() {
                  Row({ space: 8 }) {
                    ForEach(this.candidateLines, (line: string, idx: number) => {
                      Text(line)
                        .fontSize(14)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                        .backgroundColor(Theme.colors().brandPrimaryContainer)
                        .borderRadius(Theme.radius.pill)
                        .onClick((): void => this.pickCandidate(line))
                    }, (line: string, idx: number) => `cand-${idx}`)
                  }
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
                .width('100%')
              }

              AppButton({
                label: '提交接龙',
                onTap: (): void => { void this.submitAnswer() }
              })
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 8, bottom: 28 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
            .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
          }
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(14)
          .fontColor('#F8F4ED')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(28,40,51,0.88)')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
