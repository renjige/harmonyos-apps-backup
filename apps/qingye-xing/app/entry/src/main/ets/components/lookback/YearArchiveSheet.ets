import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from '../detail/DetailShell'
import { QyYearArchive } from '../../models/QyModels'
import { QyStore } from '../../services/QyStore'
import { QyDetailNav } from '../../services/QyDetailNav'
import { QyMedia } from '../../services/QyMedia'

@Component
export struct YearArchiveSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State archive: QyYearArchive = new QyYearArchive()

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.archive = await QyStore.buildYearArchive(`${new Date().getFullYear()}`)
  }

  build() {
    DetailShell({ title: `我的${this.archive.year}`, onClose: (): void => { QyDetailNav.closeYear() } }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Image(QyMedia.corridorHero())
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
          AppCard({ title: '本年数量' }) {
            Text(`记录 ${this.archive.entryCount} · 观察 ${this.archive.clipCount} · 主题 ${this.archive.themeCount}`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }
          AppCard({ title: '高频主题 / 标签' }) {
            Text(`主题 ${this.archive.topTheme} · 标签 ${this.archive.topTag}`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }
          AppCard({ title: '重要片段' }) {
            Text(this.archive.highlightTitle.length > 0 ? this.archive.highlightTitle : '还没有标记重要或珍藏的片段')
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
