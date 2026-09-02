import { Theme } from '../design-system/Theme'
import { DetailShell } from '../detail/DetailShell'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { InsightEntry } from '../../models/InsightModels'
import { DateHelper } from '../../services/DateHelper'
import { InsightStore } from '../../services/InsightStore'

@Component
export struct ReviewCenterPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onOpen: (id: string) => void = (_id: string) => {}
  onOpenTool: (kind: string) => void = (_k: string) => {}
  @State weekEntries: InsightEntry[] = []
  @State streak: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const all = await InsightStore.loadAll()
    const keys = DateHelper.lastNDays(7)
    const week: InsightEntry[] = []
    for (const n of all) {
      for (const k of keys) {
        if (n.dateKey === k) {
          week.push(n)
        }
      }
    }
    this.weekEntries = week
    this.streak = await InsightStore.streakDays()
  }

  build() {
    Column() {
      DetailShell({ title: '回顾中心', onClose: (): void => { this.onClose() } })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppCard({ title: '连续书写' }) {
            Text(`已连续 ${this.streak} 天有见解记录`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          AppButton({
            label: '打开本周三问',
            variant: 'primary',
            onTap: (): void => {
              this.onClose()
              this.onOpenTool('week')
            }
          })
          AppButton({
            label: '随机回看一条',
            variant: 'secondary',
            onTap: (): void => {
              this.onClose()
              this.onOpenTool('recall')
            }
          })
          if (this.weekEntries.length > 0) {
            AppCard({ title: '近 7 日见解' }) {
              Column({ space: 8 }) {
                ForEach(this.weekEntries, (n: InsightEntry) => {
                  Text(`${DateHelper.displayDate(n.dateKey)} · ${n.title}`)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().brandPrimary)
                    .width('100%')
                    .onClick((): void => { this.onOpen(n.id) })
                }, (n: InsightEntry) => `rv_${n.id}`)
              }
              .width('100%')
            }
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
