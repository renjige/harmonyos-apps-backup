import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppTextField } from '../design-system/AppTextField'
import { DetailShell } from './DetailShell'
import { CardItem } from '../../models/AtelierModels'
import { AtelierBizService } from '../../services/AtelierBizService'
import { AtelierDetailNav } from '../../services/AtelierDetailNav'
import { AtelierMedia } from '../../services/AtelierMedia'
import { AtelierProgress } from '../../services/AtelierProgress'
import { AuthService } from '../../services/AuthService'
import { PracticeKind } from '../../models/PracticeModels'

@Component
export struct CardDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: CardItem = new CardItem()
  @State favorited: boolean = false
  @State favId: string = ''
  @State tagDraft: string = ''
  @State loaded: boolean = false
  @State related: CardItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    AtelierDetailNav.showToast(message)
  }

  private gate(action: string): boolean {
    if (AuthService.requireAuth(action)) {
      return true
    }
    AtelierDetailNav.requestLogin()
    return false
  }

  private async reload(): Promise<void> {
    const found = await AtelierBizService.findCard(this.itemId)
    if (found === undefined) {
      return
    }
    this.item = found
    this.loaded = true
    await AtelierProgress.addReadMinutes(found.readMinutes > 0 ? found.readMinutes : 1)
    await AtelierProgress.markCardRead(found.id)
    const all = await AtelierBizService.loadCards()
    this.related = AtelierBizService.relatedCards(all.length > 0 ? all : AtelierBizService.packCards(), found, 2)
    const uid = AtelierBizService.userId()
    if (uid.length === 0) {
      this.favorited = false
      this.favId = ''
      return
    }
    const favs = await AtelierBizService.loadFavorites(uid)
    this.favorited = false
    this.favId = ''
    this.tagDraft = found.categoryLabel()
    for (const f of favs) {
      if (f.contentId === found.id) {
        this.favorited = true
        this.favId = f.id
        this.tagDraft = f.tags.length > 0 ? f.tags : found.categoryLabel()
      }
    }
  }

  private async toggleFav(): Promise<void> {
    if (!this.gate('favorite')) {
      return
    }
    if (this.favorited && this.favId.length > 0) {
      const ok = await AtelierBizService.removeFavorite(this.favId, this.item.id)
      if (ok) {
        this.favorited = false
        this.favId = ''
        this.showToast('已移出书坊')
        AtelierDetailNav.bumpRefresh()
      } else {
        this.showToast('移出失败，请稍后重试')
      }
      return
    }
    const tags = this.tagDraft.length > 0 ? this.tagDraft : this.item.categoryLabel()
    const row = await AtelierBizService.addFavorite(this.item.id, 'card', this.item.title,
      tags, this.item.coverKey, this.item.category)
    if (row !== undefined) {
      this.favorited = true
      this.favId = row.id
      this.tagDraft = row.tags.length > 0 ? row.tags : tags
      this.showToast('已收入书坊，可在「我的书坊」查看')
      AtelierDetailNav.bumpRefresh()
    } else {
      this.showToast('收入书坊失败，请登录后重试')
    }
  }

  private async saveTags(): Promise<void> {
    if (!this.favorited || this.favId.length === 0) {
      this.showToast('请先收入书坊，再写标签')
      return
    }
    const tags = this.tagDraft.trim()
    const ok = await AtelierBizService.updateFavoriteTags(this.favId, tags)
    if (ok) {
      this.showToast('标签已保存')
      AtelierDetailNav.bumpRefresh()
    } else {
      this.showToast('标签保存失败')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.item.categoryLabel(),
        showFavorite: true,
        favorited: this.favorited,
        onClose: (): void => { AtelierDetailNav.close() },
        onFavorite: (): void => { void this.toggleFav() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '这篇知识卡暂时找不到', description: '请返回发现页刷新后再试。' })
        } else {
          this.BodyBlock()
        }
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BodyBlock() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(AtelierMedia.resource(this.item.coverKey))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(220)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,42,108,0)', 0.28], ['rgba(26,42,108,0.82)', 1]]
            })
          Column({ space: 6 }) {
            Text(`${this.item.categoryLabel()} · ${this.item.readMinutes} 分钟`)
              .fontSize(Theme.type.caption)
              .fontColor('#F8F9FA')
            Text(this.item.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor('#F8F9FA')
              .maxLines(2)
          }
          .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
        }
        .width('100%')
        .borderRadius(Theme.radius.card)
        .clip(true)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          Text(this.item.summary)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .lineHeight(24)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        Text(this.item.body)
          .fontSize(Theme.type.bodyL)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .lineHeight(28)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.related.length > 0) {
          Column({ space: Theme.space.s3 }) {
            Text('同工坊推荐阅读')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.related, (row: CardItem) => {
              Row({ space: 10 }) {
                Image(AtelierMedia.resource(row.coverKey))
                  .width(56)
                  .height(56)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)
                Column({ space: 2 }) {
                  Text(row.title)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(2)
                    .width('100%')
                  Text(`${row.readMinutes} 分钟 · ${row.categoryLabel()}`)
                    .fontSize(12)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(10)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { AtelierDetailNav.openCard(row.id) })
            }, (row: CardItem) => row.id)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column({ space: Theme.space.s3 }) {
          AppButton({
            label: '做一页工坊练习',
            onTap: (): void => {
              AtelierDetailNav.openWorkNew(PracticeKind.ofCategory(this.item.category), this.item.id)
            }
          })
          AppButton({
            label: '专注计时阅读',
            variant: 'secondary',
            onTap: (): void => { AtelierDetailNav.openTimer() }
          })
          AppButton({
            label: this.favorited ? '移出书坊' : '收入书坊',
            variant: 'secondary',
            onTap: (): void => { void this.toggleFav() }
          })
          Text('书坊标签（仅自己可见）')
            .fontSize(12)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          AppTextField({
            text: this.tagDraft,
            placeholder: '例如：商业,下周复盘',
            onChange: (v: string): void => { this.tagDraft = v }
          })
          AppButton({
            label: '保存标签',
            variant: 'secondary',
            onTap: (): void => { void this.saveTags() }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
  }
}
