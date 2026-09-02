import { Theme } from '../../components/design-system/Theme'
import { AppButton } from '../../components/design-system/AppButton'
import { AppEmpty } from '../../components/design-system/AppEmpty'
import { ResearchBar } from '../../components/research/ResearchBar'
import { DailyThink } from '../../models/ResearchModels'
import { ResearchStore } from '../../services/ResearchStore'

@Component
export struct DailyThinkPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('researchRefresh') @Watch('onRefresh') refreshToken: number = 0
  @State items: DailyThink[] = []
  @State text: string = ''
  @State todayKey: string = ''
  @State todayDone: boolean = false
  @State streak: number = 0
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    this.todayKey = ResearchStore.todayKey()
    this.items = await ResearchStore.listDaily()
    this.todayDone = false
    this.text = ''
    for (const d of this.items) {
      if (d.dateKey === this.todayKey) {
        this.todayDone = true
        this.text = d.viewpoint
      }
    }
    const s = await ResearchStore.stats()
    this.streak = s.streak
  }

  private async save(): Promise<void> {
    if (this.text.trim().length === 0) {
      this.showToast('先写下今天的一个观点')
      return
    }
    const row = DailyThink.create(this.todayKey)
    row.viewpoint = this.text.trim()
    await ResearchStore.saveDaily(row)
    this.showToast('已记下，连续思考会累计')
    await this.reload()
  }

  build() {
    Stack() {
      Column() {
        ResearchBar({ title: '每日思考' })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text(`连续思考 ${this.streak} 天`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.of(this.darkModeOn).brandPrimary)
              .width('100%')
            Text('每天只记一个观点，用来练持续思考，而不是刷数量。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            TextArea({ text: this.text, placeholder: `今日（${this.todayKey}）的一个判断或疑问` })
              .height(100)
              .onChange((v: string) => { this.text = v })
            AppButton({
              label: this.todayDone ? '更新今日思考' : '记下今日思考',
              onTap: (): void => { void this.save() }
            })
            Text('过往积累')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            if (this.items.length === 0) {
              AppEmpty({
                title: '还没有打卡',
                description: '从今天开始，每天留下一条属于自己的判断。'
              })
            } else {
              ForEach(this.items, (d: DailyThink) => {
                Column({ space: 4 }) {
                  Text(d.dateKey)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                    .width('100%')
                  Text(d.viewpoint)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.of(this.darkModeOn).textPrimary)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
                .borderRadius(Theme.radius.md)
              }, (d: DailyThink) => d.dateKey)
            }
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.of(this.darkModeOn).surfacePage)

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
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
