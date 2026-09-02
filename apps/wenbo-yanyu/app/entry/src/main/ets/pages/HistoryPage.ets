import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { PolishRecord, SummaryRecord } from '../models/LanguageCraftModels'
import { LocalRecordStore } from '../services/LocalRecordStore'
import { LanguageCraftNav } from '../services/LanguageCraftNav'
import { ClipboardService } from '../services/ClipboardService'

@Component
export struct HistoryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @StorageLink('historyTab') @Watch('onHistoryTab') historyTab: string = 'polish'
  @State polishItems: PolishRecord[] = []
  @State summaryItems: SummaryRecord[] = []
  @State tab: string = 'polish'
  @State toastText: string = ''
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.applyHistoryTab()
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  onHistoryTab(): void {
    this.applyHistoryTab()
  }

  private applyHistoryTab(): void {
    if (this.historyTab === 'summary' || this.historyTab === 'polish') {
      this.tab = this.historyTab
    }
  }

  private async reload(): Promise<void> {
    this.polishItems = await LocalRecordStore.listPolish()
    this.summaryItems = await LocalRecordStore.listSummary()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => {
      this.toastText = ''
    }, 2200)
  }

  private async copyText(text: string): Promise<void> {
    const ok = await ClipboardService.copyText(text)
    this.showToast(ok ? '已复制' : '复制失败')
  }

  private async deletePolish(id: string): Promise<void> {
    await LocalRecordStore.removePolish(id)
    await this.reload()
    this.showToast('已删除')
  }

  private async deleteSummary(id: string): Promise<void> {
    await LocalRecordStore.removeSummary(id)
    await this.reload()
    this.showToast('已删除')
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.of(this.darkModeOn).textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => {
            LanguageCraftNav.closeHistory()
            this.onClose()
          })
          Text('润色与摘要历史')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.of(this.darkModeOn).textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Row({ space: Theme.space.s2 }) {
          Text('润色')
            .fontSize(Theme.type.footnote)
            .fontColor(this.tab === 'polish' ?
              Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.tab === 'polish' ?
              Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceCard)
            .borderRadius(Theme.radius.pill)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .onClick((): void => { this.tab = 'polish' })
          Text('摘要')
            .fontSize(Theme.type.footnote)
            .fontColor(this.tab === 'summary' ?
              Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.tab === 'summary' ?
              Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceCard)
            .borderRadius(Theme.radius.pill)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .onClick((): void => { this.tab = 'summary' })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.tab === 'polish') {
              if (this.polishItems.length === 0) {
                AppEmpty({ title: '暂无润色记录', description: '在润色页保存后会出现在这里' })
              } else {
                ForEach(this.polishItems, (row: PolishRecord) => {
                  Column({ space: 6 }) {
                    Row() {
                      Text(`${row.styleLabel} · ${row.createdAt}`)
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.of(this.darkModeOn).textSecondary)
                        .layoutWeight(1)
                    }
                    .width('100%')
                    Text(row.resultText)
                      .fontSize(Theme.type.footnote)
                      .fontColor(Theme.of(this.darkModeOn).textPrimary)
                      .maxLines(4)
                      .width('100%')
                    Row({ space: Theme.space.s2 }) {
                      Column() {
                        AppButton({
                          label: '复制',
                          variant: 'secondary',
                          onTap: (): void => { void this.copyText(row.resultText) }
                        })
                      }
                      .layoutWeight(1)
                      Column() {
                        AppButton({
                          label: '删除',
                          variant: 'ghost',
                          onTap: (): void => { void this.deletePolish(row.id) }
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
                }, (row: PolishRecord) => row.id)
              }
            } else if (this.summaryItems.length === 0) {
              AppEmpty({ title: '暂无摘要记录', description: '在摘要页保存后会出现在这里' })
            } else {
              ForEach(this.summaryItems, (row: SummaryRecord) => {
                Column({ space: 6 }) {
                  Text(`${row.modeLabel} · ${row.createdAt}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).textSecondary)
                    .width('100%')
                  Text(row.resultText)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.of(this.darkModeOn).textPrimary)
                    .maxLines(5)
                    .width('100%')
                  Row({ space: Theme.space.s2 }) {
                    Column() {
                      AppButton({
                        label: '复制',
                        variant: 'secondary',
                        onTap: (): void => { void this.copyText(row.resultText) }
                      })
                    }
                    .layoutWeight(1)
                    Column() {
                      AppButton({
                        label: '删除',
                        variant: 'ghost',
                        onTap: (): void => { void this.deleteSummary(row.id) }
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
              }, (row: SummaryRecord) => row.id)
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
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
