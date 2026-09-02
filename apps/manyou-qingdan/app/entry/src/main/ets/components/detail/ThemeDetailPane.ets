import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { RmWish, RmDateUtil, RmChecklist, RmTheme } from '../../models/RmModels'
import { RmStore } from '../../services/RmStore'
import { RmDetailNav } from '../../services/RmDetailNav'
import { RmMedia } from '../../services/RmMedia'
import { ChecklistListCard } from '../rm/ChecklistListCard'
import { WishListCard } from '../rm/WishListCard'
import { RmConfirmDialog } from '../rm/RmConfirmDialog'

@Component
export struct ThemeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onThemeIdChange') themeId: string = ''
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  onChanged: () => void = () => {}
  @State theme: RmTheme = new RmTheme()
  @State entries: RmChecklist[] = []
  @State clips: RmWish[] = []
  @State confirmDel: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  onThemeIdChange(): void {
    void this.reload()
  }

  private openEditor(): void {
    if (this.theme.id.length === 0) {
      return
    }
    RmDetailNav.openThemeEditor(this.theme.id)
  }

  private cloneTheme(src: RmTheme): RmTheme {
    const t = new RmTheme()
    t.id = src.id
    t.title = src.title
    t.summary = src.summary
    t.coverKey = src.coverKey
    t.createdAt = src.createdAt
    t.updatedAt = src.updatedAt
    return t
  }

  private async reload(): Promise<void> {
    const found = await RmStore.findTheme(this.themeId)
    if (found !== undefined) {
      this.theme = this.cloneTheme(found)
    }
    this.entries = await RmStore.checklistsForTheme(this.themeId)
    this.clips = await RmStore.wishesForTheme(this.themeId)
  }

  private async remove(): Promise<void> {
    await RmStore.deleteTheme(this.themeId)
    this.onChanged()
    RmDetailNav.closeTheme()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(RmMedia.coverOf(this.theme.coverKey))
              .id(`${this.theme.id}_${this.theme.coverKey}_${this.theme.updatedAt}`)
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(100)
              .linearGradient({ angle: 180, colors: [['rgba(47,74,71,0)', 0], ['rgba(47,74,71,0.82)', 1]] })
            Column({ space: 4 }) {
              Text(this.theme.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#F6F1E8')
              Text(`${this.entries.length + this.clips.length} 条 · 更新于 ${RmDateUtil.displayDate(RmDateUtil.keyFromDate(new Date(this.theme.updatedAt)))}`)
                .fontSize(Theme.type.footnote)
                .fontColor('#F6F1E8')
            }
            .padding({ left: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .clip(true)
          .borderRadius(Theme.radius.md)

          if (this.theme.summary.length > 0) {
            Text(this.theme.summary)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }

          Text('册内记录')
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.entries.length === 0) {
            AppEmpty({ title: '还没有记录', description: '在记录详情里点选本主题即可收入' })
          } else {
            ForEach(this.entries, (e: RmChecklist) => {
              ChecklistListCard({
                entry: e,
                categoryLabel: e.categoryKey,
                onOpen: (): void => { RmDetailNav.openChecklist(e.id) }
              })
            }, (e: RmChecklist) => e.id)
          }

          Text('册内观察')
            .fontSize(Theme.type.subtitleS)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.clips.length === 0) {
            AppEmpty({ title: '还没有观察', description: '在观察详情里点选本主题即可收入' })
          } else {
            ForEach(this.clips, (c: RmWish) => {
              WishListCard({ item: c, onOpen: (): void => { RmDetailNav.openWish(c.id) } })
            }, (c: RmWish) => c.id)
          }

          Row() {
            AppButton({ label: '编辑主题', onTap: (): void => { this.openEditor() } })
          }
          .width('100%')
          .onClick((): void => { this.openEditor() })
          AppButton({ label: '删除主题', variant: 'danger', onTap: (): void => { this.confirmDel = true } })
          Column().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%')
      .height('100%')

      if (this.confirmDel) {
        RmConfirmDialog({
          title: '删除这个主题？',
          message: '主题册将被删除，内容本身仍保留在记录与观察里。',
          confirmLabel: '删除',
          onConfirm: (): void => { void this.remove() },
          onCancel: (): void => { this.confirmDel = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
