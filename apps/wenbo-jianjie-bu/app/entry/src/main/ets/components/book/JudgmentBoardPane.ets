import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { InsightEntry, VerdictGuard } from '../../models/InsightModels'
import { InsightStore } from '../../services/InsightStore'

@Component
export struct JudgmentBoardPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onOpen: (id: string) => void = (_id: string) => {}
  onMutated: () => void = () => {}
  @State items: InsightEntry[] = []
  @State toastText: string = ''
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await InsightStore.judgments()
    this.loaded = true
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private async setVerdict(item: InsightEntry, code: string): Promise<void> {
    const ok = await InsightStore.patchMeta(item.id, item.starred, item.pinned, code)
    if (!ok) {
      this.showToast(InsightStore.lastError)
      return
    }
    this.showToast(VerdictGuard.label(code))
    this.onMutated()
    void this.reload()
  }

  private async adoptLatest(): Promise<void> {
    const id = await InsightStore.latestId()
    if (id.length === 0) {
      this.showToast('先在记录页写一条见解')
      return
    }
    const ok = await InsightStore.adoptAsJudgment(id)
    if (!ok) {
      this.showToast(InsightStore.lastError)
      return
    }
    this.showToast('已记入判断台账')
    this.onMutated()
    void this.reload()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        DetailShell({ title: '判断台账', onClose: (): void => { this.onClose() } })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('给「判断」框架的见解标结果：应验、落空或已修正。这不是日记，是你对自己思考的验收。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(22)
              .width('100%')
            AppButton({
              label: '把最近一条记入台账',
              variant: 'secondary',
              onTap: (): void => { void this.adoptLatest() }
            })
            if (this.loaded && this.items.length === 0) {
              AppEmpty({
                title: '台账还是空的',
                description: '新建见解时选「判断」框架，或把最近一条记入台账。',
                actionLabel: '',
                onAction: (): void => {}
              })
            }
            ForEach(this.items, (n: InsightEntry) => {
              Column({ space: 8 }) {
                Text(n.title)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                  .onClick((): void => { this.onOpen(n.id) })
                Text(`当前：${VerdictGuard.label(n.verdict)}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
                Row({ space: 8 }) {
                  ForEach(VerdictGuard.codes(), (code: string) => {
                    Text(VerdictGuard.label(code))
                      .fontSize(Theme.type.caption)
                      .fontColor(n.verdict === code ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                      .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                      .backgroundColor(n.verdict === code ?
                        Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                      .borderRadius(Theme.radius.sm)
                      .onClick((): void => { void this.setVerdict(n, code) })
                  }, (code: string) => `${n.id}_${code}`)
                }
                .width('100%')
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }, (n: InsightEntry) => `${n.id}_${n.verdict}_${n.updatedAt}`)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontColor('#FFFFFF')
          .fontSize(Theme.type.footnote)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
