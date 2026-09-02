import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ContentCard } from '../components/ContentCard'
import { FactItem } from '../models/CommonSenseModels'
import { CommonSenseBizService } from '../services/CommonSenseBizService'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { CommonSenseStore } from '../services/CommonSenseStore'
import { CommonSenseLocalService } from '../services/CommonSenseLocalService'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: FactItem[] = []
  @State loading: boolean = true
  @State toastText: string = ''
  @State folder: string = 'all'
  @State folderDraft: string = ''
  @State folders: string[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    this.loading = true
    try {
      const all = await CommonSenseBizService.loadFacts()
      const ids = CommonSenseStore.favoriteIds()
      const rows: FactItem[] = []
      for (const id of ids) {
        for (const item of all) {
          if (item.id === id) {
            rows.push(item)
          }
        }
      }
      this.items = this.applyFolder(rows)
      this.folders = CommonSenseLocalService.folderNames()
    } catch {
    } finally {
      this.loading = false
    }
  }

  private applyFolder(rows: FactItem[]): FactItem[] {
    if (this.folder === 'all') {
      return rows
    }
    const out: FactItem[] = []
    for (const item of rows) {
      const name = CommonSenseLocalService.folderOf(item.id)
      if (this.folder === 'none' && name.length === 0) {
        out.push(item)
      } else if (name === this.folder) {
        out.push(item)
      }
    }
    return out
  }

  private async assignFolder(id: string): Promise<void> {
    const name = this.folderDraft.trim()
    if (name.length === 0) {
      this.showToast('先填写分组名')
      return
    }
    await CommonSenseLocalService.setFolder(id, name)
    this.folderDraft = ''
    void this.reload()
    this.showToast(`已归入「${name}」`)
  }

  private async unfavorite(id: string): Promise<void> {
    await CommonSenseStore.toggleFavorite(id)
    void this.reload()
    this.showToast('已取消收藏')
  }

  private async exportAll(): Promise<void> {
    const titles: string[] = []
    for (const item of this.items) {
      titles.push(item.title)
    }
    const text = CommonSenseStore.exportFavoritesText(titles)
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      await pasteboard.getSystemPasteboard().setData(data)
      this.showToast('收藏清单已复制到剪贴板')
    } catch {
      this.showToast('导出失败，请稍后重试')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Column({ space: 4 }) {
            Text('我的收藏')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(`共 ${this.items.length} 条 · 仅保存在本机`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          if (this.items.length > 0) {
            AppButton({
              label: '导出',
              variant: 'secondary',
              onTap: (): void => { void this.exportAll() }
            })
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

        TextInput({ text: this.folderDraft, placeholder: '新分组名，点条目右侧归入' })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8 })
          .onChange((v: string): void => { this.folderDraft = v })

        Scroll() {
          Row({ space: 8 }) {
            Text('全部')
              .fontSize(12)
              .fontColor(this.folder === 'all' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.folder === 'all' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => {
                this.folder = 'all'
                void this.reload()
              })
            Text('未分组')
              .fontSize(12)
              .fontColor(this.folder === 'none' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.folder === 'none' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => {
                this.folder = 'none'
                void this.reload()
              })
            ForEach(this.folders, (name: string) => {
              Text(name)
                .fontSize(12)
                .fontColor(this.folder === name ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.folder === name ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  this.folder = name
                  void this.reload()
                })
            }, (name: string) => name)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)

        if (this.items.length === 0 && !this.loading) {
          AppEmpty({
            title: '收藏夹还是空的',
            description: '读到喜欢的常识，点心形即可收入。',
            actionLabel: '去今日常识',
            onAction: (): void => { CommonSenseDetailNav.switchTab(0) }
          })
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.items, (row: FactItem) => {
                Row({ space: Theme.space.s2 }) {
                  ContentCard({
                    item: row,
                    compact: false,
                    onOpen: (): void => { CommonSenseDetailNav.openFact(row.id) }
                  })
                  .layoutWeight(1)
                  Column() {
                    AppIcon({ name: 'heart', iconSize: Theme.icon.md, color: Theme.colors().brandAccent })
                  }
                  .width(44)
                  .height(44)
                  .justifyContent(FlexAlign.Center)
                  .onClick((): void => { void this.unfavorite(row.id) })
                  Column() {
                    AppIcon({ name: 'bookmark', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
                  }
                  .width(44)
                  .height(44)
                  .justifyContent(FlexAlign.Center)
                  .onClick((): void => { void this.assignFolder(row.id) })
                }
                .width('100%')
              }, (row: FactItem) => row.id)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
