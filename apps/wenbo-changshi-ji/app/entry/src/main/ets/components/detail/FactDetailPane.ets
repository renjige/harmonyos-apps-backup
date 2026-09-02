import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { FactItem } from '../../models/CommonSenseModels'
import { CommonSenseBizService } from '../../services/CommonSenseBizService'
import { CommonSenseDetailNav } from '../../services/CommonSenseDetailNav'
import { CommonSenseMedia } from '../../services/CommonSenseMedia'
import { CommonSenseStore } from '../../services/CommonSenseStore'
import { CommonSenseLocalService } from '../../services/CommonSenseLocalService'
import { ReadAloudService } from '../../services/ReadAloudService'

@Component
export struct FactDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('fontScale') fontScale: number = 1.0
  @State item: FactItem = new FactItem()
  @State favorited: boolean = false
  @State loaded: boolean = false
  @State toastText: string = ''
  @State related: FactItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private bodySize(): number {
    return Theme.type.bodyL * this.fontScale
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    const found = await CommonSenseBizService.findFact(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
      this.favorited = CommonSenseStore.isFavorite(found.id)
      await CommonSenseStore.markRead(found.id, found.title, found.categoryLabel())
      const all = CommonSenseBizService.cachedFacts()
      this.related = CommonSenseBizService.relatedFacts(all, found, 3)
    }
  }

  private async toggleFavorite(): Promise<void> {
    const on = await CommonSenseStore.toggleFavorite(this.item.id, this.item.title)
    this.favorited = on
    this.showToast(on ? '已收入收藏夹' : '已取消收藏')
  }

  private async addToList(): Promise<void> {
    const name = await CommonSenseLocalService.addFactToLatest(this.item.title, this.item.id)
    this.showToast(`已加入清单「${name}」`)
  }

  private async readAloud(): Promise<void> {
    const msg = await ReadAloudService.copyForReadAloud(this.item)
    this.showToast(msg)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.item.categoryLabel(),
        showFavorite: true,
        favorited: this.favorited,
        onClose: (): void => { CommonSenseDetailNav.close() },
        onFavorite: (): void => { void this.toggleFavorite() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '这条常识暂时找不到', description: '请返回首页刷新后再试。' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(CommonSenseMedia.resource(this.item.coverKey))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(220)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(10,37,64,0)', 0.28], ['rgba(10,37,64,0.82)', 1]]
                  })
                Column({ space: 6 }) {
                  Text(`${this.item.readMinutes} 分钟 · ${this.item.categoryLabel()} · ${this.item.sceneLabel()}`)
                    .fontSize(Theme.type.caption)
                    .fontColor('#F5F7FA')
                  Text(this.item.title)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#F5F7FA')
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
                .fontSize(this.bodySize())
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(28 * this.fontScale)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column({ space: Theme.space.s3 }) {
                AppButton({
                  label: this.favorited ? '取消收藏' : '收藏',
                  variant: 'primary',
                  onTap: (): void => { void this.toggleFavorite() }
                })
                AppButton({
                  label: '生成分享卡片',
                  variant: 'secondary',
                  onTap: (): void => { CommonSenseDetailNav.openShare(this.item.id) }
                })
                AppButton({
                  label: '加入常识清单',
                  variant: 'secondary',
                  onTap: (): void => { void this.addToList() }
                })
                AppButton({
                  label: '去做相关问答',
                  variant: 'secondary',
                  onTap: (): void => { CommonSenseDetailNav.openQuiz() }
                })
                AppButton({
                  label: '标为已掌握',
                  variant: 'secondary',
                  onTap: (): void => {
                    void CommonSenseLocalService.markMastered(this.item.id, this.item.title)
                    this.showToast('已记入掌握列表')
                  }
                })
                if (this.related.length > 0) {
                  Text('相关推荐')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  ForEach(this.related, (row: FactItem) => {
                    Text(`${row.categoryLabel()} · ${row.title}`)
                      .fontSize(Theme.type.footnote)
                      .fontColor(Theme.colors().brandPrimary)
                      .width('100%')
                      .onClick((): void => { CommonSenseDetailNav.openFact(row.id) })
                  }, (row: FactItem) => row.id)
                }
                AppButton({
                  label: '复制朗读',
                  variant: 'secondary',
                  onTap: (): void => { void this.readAloud() }
                })
                AppButton({
                  label: '添加笔记',
                  variant: 'secondary',
                  onTap: (): void => { CommonSenseDetailNav.openNote(this.item.id) }
                })
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s10
              })
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
        }
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
