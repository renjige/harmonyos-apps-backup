import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { MicroEssay } from '../../models/EssayModels'
import { EssayStore } from '../../services/EssayStore'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct ContrastPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('essayFontScale') fontScale: number = 1
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  @State leftTitle: string = ''
  @State leftSummary: string = ''
  @State leftDate: string = ''
  @State rightTitle: string = ''
  @State rightSummary: string = ''
  @State rightDate: string = ''
  @State note: string = ''
  @State toastText: string = ''
  @State ready: boolean = false
  @State saving: boolean = false
  private leftEssay: MicroEssay = new MicroEssay()
  private rightEssay: MicroEssay = new MicroEssay()

  aboutToAppear(): void {
    void this.pickPair()
  }

  private async pickPair(): Promise<void> {
    const list = await EssayStore.loadAll()
    this.ready = list.length >= 2
    if (list.length < 2) {
      return
    }
    const seedId = AppStorage.get<string>('contrastSeedId') ?? ''
    AppStorage.setOrCreate('contrastSeedId', '')
    let left = list[0]
    if (seedId.length > 0) {
      for (const it of list) {
        if (it.id === seedId) {
          left = it
          break
        }
      }
    }
    this.leftEssay = left
    let right = list[0]
    let foundSame = false
    for (const it of list) {
      if (it.id === left.id) {
        continue
      }
      if (left.senseKey.length > 0 && it.senseKey === left.senseKey) {
        right = it
        foundSame = true
        break
      }
    }
    if (!foundSame) {
      let idx = 1
      if (list.length > 2) {
        idx = 1 + Math.floor(Math.random() * (list.length - 1))
      }
      right = list[idx]
      if (right.id === left.id) {
        right = list[0]
        if (right.id === left.id && list.length > 1) {
          right = list[1]
        }
      }
    }
    this.rightEssay = right
    this.leftTitle = this.leftEssay.title
    this.leftSummary = this.leftEssay.previewSummary(90)
    this.leftDate = EssayStore.resolvedDateKey(this.leftEssay)
    this.rightTitle = this.rightEssay.title
    this.rightSummary = this.rightEssay.previewSummary(90)
    this.rightDate = EssayStore.resolvedDateKey(this.rightEssay)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async persist(): Promise<void> {
    const text = this.note.trim()
    if (text.length === 0) {
      this.showToast('请写一句「这次不同在哪」')
      return
    }
    this.saving = true
    const e = MicroEssay.createNew()
    e.title = `对照 · ${DateHelper.todayKey()}`
    e.body = [
      '【对照观察】',
      `左：${this.leftEssay.title.length > 0 ? this.leftEssay.title : '无标题'}（${EssayStore.resolvedDateKey(this.leftEssay)}）`,
      this.leftEssay.previewSummary(80),
      '',
      `右：${this.rightEssay.title.length > 0 ? this.rightEssay.title : '无标题'}（${EssayStore.resolvedDateKey(this.rightEssay)}）`,
      this.rightEssay.previewSummary(80),
      '',
      '【这次不同在哪】',
      text
    ].join('\n')
    e.tagsCsv = '对照'
    e.kind = 'contrast'
    e.senseKey = this.leftEssay.senseKey.length > 0 ? this.leftEssay.senseKey : this.rightEssay.senseKey
    e.setContrastSourceIds([this.leftEssay.id, this.rightEssay.id])
    await EssayStore.saveEssay(e)
    this.saving = false
    this.showToast('对照已写入时间线')
    this.onSaved()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('对照观察')
            .fontSize(Theme.type.title3 * this.fontScale)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Text('关闭')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => { this.onClose() })
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Text('并排重读两篇旧观察，写下这次你看见的不同。系统备忘录做不到这一步。')
          .fontSize(Theme.type.caption * this.fontScale)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

        if (!this.ready) {
          AppEmpty({
            title: '至少两篇才能对照',
            description: '先用观察卡写两篇，再回来并排重读',
            actionLabel: '关闭',
            onAction: (): void => { this.onClose() }
          })
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              this.PairCard('左', this.leftDate, this.leftTitle, this.leftSummary)
              this.PairCard('右', this.rightDate, this.rightTitle, this.rightSummary)
              Text('换一组')
                .fontSize(Theme.type.bodyS)
                .fontColor('#FFFFFF')
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor('#1A2A3A')
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { void this.pickPair() })
              Text('这次不同在哪')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              TextArea({ text: this.note, placeholder: '不写心情总结，只写一个具体差别' })
                .width('100%')
                .height(96)
                .fontSize(Theme.type.body * this.fontScale)
                .fontColor(Theme.colors().textPrimary)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.sm)
                .onChange((v: string) => { this.note = v })
              Text(this.saving ? '保存中…' : '写入对照')
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .textAlign(TextAlign.Center)
                .width('100%')
                .padding({ top: 12, bottom: 12 })
                .backgroundColor('#1A2A3A')
                .border({ width: 1, color: '#C9A96E' })
                .borderRadius(Theme.radius.md)
                .onClick((): void => { void this.persist() })
              Blank().height(Theme.space.s10)
            }
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.body)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('#1A2A3A')
          .borderRadius(Theme.radius.pill)
          .position({ x: '12%', y: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(70)
    .onAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', true)
    })
    .onDisAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
    })
  }

  @Builder
  PairCard(side: string, dateKey: string, title: string, summary: string) {
    Column({ space: 4 }) {
      Text(`${side} · ${dateKey}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandAccent)
        .width('100%')
      Text(title.length > 0 ? title : '无标题')
        .fontSize(Theme.type.subhead * this.fontScale)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(summary)
        .fontSize(Theme.type.bodyS * this.fontScale)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}
