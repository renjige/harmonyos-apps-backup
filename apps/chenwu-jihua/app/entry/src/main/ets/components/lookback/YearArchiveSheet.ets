import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from '../detail/DetailShell'
import { CwYearArchive } from '../../models/ChenwuModels'
import { ChenwuStore } from '../../services/ChenwuStore'
import { ChenwuDetailNav } from '../../services/ChenwuDetailNav'
import { ChenwuMedia } from '../../services/ChenwuMedia'

@Component
export struct YearArchiveSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State archive: CwYearArchive = new CwYearArchive()

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.archive = await ChenwuStore.buildYearArchive(`${new Date().getFullYear()}`)
  }

  build() {
    DetailShell({ title: `我的${this.archive.year}`, onClose: (): void => { ChenwuDetailNav.closeAnnual() } }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Image(ChenwuMedia.coverReview())
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
          AppCard({ title: '本年数量' }) {
            Text(`计划 ${this.archive.planCount} · 目标 ${this.archive.goalCount} · 习惯打卡 ${this.archive.habitDays} 天`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }
          AppCard({ title: '高频分类' }) {
            Text(this.archive.topCategory)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }
          AppCard({ title: '年度亮点' }) {
            Text(this.archive.highlightTitle.length > 0 ? this.archive.highlightTitle : '本年度尚未留下记录')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }
          Text('根据本机已有记录自动整理，不含生成式内容。')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
      }
      .width('100%')
      .layoutWeight(1)
    }
  }
}
