import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { LifeConfirmDialog } from '../life/LifeConfirmDialog'
import { LifeCraftItem } from '../../models/LifeModels'
import { LifeDateHelper } from '../../services/LifeLocalStore'
import { LifeCraftStore } from '../../services/LifeCraftStore'
import { LifeDetailNav } from '../../services/LifeDetailNav'

@Component
export struct CraftDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('lifeCraftDetailId') @Watch('onIdChange') craftId: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State item: LifeCraftItem = new LifeCraftItem()
  @State confirmDelete: boolean = false
  @State toast: string = ''
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onIdChange(): void {
    void this.load()
  }

  onRefreshChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    if (this.craftId.length === 0) {
      return
    }
    const found = await LifeCraftStore.find(this.craftId)
    if (found !== undefined) {
      this.item = found
    }
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 1800)
  }

  private async togglePin(): Promise<void> {
    this.item.pinned = !this.item.pinned
    await LifeCraftStore.save(this.item)
    this.onChanged()
    this.showToast(this.item.pinned ? '已加入收藏' : '已取消收藏')
  }

  private async bump(): Promise<void> {
    if (this.item.kind === 'goal') {
      let next = this.item.progress + 10
      if (next > 100) {
        next = 100
      }
      this.item.progress = next
    } else if (this.item.kind === 'challenge') {
      this.item.progress = this.item.progress + 1
    } else {
      return
    }
    await LifeCraftStore.save(this.item)
    this.onChanged()
    this.showToast('进度已更新')
  }

  private async doDelete(): Promise<void> {
    this.confirmDelete = false
    await LifeCraftStore.remove(this.craftId)
    this.onChanged()
    LifeDetailNav.closeCraft()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text(`${this.item.kindLabel()} · ${this.item.category} · ${LifeDateHelper.formatDateTime(
            LifeDateHelper.effectiveTs(this.item.createdAt, this.item.updatedAt, this.item.id))}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
          if (this.item.body.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text(this.item.kind === 'issue' ? '问题' : '说明')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(this.item.body)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .lineHeight(24)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .alignItems(HorizontalAlign.Start)
          }
          if (this.item.extra.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text(this.item.kind === 'issue' ? '我的解决办法' : '补充')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(this.item.extra)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .lineHeight(24)
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .alignItems(HorizontalAlign.Start)
          }
          if (this.item.progressLabel().length > 0) {
            Text(this.item.progressLabel())
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().brandDeep)
          }
          if (this.item.kind === 'goal' || this.item.kind === 'challenge') {
            AppButton({
              label: this.item.kind === 'goal' ? '进度 +10%' : '今日完成 +1 天',
              variant: 'primary',
              onTap: (): void => { void this.bump() }
            })
          }
          AppButton({
            label: this.item.pinned ? '取消收藏' : '加入收藏夹',
            variant: 'secondary',
            onTap: (): void => { void this.togglePin() }
          })
          AppButton({
            label: '编辑',
            variant: 'secondary',
            onTap: (): void => { LifeDetailNav.openCraftEditor(this.craftId, this.item.kind) }
          })
          AppButton({
            label: '删除',
            variant: 'danger',
            onTap: (): void => { this.confirmDelete = true }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')

      if (this.confirmDelete) {
        LifeConfirmDialog({
          title: '删除这条记录',
          message: '删除后无法恢复。是否继续？',
          confirmLabel: '确认删除',
          danger: true,
          onConfirm: (): void => { void this.doDelete() },
          onCancel: (): void => { this.confirmDelete = false }
        })
      }
      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '12%', y: 24 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
